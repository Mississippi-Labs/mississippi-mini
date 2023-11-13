use starknet::{ContractAddress};

// define the interface
#[starknet::interface]
trait IConfig<TContractState> {
    fn initRole(self: @TContractState);
    fn initSkill(self: @TContractState);
}

// dojo decorator
#[dojo::contract]
mod config {
    use pet_battle::models::{Role, Skill};
    use pet_battle::constants;
    use super::IConfig;

    #[external(v0)]
    impl ConfigImpl of IConfig<ContractState> {
        fn initRole(self: @ContractState) {
            let world = self.world_dispatcher.read();

            let warrior = Role { 
                id: constants::ROLE_WARRIOR, 
                hp: 300,
                attack: 100,
                defense: 40,
                hit: 0,
                dodge: 0,
                crit: 0,
                speed: 20,
            };
            set!(world, (warrior));

            let knight = Role {
                id: constants::ROLE_KNIGHT,
                hp: 400,
                attack: 70,
                defense: 60,
                hit: 0,
                dodge: 0,
                crit: 0,
                speed: 18,
            };
            set!(world, (knight));
        }

        fn initSkill(self: @ContractState) {
            let world = self.world_dispatcher.read();

            let comboAttackSkill = Skill {
                id : constants::SKILL_COMBO_ATTACK,
                value : 20,
            };
            set!(world, comboAttackSkill);

            let addHpSkill = Skill{
                id : constants::SKILL_ADD_HP,
                value : 100,
            };
            set!(world, addHpSkill);

            let addSpeedSkill = Skill{
                id : constants::SKILL_ADD_SPEED,
                value : 100,
            };
            set!(world, addSpeedSkill);
        }
    }

}