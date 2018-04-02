import React from 'react';
import Konva from 'konva';
import { Stage, Layer, Rect, Text } from 'react-konva';
/**
tank is : {x, y, width, height, hp, orientation, player}
player is : {name, id, is_owner, is_ready, tank_thumbnail}
*/

export default (props) => {
  let player = props.player;
  let tank = props.tank;
  let player_name = window.user == player.id ? "You" : player.name;

  let hp = tank ? tank.hp : 0;
  let hp_bar_container_style = {
    // width: "200px",
    flexGrow: 1,
  };
  let hp_bar_style = {
    width: `${hp/4 * 100}%`,
  };
  let thumbnail_style = {
    width: "40px",
    height: "40px",
  };
  let player_name_style = {
    fontWeight: "bold",
    color: window.user == player.id ? "black" : "darkgray",
  };
  return (
    <div className="player-hp d-flex flex-row mb-2">
      <img src={player.tank_thumbnail} alt={`player ${player.name}'s tank thumbnail`} style={thumbnail_style} />
      <div style={hp_bar_container_style} className="d-flex flex-column justify-content-end px-2">
        <div style={player_name_style}>{player_name}</div>
        <div className="progress">
        <div className="progress-bar" role="progressbar" style={hp_bar_style} aria-valuenow={hp} aria-valuemin="0" aria-valuemax="4"></div>
        </div>
      </div>
    </div>
  );
}
