import React, {Component} from 'react';
import {render} from 'react-dom';

export default (root) => render(<Input />, root);

const STATUS_FULL = "full",
      STATUS_INBATTLE = "in battle",
      STATUS_OPEN = "open",
      STATUS_NOT_EXIST = "";

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
          console.log(json.data);
          this.setState({room_status: json.data.room_status});
        });
    }


  }

  joinGame() {

  }

  observeGame() {

  }

  createGame() {

  }

  render() {
    let buttons;

    if (this.state.term.trim() == "") buttons = '';
    else if (this.state.room_status == STATUS_FULL || this.state.room_status == STATUS_INBATTLE) {
      buttons = <div className="input-group-append">
                  <button className="btn btn-outline-secondary" type="button" onClick={this.observeGame.bind(this)}>Observe</button>
                </div>;
    } else if (this.state.room_status == STATUS_OPEN) {
      buttons = <div className="input-group-append">
                  <button className="btn btn-outline-secondary" type="button" onClick={this.joinGame.bind(this)}>Join</button>
                  <button className="btn btn-outline-secondary" type="button" onClick={this.observeGame.bind(this)}>Observe</button>
                </div>;
    } else {
      buttons = <div className="input-group-append">
                  <button className="btn btn-outline-secondary" type="button" onClick={this.createGame.bind(this)}>Create</button>
                </div>;
    }

    return (
        <div className="input-group">
          <input type="text" className="form-control" placeholder="Create A Room" aria-label="Create A Room" aria-describedby="basic-addon2" onChange={this.onChangeTerm.bind(this)} ref="input" />
          {buttons}
        </div>
    );
  }
}
