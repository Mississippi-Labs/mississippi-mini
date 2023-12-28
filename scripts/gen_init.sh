#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..

# export RPC_URL="http://localhost:5050";
export RPC_URL="https://starknet-goerli.infura.io/v3/5ca372516740427e97512d4dfefd9c47";
export WORLD_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.world.address')

export GAME_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.contracts[] | select(.name == "mississippi_mini::game::game" ).address')

export CONFIG_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.contracts[] | select(.name == "mississippi_mini::config::config" ).address')


echo "---------------------------------------------------------------------------"
echo world : $WORLD_ADDRESS 
echo " "
echo game : $GAME_ADDRESS
echo " "
echo config : $CONFIG_ADDRESS
echo "---------------------------------------------------------------------------"

# enable system -> component authorizations
game_component=("Role" "Skill" "Global" "Player" "BattleInfo" "BattleResult")
config_component=("Role" "Skill" "Global")


sozo execute mississippi_mini::config::config init_skill  --rpc-url $RPC_URL 





echo "Default authorizations have been successfully set."