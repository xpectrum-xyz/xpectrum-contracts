<picture>
  <source media="(prefers-color-scheme: dark)" srcset=".github/assets/banner-contracts-dark.svg">
  <img alt="Xpectrum contracts" src=".github/assets/banner-contracts-light.svg" width="100%">
</picture>

The smart contracts behind Xpectrum on Octra mainnet, written in AML.
Each source file compiles to the exact bytecode deployed at its address.

[Documentation](https://docs.xpectrum.xyz) · [Changelog](./CHANGELOG.md) · [Octrascan](https://octrascan.io)

## Deployments

| Contract | Version | Address | Purpose |
|---|---|---|---|
| [XuperFactory](./contracts/launch/XuperFactory.aml) | 4.0.0 | [`octCzmWD…4rx2nz`](https://octrascan.io/address.html?addr=octCzmWDXWPFWzFhjPXF3rfdeecFPNYedAoRjUyBU4rx2nz) | Creates a configured collection in one transaction |
| [Xcollection](./contracts/launch/Xcollection.aml) | 6.0.0 | one per launch | The collection and its sale, deployed by XuperFactory |
| [Xlist](./contracts/launch/Xlist.aml) | 4.0.0 | [`octBnPAc…y5qiG9`](https://octrascan.io/address.html?addr=octBnPAc1ckgGwXDDHGJcbAFtDb7ttorssqsz54epy5qiG9) | Shared allowlists and holder lists |
| [Xmarket](./contracts/market/Xmarket.aml) | 3.2.0 | [`octGoeTj…VmBj6h`](https://octrascan.io/address.html?addr=octGoeTjaF8MiKTP5ad5FJfWMCZmmEdnrfxTow6UUVmBj6h) | Fixed-price listings, token offers, collection offers |
| [Xauction](./contracts/market/Xauction.aml) | 5.0.0 | [`octBv5yU…16LkUn`](https://octrascan.io/address.html?addr=octBv5yUWMp3D5mAVcvpgC3DWgUGvH8KPMkfsSXv216LkUn) | Sealed-bid auctions |
| [Xdutch](./contracts/market/Xdutch.aml) | 2.0.0 | [`octxD2gf…JjN2s5`](https://octrascan.io/address.html?addr=octxD2gf2i6NDj3XJGBpNNNgiejnUFV1Dk45rNr5fJjN2s5) | Descending-price auctions |
| [Xenglish](./contracts/market/Xenglish.aml) | 1.0.0 | [`oct8p3Uh…W46ipU`](https://octrascan.io/address.html?addr=oct8p3UhGRurjgbfbMERZBENuft4hcodx6DMTJj14W46ipU) | Open ascending auctions |
| [XpectrumGenesis](./contracts/xpectra/XpectrumGenesis.aml) | 1.0.1 | [`octC4PvH…dstZfQ`](https://octrascan.io/address.html?addr=octC4PvHrT8U1vDsZ5ejEBj6UgW2fRoLfohFBSCePdstZfQ) | The Xpectra collection |
| [Xlist](./contracts/xpectra/Xlist.aml) | 2.0.0 | [`oct6hqXn…dKhXzx`](https://octrascan.io/address.html?addr=oct6hqXn2kSm8HptJ3MRmRAbTaY4jvTHH2ntFcSWKdKhXzx) | The Xpectra allowlist |
| [Xincinerator](./contracts/xpectra/Xincinerator.aml) | 1.0.0 | [`octGn3Qw…oaeg6q`](https://octrascan.io/address.html?addr=octGn3QwHTcGjo6Vjz5G9y8Z9hZDsYoA7gbksRqdJoaeg6q) | Burn address |
| [XincineratorLog](./contracts/xpectra/XincineratorLog.aml) | 1.0.0 | [`oct4u3Pm…dPN3zh`](https://octrascan.io/address.html?addr=oct4u3PmynG2jDJADUF1iVTwPA8oxNy2LQTYNKueGdPN3zh) | Burns a holder's own tokens into the burn address |
| [XNS1](./contracts/standard/XNS1.aml) | 4.0.0 | not deployed | Reference implementation of the XNS-1 standard |

Superseded and still on chain: [XuperFactory 2.0.0](./contracts/legacy/XuperFactory.aml) at [`octHgTcv…oSdBVN`](https://octrascan.io/address.html?addr=octHgTcvueQE5LRb2PYLJqa5T9ypUgBuyY5XyxRstoSdBVN) and the [Xcollection 4.0.0](./contracts/legacy/Xcollection.aml) it deploys.
New launches go through 4.0.0.

The same list is machine-readable in [`deployments.json`](./deployments.json), with each contract's bytecode hash and certificate path.

## Verification

```sh
scripts/verify.sh           # recompile every source and compare it with its certificate
scripts/verify.sh --live    # also compare each deployed contract with the code on chain
```

The script requires `curl` and `jq`, needs no wallet and sends no transaction. Exit status 0 means every source matches.
Every contract passes Octra's AML safety verifier with 0 errors; the full reports are in [`verification/`](./verification/).
Checking a single contract by hand is described in [Verify a contract](https://docs.xpectrum.xyz/developers/verify).

## Repository layout

```
contracts/
  standard/   XNS1                                    the interface, as a reference implementation
  launch/     XuperFactory, Xcollection, Xlist        launching a collection
  market/     Xmarket, Xauction, Xdutch, Xenglish     trading any XNS-1 contract
  xpectra/    XpectrumGenesis, Xlist, Xincinerator,   the Xpectra collection and its burn path
              XincineratorLog
  legacy/     XuperFactory 2.0.0, Xcollection 4.0.0   superseded, still deployed
verification/  one certificate per source, same layout
deployments.json
scripts/verify.sh
```

Three contracts declare an identifier that differs from their filename, because the identifier is compiled into deployed bytecode: `Xmarket.aml` declares `Xmarket_v3`, `Xauction.aml` declares `Xauction_v2` and `xpectra/Xlist.aml` declares `Xlist_v2`.

## Documentation

| Topic | Page |
|---|---|
| Architecture and how the contracts call each other | [Contracts overview](https://docs.xpectrum.xyz/contracts/overview) |
| The token interface the market contracts read | [XNS-1](https://docs.xpectrum.xyz/standards/xns-1) |
| Making a contract tradeable on Xpectrum | [Integrate](https://docs.xpectrum.xyz/developers/integrate) |
| Version history and caller impact | [CHANGELOG.md](./CHANGELOG.md) |

Each public function is documented in the source with `//|` comment blocks stating who may call it, what it pays and holds, what it makes public, and its parameters and return value.

## License

Contracts first published under MIT remain MIT.
Contracts whose header carries `SPDX-License-Identifier: FSL-1.1-MIT` are under the Functional Source License 1.1 and become MIT two years after publication, on the date in each header.
See [LICENSE](./LICENSE).
