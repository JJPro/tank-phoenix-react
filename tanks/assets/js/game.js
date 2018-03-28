import React, { Component } from 'react';
import socket from './socket';
import Konva from 'konva';
import { Stage, Layer, Rect, Text } from 'react-konva';
import Tank from './parts/tank';
import Missile from './parts/missile';
import Brick from './parts/brick';
import Steel from './parts/steel';

export default class Game extends Component{
  constructor(props) {
    super(props);

    this.channel = props.channel;
    window.game_channel = this.channel;
    this.gameover = false;
    this.state = {
      canvas: {width: 0, height: 0},
      tanks: [],
      missiles: [],
      bricks: [],
      steels: [],
      destroyed_tanks_last_frame: [],
    };

    // this.testData();

    console.log("initializing game component");
    this.channelInit();
    this.attachKeyEventHandler();
  }

  componentWillMount(){
    // setInterval(this.animate.bind(this), 50);
    this.animate();
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
    let style = {
      border: "1px solid red",
      width: canvas.width * unit,
      height: canvas.height * unit,
    };

    let tankhp_list = _.map(this.state.tanks, (tank, ii) => {
      return <TankHPItem username={tank.player.name} key={ii} hp={tank.hp} />;
    });

    // let tank = _.find(destroyed_tanks, function(tank) {
    //   return tank.player.id == window.user;
    // });
    //
    // if (tank) {
    //   window.alert("You are killed and now become the observer.");
    //   this.channel.push("delete_a_destroyed_tank", {uid: window.user})
    //       .receive("ok", this.gotView.bind(this));
    // }

    return (
      <div>
        <Stage width={canvas.width * unit} height={canvas.height * unit} style={style}>
          <Layer>
            {tanks.map( t => <Tank tank={t} unit={unit} key={t.player.id} />)}
            {bricks.map( (b,i) => <Brick brick={b} unit={unit} key={i} />)}
            {steels.map( (s,i) => <Steel steel={s} unit={unit} key={i} />)}
            {missiles.map( (m,i) => <Missile missile={m} unit={unit} key={i} />)}
          </Layer>
        </Stage>
        <div display="block">{tankhp_list}</div>
      </div>
    );
  }

  // format game data as needed
  gotView(game) {
    window.game = game;
    // console.log(JSON.stringify(game));
    // console.log(game);
    // if (game.tanks.length == 1)
    //   this.channel.push("end");
    // else
    //   this.setState(game);
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
        });

    this.channel.on("gameover", () => {
      this.gameover = true;
      // this.displayGameOver();
      setTimeout(()=>this.channel.push("game_ended"), 5000);
    });
  }

  animate() {

    // this.channel.push("get_state")
    //   .receive("ok", game => {
    //     this.gotView(game);
    //   });

    this.channel.push("get_state")
      .receive("ok", game => {
        this.gotView(game);
        if (!this.gameover)
          requestAnimationFrame(this.animate.bind(this));
      });
  }

  attachKeyEventHandler() {
    document.addEventListener('keydown', this.onKeyDown.bind(this));
  }

  /***
  send fire and move actions
  */
  onKeyDown(e) {
    // console.log(key);

    if (!this.is_player())
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

    // console.log(direction);
    // console.log(fire);
    if (direction){
      e.preventDefault();
      this.channel.push("move", {uid: window.user, direction: direction})
          .receive("ok", this.gotView.bind(this));
    }
    if (fire){
      e.preventDefault();
      this.channel.push("fire", {uid: window.user})
          .receive("ok", this.gotView.bind(this));
    }
  }

  displayGameOver(){
    let winner = this.state.tanks[0].player.id;
    if (window.user == winner)
      console.log("YOU WIN!!!!!");
    console.log("Game is over! Returning back to room in 5s");
  }

  is_player() {
    let uid = window.user;
    let tanks = this.state.tanks;
    return _.contains(tanks.map( (t) => t.player.id), uid);
  }



  testData(){

    let data = {"missiles":[{"y":5,"x":1, "width": 1/5, "height": 1/4, "direction": "up"}], "tanks":[{"y":0,"x":0,"width":2,"player":{"tank_thumbnail":"/images/tank-red.png","name":"Lu Ji","is_ready":true,"is_owner":false,"id":2},"orientation":"down","image":"/images/tank-red.png","hp":4,"height":2},{"y":24,"x":24,"width":2,"player":{"tank_thumbnail":"/images/tank-cyan.png","name":"Joyce","is_ready":true,"is_owner":true,"id":3},"orientation":"up","image":"/images/tank-cyan.png","hp":4,"height":2}],"steels":[{"y":12,"x":0},{"y":12,"x":1},{"y":0,"x":11},{"y":1,"x":11},{"y":24,"x":11},{"y":25,"x":11},{"y":12,"x":12},{"y":13,"x":12},{"y":12,"x":13},{"y":13,"x":13},{"y":0,"x":14},{"y":1,"x":14},{"y":24,"x":14},{"y":25,"x":14},{"y":12,"x":24},{"y":12,"x":25}],"destroyed_tanks_last_frame":[],"canvas":{"width":26,"height":26},"bricks":[{"y":2,"x":2},{"y":3,"x":2},{"y":4,"x":2},{"y":5,"x":2},{"y":6,"x":2},{"y":7,"x":2},{"y":10,"x":2},{"y":11,"x":2},{"y":12,"x":2},{"y":13,"x":2},{"y":14,"x":2},{"y":15,"x":2},{"y":18,"x":2},{"y":19,"x":2},{"y":20,"x":2},{"y":21,"x":2},{"y":22,"x":2},{"y":23,"x":2},{"y":2,"x":3},{"y":3,"x":3},{"y":4,"x":3},{"y":5,"x":3},{"y":6,"x":3},{"y":7,"x":3},{"y":10,"x":3},{"y":11,"x":3},{"y":12,"x":3},{"y":13,"x":3},{"y":14,"x":3},{"y":15,"x":3},{"y":18,"x":3},{"y":19,"x":3},{"y":20,"x":3},{"y":21,"x":3},{"y":22,"x":3},{"y":23,"x":3},{"y":12,"x":4},{"y":13,"x":4},{"y":12,"x":5},{"y":13,"x":5},{"y":2,"x":6},{"y":3,"x":6},{"y":4,"x":6},{"y":7,"x":6},{"y":8,"x":6},{"y":9,"x":6},{"y":12,"x":6},{"y":13,"x":6},{"y":16,"x":6},{"y":17,"x":6},{"y":18,"x":6},{"y":21,"x":6},{"y":22,"x":6},{"y":23,"x":6},{"y":2,"x":7},{"y":3,"x":7},{"y":4,"x":7},{"y":7,"x":7},{"y":8,"x":7},{"y":9,"x":7},{"y":12,"x":7},{"y":13,"x":7},{"y":16,"x":7},{"y":17,"x":7},{"y":18,"x":7},{"y":21,"x":7},{"y":22,"x":7},{"y":23,"x":7},{"y":2,"x":10},{"y":3,"x":10},{"y":4,"x":10},{"y":5,"x":10},{"y":6,"x":10},{"y":7,"x":10},{"y":10,"x":10},{"y":11,"x":10},{"y":12,"x":10},{"y":13,"x":10},{"y":14,"x":10},{"y":15,"x":10},{"y":18,"x":10},{"y":19,"x":10},{"y":20,"x":10},{"y":21,"x":10},{"y":22,"x":10},{"y":23,"x":10},{"y":2,"x":11},{"y":3,"x":11},{"y":4,"x":11},{"y":5,"x":11},{"y":6,"x":11},{"y":7,"x":11},{"y":10,"x":11},{"y":11,"x":11},{"y":12,"x":11},{"y":13,"x":11},{"y":14,"x":11},{"y":15,"x":11},{"y":18,"x":11},{"y":19,"x":11},{"y":20,"x":11},{"y":21,"x":11},{"y":22,"x":11},{"y":23,"x":11},{"y":5,"x":12},{"y":6,"x":12},{"y":19,"x":12},{"y":20,"x":12},{"y":5,"x":13},{"y":6,"x":13},{"y":19,"x":13},{"y":20,"x":13},{"y":2,"x":14},{"y":3,"x":14},{"y":4,"x":14},{"y":5,"x":14},{"y":6,"x":14},{"y":7,"x":14},{"y":10,"x":14},{"y":11,"x":14},{"y":12,"x":14},{"y":13,"x":14},{"y":14,"x":14},{"y":15,"x":14},{"y":18,"x":14},{"y":19,"x":14},{"y":20,"x":14},{"y":21,"x":14},{"y":22,"x":14},{"y":23,"x":14},{"y":2,"x":15},{"y":3,"x":15},{"y":4,"x":15},{"y":5,"x":15},{"y":6,"x":15},{"y":7,"x":15},{"y":10,"x":15},{"y":11,"x":15},{"y":12,"x":15},{"y":13,"x":15},{"y":14,"x":15},{"y":15,"x":15},{"y":18,"x":15},{"y":19,"x":15},{"y":20,"x":15},{"y":21,"x":15},{"y":22,"x":15},{"y":23,"x":15},{"y":2,"x":18},{"y":3,"x":18},{"y":4,"x":18},{"y":7,"x":18},{"y":8,"x":18},{"y":9,"x":18},{"y":12,"x":18},{"y":13,"x":18},{"y":16,"x":18},{"y":17,"x":18},{"y":18,"x":18},{"y":21,"x":18},{"y":22,"x":18},{"y":23,"x":18},{"y":2,"x":19},{"y":3,"x":19},{"y":4,"x":19},{"y":7,"x":19},{"y":8,"x":19},{"y":9,"x":19},{"y":12,"x":19},{"y":13,"x":19},{"y":16,"x":19},{"y":17,"x":19},{"y":18,"x":19},{"y":21,"x":19},{"y":22,"x":19},{"y":23,"x":19},{"y":12,"x":20},{"y":13,"x":20},{"y":12,"x":21},{"y":13,"x":21},{"y":2,"x":22},{"y":3,"x":22},{"y":4,"x":22},{"y":5,"x":22},{"y":6,"x":22},{"y":7,"x":22},{"y":10,"x":22},{"y":11,"x":22},{"y":12,"x":22},{"y":13,"x":22},{"y":14,"x":22},{"y":15,"x":22},{"y":18,"x":22},{"y":19,"x":22},{"y":20,"x":22},{"y":21,"x":22},{"y":22,"x":22},{"y":23,"x":22},{"y":2,"x":23},{"y":3,"x":23},{"y":4,"x":23},{"y":5,"x":23},{"y":6,"x":23},{"y":7,"x":23},{"y":10,"x":23},{"y":11,"x":23},{"y":12,"x":23},{"y":13,"x":23},{"y":14,"x":23},{"y":15,"x":23},{"y":18,"x":23},{"y":19,"x":23},{"y":20,"x":23},{"y":21,"x":23},{"y":22,"x":23},{"y":23,"x":23}]};
    this.state = data;
    // console.log({tanks: data.tanks, missiles: data.missiles});
  }
}

function TankHPItem(props) {
  let player = props.username;
  let hp = props.hp;
  return <div className="row font-weight-bold text-warning"><span className="text h3">{player} remain HP is: {hp}</span></div>;
}
