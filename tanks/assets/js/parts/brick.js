import React from 'react';
import Konva from 'konva';
import { Rect, Line, Group } from 'react-konva';

export default ({brick, unit}) => {

  let x = brick.x*unit, y = brick.y*unit,
      w = unit, h = unit;
  let strokeWidth = 2;
  return (
    <Group>
      <Rect x={x} y={y} width={w} height={h} fill={"red"} />
      <Line points={[x+w, y, x+strokeWidth/2, y, x+strokeWidth/2, y+h/2, x+w, y+h/2]} stroke="black" strokeWidth={strokeWidth} />
      <Line points={[x+w/2, y+h/2, x+w/2, y+h]} stroke="black" strokeWidth={strokeWidth} />
    </Group>
  );
}
