import React from 'react';
import Konva from 'konva';
import { Stage, Layer, Rect, Text } from 'react-konva';

export default ({missile, unit}) => {
  return (<Rect x={missile.x*unit} y={missile.y*unit} width={missile.width * unit} height={missile.height * unit} fill={"gray"} />);
}
