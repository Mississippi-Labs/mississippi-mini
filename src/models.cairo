use starknet::ContractAddress;
// use array::ArrayTrait;
// use default

// dojo data models
#[derive(Model, Drop, Serde)]
struct Player {
    #[key] // primary key
    addr: ContractAddress,
    name: felt252,
    roleId: u32,
    skillId: u32,
}

#[derive(Model, Copy, Drop, Print, Serde)]
struct Role {
    #[key] // primary key
    id: u32,
    hp: u32,
    attack: u32, 
    defense: u32,
    hit: u32,
    dodge: u32,
    crit: u32,
    speed: u32,
}

#[derive(Model, Copy, Drop, Print, Serde)]
struct Skill {
    #[key] // primary key
    id: u32,
    value: u32,
}

#[derive(Model, Copy, Drop, Print, Serde)]
struct Config {
    #[key] // primary key
    id: u32,
    battleId : u32,
}

#[derive(Model, Copy, Drop, Print, Serde)]
struct Global {
    #[key] // primary key
    id: u32,
    battleId : u32,
}

#[derive(Model, Copy, Drop, Print, Serde)]
struct BattleInfo {
    #[key] // primary key
    battleId: u32,
    #[key]
    is_attacker: bool,
    addr: ContractAddress,
    hp: u32,
    attack: u32, 
    defense: u32,
    hit: u32,
    crit: u32,
    dodge: u32,
    speed: u32,
    skillId: u32,
}

#[derive(Model, Copy, Drop, Print, Serde)]
struct BattleResult {
    #[key] // primary key
    battleId: u32,
    winner: ContractAddress,
}

#[derive(Model, Copy, Drop, Print, Serde)]
struct BattleRank {
    #[key] // primary key
    addr: ContractAddress,
    score: u32,
}
