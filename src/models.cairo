use starknet::ContractAddress;
use array::ArrayTrait;

// dojo data models
#[derive(Model, Copy, Drop, Print, Serde)]
struct Player {
    #[key] // primary key
    addr: ContractAddress,
    // equip vec  // how to define it in cairo 
    equip   Array<Equipment>,
}

#[derive(Model, Copy, Drop, Print, Serde)]
struct Equipment {
    #[key] // primary key
    id: u32,
    hp: u32,
    attack: u32, 
    defense: u32,
    hit: u32,
    dodge: u32,
    crit: u32,
}

#[derive(Model, Copy, Drop, Print, Serde)]
struct Battle {
    #[key] // primary key
    battleId: u32,
    attackerHp: u32 
    attackerAttack: u32,
    attackerDefense: u32,
    attackerHit: u32,
    attackerDodge: u32,
    attackerCrit: u32, 
    defenderHp: u32,
    defenderAttack: u32,
    defenderDefense: u32,
    defenderHit: u32,
    defenderDodge: u32,
    defenderCrit: u32,
}

#[derive(Model, Copy, Drop, Print, Serde)]
struct Room {
    #[key] // primary key
    roomId: u32,
    battleId: u32, 
}


