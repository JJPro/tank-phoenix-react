import React from 'react';
import Konva from 'konva';
import { Stage, Layer, Rect, Text } from 'react-konva';

export default ({missile, unit}) => {
  let x = missile.x*unit, y = missile.y*unit,
      w = missile.width*unit, h = missile.height*unit;
  if (missile.direction == "left" || missile.direction == "right"){
    let temp = h;
    h = w;
    w = temp;
  }
  return (<Rect x={x-w/2} y={y-h/2} width={w} height={h} fill={"black"} />);
}
