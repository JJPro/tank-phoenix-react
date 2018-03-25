import React, {Component} from 'react';
import {render} from 'react-dom';
import socket from './socket'

export default (root) => {
  let channel = socket.channel("list_rooms", {});
  render(<List channel={channel} />, root);
}

// List rooms as cards on home page
class List extends Component {
  constructor(props){
    super(props);
    this.channel = props.channel;
    this.state = {
      rooms: [],
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
  }

  render() {
    // console.log("render", this.state.rooms);
    return (
      <div className='room-cards d-flex justify-content-center flex-wrap'>
        {this.state.rooms.map( (r) => <Room room={r} key={r.name} /> )}
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
