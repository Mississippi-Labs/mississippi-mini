import { Container } from '@pixi/react';
import Player, { IPlayer } from '@/components/PIXIPlayers/Player';

interface IProps {
  data: IPlayer[];
  huntingPlayerId?: string;
}

const PIXIPlayers = (props: IProps) => {

  const { data = [], huntingPlayerId } = props;
  return (
    <Container>
      {
        data.map((player, index) => {

          return <Player key={index} hpVisible hunted={huntingPlayerId === player.addr} {...player}/>;
        })
      }
    </Container>
  );
};

export default PIXIPlayers;