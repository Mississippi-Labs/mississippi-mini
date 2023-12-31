import React from 'react';
import { CopyToClipboard } from 'react-copy-to-clipboard';
import './styles.scss';

interface IProps {
  account: string;
  address: string;
}

const UserAddress = (props: IProps) => {

  const { account, address = '' } = props;
  const addressTxt = `${address.slice(0, 6)}...${address.slice(-4)}`;

  const onCopy = () => {
    alert('Successfully copied');
  }

  return (
    <div className="user-address-wrapper">
      <div className="user-account">{account}</div>
      <CopyToClipboard text={address} onCopy={onCopy}>
        <div className="user-address">{addressTxt}</div>
      </CopyToClipboard>
    </div>
  );
};

export default UserAddress;