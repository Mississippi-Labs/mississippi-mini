import './styles.scss';
import * as PIXI from 'pixi.js';
import { Stage } from '@pixi/react';
import Player, { IPlayer } from '@/components/PIXIPlayers/Player';
import fightIcon from '@/assets/img/fight-icon.png';
import { Skills } from '@/config/hero';
import { hunterEquip, warriorEquip } from '@/mock/data';


PIXI.settings.SCALE_MODE = PIXI.SCALE_MODES.NEAREST;

export interface IUserInfo {
  player?: any;
}

const UserInfo = (props: IUserInfo) => {

  const { player } = props;
  const lootHasLoaded = player?.addr;

  return (
    <div className={'ffa-userinfo-wrapper'}>
      <div className="left-main-content">
        <h3>User Info</h3>
        <div className={`user-detail-wrapper ${lootHasLoaded ? 'user-loaded' : ''}`}>
          <div className="user-detail-content">
            <div className="user-appearance-wrapper">
              <div className="user-appearance-box">
                <Stage width={256} height={256} options={{ resolution: 1, backgroundAlpha: 0 }}>
                  <Player size={128} x={0.5} y={0.5} equip={player?.equip ?? {}} action={'idle'} />
                </Stage>
              </div>
            </div>

            <div className={`user-attr-wrapper ${lootHasLoaded ? 'loaded' : ''}`}>
              <dl>
                <dt>HP</dt>
                <dd><span className="base-attr">{player?.hp ?? 0}</span></dd>
              </dl>
              <dl>
                <dt>Attack</dt>
                <dd><span className="base-attr">{player?.attack ?? 0}</span></dd>
              </dl>
              <dl>
                <dt>Defense</dt>
                <dd><span className="base-attr">{player?.defense ?? 0}</span></dd>
              </dl>
              <dl>
                <dt>Speed</dt>
                <dd><span className="base-attr">{player?.speed ?? 0}</span></dd>
              </dl>

              <div className="skills-wrapper">
                <h4>Skills</h4>
                <ul className="skill-list">
                  {
                    Skills.map((item) => (
                      <li className={`skill-item skill-${item.type}`} key={item.name}>
                        {/*<div className="txt" >{item.name}</div>*/}
                      </li>
                    ))
                  }
                </ul>
              </div>
            </div>
            


          </div>

        </div>
      </div>
      <div className="right-main-content">
        <h3>How to play</h3>

        <div className=" how-to-play">

          <p>
            1. Click “MINT” to generate your character
          </p>
          <p>
            2. Click “BATTLE” to enter the battlefield
          </p>
          <p>
            3. Click a user’s name to check the stats, and
            <img src={fightIcon} alt="fight" style={{ verticalAlign: -3, width: 19, height: 19, margin: '0 8px' }}/>
            to challenge
          </p>
          <p>
            4. Select one skill for each battle: <br/>
            HP Boost: Increases HP by 100 <br/>
            SPD Surge: Boosts speed by 100 <br/>
            Chain ATK: 20% chance of a consecutive atk
          </p>
          <p>
            5. You are all ready now! Stand by to see the outcome of the battle with your sage strategic planning
          </p>

        </div>
      </div>
    </div>
  );
};

export default UserInfo;