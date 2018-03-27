import React from 'react';
import Konva from 'konva';
import { Stage, Layer, Rect, Text } from 'react-konva';

export default ({tank, unit}) => {
  console.log(tank, unit);
  return (<Rect x={tank.x*unit} y={tank.y*unit} width={tank.width*unit} height={tank.width*unit} stroke={"blue"} />);
}
