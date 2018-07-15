import React, { Component } from 'react';
import socket from './socket';
import Konva from 'konva';
import { Stage, Layer, Rect, Text } from 'react-konva';
import Tank from './parts/tank';
import Missile from './parts/missile';
import Brick from './parts/brick';
import Steel from './parts/steel';
import HP from './parts/hp';
import Chat from './chat';

export default class Game extends Component{
  constructor(props) {
    super(props);

    this.channel = props.channel;
    window.game_channel = this.channel;
    this.state = {
      canvas: {width: 0, height: 0},
      tanks: [],
      missiles: [],
      bricks: [],
      steels: [],
      destroyed_tanks_last_frame: [],
      players: this.props.players,
    };

    /**
    tank is : {x, y, width, height, hp, orientation, player}
    player is : {name, id, is_owner, is_ready, tank_thumbnail}
    */

    console.log("initializing game component");
    this.channelInit();
    this.attachKeyEventHandler();
  }

  render(){
    let canvas = this.state.canvas,
        tanks = this.state.tanks,
        missiles = this.state.missiles,
        bricks = this.state.bricks,
        steels = this.state.steels,
        destroyed_tanks = this.state.destroyed_tanks_last_frame;

    // console.log({canvas: canvas});
    let unit = 26;
    let stage_style = {
      border: "1px solid red",
      width: canvas.width * unit,
      height: canvas.height * unit,
    };
    let hp_container_style = {
      // width: "300px",
    };

    let player_tank_map = this.state.players.map( player => {
      let tank = tanks.find( t => t.player.id == player.id);
      return {player, tank};
    });

    return (
      <div className="game-container d-flex flex-row justify-content-start">
        <Stage width={canvas.width * unit} height={canvas.height * unit} style={stage_style} onClick={this.focus.bind(this)}>
          <Layer>
            {tanks.map( t => <Tank tank={t} unit={unit} key={t.player.id} />)}
            {bricks.map( (b,i) => <Brick brick={b} unit={unit} key={i} />)}
            {steels.map( (s,i) => <Steel steel={s} unit={unit} key={i} />)}
            {missiles.map( (m,i) => <Missile missile={m} unit={unit} key={i} />)}
          </Layer>
        </Stage>
        <div className="sidebar d-flex flex-column px-3">
          <div className="sidebar-hp d-flex flex-column" style={hp_container_style}>
            {player_tank_map.map( ({player, tank}) => <HP player={player} tank={tank} key={player.id} />)}
          </div>

          <div className="sidebar-instructions mt-3">
            <h5 className="text-center">Instructions:</h5>
            <p><span className="p-2 font-weight-bold">Move:</span>↑,↓,←,→ | WASD</p>
            <p><span className="p-2 font-weight-bold">Shoot:</span>Shift | Space</p>
            <p>Fire wisely, tank needs to cool down for <span className="font-weight-bold">700ms</span> after each firing.</p>
          </div>

          <Chat channel={socket.channel(`chat:${window.room_name}`)}/>
        </div>
      </div>
    );
  }

  // format game data as needed
  gotView(game) {
    // console.log(JSON.stringify(game));
    this.setState(game);
  }

  channelInit() {
    this.channel.join()
      .receive("ok", this.gotView.bind(this))
      .receive("error", resp => {
        if (resp.reason == "terminated"){
          this.channel.leave();
        } else
        console.error("Unable to join game channel", resp)
      }
    );

    // handle game over message
    this.channel.on("gameover", (game) => {
      this.displayGameOver(); // game.tank.player is the winner
    });

    // handle state update
    this.channel.on("update_game", ({game}) => {
      this.gotView(game);
    });
  }

  attachKeyEventHandler() {
    document.addEventListener('keydown', this.onKeyDown.bind(this));
  }

  // regain game control when user clicks on canvas
  focus(e) {
    if (document.activeElement.tagName.toUpperCase() == "INPUT"){
      document.activeElement.blur();
    }
  }

  /***
  send fire and move actions
  */
  onKeyDown(e) {
    // console.log(e);
    // window.ev = e;

    if (!this.is_player())
      return;

    if (e.target.tagName.toUpperCase() == "INPUT")
      return;

    let key = e.key

    let direction = null;
    let fire = false;
    switch (key) {
      case "w":
      case "ArrowUp":
        direction = "up";
        break;
      case "s":
      case "ArrowDown":
        direction = "down";
        break;
      case "a":
      case "ArrowLeft":
        direction = "left";
        break;
      case "d":
      case "ArrowRight":
        direction = "right";
        break;
      case " ":
      case "Shift":
        fire = true;
        break;
      default:
        break;
    }

    if (direction){
      e.preventDefault();
      this.channel.push("move", {direction: direction});
    }
    if (fire && this.canFire()){
      e.preventDefault();
      this.channel.push("fire");
    }
  }

  canFire(){
    if (!this.lastFireMoment){
      this.lastFireMoment = Date.now();
      return true;
    } else {
      let now = Date.now();
      if (now-this.lastFireMoment >= 700){
        this.lastFireMoment = now;
        return true;
      } else {
        return false;
      }
    }
  }

  displayGameOver(){
    let winner = this.state.tanks.length > 0 ? this.state.tanks[0].player.id : -1;
    let greeting_msg = "Game Over";
    if (window.user == winner)
      greeting_msg = "Congrats! YOU WIN!!!";
    let gameover_layer = $('<div style="position:fixed; top: 0; width: 100vw; height: 100vh; background: rgba(255,255,255,.7); display: flex; flex-direction: column; align-items: center;justify-content: center;"></div>');
    let greeting_element = $('<p style="font-size:5em;"></p>').html(greeting_msg);
    let countdown = $('<p style="font-size: 2em;"></p>');
    greeting_element.appendTo(gameover_layer);
    countdown.appendTo(gameover_layer);
    gameover_layer.appendTo('body');
    // animate countdown process
    const wait = ms => new Promise((resolve) => setTimeout(resolve, ms));
    async function countdown_fn(n){
      while(n > 0){
        countdown.html(`Returning to room in ${n}`);
        n = await wait(1000).then( () => n-1 );
      }
      // remove countdown layer, keyboard blocking will be automatically removed when element is removed.
      gameover_layer.remove();
    }
    countdown_fn(5);
  }

  is_player() {
    let uid = window.user;
    let tanks = this.state.tanks;
    return tanks.map( (t) => t.player.id ).includes(uid);
  }
}
