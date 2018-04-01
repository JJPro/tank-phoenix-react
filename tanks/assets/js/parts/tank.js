import React, { Component } from 'react';
import Konva from 'konva';
import { Image, Rect } from 'react-konva';

export default class Tank extends Component{
  constructor(props){
    super(props);
    this.state = {image: null, x:0, y:0, w:0, h:0, orientation:""}
  }

  componentDidMount(){
    let image = new window.Image();
    image.src = this.props.tank.player.tank_thumbnail;
    // let orientation = this.props.tank.orientation;
    image.onload = () => {
      this.setState({
        image: image,
        x: this.props.tank.x * this.props.unit,
        y: this.props.tank.y * this.props.unit,
        w: this.props.tank.width * this.props.unit,
        h: this.props.tank.height * this.props.unit,
        orientation: this.props.tank.orientation,
      });
    }
  }

  componentWillReceiveProps(new_props) {
    if (this.props != new_props){
      this.setState({
        x: new_props.tank.x * new_props.unit,
        y: new_props.tank.y * new_props.unit,
        orientation: new_props.tank.orientation,
      });
    }
  }
  render(){
    let x = this.state.x,
        y = this.state.y,
        w = this.state.w,
        h = this.state.h;
    let rotation = 0;
    switch (this.state.orientation) {
      case "up":
        rotation = 0;
        break;
      case "right":
        rotation = 90;
        x += w;
        break;
      case "down":
        rotation = 180;
        x += w;
        y += h;
        break;
      case "left":
        rotation = -90;
        y += h;
        break;
    }
    return (<Image image={this.state.image} width={w} height={h} x={x} y={y} rotation={rotation} />);
  }
}
