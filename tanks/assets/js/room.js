import React, {Component} from 'react';
import {render} from 'react-dom';
import socket from './socket'


export default (root) => {
  let channel = socket.channel(`room:${room_name}`, {uid: window.user});
  render(<Room channel={channel} />, root);
}

class Room extends Component {
  constructor(props) {
    super(props);

    this.channel = props.channel;
    window.channel = this.channel;
    this.state = {
      name: "",
      players: [],

    };

    this.channel.join()
        // .receive("ok", data => {console.log(data);})
        .receive("ok", this.gotView.bind(this) )
        .receive("error", resp => { console.log("Unable to join", resp) });
  }

  gotView(data) {
    console.log(data);

    this.setState({
      name: data.name,
      players: data.players,
    });
  }

  render(){
    return (
      <div></div>
    );
  }
}
