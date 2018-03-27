import React, {Component} from 'react';
import socket from './socket';

export default class Game extends Component{
  constructor(props) {
    super(props);

    this.channel = props.channel;
    this.state = {
      tanks: [],
      missiles: [],
      bricks: [],
      steels: [],
    };

    this.channelInit();
  }

  componentWillMount(){
    this.animate();
  }

  render(){
    return <div>Game World</div>
  }

  // format game data as needed
  gotView({game}) {
    // console.log("got view: ", game);
    this.setState(game);
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
        this.setState(game);
        requestAnimationFrame(this.animate.bind(this));
      });
  }

  /***
  send fire and move actions
  */
  onKeyPress(e) {
    console.log(e);

  }
}
