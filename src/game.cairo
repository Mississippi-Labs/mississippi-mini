use starknet::{ContractAddress};

// define the interface
#[starknet::interface]
trait IGame<TContractState> {
    // fn spawn(self: @TContractState);
    // fn move(self: @TContractState, direction: Direction);
    fn choose_role(self: @TContractState, role: u32);
    fn choose_skill(self: @TContractState, skill: u32);
    fn start_battle(self: @TContractState, target: ContractAddress);
}

// dojo decorator
#[dojo::contract]
mod game {
    use starknet::{ContractAddress, get_caller_address};
    use mississippi_mini::models::{Player, BattleInfo, BattleResult, Skill, Role, Global, BattleRank};
    use mississippi_mini::constants;
    use mississippi_mini::random::{RandomTrait};
    // use mississippi_mini::utils::battle_property_settting;
    use super::IGame;

    const DICE_FACE_COUNT: u8 = 100;
    const DICE_SEED: felt252 = 'SEED';

    // declaring custom event struct
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Win: Win,
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
        // choose role
        fn choose_role(self: @ContractState, role: u32) {
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
        fn choose_skill(self: @ContractState, skill: u32) {
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
        fn start_battle(self: @ContractState, target: ContractAddress) {
            // retrive player 
            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            
            let mut globalParams = get!(world, constants::GlOBAL_CONFIG_KEY, (Global));
            globalParams.battleId = globalParams.battleId + 1;
            let battleId = globalParams.battleId;
            set!(world, (globalParams));

            // globalParams.battleId.print();


            // check target exist 

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
            battle_property_settting(world, gamePlayer.roleId, gamePlayer.skillId, ref attackerBattleInfo, player);
            

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
            battle_property_settting(world, targetPlayer.roleId, targetPlayer.skillId, ref defenderBattleInfo, target);
            
            battle(world, ref attackerBattleInfo, ref defenderBattleInfo);
        }
    }

    fn battle_property_settting(world: IWorldDispatcher, roleId: u32, skillId: u32, ref info: BattleInfo, addr : ContractAddress) {
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
    fn battle(world: IWorldDispatcher,   ref attacker: BattleInfo, ref defender: BattleInfo) {
        // skill effect 
        effect_skill(world, ref attacker);
        effect_skill(world, ref defender);

        let mut attackerPrior = true;
        if attacker.speed < defender.speed {
            attackerPrior = false;
        }

        loop {
            if attacker.hp <= 0 || defender.hp <= 0 {
                break;
            }

            if attackerPrior {
                battle_round(world, ref attacker, ref defender);
            } else {
                battle_round(world, ref defender, ref attacker);
            }

            let mut  attacker_combot_flag = false;
            effect_after_battle_skill(world, attacker, ref attacker_combot_flag);
            if attacker_combot_flag && defender.hp >0 && attacker.hp > 0{
                battle_round(world, ref attacker, ref defender);
            }

            let mut  defender_combot_flag = false;
            effect_after_battle_skill(world, defender, ref defender_combot_flag);
            if defender_combot_flag && defender.hp >0 && attacker.hp > 0{
                battle_round(world,  ref defender, ref attacker);
            }
        };



        let mut winner = attacker.addr;
        if defender.hp > 0  {
            winner = defender.addr;
        } else if defender.hp == 0 && attacker.hp == 0 { 
            if attackerPrior == false {
                winner = defender.addr;
            }
        }

        let mut battleResult = BattleResult{
            battleId : attacker.battleId,
            winner : winner,
        };
        set!(world, (battleResult));

        let mut rankInfo = get!(world, winner, (BattleRank));

        let mut battleRank = BattleRank {
            addr : winner,
            score:  (rankInfo.score + 1),
        };
        set!(world, (battleRank));

        emit!(world, Win { battleId: attacker.battleId, winner: winner});
    }

    fn effect_skill(world: IWorldDispatcher, ref info: BattleInfo) {
        if info.skillId == constants::SKILL_ADD_HP {
            let skill = get!(world, info.skillId , (Skill));
            info.hp = info.hp + skill.value;
        } else if info.skillId == constants::SKILL_ADD_SPEED {
            let skill = get!(world, info.skillId , (Skill));
            info.speed = info.speed + skill.value;
        }
    }

    fn effect_after_battle_skill(world: IWorldDispatcher, info: BattleInfo, ref flag: bool)  {
        if info.skillId == constants::SKILL_COMBO_ATTACK {
            let mut dice = RandomTrait::new(DICE_FACE_COUNT, DICE_SEED);
            if dice.roll() > 80 {
                flag = true;
            }
        } 
    }

    fn battle_round(world: IWorldDispatcher, ref  attacker: BattleInfo, ref defender: BattleInfo) {
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
    use debug::PrintTrait;

    // import world dispatcher
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    // import test utils
    use dojo::test_utils::{spawn_test_world, deploy_contract};

    // import models
    use mississippi_mini::models::{player};
    use mississippi_mini::models::{Player, BattleInfo, BattleResult, Skill, Role, BattleRank};

    // import config
    use mississippi_mini::config::{config, IConfigDispatcher, IConfigDispatcherTrait};

    // import game
    use super::{game, IGameDispatcher, IGameDispatcherTrait};

    #[test]
    #[available_gas(8000000000)]
    fn test_battle() {
        // attacker
        let caller = starknet::contract_address_const::<0x0>();
        caller.print();
        // print!("start battle");

        // models
        let mut models = array![player::TEST_CLASS_HASH];

        // deploy world with models
        let world = spawn_test_world(models);

        let config_contract_address = world
            .deploy_contract('salt', config::TEST_CLASS_HASH.try_into().unwrap());
        let config_actions = IConfigDispatcher { contract_address: config_contract_address };

        // deploy systems contract
        let contract_address = world
            .deploy_contract('salt', game::TEST_CLASS_HASH.try_into().unwrap());
        let actions_system = IGameDispatcher { contract_address };

        config_actions.init_role();
        config_actions.init_skill();


        actions_system.choose_role(1);
        actions_system.choose_skill(1);


        // defender 
        let target = starknet::contract_address_const::<0x1>();
        // actions_system.choose_role( 1);
        // actions_system.choose_skill(2);



        // battle
        // actions_system.start_battle(caller);

        let p = get!(world, caller, (Player));
        p.roleId.print();
        // "adfasd".print();

        let battleRank = get!(world, caller, (BattleRank));
        battleRank.print();
        let battleInfo = get!(world, (1, false), (BattleInfo));
    }
}
