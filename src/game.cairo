use pet_battle::models::{Direction};
use starknet::{ContractAddress};

// define the interface
#[starknet::interface]
trait IGame<TContractState> {
    fn spawn(self: @TContractState);
    fn move(self: @TContractState, direction: Direction);
    fn chooseRole(self: @TContractState, role: u32);
    fn chooseSkill(self: @TContractState, skill: u32);
    fn startBattle(self: @TContractState, target: ContractAddress);
}

// dojo decorator
#[dojo::contract]
mod game {
    use starknet::{ContractAddress, get_caller_address};
    use pet_battle::models::{Player, BattleInfo, Position, Moves, Direction, Vec2, BattleResult, Skill, Role};
    use pet_battle::utils::next_position;
    use pet_battle::constants;
    // use pet_battle::utils::battle_property_settting;
    use super::IGame;

    // declaring custom event struct
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Moved: Moved,
        Win: Win,
    }

    // declaring custom event struct
    #[derive(Drop, starknet::Event)]
    struct Moved {
        player: ContractAddress,
        direction: Direction
    }

    // declaring custom event struct
    #[derive(Drop, starknet::Event)]
    struct Win {
        battleId : u32,
        winner: ContractAddress,
    }

    // impl: implement functions specified in trait
    #[external(v0)]
    impl GameImpl of IGame<ContractState> {
        // ContractState is defined by system decorator expansion
        fn spawn(self: @ContractState) {
            // Access the world dispatcher for reading.
            let world = self.world_dispatcher.read();

            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();

            // Retrieve the player's current position from the world.
            let position = get!(world, player, (Position));

            // Retrieve the player's move data, e.g., how many moves they have left.
            let moves = get!(world, player, (Moves));

            // Update the world state with the new data.
            // 1. Set players moves to 10
            // 2. Move the player's position 100 units in both the x and y direction.
            set!(
                world,
                (
                    Moves { player, remaining: 100, last_direction: Direction::None(()) },
                    Position { player, vec: Vec2 { x: 10, y: 10 } },
                )
            );
        }

        // Implementation of the move function for the ContractState struct.
        fn move(self: @ContractState, direction: Direction) {
            // Access the world dispatcher for reading.
            let world = self.world_dispatcher.read();

            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();

            // Retrieve the player's current position and moves data from the world.
            let (mut position, mut moves) = get!(world, player, (Position, Moves));

            // Deduct one from the player's remaining moves.
            moves.remaining -= 1;

            // Update the last direction the player moved in.
            moves.last_direction = direction;

            // Calculate the player's next position based on the provided direction.
            let next = next_position(position, direction);

            // Update the world state with the new moves data and position.
            set!(world, (moves, next));

            // Emit an event to the world to notify about the player's move.
            emit!(world, Moved { player, direction });
        }

        // choose role
        fn chooseRole(self: @ContractState, role: u32) {
            // assert(role < 3 && role > 0, 'invalid role');
            assert(role < 2, 'invalid role');

            // Access the world dispatcher for reading.
            let world = self.world_dispatcher.read();

            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();

            let mut gamePlayer = get!(world, player, (Player));
            gamePlayer.roleId = role;

            set!(world, (gamePlayer));
        }

        // choose skill
        fn chooseSkill(self: @ContractState, skill: u32) {
            // assert(skill < 4 && skill > 0, 'invalid role');
            assert(skill < 3, 'invalid role');

            // Access the world dispatcher for reading.
            let world = self.world_dispatcher.read();

            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();

            // Retrieve the player's current position and moves data from the world.
            let mut gamePlayer = get!(world, player, (Player));
            gamePlayer.skillId = skill;

            set!(world, (gamePlayer));
        }

        // start battle
        fn startBattle(self: @ContractState, target: ContractAddress) {
            // 获取玩家
            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            let battleId = 1;

            let mut attackerBattleInfo = BattleInfo{
                battleId,
                is_attacker: true,
                addr: player,
                hp: 0,
                attack: 0,
                defense: 0,
                hit: 0,
                dodge: 0,
                crit: 0,
                speed: 0,
                skillId: 0,
            };
            let mut gamePlayer = get!(world, player, (Player));
            battle_property_settting(world, gamePlayer.roleId, gamePlayer.skillId, attackerBattleInfo, player);
            

            let mut defenderBattleInfo = BattleInfo{
                battleId,
                is_attacker: false,
                addr: target,
                hp: 0,
                attack: 0,
                defense: 0,
                hit: 0,
                dodge: 0,
                crit: 0,
                speed:0,
                skillId: 0,
            };
            let mut targetPlayer = get!(world, target, (Player));
            battle_property_settting(world, targetPlayer.roleId, targetPlayer.skillId, defenderBattleInfo, target);
            
            battle(world, attackerBattleInfo, defenderBattleInfo);
        }
    }

    fn battle_property_settting(world: IWorldDispatcher, roleId: u32, skillId: u32, mut info: BattleInfo, addr : ContractAddress) {
        let role = get!(world, roleId, (Role));
        info.hp = role.hp;
        info.attack = role.attack;
        info.defense = role.defense;
        info.hit = role.hit;
        info.dodge = role.dodge;
        info.speed = role.speed;
        info.skillId = skillId;
    }

    // battle
    fn battle(world: IWorldDispatcher,  mut attacker: BattleInfo, mut defender: BattleInfo) {
        // skill effect 
        battleSkillEffect(world, attacker);
        battleSkillEffect(world, defender);

        loop {
            if attacker.hp == 0 || defender.hp == 0 {
                break;
            }

            roundBattle(world, attacker, defender);
        };

        let mut attackerPrior = true;
        if attacker.speed < defender.speed {
            attackerPrior = false;
        }

        let mut winner = attacker.addr;
        if defender.hp > 0  {
            winner = defender.addr;
        } else if defender.hp == 0 && attacker.hp == 0 { // attacker.hp > 0 
            if attackerPrior == false {
                winner = defender.addr;
            }
        }

        let mut battleResult = BattleResult{
            battleId : attacker.battleId,
            winner : winner,
        };

// emit!(world, Moved { player, direction });
        emit!(world, Win { battleId: attacker.battleId, winner: winner});
    }

    fn battleSkillEffect(world: IWorldDispatcher, mut info: BattleInfo) {
        if info.skillId == constants::SKILL_COMBO_ATTACK {
            
        } else if info.skillId == constants::SKILL_ADD_HP {
            let skill = get!(world, info.skillId , (Skill));
            info.hp = info.hp + skill.value;
        } else if info.skillId == constants::SKILL_ADD_SPEED {
            let skill = get!(world, info.skillId , (Skill));
            info.speed = info.speed + skill.value;
        }
    }

    fn roundBattle(world: IWorldDispatcher, mut  attacker: BattleInfo, mut defender: BattleInfo) {
        let attackerHurt = defender.attack - attacker.defense;
        if attackerHurt > 0 {
            defender.hp = defender.hp - attackerHurt;
        }

        let defenderHurt = attacker.attack - defender.defense;
        if defenderHurt > 0 {
            attacker.hp = attacker.hp - defenderHurt;
        }
    }

    
}

#[cfg(test)]
mod tests {
    use starknet::class_hash::Felt252TryIntoClassHash;

    // import world dispatcher
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    // import test utils
    use dojo::test_utils::{spawn_test_world, deploy_contract};

    // import models
    use pet_battle::models::{position, moves};
    use pet_battle::models::{Position, Moves, Direction, Vec2};

    // import game
    use super::{game, IGameDispatcher, IGameDispatcherTrait};

    #[test]
    #[available_gas(30000000)]
    fn test_move() {
        // caller
        let caller = starknet::contract_address_const::<0x0>();

        // models
        let mut models = array![position::TEST_CLASS_HASH, moves::TEST_CLASS_HASH];

        // deploy world with models
        let world = spawn_test_world(models);

        // deploy systems contract
        let contract_address = world
            .deploy_contract('salt', game::TEST_CLASS_HASH.try_into().unwrap());
        let actions_system = IGameDispatcher { contract_address };

        // call spawn()
        actions_system.spawn();

        // call move with direction right
        actions_system.move(Direction::Right(()));

        // Check world state
        let moves = get!(world, caller, Moves);

        // casting right direction
        let right_dir_felt: felt252 = Direction::Right(()).into();

        // check moves
        assert(moves.remaining == 99, 'moves is wrong');

        // check last direction
        assert(moves.last_direction.into() == right_dir_felt, 'last direction is wrong');

        // get new_position
        let new_position = get!(world, caller, Position);

        // check new position x
        assert(new_position.vec.x == 11, 'position x is wrong');

        // check new position y
        assert(new_position.vec.y == 10, 'position y is wrong');
    }
}
