import React, {Component} from 'react';
import {render} from 'react-dom';
import socket from './socket';

export default class Chat extends Component {
  constructor(props){
    super(props);
    this.channel = props.channel;

    this.state = {
      messages: []
    };

    this.channelInit();

  }

  render(){
    let outter_container_style = {
      flexGrow: 1,
      position: "relative",
    }
    let container_style = {
      display: "flex",
      flexDirection: "column",
      border: "1px solid #ddd",
      boxShadow: "1px 3px 5px rgba(0,0,0,0.05)",
      borderRadius: "2px",
      position: "absolute",
      width: "100%",
      height: "100%",
    };
    let chat_window_style = {
      flexGrow: "1",
      background: "#f9f9f9",
      display: "flex",
      flexDirection: "column",
    };
    let input_style = {
      padding: "10px 20px",
      background: "#eee",
      border: 0,
      display: "block",
      background: "#fff",
      borderBottom: "1px solid #eee",
      fontFamily: "Nunito",
      fontSize: "16px",
    };
    let output_style = {
      overflow: "auto",
      flexGrow: 1,
      textAlign: "left",
      display: "flex",
      flexDirection: "column",

    };
    let header_style = {
      margin: "0.5rem 0",
    };
    let msg_style = {
      outter: {
        padding: "14px 0px",
        margin: "0 20px",
        borderBottom: "1px solid #e9e9e9",
        color: "#555",
      },
      inner: {
        color: "#575ed8",
      }
    };

    return (
      <div style={outter_container_style}>
        <div className="sidebar-chat" style={container_style}>
          <h5 className="text-center" style={header_style}>Chat Room</h5>
          <div className="chat-window" style={chat_window_style}>
            <div className="output" ref="output" style={output_style}>
              {
                this.state.messages.map((msg, index) => {
                  return <p style={msg_style.outter} key={index}>
                    <strong style={msg_style.inner}>{msg.sender_name}:</strong> {msg.msg_body}
                  </p>;
                })
              }
            </div>
            <div className="feedback" ref="feedback"></div>
          </div>
          <input type="text" placeholder="Message, Press Enter to send" className="message" style={input_style} onKeyPress={this.sendMessage.bind(this)} />
        </div>
      </div>
    );
  }

  channelInit() {
    this.channel.join()
      .receive("ok", data => {
        // console.log(this.state, "state");
        this.setState({messages: data.chat_history});
      })
      .receive("error", resp => { console.log("Unable to join chat", resp) });

    // received message
    this.channel.on("chat", ({name, message}) => {
      this.refs.feedback.innerHTML = '';
      this.refs.output.innerHTML += `<p style="padding: 14px 0px; margin: 0 20px; border-bottom: 1px solid #e9e9e9; color: #555;"><strong style="color: #575ed8;">${name}:</strong> ${message}</p>`;

      // auto-scroll to the bottom, so users see the latest message without scrolling.
      this.refs.output.scrollTo(0, this.refs.output.scrollHeight);
    });

    // typing indicator
    this.channel.on("typing", ({name}) => {
      this.refs.feedback.innerHTML = `<p style="color: #aaa; padding: 14px 0; margin: 0 20px;"><em>${name} is typing a message...</em></p>`;
      setTimeout(() => {this.refs.feedback.innerHTML = ''}, 2000);
    });
  }

  sendMessage(ev){
    // keypress only accepts character value, including 'Enter' as it is new line character.
    ev.stopPropagation();
    if (ev.target.value){

      if (ev.key == 'Enter'){
        let message = ev.target.value;
        this.channel.push("chat", {uid: window.user, message: message});
        // clear input field
        ev.target.value = "";
      } else {
        this.channel.push("typing", {uid: window.user});
      }
    }
  }

  componentDidUpdate() {
    // scroll to chat bottom after rendering
    this.refs.output.scrollTo(0, this.refs.output.scrollHeight);
  }
}
