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
          console.log("join", data)
          this.setState({rooms: data.rooms});
        })
        // .receive("ok", (data) => this.state.rooms = data.rooms )
        .receive("error", resp => { console.log("Unable to join", resp) });
  }

  componentDidMount(){
    // TODO: should I put this in constructor?
    this.channel.on("rooms_status_updated", (data) => {
      console.log("rooms updated", data);
      // this.setState({rooms: data.rooms});
    });

    // test cross socket communication
    this.channel.on("update_room", (data) => {
      console.log('room updated', data);
    });
  }

  render() {
    console.log("render", this.state.rooms);
    return (
      <div className='room-cards'>
        {this.state.rooms.map( (r) => <Room room={r} key={r.name} /> )}
      </div>
    );
  }
}

function Room(props) {
  // console.log("props", props);
  let join_button = '', observe_button = '';
  observe_button = <a href='' className='btn btn-observe'>Observe</a>;
  if (props.room.status == "open") {
    join_button = <a href='' className='btn btn-join'>Join</a>;
  }
  return (
    <div className="room-card status-{props.status}">
      <h2 className="room-status">{props.room.status}</h2>
      <h3 className="room-name">{props.room.name}</h3>
      {join_button}
      {observe_button}
    </div>
  );
}
