import React, {Component} from 'react';
import {render} from 'react-dom';
import socket from './socket'

export default (root) => {
  let channel = socket.channel("list_rooms", {uid: window.user});
  render(<List channel={channel} />, root);
}

// List rooms as cards on home page
class List extends Component {
  constructor(props){
    super(props);
    this.channel = props.channel;
    this.state = {
      rooms: [],
      users_online: [],
    };

    this.channel.join()
        .receive("ok", (data) => {
          // console.log("join", data)
          this.setState({rooms: data.rooms});
        })
        // .receive("ok", (data) => this.state.rooms = data.rooms )
        .receive("error", resp => { console.log("Unable to join", resp) });
    this.channel.on("rooms_status_updated", (data) => {
      // console.log("rooms updated", data);
      let rooms;
      if (data.room.status == "deleted")
        rooms = this.state.rooms.filter( (r) => data.room.name != r.name );
      else {
        let exists = false;
        rooms = this.state.rooms.map( r => {
          if (r.name == data.room.name) {
            exists = true;
            return data.room;
          } else {
            return r;
          }
        });
        if (!exists)
        rooms.push(data.room);
      }

      this.setState({rooms: rooms});
    });

    this.channel.on("update_users_online", (data) => {
      // let users_online = Object.values(data.users_online);
      window.data = data;
      this.setState({users_online: data.users_online});
      console.log(data.users_online);
    });
  }

  colorHex(id) {
    let red = this.rgbToHex(id * 13);
    let green = this.rgbToHex(id * 17);
    let blue = this.rgbToHex(id * 113);

    return `#${red}${green}${blue}`;
  }

  rgbToHex(number) {
    let hex = Number(number%256).toString(16);
    if (hex.length < 2) {
      hex = "0" + hex;
    }
    return hex;
  }

  render() {
    // console.log("render", this.state.rooms);
    let style = {
      users_online_div: {
        position: "fixed",
        bottom: 0, left: 0, width: "100%",
        textAlign: "center",
      },
      users_online_list: {
        listStyle: "none", padding: 0,
      },
      users_online_list_item: {
        width: "25px", height: "25px", borderRadius: "50%", display: "inline-block", margin: "1px",
      },
    };


    return (
      <div>
        <div className='room-cards d-flex justify-content-center flex-wrap'>
          {this.state.rooms.map( (r) => <Room room={r} key={r.name} /> )}
        </div>

        <div id="users-online" style={style.users_online_div}>
          <ul style={style.users_online_list}>
            {this.state.users_online.map( (user) => <li key={user.id} style={Object.assign({}, style.users_online_list_item, {background: this.colorHex(user.id)})} data-toggle="tooltip" title={user.name}></li>)}
          </ul>
        </div>
      </div>
    );
  }
}

function Room({room}) {
  // console.log("props", room);
  let join_button = '', observe_button = '';
  observe_button = <a href={room_url.replace('placeholder', room.name)} className='btn btn-block btn-info btn-small btn-observe'>Observe</a>;
  if (room.status == "open") {
    join_button = <a href={room_url.replace('placeholder', room.name)+"?join=true"} className='btn btn-block btn-success btn-small btn-join'>Join</a>;
  }

  return (
    <div className={`room-card status-${room.status} align-self-stretch p-3`}>
      <h2 className="room-status">{room.status}</h2>
      <h3 className="room-name">{room.name}</h3>
      {join_button}
      {observe_button}
    </div>
  );
}
