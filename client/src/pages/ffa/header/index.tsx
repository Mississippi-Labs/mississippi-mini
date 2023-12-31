import React, { useState, useEffect } from 'react';
import Logo from '@/assets/img/logo.png';
import './styles.scss';
import imgTwitter from '@/assets/img/icon_tw.png';
import imgDiscord from '@/assets/img/icon_d.png';
import UserAddress from '@/components/UserAddress';
import { useDojo } from "../../../DojoContext";

interface IProps {
  onPlayBtnClick: () => void;
  onlyRight?: boolean;
}


const HomeHeader = (props: IProps) => {

  const [walletBalance, setWalletBalance] = useState('0');

  const {
    account: {
      account,
    },
  } = useDojo()

  const walletAddress = account.address



  return (
    <div className="home-header" >
      <div className='home-header-l'>
        <a href="/">
          <img src={Logo} alt="MISSISSIPPI" className="header-logo"/>
        </a>

        <nav className="header-nav">
          <ul className="menu-lv1">
            {/* <li><a href="">Leaderboard</a></li> */}
            <li><a href="https://mississippi.gitbook.io/mississippi/" target='_blank' rel="noreferrer">Docs</a></li>
            <li className="menu-socials">
              <a href="">Socials</a>
              <ul className="menu-lv2">
                <li>
                  <a href="https://twitter.com/0xMississippi" target="_blank" rel="noreferrer">Twitter</a>
                  <img src={imgTwitter} alt=""/>
                </li>
                <li>
                  <a href="https://discord.gg/UkarGN9Fjn" target="_blank" title="coming soon" rel="noreferrer">Discord</a>
                  <img src={imgDiscord} alt=""/>
                </li>

              </ul>
            </li>
          </ul>
        </nav>
      </div>
      {
        walletAddress ?
          <UserAddress address={walletAddress} account={walletBalance + 'ETH'}/>
          :
          <button className="play-btn mi-btn" onClick={props.onPlayBtnClick}>PLAY NOW</button>
      }
    </div>
  );
};

export default HomeHeader;