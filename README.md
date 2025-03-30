# iLeaf Smart Contracts

## Overview
This repository contains two smart contracts built using Motoko:

- **iLeafERC20**: An ERC-20-like token that represents the ecosystem currency.
- **iLeafERC1155**: An ERC-1155-like multi-token standard contract where each leaf is a unique NFT linked to a specific tree and owner.

## Token Workflow
1. **Tree Creation**:  
   - The contract owner mints a tree (a collection of NFT leaves) for a user.  
   - Each leaf within a tree has a unique ID encoded with the owner's principal, the tree ID, and the leaf index.  
   - The owner sets a price for each leaf in ERC-20 tokens.

2. **Leaf Burning and Rewarding**:  
   - The contract owner can burn a leaf from a user's tree.  
   - When a leaf is burned, the corresponding ERC-20 reward (leaf price) is minted to the user's balance.  
   - Once all leaves from a tree are burned, the tree is removed.

3. **Balance Management**:  
   - Users can check their balance of ERC-20 tokens.  
   - Users can query the number of leaves they own for a specific tree.  
   - If a leaf exists in a user's balance, it has a value of 1; otherwise, it is considered removed.

## Deployment
To deploy the contracts, run the deployment script:

```sh
bash scripts/deploy.sh
```

This script will:

Deploy the `ERC-20` contract (`iLeafERC20`).

Deploy the `ERC-1155` contract (`iLeafERC1155`) with a reference to the deployed `ERC-20` contract.

Grant `iLeafERC1155` permission to mint `iLeafERC20` tokens.
