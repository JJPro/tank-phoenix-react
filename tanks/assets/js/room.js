import React, {Component} from 'react';
import {render} from 'react-dom';
import socket from './socket';
import Game from './game';
import Chat from './chat';


export default (root) => {

  if (is_request_valid()){ // verify that room exists or is creating the room.

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
    window.channel = this.channel; // attach to window for testing
    this.state = {
      name: "",
      players: [],
      is_playing: false,
    };

    /**
    Player is : {name, id, is_owner, is_ready, tank_thumbnail}
    */

    this.channelInit();
  }

  gotView({room}) {
    window.room = room; // attach to window for testing
    // console.log(room.players);
    this.setState(room)
  }

  // Check room status,
  //    if playing -> render game,
  //    otherwise, render room.
  render(){
    if (this.state.is_playing){
      return (<Game channel={socket.channel(`game:${this.state.name}`, {uid: window.user})} players={this.state.players}/>);
    } else {

      let {name, players} = this.state;
      let button_start = '';
      let button_ready_cancel = '';
      let button_leave = '';
      let button_join = '';

      // test whether current user is a player or observer
      // only show button options to players
      let current_player = players.find( p => p.id == window.user);
      let owner = players.find( p => p.is_owner );
      if ( current_player ){
        button_ready_cancel =
        current_player.is_ready
        ?<button className="btn btn-outline-danger btn-lg btn-ready m-3" onClick={this.onCancel.bind(this)}>Cancel</button>
        :<button className="btn btn-outline-success btn-lg btn-ready m-3" onClick={this.onReady.bind(this)}>Ready</button>;

        let disable_start = players.length < 2 || players.some( p => !p.is_ready );
        if (current_player.is_owner)
        button_start = <button className="btn btn-info btn-lg btn-start m-3"  onClick={this.onStart.bind(this)} disabled={disable_start}>Start</button>;
      }
      if (!current_player && players.length < 4)
        button_join = <button className="btn btn-success btn-lg btn-join m-3" onClick={this.onObserverJoin.bind(this)}>Join</button>;

      button_leave = <button className="btn btn-outline-warning btn-lg btn-leave m-3" onClick={this.onLeave.bind(this)}>Leave</button>;

      let chat_container_style = {
        width: "250px",
        display: "flex",
      }

      return (
        <div className="text-center p-3">
          <h1>Room: {name}</h1>
          <div className="d-flex flex-row">
            <div className="players-container col">
              <div className="players d-flex justify-content-center flex-wrap">
                {players.map( (p, index) => <Player player={p} owner={owner} key={index} index={index} onKickout={this.onKickout.bind(this)} /> )}
              </div>
              <div className="d-flex justify-content-center flex-wrap p-3">
                {button_join}
                {button_ready_cancel}
                {button_start}
                {button_leave}
              </div>
            </div>
            <div className="chat-container" style={chat_container_style}>
              <Chat channel={socket.channel(`chat:${window.room_name}`)}/>
            </div>
          </div>
        </div>
      );
    }
  }

  channelInit(){
    this.channel.join()
        .receive("ok", this.gotView.bind(this) )
        .receive("error", resp => { console.log("Unable to join room channel", resp) });

    if ( window.location.search.includes('join') ){
      this.channel.push("enter", {uid: window.user})
        .receive("ok", resp => {
          console.log("join success:", resp);
        })
        .receive("error", ({reason}) => {
          console.log("enter error:", reason);
          alert("Unable to Join: " + reason);

        }
      );

    }

    this.channel.on("update_room", data => {
      // console.log("update room", data);
      // console.log("room playing?", room.is_playing);

      this.gotView(data);
    });

    // handle game start message
    // this is a good chance to do stuff before game start, ex. game start animations
    this.channel.on("gamestart", () => {
      // block all key actions
      let blockKeyPress = (e) => {
        e.preventDefault();
        e.stopPropagation();
      };
      // build basic elements for countdown animations
      let countdown = $('<div id="active" tabindex="0" style="position: fixed; top: 0; font-size: 20em; width: 100vw; height: 100vh; background: rgba(255,255,255,.7); display: flex; flex-direction: column; align-items: center;justify-content: center;"></div>');
      countdown.appendTo('body');
      document.getElementById("active").addEventListener("keydown", blockKeyPress);

      // animate countdown process with promises
      const wait = ms => new Promise((resolve) => setTimeout(resolve, ms));
      async function countdown_fn(n) {
        while(n > 0){
          countdown.html(n);
          // n--
          n = await wait(1000).then(() => n-1);
        }
        countdown.remove();
      }

      countdown_fn(5);
    });

    this.channel.on("all_exit_room", () => {
      setTimeout(() => window.location = "/", 700 );
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

  onObserverJoin(){
    this.channel.push("enter", {uid: window.user});
  }
}

function Player({player, owner, onKickout, index}){
  let owner_class = player.is_owner ? "room-owner" : '';
  let name = player.id == window.user ? "YOU" : player.name;
  let kickout_button = (window.user == owner.id && player.id != owner.id)
                        ? <button className="btn btn-outline-danger" onClick={() => onKickout(player.id)}>kickout</button>
                        : '';

  let card_style = {
    borderRadius: 10,
    padding: 10,
    marginBottom: 20,
    border: 'gray solid 0.5px',
    flexGrow: 1,
  };
  if (player.is_owner) {
    // card_wrapper_style.border = "5px solid green";
    card_style.boxShadow = '0 0 15px 5px #5fff45, 0 0 2px 1px #5fff45 inset';

  }

  let ready_box_style = {
    width: "100px",
    height: "100px",
  };
  if (player.is_ready) {
    ready_box_style.background = 'url("/images/ready.png") no-repeat center/100%';
  }

  let tank_thumbnail_style = {
    width: 50,
    height: 50,
    backgroundRepeat: 'no-repeat',
    backgroundPosition: 'center',
    backgroundSize: 'contain',
    display: 'inline-block',
  };
  tank_thumbnail_style.backgroundImage = `url(${player.tank_thumbnail})`;

  return (
    <div className="player-card-wrapper align-self-stretch p-3 text-center d-flex flex-column align-items-center">
      <div className={`player-card ${owner_class} text-center d-flex flex-column align-items-center`} style={card_style}>
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
