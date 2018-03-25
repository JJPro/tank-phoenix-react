import React, {Component} from 'react';
import {render} from 'react-dom';
import socket from './socket'


export default (root) => {

  if (is_request_valid()){

    let channel = socket.channel(`room:${window.room_name}`, {uid: window.user});
    render(<Room channel={channel} />, root);
  } else {
    alert("invalid request");
  }

}

class Room extends Component {
  constructor(props) {
    super(props);

    this.channel = props.channel;
    window.channel = this.channel; // TODO: attach to window for testing
    this.state = {
      name: "",
      players: [],

    };

    this.channelInit();
  }

  gotView({room}) {
    // console.log("gotView", data.room);
    this.setState({
      name: room.name,
      players: room.players,
    });
  }

  render(){
    let {name, players} = this.state;
    let button_start = '';
    let button_ready_cancel = '';
    let button_leave = '';

    // test whether current user is a player or observer
    // only show button options to players
    let current_player = players.find( p => p.id == window.user);
    let owner = players.find( p => p.is_owner );
    if ( current_player ){
      button_ready_cancel =
          current_player.is_ready
          ?<button className="btn btn-outline-danger btn-lg btn-ready m-3" onClick={this.onCancel.bind(this)}>Cancel</button>
          :<button className="btn btn-outline-success btn-lg btn-ready m-3" onClick={this.onReady.bind(this)}>Ready</button>;

      button_leave = <button className="btn btn-outline-warning btn-lg btn-leave m-3" onClick={this.onLeave.bind(this)}>Leave</button>;

      let disable_start = players.length < 2 || players.some( p => !p.is_ready );
      if (current_player.is_owner)
        button_start = <button className="btn btn-info btn-lg btn-start m-3"  onClick={this.onStart.bind(this)} disabled={disable_start}>Start</button>;
    }

    return (
      <div className="text-center p-3">
        <h1>Room: {name}</h1>
        <div className="players d-flex justify-content-center flex-wrap">
          {players.map( (p, index) => <Player player={p} owner={owner} key={p.id} index={index} onKickout={this.onKickout.bind(this)} /> )}
        </div>
        <div className="d-flex justify-content-center flex-wrap p-3">
          {button_ready_cancel}
          {button_start}
          {button_leave}
        </div>
      </div>
    );
  }

  channelInit(){
    this.channel.join()
        .receive("ok", this.gotView.bind(this) )
        .receive("error", resp => { console.log("Unable to join", resp) });

    if ( window.location.search.includes('join') ){
      this.channel.push("enter", {uid: window.user})
          .receive("ok", resp => {
            console.log("join success:", resp);
          })
          .receive("error", ({reason}) => {
            console.log("enter error:", reason);
            alert("Unable to Join: " + reason);

          });
    }

    this.channel.on("update_room", data => {
      console.log("update room", data);
      this.gotView(data);
    });
  }

  onReady(){
    this.channel.push("ready", {uid: window.user});
  }

  onCancel(){
    this.channel.push("cancel", {uid: window.user});
  }

  onLeave(){
    this.channel.push("leave", {uid: window.user});
    window.location = "/";
  }

  onStart(){
    this.channel.push("start")
        .receive("error", ({reason}) => {
          alert(reason);
        });
  }

  onKickout(player_id){
    this.channel.push("kickout", {uid: player_id});
  }
}

function Player({player, owner, onKickout, index}){
  let owner_class = player.is_owner ? "room-owner" : '';
  let name = player.id == window.user ? "YOU" : player.name;
  let kickout_button = (window.user == owner.id && player.id != owner.id)
                        ? <button className="btn btn-outline-danger" onClick={onKickout(player.id)}></button>
                        : '';
  let tank_thumbnails = ['url("/images/tank-cyan.png")',
                         'url("/images/tank-red.png")',
                         'url("/images/tank-army-green.png")',
                         'url("/images/tank-yellow.png")',
                         'url("/images/tank-khaki.png")',
                         'url("/images/tank-green.png")',
                         'url("/images/tank-magenta.png")',
                         'url("/images/tank-purple.png")',];

  let card_style = {
    borderRadius: 10,
    padding: 10,
    marginBottom: 20,
    border: 'gray solid 0.5px',
  };
  if (player.is_owner) {
    // card_wrapper_style.border = "5px solid green";
    card_style.boxShadow = '0 0 15px 5px #5fff45, 0 0 2px 1px #5fff45 inset';

  }

  let ready_box_style = {
    width: 150,
    height: 150,
  };
  if (player.is_ready) {
    ready_box_style.background = 'url("/images/ready.png") no-repeat center/70%';
  }

  let tank_thumbnail_style = {
    width: 50,
    height: 50,
    backgroundRepeat: 'no-repeat',
    backgroundPosition: 'center',
    backgroundSize: 'contain',
    display: 'inline-block',
  };

  tank_thumbnail_style.backgroundImage = tank_thumbnails[index];

  return (
    <div className="player-card-wrapper align-self-stretch p-3 text-center">
      <div className={`player-card ${owner_class} text-center`} style={card_style}>
        <h2>{name}</h2>
        <div className="ready-box" style={ready_box_style}></div>
        {kickout_button}
      </div>
      <div className="tank-thumbnail" style={tank_thumbnail_style}></div>
    </div>
  );
}


function is_request_valid(){
  let is_create_request;
  is_create_request = window.location.search.includes('create');
  return window.room_exists || is_create_request;
}
