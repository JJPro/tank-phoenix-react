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

  render(){
    return <div>Game World</div>
  }

  gotView({game}) {
    console.log("got view: ", game);
    this.setState(game);
  }

  channelInit() {
    this.channel.join()
        .receive("ok", this.gotView.bind(this))
        .receive("error", resp => { console.error("Unable to join", resp) });

    this.channel.on("update", game => this.gotView(game) );
  }

  /***
  send fire and move actions
  */
  onKeyPress(e) {
    console.log(e);

  }
}
