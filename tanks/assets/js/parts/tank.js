import React, { Component } from 'react';
import Konva from 'konva';
import { Image } from 'react-konva';

export default class Tank extends Component{
  constructor(props){
    super(props);
    this.state = {image: null}
  }

  componentDidMount(){
    console.log({thumbnail: this.props.tank.player.tank_thumbnail});
    let image = new window.Image();
    image.src = this.props.tank.player.tank_thumbnail;
    image.onload = () => {
      this.setState({image: image})
    }
  }
  render(){
    let x = this.props.tank.x,
        y = this.props.tank.y,
        width = this.props.tank.width,
        height = this.props.tank.height,
        unit = this.props.unit;
    return (<Image image={this.state.image} width={width*unit} height={height*unit} />);
  }
// ({tank, unit}) => {
//   console.log(tank, unit);
//   // console.log(`"${tank.player.tank_thumbnail}"`);
//   console.log(Image);
//
//   let imageObj = new window.Image();
//   imageObj.src = "/images/tank-cyan.png";
//   return (<Image image="/images/tank-cyan.png" x={tank.x*unit} y={tank.y*unit} width={tank.width*unit} height={tank.height*unit} />);
}
