import React, {Component} from 'react';
import {render} from 'react-dom';
import socket from './socket';

export default () => {
    let channel = socket.channel(`game:${window.room_name}`);
    return (<Game channel={channel} />);
}
