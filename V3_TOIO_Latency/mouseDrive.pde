boolean mouseDrive = false;

void mouseDrive_() {
  float mx = (mouseX);
  float my = (mouseY);
  float cx = total_MAT_WIDTH/2;
  float cy = total_MAT_HEIGHT/2;

 // float cx = 300;
 // float cy = 530;


  float mulr = 230;

  textSize(14);
  fill(255, 0, 0);
  text("mouseDrive Mode enabled", 20, 20);

  float aMouse = atan2( my-cy, mx-cx);
  float r = sqrt ( (mx - cx)*(mx-cx) + (my-cy)*(my-cy));
  r = min(mulr, r);
  for (int i = 0; i< nCubes; i++) {
    if (cubes[i].isLost==false) {
      float angle = TWO_PI*i/nCubes;
      float na = aMouse+angle;
      float tax = cx + r*cos(na);
      float tay = cy + r*sin(na);

      pushMatrix();
      translate(tax, tay);
      //stroke(255);
      //fill(255, 0, 0);
      //ellipse(0, 0, 10, 10);

      cubes[i].targetx = tax;
      cubes[i].targety = tay;
      popMatrix();
    }
  }


  //do the actual aim 
  for (int i = 0; i< nCubes; ++i) {
    if (cubes[i].isLost==false) {
      moveTo(i, int(cubes[i].targetx), int(cubes[i].targety), 200, 10);
    } else {
      
      pose(i);
    }
  }
}
