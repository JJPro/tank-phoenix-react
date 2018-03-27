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
    this.state = {
      canvas: {},
      tanks: [],
      missiles: [],
      bricks: [],
      steels: [],
    };

    this.testData();

    // this.channelInit();
  }

  componentWillMount(){
    // this.animate();
  }

  render(){
    // {canvas, tanks, missiles, bricks, steels} = this.state;
    let canvas = this.state.canvas,
        tanks = this.state.tanks,
        missiles = this.state.missiles,
        bricks = this.state.bricks,
        steels = this.state.steels;

    let unit = 26;
    let style = {
      border: "1px solid red",
      width: canvas.width * unit,
      height: canvas.height * unit,
    };

    return (
      <Stage width={canvas.width * unit} height={canvas.height * unit} style={style}>
        <Layer>
          {tanks.map( t => <Tank tank={t} unit={unit} key={t.player.id} />)}
          {bricks.map( (b,i) => <Brick brick={b} unit={unit} key={i} />)}
          {steels.map( (s,i) => <Steel steel={s} unit={unit} key={i} />)}
          {missiles.map( (m,i) => <Missile missile={m} unit={unit} key={i} />)}
        </Layer>
      </Stage>
    );
  }

  // format game data as needed
  gotView(game) {
    // console.log("got view: ", game);
    // console.log(JSON.stringify(game));

    this.setState();
  }

  channelInit() {
    this.channel.join()
        .receive("ok", this.gotView.bind(this))
        .receive("error", resp => { console.error("Unable to join", resp) });

    this.channel.on("update", game => this.gotView(game) );
  }

  animate() {
    this.channel.push("get_state")
      .receive("ok", game => {
        this.gotView(game);
        requestAnimationFrame(this.animate.bind(this));
      });
  }

  /***
  send fire and move actions
  */
  onKeyDown({key}) {
    // console.log(key);

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
      case "Enter":
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
      this.channel.push("move", {uid: window.user, direction: direction})
          .receive("ok", this.gotView.bind(this));
    }
    if (fire){
      this.channel.push("fire", {uid: window.user})
          .receive("ok", this.gotView.bind(this));
    }
  }

  testData(){

    let data = {"tanks":[{"y":0,"x":0,"width":2,"player":{"tank_thumbnail":"/images/tank-red.png","name":"Lu Ji","is_ready":true,"is_owner":false,"id":2},"orientation":"down","hp":4,"height":2},{"y":24,"x":24,"width":2,"player":{"tank_thumbnail":"/images/tank-cyan.png","name":"Joyce","is_ready":true,"is_owner":true,"id":3},"orientation":"up","hp":4,"height":2}],"steels":[{"y":12,"x":0},{"y":12,"x":1},{"y":12,"x":12},{"y":13,"x":12},{"y":24,"x":12},{"y":25,"x":12},{"y":0,"x":13},{"y":1,"x":13},{"y":12,"x":13},{"y":13,"x":13},{"y":12,"x":24},{"y":12,"x":25}],"missiles":[],"destroyed_tanks_last_frame":[],"canvas":{"width":26,"height":26},"bricks":[{"y":8,"x":0},{"y":9,"x":0},{"y":16,"x":0},{"y":17,"x":0},{"y":8,"x":1},{"y":9,"x":1},{"y":16,"x":1},{"y":17,"x":1},{"y":2,"x":2},{"y":3,"x":2},{"y":4,"x":2},{"y":5,"x":2},{"y":8,"x":2},{"y":9,"x":2},{"y":16,"x":2},{"y":17,"x":2},{"y":20,"x":2},{"y":21,"x":2},{"y":22,"x":2},{"y":23,"x":2},{"y":2,"x":3},{"y":3,"x":3},{"y":4,"x":3},{"y":5,"x":3},{"y":8,"x":3},{"y":9,"x":3},{"y":16,"x":3},{"y":17,"x":3},{"y":20,"x":3},{"y":21,"x":3},{"y":22,"x":3},{"y":23,"x":3},{"y":2,"x":4},{"y":3,"x":4},{"y":8,"x":4},{"y":9,"x":4},{"y":12,"x":4},{"y":13,"x":4},{"y":16,"x":4},{"y":17,"x":4},{"y":22,"x":4},{"y":23,"x":4},{"y":2,"x":5},{"y":3,"x":5},{"y":8,"x":5},{"y":9,"x":5},{"y":12,"x":5},{"y":13,"x":5},{"y":16,"x":5},{"y":17,"x":5},{"y":22,"x":5},{"y":23,"x":5},{"y":2,"x":6},{"y":3,"x":6},{"y":6,"x":6},{"y":7,"x":6},{"y":8,"x":6},{"y":9,"x":6},{"y":12,"x":6},{"y":13,"x":6},{"y":16,"x":6},{"y":17,"x":6},{"y":18,"x":6},{"y":19,"x":6},{"y":22,"x":6},{"y":23,"x":6},{"y":2,"x":7},{"y":3,"x":7},{"y":6,"x":7},{"y":7,"x":7},{"y":8,"x":7},{"y":9,"x":7},{"y":12,"x":7},{"y":13,"x":7},{"y":16,"x":7},{"y":17,"x":7},{"y":18,"x":7},{"y":19,"x":7},{"y":22,"x":7},{"y":23,"x":7},{"y":12,"x":8},{"y":13,"x":8},{"y":12,"x":9},{"y":13,"x":9},{"y":4,"x":10},{"y":5,"x":10},{"y":8,"x":10},{"y":9,"x":10},{"y":10,"x":10},{"y":11,"x":10},{"y":12,"x":10},{"y":13,"x":10},{"y":14,"x":10},{"y":15,"x":10},{"y":16,"x":10},{"y":17,"x":10},{"y":20,"x":10},{"y":21,"x":10},{"y":4,"x":11},{"y":5,"x":11},{"y":8,"x":11},{"y":9,"x":11},{"y":10,"x":11},{"y":11,"x":11},{"y":12,"x":11},{"y":13,"x":11},{"y":14,"x":11},{"y":15,"x":11},{"y":16,"x":11},{"y":17,"x":11},{"y":20,"x":11},{"y":21,"x":11},{"y":2,"x":12},{"y":3,"x":12},{"y":4,"x":12},{"y":5,"x":12},{"y":20,"x":12},{"y":21,"x":12},{"y":22,"x":12},{"y":23,"x":12},{"y":2,"x":13},{"y":3,"x":13},{"y":4,"x":13},{"y":5,"x":13},{"y":20,"x":13},{"y":21,"x":13},{"y":22,"x":13},{"y":23,"x":13},{"y":4,"x":14},{"y":5,"x":14},{"y":8,"x":14},{"y":9,"x":14},{"y":10,"x":14},{"y":11,"x":14},{"y":12,"x":14},{"y":13,"x":14},{"y":14,"x":14},{"y":15,"x":14},{"y":16,"x":14},{"y":17,"x":14},{"y":20,"x":14},{"y":21,"x":14},{"y":4,"x":15},{"y":5,"x":15},{"y":8,"x":15},{"y":9,"x":15},{"y":10,"x":15},{"y":11,"x":15},{"y":12,"x":15},{"y":13,"x":15},{"y":14,"x":15},{"y":15,"x":15},{"y":16,"x":15},{"y":17,"x":15},{"y":20,"x":15},{"y":21,"x":15},{"y":12,"x":16},{"y":13,"x":16},{"y":12,"x":17},{"y":13,"x":17},{"y":2,"x":18},{"y":3,"x":18},{"y":6,"x":18},{"y":7,"x":18},{"y":8,"x":18},{"y":9,"x":18},{"y":12,"x":18},{"y":13,"x":18},{"y":16,"x":18},{"y":17,"x":18},{"y":18,"x":18},{"y":19,"x":18},{"y":22,"x":18},{"y":23,"x":18},{"y":2,"x":19},{"y":3,"x":19},{"y":6,"x":19},{"y":7,"x":19},{"y":8,"x":19},{"y":9,"x":19},{"y":12,"x":19},{"y":13,"x":19},{"y":16,"x":19},{"y":17,"x":19},{"y":18,"x":19},{"y":19,"x":19},{"y":22,"x":19},{"y":23,"x":19},{"y":2,"x":20},{"y":3,"x":20},{"y":8,"x":20},{"y":9,"x":20},{"y":12,"x":20},{"y":13,"x":20},{"y":16,"x":20},{"y":17,"x":20},{"y":22,"x":20},{"y":23,"x":20},{"y":2,"x":21},{"y":3,"x":21},{"y":8,"x":21},{"y":9,"x":21},{"y":12,"x":21},{"y":13,"x":21},{"y":16,"x":21},{"y":17,"x":21},{"y":22,"x":21},{"y":23,"x":21},{"y":2,"x":22},{"y":3,"x":22},{"y":4,"x":22},{"y":5,"x":22},{"y":8,"x":22},{"y":9,"x":22},{"y":16,"x":22},{"y":17,"x":22},{"y":20,"x":22},{"y":21,"x":22},{"y":22,"x":22},{"y":23,"x":22},{"y":2,"x":23},{"y":3,"x":23},{"y":4,"x":23},{"y":5,"x":23},{"y":8,"x":23},{"y":9,"x":23},{"y":16,"x":23},{"y":17,"x":23},{"y":20,"x":23},{"y":21,"x":23},{"y":22,"x":23},{"y":23,"x":23},{"y":8,"x":24},{"y":9,"x":24},{"y":16,"x":24},{"y":17,"x":24},{"y":8,"x":25},{"y":9,"x":25},{"y":16,"x":25},{"y":17,"x":25}]};
    this.state = data;
    console.log(data);
  }
}
