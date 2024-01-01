import { useEffect, useRef, useState } from 'react';
import './styles.scss';
import Header from './header';
import UserInfo from './userInfo';
import fightIcon from '@/assets/img/fight-icon.png';
import Dialog from '@/pages/ffa/dialog';
import DuelField, { IDuelFieldMethod } from '@/components/DuelField';
import { hunterEquip, playerA, playerB, warriorEquip } from '@/mock/data';

import { Skills } from '@/config/hero';

import { useEntityQuery } from '@dojoengine/react'
import { Has, getComponentValue } from "@dojoengine/recs";
import { useDojo } from "../../DojoContext";

const FFA = () => {
  const {
    setup: {
      components: { BattleInfo, BattleResult, Player, Skill, Role, Global },
      systemCalls: { chooseSkill, chooseRole, startBattle: $startBattle, initRole, initSkill },
    },
    account: {
      clear,
      create: createAccount,
      account,
      list,
      select
    },
  } = useDojo()

  const RoleData = useEntityQuery([Has(Role)]).map((entity) => getComponentValue(Role, entity));

  const SkillData = useEntityQuery([Has(Skill)]).map((entity) => getComponentValue(Skill, entity));
  const BattleInfoData = useEntityQuery([Has(BattleInfo)]).map((entity) => getComponentValue(BattleInfo, entity));
  const BattleResultData = useEntityQuery([Has(BattleResult)]).map((entity) => getComponentValue(BattleResult, entity));
  const PlayerData:any = useEntityQuery([Has(Player)]).map((entity) => {
    let player = getComponentValue(Player, entity);
    let addr:any = player?.addr;
    const bn = BigInt(addr);
    const hex = bn.toString(16);
    let role = RoleData.find((role:any) => role.id == player?.roleId);
    return {
      ...role,
      ...player,
      addr: '0x' + hex,
      _addr: addr,
      countOfWin: 0,
      equip: role.id === 0 ? hunterEquip : warriorEquip,
    }
  });
  BattleResultData.forEach((data) => {
    const player = PlayerData.find(item => item._addr === data.winner);
    if (player) {
      player.countOfWin += 1;
    }
  });
  console.log(SkillData, RoleData, PlayerData, 'SkillData')
  console.log(BattleInfoData, BattleResultData, 'BattleInfoData')
  const GlobalData = useEntityQuery([Has(Global)]).map((entity) => getComponentValue(Global, entity));
  console.log(GlobalData, 'GlobalData')

  const curPlayer = PlayerData.find((player: any) => player.addr.toLocaleLowerCase() == account.address.toLocaleLowerCase()) || {};
  
  const [tab, setTab] = useState('home');
  const [dialogVisible, setDialogVisible] = useState(false);
  const [nameDialogVisible, setNameDialogVisible] = useState(false);
  const [skillDialogVisible, setSkillDialogVisible] = useState(false);
  const [battleResultDialogVisible, setBattleResultDialogVisible] = useState(false);
  const [battleResult, setBattleResult] = useState('');
  const [skillName, setSkillName] = useState('');
  const [battleVisible, setBattleVisible] = useState(false);
  const [mintState, setMintState] = useState('init');
  const [fighting, setFighting] = useState(false);
  const [attacker, setAttacker] = useState({...playerA});
  const [defer, setDefer] = useState({...playerB});
  const battleRef = useRef<IDuelFieldMethod>();
  const [round, setRound] = useState(0);
  const [attackRole, setAttackRole] = useState('left');
  const [logs, setLogs] = useState([]);

  const [skillId, setSkillId] = useState(0);
  const [battleId, setBattleId] = useState(-1);

  const targetData:any = useRef();
  const usernameRef = useRef('');


  const showDialog = (addr) => {
    targetData.current = PlayerData.find(item => item.addr === addr);
    setDialogVisible(true);
  }

  const closeDialog = () => {
    targetData.current = null;
    setDialogVisible(false);
  }


  const formatAddress = (addr:string) => {
    return addr.slice(0, 4) + '...' + addr.slice(-2);
  }

  useEffect(() => {
    let battleResultData:any = BattleResultData.find((item:any) => item.battleId == battleId);
    if (battleResultData) {
      let win = battleResultData?.winner;
      console.log(battleResultData, 'win')
      const bn = BigInt(win);
      const hex = bn.toString(16);
      let winner = '0x' + hex;
      console.log('______________________________________________')
      console.log(winner == account.address ? 'You win!' : 'You lose!')
      console.log('______________________________________________')
      // setBattleId(-1)
    }
  }, [battleId])

  useEffect(() => {
    setSkillId(curPlayer?.skillId)
  }, [curPlayer?.skillId])

  useEffect(() => {
    const init = async () => {
      clear();
      const newAccount = await createAccount();
      console.log(newAccount, 'newAccount')
      select(newAccount.address);
      localStorage.setItem('isFirst', '2');
    }
    let isFirst:any = localStorage.getItem('isFirst');
    console.log(isFirst, 'isFirst')
    if (isFirst != 2) {
      init()
    }

  }, [])


  useEffect(() => {
    if (round > 0) {
      if (attackRole === 'left') {
        battleRef.current?.leftAttack('sprint');
        defer.hp -= attacker.attack - defer.defense;
        if (defer.hp <= 0) {
          defer.hp = 0;
          showBattleResult('win');
          setRound(0);
          setLogs([...logs, {addr: defer.addr, win: true}]);
        } else {
          setTimeout(() => {
            setRound((prevState => prevState + 1));
            // setAttackRole('right');
            if (skillName === 'atk' && round % 3 === 0 && round <= 15) {
              console.log('追击');
            } else {
              setAttackRole('right');
            }
          }, 3000)
        }
        setDefer({...defer});
      } else {
        battleRef.current?.rightAttack('sprint');
        attacker.hp -= defer.attack - attacker.defense;
        if (attacker.hp <= 0) {
          attacker.hp = 0;
          showBattleResult('lose');
          setRound(0);
          setLogs([...logs, {addr: defer.addr, win: false}]);
        } else {
          setTimeout(() => {
            setRound((prevState => prevState + 1));
            if (defer.skillId === 2 && round % 3 === 0 && round <= 15) {
              console.log('追击');
            } else {
              setAttackRole('left');
            }
          }, 3000)
        }
        setAttacker({...attacker});
      }
    }
  }, [round]);

  const mint = () => {
    setNameDialogVisible(true);
  }

  const create = async () => {
    if (!usernameRef.current.value) {
      alert('please input your username');
      return false;
    }
    setNameDialogVisible(false);
    setMintState('minting');
    console.log(account, 'account')
    // 随机0or1
    const id = Math.floor(Math.random() * 2);
    await chooseRole(account, id);
    setMintState('finished');
  }

  const selectSkill = (name) => {
    setSkillDialogVisible(true);
    setSkillName(name);
  }

  const startBattle = async () => {
    const skillIndex = Skills.findIndex(item => item.name === skillName);
    const skillType = Skills[skillIndex].type;
    const _attacker = {...curPlayer};
    const _defer = {...targetData.current};

    if (_defer.skillId === 0) {
      _defer.hp += 100;
    } else if (_defer.skillId === 1) {
      _defer.speed += 15;
    }

    switch (skillType) {
      case 'spd':
        _attacker.speed += 15;
        break;
      case 'hp':
        _attacker.hp += 100;
        break;
    }

    await chooseSkill(account, skillId);
    const event = await $startBattle(account, targetData.current.addr);
    console.log(event, 'event');
    let battleId = event?.[0]?.data?.[5] || ''
    battleId = Number(battleId)
    setBattleId(battleId)

    setAttacker({..._attacker, maxHp: _attacker.hp});
    setDefer({..._defer, maxHp: _defer.hp});
    setSkillDialogVisible(false);
    setFighting(true);
    setRound(1);
    setAttackRole(_attacker.speed >= _defer.speed ? 'left' : 'right');
  }

  const showBattleResult = (result) => {
    setTimeout(() => {
      setBattleVisible(false);
      setBattleResultDialogVisible(true);
      setBattleResult(result);
    }, 3000);
  }


  return (
    <div className={'ffa-page'}>

      <Header addr={curPlayer?.addr}/>

      <section className={'ffa-section'}>
        <div className="ffa-switch-wrapper">
          <h2
            className={`switch-item ${tab === 'home' ? 'active' : ''}`}
            onClick={() => {
              setTab('home')
            }}
          >Home</h2>
          <h2
            className={`switch-item ${tab === 'battle' ? 'active' : ''}`}
            onClick={() => {
              setTab('battle')
            }}
          >Battle</h2>
        </div>
        {
          (tab === 'home') && <>
            <UserInfo player={curPlayer}/>
            {
              (mintState !== 'finished' && !curPlayer.addr ) && (
                <button className="mi-btn" onClick={mint}>{
                  mintState === 'init' ? 'Mint' : 'Minting...'
                }</button>
              )
            }
          </>
        }

        {
          tab === 'battle' && <div className={'ffa-battle-wrapper'} >
            <div className="left-content">
              <h3>Leaderboard</h3>
              <div className="leaderboard-wrapper">
                <ul className={'leaderboard-list'}>
                  {
                    PlayerData.sort((a, b) => b.countOfWin - a.countOfWin).map((item:any, index) => (
                      <li className={'rank-row'} key={index}>
                        <div className="rank-num">{index + 1}</div>
                        {/*<div className="username">{item.name.toString()}</div>*/}
                        <div className="addr">{formatAddress(item.addr.toString())}</div>
                        <div className="win-count">V{item.countOfWin}</div>
                        {
                          curPlayer?.addr !== item.addr && (
                            <div
                              className="fight-icon"
                              onClick={() => showDialog(item.addr)}
                            >
                              <img src={fightIcon} alt="fight"/>
                            </div>
                          )
                        }
                      </li>
                    ))
                  }
                </ul>
                {
                  curPlayer?.addr && (
                    <div className="my-rank-info rank-row">
                      <div className="rank-num">{PlayerData.findIndex(item => item.addr === curPlayer?.addr) + 1}</div>
                      {/*<div className="username">{curPlayer.name}</div>*/}
                      <div className="addr">{formatAddress(curPlayer.addr)}</div>
                      <div className="win-count">V{curPlayer.countOfWin}</div>
                      {/*<div className="lose-count">D{curPlayer.lose}</div>*/}
                    </div>
                  )
                }

              </div>
            </div>
            <div className="right-content">
              <h3>My Battle Logs</h3>
              <ul className="ffa-logs-wrapper">
                {
                  logs.map((log, index) => {
                    const addr = formatAddress(log.addr);
                    return (
                      <li key={index}>
                        <div className="ffa-content">I challenged {addr} {log.win ? 'Victory' : 'Defeat'}</div>
                        {/*<time>12/30 20:20</time>*/}
                      </li>
                    )
                  })
                }
              </ul>
            </div>
          </div>
        }
      </section>
      <Dialog visible={dialogVisible}>
        <div className={'dialog-user'}>
          <div className="dialog-userinfo">
            <dl>
              <dt>HP</dt>
              <dd>{targetData?.current?.hp}</dd>
            </dl>
            <dl>
              <dt>Attack</dt>
              <dd>{targetData?.current?.attack}</dd>
            </dl>
            <dl>
              <dt>Defense</dt>
              <dd>{targetData?.current?.defense}</dd>
            </dl>
            <dl>
              <dt>Speed</dt>
              <dd>{targetData?.current?.speed}</dd>
            </dl>
          </div>

          <div className="dialog-opt">
            <button
              className="battle-opt mi-btn"
              onClick={() => {
                setBattleVisible(true);

                setDialogVisible(false);
              }}>Battle</button>
            <button
              className="battle-opt mi-btn"
              onClick={closeDialog}
            >OK</button>

          </div>
        </div>
      </Dialog>
      <Dialog visible={nameDialogVisible}>
        <p className={'mint-name-text'}>
          You have successfully created a wallet.Name your character and start your journey!
        </p>
        <div className="mint-name">
          <input type="text" className="mi-input" ref={usernameRef}/>
          <button className="mi-btn" onClick={create}>OK</button>
        </div>
      </Dialog>
      <Dialog visible={skillDialogVisible}>
        <div className="skill-dialog-content">
          <h3>Skill</h3>
          <p>Select {skillName} as your skill</p>
          <div className="opt-wrapper">
            <button className="mi-btn" onClick={startBattle}>CONFIRM</button>
            <button className="mi-btn" onClick={() => setSkillDialogVisible(false)}>Back</button>
          </div>
        </div>

      </Dialog>
      <Dialog visible={battleResultDialogVisible}>
        <div className="battle-result-content">
          <h3>BATTLE RESULT</h3>
          <pre>
          {
            battleResult === 'win' ?
              'Congratulations! \n You are the winner!'
              :
              'You lost. \n Come and try again. '
          }
          </pre>
          <button className="mi-btn" onClick={() => {
            setBattleResultDialogVisible(false);
            setFighting(false)
          }}>OK</button>
        </div>
      </Dialog>
      {
        battleVisible && (
          <div className="ffa-battle-dialog-wrapper">
          <div className="ffa-battle-dialog">
            <div className="icon-rect"/>
            <div className="icon-rect"/>
            <div className="icon-rect"/>
            <div className="icon-rect"/>

            {
              !fighting && (
                <div className="skills-desc">
                  <ul className="skill-list">
                    {
                      Skills.map((item) => (
                        <li className={`skill-item skill-${item.type}`} key={item.name} onClick={() => selectSkill(item.name)}>
                          <div className="txt" >{item.name}</div>
                        </li>
                      ))
                    }
                  </ul>

                  <div className="desc-txt">
                    Select one of the three skills for the battle: <br/>
                    HP Boost: Increases HP by 100. <br/>
                    SPD Surge: Boosts speed by 100. <br/>
                    Chain ATK: 20% chance of a consecutive attack.
                  </div>
                </div>
              )
            }
            <div className="battle-user-info player1">
              <div className="battle-user-info-detail">
                <div className="username">{attacker.name}</div>
                <div>ATK {attacker.attack}</div>
                <div>DEF {attacker.defense}</div>
                <div>SPD {attacker.speed}</div>
              </div>

              <div className="hp-wrapper">
                <div className="hp" >
                  <div className="hp-bar" style={{ width: `${attacker.hp * 100 / attacker.maxHp}%` }}/>
                  {attacker.hp}/{attacker.maxHp}
                </div>
              </div>
            </div>

            <div className="battle-user-info player2">
              <div className="battle-user-info-detail">
                <div className="username">{defer.name}</div>
                <div>ATK {defer.attack}</div>
                <div>DEF {defer.defense}</div>
                <div>SPD {defer.speed}</div>
              </div>

              <div className="hp-wrapper">
                <div className="hp">
                  <div className="hp-bar" style={{ width: `${defer.hp * 100 / defer.maxHp}%` }}/>
                  {defer.hp}/{defer.maxHp}
                </div>
              </div>
            </div>

            <ul className="skill-list attacker-skill">
              <li className={`skill-item skill-${Skills.find(item => item.name === skillName)?.type}`}>
              </li>
            </ul>

            <ul className="skill-list defer-skill">
              <li className={`skill-item skill-${Skills[targetData?.current?.skillId]?.type}`}>
              </li>
            </ul>

            <DuelField
              ref={battleRef}
              leftPlayer={curPlayer}
              rightPlayer={targetData.current ?? {}}
            />
          </div>
          </div>
        )
      }
    </div>
  );
};

export default FFA;