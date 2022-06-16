// toio mat Unit => 1260mm = 912, 1188mm = 862
//  420mm = 304, 558mm = 410
// 1:0.7238 | 1.3815:1
// toio width: 31.8mm : 23 | height 26mm : 18.8
// UnderStage Height: 103.5mm: 75



int stageWidthMax = 912;
int stageDepthMax = 862;

// Size of Stage Width, Stage Depth
int stageWidth = MAT_WIDTH;
int stageDepth = MAT_HEIGHT;


color MainStageColor =  color(200, 230);


void display3D() {
  pushMatrix();
  rotateX(radians(45));

  drawMainStage();

  pushMatrix();
  translate(-stageWidth/2, -stageDepth/2, 2);

  drawAxis();
  
  int target3d_x = 100, target3d_y = 200, target3d_z = 100; 
  drawTarget3D(target3d_x, target3d_y, target3d_z);
  

  //render All toio
  for (int i = 0; i< nCubes; i++) {
    renderToio(i);
  }


  popMatrix();

  popMatrix();
}

void drawTarget3D(int x, int y, int z){
  pushMatrix();
  translate(x,y,z);
  
  fill(255,0,0);
  noStroke();
  sphere(10);
  
  textSize(12);
  rotateX(radians(90));
  text("3D target[" + x + ", " + y + ", " + z + "]", 15,0);
  popMatrix();
}

void debugFor3DView() {

  fill(255);
  textSize(20);
  text("Hold 'SPACE' + Drag to Rotate the 3D Model \nHold 'd' to remove the debug view.", 20, 30);
  display2D();
}


void drawMainStage() {
  noStroke();
  fill(MainStageColor);

  PShape s = createShape();
  s.beginShape();

  // Exterior part of shape
  s.vertex(-stageWidth/2, -stageDepth/2);
  s.vertex(stageWidth/2, -stageDepth/2);
  s.vertex(stageWidth/2, stageDepth/2);
  s.vertex(-stageWidth/2, stageDepth/2);
  s.vertex(-stageWidth/2, -stageDepth/2);

  // Finishing off shape
  s.endShape();

  shape(s);

  pushMatrix();
  translate(-stageWidth/2, -stageDepth/2, 2);
  stroke(255, 30);
  for (int i = 0; i < 3; i++) {
    line(stageWidthMax/3 * (i+1), 0, stageWidthMax/3 * (i+1), stageDepthMax);
  }
  for (int i = 0; i < 4; i++) {
    line(stageWidthMax, stageDepthMax/4 * (i+1), 0, stageDepthMax/4 * (i+1));
  }

  fill(255, 20);

  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 4; j++) {
      int matID = 1 + (j) + i*4;
      text("#" + matID, stageWidthMax/3 * (i), stageDepthMax/4 * (j)+50);
    }
  }


  popMatrix();
}

void drawAxis() {
  strokeWeight(2);
  stroke(255, 0, 0);
  line(0, 0, 0, 1000, 0, 0);
  stroke(0, 255, 0);
  line(0, 0, 0, 0, 1000, 0);
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 1000);
}


void renderToio(int toioID) {

  int x = cubes[toioID].x, y = cubes[toioID].y, deg = cubes[toioID].deg;
  pushMatrix();
  if (cubes[toioID].isLost) {
    stroke(200, 50);
  } else {
    stroke(200);
  }

  strokeWeight(1);

  fill(255);
  translate(x, y, 10);
  rotate(radians(deg));
  box(23, 23, 19);
  stroke(255, 0, 0);
  strokeWeight(2);
  line(13, 0, 10, 5, 0, 10);
  popMatrix();
}
