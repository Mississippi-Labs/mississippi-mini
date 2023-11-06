use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::ContractAddress;

// interface
#[starknet::interface]
trait IPlayerActions<TContractState> {
    fn spawn(self: @TContractState, world: IWorldDispatcher);
}

// contract
#[starknet::contract]
mod player_actions {
    use starknet::{ContractAddress, get_caller_address};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use pet_battle::models::{Position,  Vec2};
    use super::IPlayerActions;

    // note the is no storage here - it's in the world contract
    #[storage]
    struct Storage {}

    #[external(v0)]
    impl PlayerActionsImpl of IPlayerActions<ContractState> {
        // 
        // NOTICE: we pass the world dispatcher as an argument to every function. 
        // This is how we interact with the world contract.
        //
        fn spawn(self: @ContractState, world: IWorldDispatcher) {
            // get player address
            let player = get_caller_address();

            // dojo command - get player position
            let position = get!(world, player, (Position));

            // dojo command - set player position
            set!(world, (Position { player, vec: Vec2 { x: 10, y: 10 } }));
        }
    }
}