import { IPlayer } from '@/components/Player';
import { ITreasureChest } from '@/components/TreasureChest';


export const PlayersMockData: IPlayer[] = [
  {
    id: 3,
    username: 'Me',
    x: 5,
    y: 4,
    gem: 0,
    equip: {
      head: 'ChristmasHat',
      handheld: 'Beer',
      clothes: 'Chain'
    },
  },
  {
    id: 1,
    username: 'Piter',
    x: 18,
    y: 10,
    gem: 2,
    equip: {
      head: 'HiTechGlasses',
      handheld: 'Guitar',
      clothes: 'Niddle'
    },
  },
  {
    id: 6,
    username: 'Tom',
    gem: 5,
    x: 18,
    y: 13,
    equip: {
      head: 'Robber',
      handheld: 'Shield',
      clothes: 'Deliver'
    },
  },
  {
    id: 8,
    username: 'Stone',
    x: 18,
    y: 13,
    gem: 8,
    equip: {
      head: 'Turban',
      handheld: 'Wand',
      clothes: 'Shirt'
    },
  },
];

export const CurIdMockData = 3;

export const UserAddress = '0X1234567894519845184814';

export const TreasureChestMockData: ITreasureChest[] = [
  {
    id: 1,
    x: 6,
    y: 6,
    gem: 3
  },
  {
    id: 2,
    x: 17,
    y: 12,
    gem: 5
  }
];

const hunterEquip = {
  head: 'Demon Crown',
  clothes: 'Demon Husk',
  handheld: 'Club'
}

const warriorEquip = {
  head: 'Ancient Helm',
  clothes: 'Holy Chestplate',
  handheld: 'Mace'
}

export const playerA = {
  "x": 0.5,
  "y": 1.5,
  "hp": 300,
  "def": 40,
  "attack": 100,
  "attackRange": 4,
  "speed": 20,
  "strength": 35,
  "space": 3,
  "oreBalance": 0,
  "treasureBalance": 0,
  "state": 2,
  "lastBattleTime": 0,
  "maxHp": 300,
  "name": "Alice",
  "url": "",
  "addr": "0xb53c83ef2467da36c687c81cb23140d92e3d10ba",
  "username": "Alice",
  "equip": warriorEquip,
  "waiting": false,
  "action": "idle",
  "moving": false,
  "toward": "Right"
}

export const playerB = {
  "x": 5.1,
  "y": 1.5,
  "hp": 400,
  "def": 60,
  "attack": 70,
  "attackRange": 3,
  "speed": 18,
  "strength": 32,
  "space": 3,
  "oreBalance": 0,
  "treasureBalance": 0,
  "state": 2,
  "lastBattleTime": 0,
  "maxHp": 400,
  "name": "BoB",
  "url": "",
  "addr": "0xb58fd9cb0c9100bb6694a4d18627fb238d3bb893",
  "username": "BoB",
  "equip": hunterEquip,
  "waiting": false,
  "action": "idle",
  "moving": false,
  "toward": "Left"
}

export const Rank1 = [
  {
    name: 'Bob',
    address: '0x56..14',
    win: 0,
    lose: 0
  },
  {
    name: 'Alice',
    address: '0x34..35',
    win: 0,
    lose: 0
  },
];

export const Rank2 = [
  {
    name: 'Alice',
    address: '0x34..35',
    win: 1,
    lose: 0
  },
  {
    name: 'Bob',
    address: '0x56..14',
    win: 0,
    lose: 1
  },

];