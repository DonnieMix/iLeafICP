# iLeaf Smart Contracts

## Overview
This repository contains two smart contracts built using Motoko:

- **iLeafERC20**: An ERC-20-like token that represents the ecosystem currency.
- **iLeafERC1155**: An ERC-1155-like multi-token standard contract where each leaf is a unique NFT linked to a specific tree and owner.

## Deployment
To deploy the contracts, run the deployment script:

```sh
bash scripts/deploy.sh
```

This script will:

Deploy the `ERC-20` contract (`iLeafERC20`).

Deploy the `ERC-1155` contract (`iLeafERC1155`) with a reference to the deployed `ERC-20` contract.

Grant `iLeafERC1155` permission to mint `iLeafERC20` tokens.
