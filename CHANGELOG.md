# Changelog

Every contract version, newest first, with the caller impact of each.

This file is mirrored at [docs.xpectrum.xyz/changelog](https://docs.xpectrum.xyz/changelog). Update both together.

Contracts are immutable once deployed, so any change requires a new deployment under a new version. This file records every version and states the impact on existing callers.

Source and verification certificates: [xpectrum-xyz/xpectrum-contracts](https://github.com/xpectrum-xyz/xpectrum-contracts).

## Versioning

`vMAJOR.MINOR.PATCH`, classified by one question: **does an existing, correct caller keep working, unchanged, with the same result?**

| | Meaning |
|---|---|
| **MAJOR** | The interface changed and calling code must be updated. Renames, signature or return-shape changes, a field that retains its name and changes meaning, or a call that previously succeeded and now reverts. |
| **MINOR** | The interface is unchanged and the observable behaviour differs. New views or events, or a revised constant such as a reserve ceiling or a phase minimum. No code change is required, but values used for planning may differ. |
| **PATCH** | No observable change. Internal hardening only. |

Standards (XNS-1, the Metadata Standard) version separately from the contracts that implement them, as `vMAJOR.MINOR`.

## Deployed now

| Contract | Version | Address |
|---|---|---|
| XuperFactory | v4.0.0 | `octCzmWDXWPFWzFhjPXF3rfdeecFPNYedAoRjUyBU4rx2nz` |
| Xcollection | v6.0.0 | deployed per collection by XuperFactory v4.0.0 |
| Xlist | v4.0.0 | `octBnPAc1ckgGwXDDHGJcbAFtDb7ttorssqsz54epy5qiG9` |
| Xmarket | v3.2.0 | `octGoeTjaF8MiKTP5ad5FJfWMCZmmEdnrfxTow6UUVmBj6h` |
| Xauction | v5.0.0 | `octBv5yUWMp3D5mAVcvpgC3DWgUGvH8KPMkfsSXv216LkUn` |
| Xdutch | v2.0.0 | `octxD2gf2i6NDj3XJGBpNNNgiejnUFV1Dk45rNr5fJjN2s5` |
| Xenglish | v1.0.0 | `oct8p3UhGRurjgbfbMERZBENuft4hcodx6DMTJj14W46ipU` |
| XpectrumGenesis (Xpectra) | v1.0.1 | `octC4PvHrT8U1vDsZ5ejEBj6UgW2fRoLfohFBSCePdstZfQ` |
| Xlist (Xpectra) | v2.0.0 | `oct6hqXn2kSm8HptJ3MRmRAbTaY4jvTHH2ntFcSWKdKhXzx` |
| Xincinerator | v1.0.0 | `octGn3QwHTcGjo6Vjz5G9y8Z9hZDsYoA7gbksRqdJoaeg6q` |
| XincineratorLog | v1.0.0 | `oct4u3PmynG2jDJADUF1iVTwPA8oxNy2LQTYNKueGdPN3zh` |

Superseded and still deployed: XuperFactory v2.0.0 at `octHgTcvueQE5LRb2PYLJqa5T9ypUgBuyY5XyxRstoSdBVN`, with the Xcollection v4.0.0 it deploys.
`XNS1.aml` is the reference implementation and is not deployed.

---

## Source documentation

**2026-10-30.** No bytecode change.

Every source in this repository now carries Prism documentation: a header stating the contract's model, custody, payout, privacy and units, and a block on every public function stating who may call it, what it pays, what it holds, what it makes public, what it logs, and each parameter and return.
Comments do not change bytecode.
Each restyled source was compiled on mainnet before and after, and the bytecode hash, ABI and verifier report are identical; for every deployed contract the hash also equals the code running on chain.

The two superseded contracts in `contracts/legacy/` are kept exactly as first published.

The layout moved from one `contracts/` folder to `standard/`, `launch/`, `market/`, `xpectra/` and `legacy/`, with `verification/` mirroring it.
`deployments.json` is new, and `scripts/verify.sh --live` checks every deployed contract against the chain.

---

## XuperFactory v4.0.0, Xcollection v6.0.0 and Xlist v4.0.0

**2026-10-24, mainnet.** Breaking. A rewrite of the launch path; nothing in it is compatible with XuperFactory v2.0.0 or Xcollection v4.0.0.

### What changes for callers
- `create_collection` takes fifteen arguments, starting with the tag `"xf6"`, and the collection receives every setting in its constructor. There is no `init` and no setup transaction afterwards.
- The caller must be the `creator` argument, and must attach exactly the launch fee plus the launch budget. The budget is forwarded to the launch key.
- New factory views `collection_by_creator` and `collection_by_launcher`. Ownership of the factory moves in two steps, `propose_ownership` then `accept_ownership`.
- The sale is a table of phases: the Xpectra holder phase first, up to four listed phases, and public last. `get_phase(n)` and `mint_state(wallet)` replace `get_phase_info`, `get_wallet_state` and `get_xholder_status`.
- `mint(quantity, code)` mints up to 100 at a time and requires the exact price; there is no refund path. Holders of Xpectra claim with `mint_holder(ids)`.
- A paid mint sends the 2.5% platform fee and the proceeds in the same transaction. `claim_proceeds`, `pending_proceeds`, `reserve` and `sweep_unaccounted` are removed.
- The reveal is an epoch set with `set_reveal`; `token_uri` switches by itself. `freeze_metadata` locks it.
- `burn_many(ids)` burns 1 to 100 of the caller's own tokens in one transaction.
- Ownership of a collection moves in two steps, `propose_owner` then `accept_owner`.
- The hand-rolled event log, `get_contract_info`, `get_tokens_page` and the phase override are removed. State is read by name, and events are real events.
- Allowlists move from one Xlist per collection to a single shared Xlist. A list is named by its owner's address and a number, and a collection owns its own lists; `is_member(owner, list_id, who, code)` answers membership. A list may store digests rather than addresses, or be a holder list that admits anyone holding a token of a given collection.

### What changes for creators
- Launching costs 1 OCT, as before, and the collection is usable the moment the creation transaction lands.
- The Xpectra holder cap is a ceiling on phase 0, not an allocation. Nothing is swept and nothing needs releasing.
- A phase may be priced at zero; a collection is either free in every phase or paid in every phase.

### Hashes

| Contract | Chain | bytecode_hash |
|---|---|---|
| XuperFactory | mainnet | `978a7ec7…` |
| Xcollection | mainnet | `2eafd458…` |
| Xcollection | devnet | `977dcc4a…` |
| Xlist | mainnet | `4a20afd1…` |

---

## Xauction v5.0.0, Xdutch v2.0.0 and Xenglish v1.0.0

**2026-09-25, mainnet.** First publication in this repository. Earlier versions of Xauction and Xdutch reached devnet only and are not published.

All three escrow the token in the contract from listing until it sells or is reclaimed, take the 2.5% market fee and pay the collection's royalty at settlement, credit proceeds and refunds inside the contract for `claim_proceeds`, and can restrict buyers to a hashed allowlist loaded with `add_allow`.

### Xauction v5.0.0
- Sealed bids in three windows: bidding, posting and payment, each in epochs.
- A bid is a commitment with a bond. The amount stays hidden until the bidder, or anyone holding the opening, posts it with `post_bid` or `post_bid_for`, so a bid can settle with its bidder offline.
- The posting window is at least 2,144 epochs and the payment window at least 8,575.
- The highest posted bid at or above `min_bid` wins and pays its own price with `pay`.
- A winner who does not pay before the deadline forfeits the bond to the seller, and the runner-up is offered the token at their own bid. With no runner-up the auction is void and the seller reclaims the token.
- A bid that is never posted forfeits its bond to the seller.
- `min_bid` is the only price constraint. There is no reserve.

### Xdutch v2.0.0
- The price falls by a fixed step each epoch from a start price to a floor, and the first buyer at the current price takes the token.
- Only the buyer sends a transaction, so a bidder who walks away leaves no record on chain.
- `get_sale` returns twelve pipe-separated fields.

### Xenglish v1.0.0
- Open ascending bids. Each bid must clear the previous one by the auction's increment, between 1% and 50%.
- A bid in the last 30 epochs moves the close to 30 epochs after that bid.
- An outbid bid is credited back to its bidder, who can withdraw it or bid it again.

### Hashes

| Contract | Chain | bytecode_hash |
|---|---|---|
| Xauction | mainnet | `8cafcdef…` |
| Xdutch | mainnet | `9eb708c2…` |
| Xenglish | mainnet | `c0f1f9dc…` |

---

## Xlist v2.0.0

**First publication of the source.** The contract has been on mainnet since the Xpectra mint as `oct6hqXn2kSm8HptJ3MRmRAbTaY4jvTHH2ntFcSWKdKhXzx`, and XuperFactory v2.0.0 embeds the same bytecode.
Its compiled form was always public inside the factory; the source now sits beside it and compiles to the same hash, `57b1c272…`.

---

## XNS1 v4.0.0

**Reference implementation. Verified, not deployed.** Breaking against rev 3.

Rev 3 is withdrawn and is not included in this repository. Existing implementations based on it should migrate to v4.0.0.

### What changes for implementers
- `is_approved_or_owner` returns `u128` (`1` or `0`). **Rev 3 returned `bool`, which `Xmarket.require(approved == 1)` cannot satisfy, so a literal rev-3 implementation is untradeable on Xmarket.** This is the reason for the migration.
- `total_supply()` is live supply. `total_minted()` is the id count. Rev 3 had one counter.
- New: `burn(token_id)` (holder only), `total_minted()`, `burned()`, `is_burned(token_id)`.
- `get_contract_info()` gained `total_minted | burned | events`.
- Mint emits `Transferred(id, 0, to)`; rev 3 emitted `(id, caller, to)`. Burn emits `Transferred(id, owner, 0)`.
- `event_log` and `get_event_log` added, so an XNS-1 contract is visible to an indexer at all.
- `bool` removed from state and from numerically compared parameters.
- `get_token_circle_info` version is now 2: the `active` column is `1`/`0`.

### Hashes

Source `f55d89cd…`, identical on both chains. Bytecode differs per chain, which is expected:

| Chain | bytecode_hash | size |
|---|---|---|
| mainnet | `cabadd61…` | 12172 |
| devnet | `5336acb6…` | 12412 |

Verified true, 0 errors, 7 warnings on both.

---

## XuperFactory v2.0.0

**2026-08-21, mainnet.** Breaking.

Replaces SuperFactory, which was deployed on 2026-07-20 and never used (`count` 0, so nothing was orphaned).

**What changes for callers**
- The contract is renamed `SuperFactory` to `XuperFactory`. Revert strings are prefixed `xuperfactory:`.
- `create_collection` is payable and requires `value >= launch_fee`. A call that sends nothing now reverts. This is the breaking part.
- The `genesis` parameter is renamed `xpectra`. Positional order is unchanged, so the wire format is identical and no signature changes.
- New views `get_launch_fee()` and `get_fee_balance()`.

**What changes for creators**
- Launching costs a **1 OCT** fee, on top of about 0.2 OCT of network fee. The fee is owner-settable and readable on-chain, and zero is legal.

**Hashes**

| Chain | bytecode_hash |
|---|---|
| mainnet | `4fa02e39…` |
| devnet | `af011ece…` |

The mainnet and devnet builds differ because the embedded Xcollection is compiled per chain. Same source, different bytecode, which is expected on this toolchain.

---

## Xcollection v4.0.0

**2026-08-21, mainnet**, embedded in XuperFactory v2.0.0. Breaking.

Folds in an earlier build from 2026-08-12 that was never deployed.

**What changes for callers**
- `genesis_mint(genesis_id)` is now `xholder_mint(xpectra_id)`.
- `get_genesis_status`, `has_claimed_genesis` and `is_genesis_id_used` are now `get_xholder_status`, `has_claimed_xholder` and `is_xpectra_id_used`.
- `genesis_contract`, `genesis_minted_count`, `genesis_claimed` and `used_genesis_ids` are now `xpectra_contract`, `xholder_minted_count`, `xholder_claimed` and `used_xpectra_ids`.
- `event GenesisMint` is now `event XholderMint`. **Indexers must update their filter, otherwise these mints will no longer be observed.**
- `total_supply()` now returns live supply and `total_minted()` returns the id count. Callers reading `total_supply` as the total ever minted will receive a different value.
- `get_contract_info()` gained a trailing `burned` column.
- New: `burn(token_id)`, `total_minted()`, `burned()`, `is_burned(token_id)`.
- `get_provenance_hash` is now a `view fn`. Reading it no longer costs a transaction.

**What changes for creators**
- The Xholder reserve ceiling is **111**, previously 222. For collections above 555 supply this materially changes the reserved allocation.
- The minimum phase length is **240 epochs**, approximately 40 minutes, previously 360. The earlier value assumed exactly ten seconds per epoch, a rate the chain has not sustained. 240 is derived from the fastest rate measured over 160 days.
- Burning is available, holder-only. It never lowers `max_supply` and never reopens a mint slot.

**Hashes**

| Chain | bytecode_hash |
|---|---|
| mainnet | `e097aa4c…` |

---

## Xcollection v3.1.1

**2026-07-20, mainnet**, embedded in SuperFactory. Patch.

Hardening only, no interface change: checked mint-cost multiplication, a bounds check on `get_approved`, dropped vestigial guards, and `xholder_mint` marks claim state before the external `owner_of` call.

---

## Xcollection v3.1.0

**2026-06-26, devnet.** Minor.

**What changes for creators**
- The Xholder claim became **one per wallet** and was decoupled from the Guaranteed allocation. It no longer increments `gtd_minted` or consumes `gtd_cap`/`gtd_wallet_cap`, so the reserve can never erode a creator's own allowlist.
- New view `has_claimed_genesis` (renamed to `has_claimed_xholder` in v4.0.0).

---

## Xincinerator v1.0.0 and XincineratorLog v1.0.0

**2026-07-28, mainnet.** New.

`Xincinerator` is an ownerless sink: no owner, no entry points, no `call()`, two view functions and nothing else. A token sent to it can never be moved again. `XincineratorLog` batches transfers into it and emits `Burned`, and can only ever name the incinerator fixed in its constructor.

Used to burn 111 Xpectra. See [Xpectra](https://docs.xpectrum.xyz/contracts/genesis#supply).

**Hashes**

| Contract | bytecode_hash |
|---|---|
| Xincinerator | `de1ce6aa…` |
| XincineratorLog | `7b12f208…` |

---

## XpectrumGenesis v1.0.1

**2026-07-21, mainnet**, deployed as Xpectra. Patch.

Hardening for parity with Xcollection: checked mint-cost multiplication, a bounds check on `get_approved`, dropped vestigial guards. No interface change.

**Hashes:** bytecode_hash `9e17d6c9…`

---

## Xmarket v3.2.0

**2026-07-20, mainnet.** Breaking, relative to v3.1.

**What changes for callers**
- `make_collection_offer(nft, duration, quantity)` takes a quantity. `get_offer` now returns 9 fields, and the `coffer` event 7.
- Accepting an offer emits an `osale` event rather than `sale`. Previously an offer accept emitted `sale` carrying an offer id in the listing-id field, which corrupted indexer listing tables. **Consumers indexing sales must handle `osale`.**
- A `cancel` event is now logged when an accept auto-closes a listing, with status 0 rather than 2.
- New `cancel_offer` event.
- New `standard_mode` compatibility lane: owner-flagged collections are checked via `owner_of` plus `get_approved`, which lets ERC-721-shaped contracts trade.
- Accepting one's own offer is now rejected.

**Hashes:** bytecode_hash `943cbd42…`

---

## Earlier

Versions preceding this point were deployed to devnet only. The public history begins at mainnet launch on 2026-07-20.
