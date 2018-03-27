import React from 'react';
import Konva from 'konva';
import { Stage, Layer, Rect, Text } from 'react-konva';

export default ({steel, unit}) => {
  return (<Rect x={steel.x*unit} y={steel.y*unit} width={unit} height={unit} fill={"gray"} />);
}
