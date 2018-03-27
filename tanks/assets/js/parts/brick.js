import React from 'react';
import Konva from 'konva';
import { Stage, Layer, Rect, Text } from 'react-konva';

export default ({brick, unit}) => {
  return (<Rect x={brick.x*unit} y={brick.y*unit} width={unit} height={unit} fill={"red"} />);
}
