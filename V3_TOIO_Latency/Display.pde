
void displayDebug() {

  background(0);
  stroke(255);



  if (!enable3Dview) {
    fill(255);
    textSize(12);
    text("FPS = " + frameRate, 10, height-10);//Displays how many clients have connected to the server
    display2D();
  } else {
    if (keyPressed && key == ' ') {
      cam.setMouseControlled(true);
    } else {
      cam.setMouseControlled(false);
    }
    display3D();

    cam.beginHUD();
    if (debugView) {
      debugFor3DView();
    }
    cam.endHUD();
  }
}

void display2D() {



  //draw the "mat"
  noFill();
  for (int i = 0; i< matCol; i++) {
    for (int j = 0; j < matRow; j++) {
      rect(MAT_WIDTH*i, MAT_HEIGHT*j, MAT_WIDTH, MAT_HEIGHT);
    }
  }

  //rect(0,0,MAT_WIDTH,MAT_HEIGHT);



  //draw the cubes
  for (int i = 0; i < cubes.length; ++i) {
    pushMatrix();
    translate(cubes[i].x, cubes[i].y);

    int alpha = 255;
    if (cubes[i].isLost) {
      alpha = 50;
    }
    textSize(12);
    fill(0, 255, 255, alpha);
    text("#"+i + " ["+cubes[i].x+", "+cubes[i].y+"]", 10, -10);

    fill(0, 255, 0, alpha);
    //text("V= ["+ float(round(cubes[i].speedX*100))/100.0 +", "+ float(round(cubes[i].speedY*100))/100.0+"]", 20, 3);
    noFill();

    stroke(0, 255, 0);
    strokeWeight(2);
    line(0, 0, cubes[i].ave_speedX, cubes[i].ave_speedY);
    strokeWeight(1);

    rotate(cubes[i].deg * PI/180);


    if (cubes[i].buttonState) {
      stroke(0, 255, 255, alpha);
    } else {
      stroke(255, alpha);
    }
    if (  abs(cubes[i].currentMotL) == 115 &&   abs(cubes[i].currentMotR) == 115) {
      stroke (255, 0, 0);
    }


    rect(-11, -11, 22, 22);
    rect(0, -5, 20, 10);

    stroke(255, 0, 0, alpha);
    line(-5, -5, 5, 5);
    line(5, -5, -5, 5);




    popMatrix();

    if (cubes[i].targetMode) {

      //draw target point
      pushMatrix();
      translate(cubes[i].targetx, cubes[i].targety);
      stroke(255);
      fill(255, 0, 0);
      ellipse(0, 0, 10, 10);

      fill(255, 0, 0);
      textSize(11);
      text(""+int(cubes[i].targetx)+", "+ int(cubes[i].targety)+".", 10, 15);

      popMatrix();

      stroke(255, 0, 0);
      line(cubes[i].x, cubes[i].y, cubes[i].targetx, cubes[i].targety);
    }
  }
}
