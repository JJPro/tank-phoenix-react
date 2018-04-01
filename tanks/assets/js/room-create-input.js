import React, {Component} from 'react';
import {render} from 'react-dom';

export default (root) => render(<Input />, root);

const STATUS_FULL = "full",
      STATUS_PLAYING = "playing",
      STATUS_OPEN = "open",
      STATUS_NOT_EXIST = null;

class Input extends Component {
  constructor(props) {
    super(props);

    this.state = {
      term: "",
      room_status: STATUS_NOT_EXIST,
    }
  }


  onChangeTerm() {
    let term = this.refs.input.value;
    this.setState({term: term})

    // ajax call
    if (term.trim() != ""){

      let url = window.api_game_url.replace('placeholder', term);
      fetch(url)
        .then((resp) => resp.json())
        .then((json) => {
          // console.log(json.data);
          this.setState({room_status: json.data.room_status});
        }
      );
    }
  }

  onKeyDown(ev) {
    if (ev.key == 'Enter'){
      if (this.state.room_status == STATUS_NOT_EXIST){
        window.location = window.room_url.replace('placeholder', this.state.term.trim() + "?create=true" );
      }
    }
  }

  render() {
    let buttons;

    if (this.state.term.trim() == "") buttons = '';
    else if (this.state.room_status == STATUS_FULL || this.state.room_status == STATUS_PLAYING) {
      buttons = <div className="input-group-append">
                  <a className="btn btn-outline-info" href={window.room_url.replace('placeholder', this.state.term.trim() )}>Observe</a>
                </div>;
    } else if (this.state.room_status == STATUS_OPEN) {
      buttons = <div className="input-group-append">
                  <a className="btn btn-outline-success" href={window.room_url.replace('placeholder', this.state.term.trim() + "?join=true" )}>Join</a>
                  <a className="btn btn-outline-info" href={window.room_url.replace('placeholder', this.state.term.trim() )}>Observe</a>
                </div>;
    } else {
      buttons = <div className="input-group-append">
                  <a className="btn btn-outline-primary" href={window.room_url.replace('placeholder', this.state.term.trim() + "?create=true" )}>Create</a>
                </div>;
    }

    return (
        <div className="input-group">
          <input type="text" className="form-control" placeholder="Create A Room" aria-label="Create A Room" aria-describedby="basic-addon2" onChange={this.onChangeTerm.bind(this)} onKeyPress={this.onKeyDown.bind(this)} ref="input" />
          {buttons}
        </div>
    );
  }
}
