#!/usr/bin/env bash
# Recompiles every contract in contracts/ against an Octra node and checks the result against its certificate in verification/.
# With --live it also reads the code hash of every deployed contract in deployments.json from the chain and checks that it matches.
#
# Requires curl and jq.
# Both calls are free reads and need no wallet.
# Set RPC to use a different node.
# Exit status 0 means every check passed.

set -uo pipefail
cd "$(dirname "$0")/.."

RPC="${RPC:-https://octra.network/rpc}"
LIVE=0
[ "${1:-}" = "--live" ] && LIVE=1
fail=0
checked=0
skipped=0

rpc() {
  for attempt in 1 2 3 4; do
    out=$(curl -s -X POST "$RPC" \
      -H "Content-Type: application/json" \
      -H "Origin: https://octra.network" \
      -H "User-Agent: Mozilla/5.0" \
      -d "$1")
    if echo "$out" | jq -e '.result' >/dev/null 2>&1; then
      echo "$out"
      return 0
    fi
    sleep $((attempt * 3))
  done
  return 1
}

for src in $(find contracts -name '*.aml' | sort); do
  rel=${src#contracts/}
  dir=$(dirname "$rel")
  name=$(basename "$rel" .aml)
  cert=$(ls verification/"$dir"/"$name"_v*.json 2>/dev/null | head -1)

  if [ -z "$cert" ]; then
    echo "FAIL  $rel: no certificate in verification/$dir/"
    fail=1
    continue
  fi

  if ! out=$(rpc "$(jq -Rs '{jsonrpc:"2.0",id:1,method:"octra_compileAml",params:[.,true]}' "$src")"); then
    echo "SKIP  $rel: no usable response from the node"
    skipped=$((skipped + 1))
    continue
  fi

  got=$(echo "$out" | jq -r '.result.certificate.bytecode_hash')
  verified=$(echo "$out" | jq -r '.result.verification.verified')
  errors=$(echo "$out" | jq -r '.result.verification.errors')
  want=$(jq -r '.certificate.bytecode_hash' "$cert")

  if [ "$got" != "$want" ]; then
    echo "FAIL  $rel: compiles to $got, certificate records $want"
    fail=1
    continue
  fi
  if [ "$verified" != "true" ] || [ "$errors" != "0" ]; then
    echo "FAIL  $rel: verified=$verified errors=$errors"
    fail=1
    continue
  fi

  line="OK    $(printf '%-34s' "$rel") ${got:0:16}"

  if [ "$LIVE" = 1 ]; then
    addr=$(jq -r --arg s "$src" '.contracts[] | select(.source == $s) | .address // empty' deployments.json)
    if [ -n "$addr" ]; then
      if ! live=$(rpc "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"vm_contract\",\"params\":[\"$addr\"]}"); then
        echo "SKIP  $rel: could not read $addr"
        skipped=$((skipped + 1))
        continue
      fi
      code=$(echo "$live" | jq -r '.result.code_hash')
      if [ "$code" != "$got" ]; then
        echo "FAIL  $rel: $addr runs $code"
        fail=1
        continue
      fi
      line="$line  live at $addr"
    fi
  fi

  echo "$line"
  checked=$((checked + 1))
  sleep 2
done

echo
if [ "$fail" -ne 0 ]; then
  echo "One or more checks failed."
  exit 1
fi
if [ "$skipped" -ne 0 ]; then
  echo "$checked passed, $skipped not checked. Run again to cover the rest."
  exit 1
fi
echo "$checked contracts match their certificates$([ "$LIVE" = 1 ] && echo ", and every deployed one matches the chain")."
