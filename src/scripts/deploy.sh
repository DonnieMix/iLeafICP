#!/bin/bash

set -e

echo "Deploying ERC20..."
dfx deploy erc20 --argument '( "iLeafCoin", "ILC", principal "'$(dfx identity get-principal)'" )'
ERC20_PRINCIPAL=$(dfx canister id erc20)
echo "ERC20 deployed at: $ERC20_PRINCIPAL"

echo "Deploying ERC1155 with ERC20 Principal..."
dfx deploy erc1155 --argument '( principal "'$(dfx identity get-principal)'", principal "'$ERC20_PRINCIPAL'" )'
ERC1155_PRINCIPAL=$(dfx canister id erc1155)
echo "ERC1155 deployed at: $ERC1155_PRINCIPAL"

echo "Granting ERC1155 permission to mint on ERC20..."
dfx canister call erc20 setPermission '( principal "'$ERC1155_PRINCIPAL'", true )'

echo "Deployment complete"
