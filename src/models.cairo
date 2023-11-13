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

// impl Default for MyStruct {
//     fn default() -> Self {
//         Self::new(0, String::default(), false)
//     }
// }

#[derive(Model, Copy, Drop, Print, Serde)]
struct Room {
    #[key] // primary key
    roomId: u32,
    battleId: u32, 
}

#[derive(Serde, Copy, Drop, Introspect)]
enum Direction {
    None: (),
    Left: (),
    Right: (),
    Up: (),
    Down: (),
}

impl DirectionIntoFelt252 of Into<Direction, felt252> {
    fn into(self: Direction) -> felt252 {
        match self {
            Direction::None(()) => 0,
            Direction::Left(()) => 1,
            Direction::Right(()) => 2,
            Direction::Up(()) => 3,
            Direction::Down(()) => 4,
        }
    }
}

#[derive(Model, Drop, Serde)]
struct Moves {
    #[key]
    player: ContractAddress,
    remaining: u8,
    last_direction: Direction
}

#[derive(Copy, Drop, Serde, Introspect)]
struct Vec2 {
    x: u32,
    y: u32
}

#[derive(Model, Copy, Drop, Serde)]
struct Position {
    #[key]
    player: ContractAddress,
    vec: Vec2,
}

trait Vec2Trait {
    fn is_zero(self: Vec2) -> bool;
    fn is_equal(self: Vec2, b: Vec2) -> bool;
}

impl Vec2Impl of Vec2Trait {
    fn is_zero(self: Vec2) -> bool {
        if self.x - self.y == 0 {
            return true;
        }
        false
    }

    fn is_equal(self: Vec2, b: Vec2) -> bool {
        self.x == b.x && self.y == b.y
    }
}

#[cfg(test)]
mod tests {
    use super::{Position, Vec2, Vec2Trait};

    #[test]
    #[available_gas(100000)]
    fn test_vec_is_zero() {
        assert(Vec2Trait::is_zero(Vec2 { x: 0, y: 0 }), 'not zero');
    }

    #[test]
    #[available_gas(100000)]
    fn test_vec_is_equal() {
        let position = Vec2 { x: 420, y: 0 };
        assert(position.is_equal(Vec2 { x: 420, y: 0 }), 'not equal');
    }
}



