import oscP5.*;
import netP5.*;
import teilchen.*;
import teilchen.behavior.*;
import teilchen.constraint.*;
import teilchen.cubicle.*;
import teilchen.force.*;
import teilchen.integration.*;
import teilchen.util.*;
import controlP5.*;
import deadpixel.keystone.*;
/*
 * this sketch demonstrates how to create a `Spring` that connects two particles. it also
 * demonstrates how to create a `ViscousDrag` to slow down particle motion over time.
 *
 * drag mouse to move particle.
 */

//teilchen
Physics mPhysics;
Particle mParticle;
Spring mSpring;

//control p5
ControlP5 cp5;
Accordion accordion;
CheckBox checkbox;
CheckBox checkbox2;
CheckBox checkbox3;


//Keystone
Keystone ks;
CornerPinSurface surface;
PGraphics offscreen;




//for OSC
OscP5 oscP5;
//where to send the commands to
NetAddress[] server;


//we'll keep the cubes here
Cube[] cubes;

int projection_correction = 45;
boolean mouseDrive = false;
boolean chase = false;
boolean spin = false;
boolean drop = false;
boolean release = false;
Gravity mGravity = new Gravity();

float x_vel;
float y_vel;


Particle myA;
Particle myB;

void settings() {
  size(1000, 1000, P3D);
}


void setup() {


  // for OSC
  // receive messages on port 3333
  oscP5 = new OscP5(this, 3333);

  //send back to the BLE interface
  //we can actually have multiple BLE bridges
  server = new NetAddress[1]; //only one for now
  //send on port 3334
  server[0] = new NetAddress("127.0.0.1", 3334);
  //server[1] = new NetAddress("192.168.0.103", 3334);
  //server[2] = new NetAddress("192.168.200.12", 3334);


  //create cubes
  cubes = new Cube[nCubes];
  for (int i = 0; i< cubes.length; ++i) {
    cubes[i] = new Cube(i, true);
  }

  /* create a particle system */
  mPhysics = new Physics();
  /* create a viscous force that slows down all motion; 0 means no slowing down. */
  ViscousDrag myDrag = new ViscousDrag(0.5f);
  mPhysics.add(myDrag);
  /* create two particles that we can connect with a spring */
  myA = mPhysics.makeParticle();
  myA.position().set(width / 3.0f - 100, height / 3.0f);
  myB = mPhysics.makeParticle();
  myB.position().set(width / 3.0f - 150, height / 3.0f);
  /* create a spring force that connects two particles.
   * note that there is more than one way to create a spring.
   * in our case the restlength of the spring is defined by the
   * particles current position.
   */
  myA.fixed(true);
  mSpring = mPhysics.makeSpring(myA, myB);
  mSpring.setOneWay(true);

  mParticle = mPhysics.makeParticle();


  /* create a gravitational force */

  /* the direction of the gravity is defined by the 'force' vector */
  mGravity.force().set(0, 50);
  /* forces, like gravity or any other force, can be added to the system. they will be automatically applied to
   all particles */
  mPhysics.add(mGravity);


  //for projections
  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(410, 410, 20);

  // We need an offscreen buffer to draw the surface we
  // want projected
  // note that we're matching the resolution of the
  // CornerPinSurface.
  // (The offscreen buffer can be P2D or P3D)
  offscreen = createGraphics(410, 410, P3D);

  parameter_gui();
}

void draw() {
  background(255);
  stroke(0);
  long now = System.currentTimeMillis();

  /* update the particle system */
  final float mDeltaTime = 1.0f / frameRate;
  mPhysics.step(mDeltaTime);


  // change gravity using control p5 slider
  float s1 = cp5.getController("gravity").getValue();
  mGravity.force().set(0, s1);

  // change spring damping using control p5 slider
  float s2 = cp5.getController("spring damping").getValue();
  mSpring.damping(s2);

  // change gravity using control p5 slider
  float s3 = cp5.getController("spring strength").getValue();
  mSpring.strength(s3);

  // change gravity using control p5 slider
  float s4 = cp5.getController("spring length").getValue();
  mSpring.restlength(s4);

  //draw the "mat"
  fill(255);
  rect(45, 45, 410, 410);




  //draw the cubes
  for (int i = 0; i < cubes.length; ++i) {
    if (cubes[i].isLost==false) {
      pushMatrix();
      translate(cubes[i].x, cubes[i].y);
      rotate(cubes[i].deg * PI/180);
      rect(-10, -10, 20, 20);
      rect(0, -5, 20, 10);
      popMatrix();
    }
  }

  int time = 0;



  // toio drop code start
  if (drop) {

    offscreen.beginDraw();
    offscreen.background(255);

    float spring_midPoint_x = (mSpring.a().position().x + mSpring.b().position().x) / 2;
    float spring_midPoint_y = (mSpring.a().position().y + mSpring.b().position().y) / 2;
    

    if (checkbox3.getArrayValue()[2] == 1 ) {
      offscreen.pushMatrix();
      offscreen.translate(spring_midPoint_x, spring_midPoint_y);
      String a = "Force is: " + calculateSpringForce(mSpring.strength(), mSpring.currentLength() - mSpring.restlength());
      offscreen.textSize(15);
      offscreen.text(a, 0, -40);
      offscreen.popMatrix();
    }
    //draw the cubes
    if (checkbox2.getArrayValue()[3] == 1 ) {

      for (int i = 0; i < cubes.length; ++i) {
        if (cubes[i].isLost==false) {
          offscreen.pushMatrix();
          offscreen.fill(255);
          offscreen.translate(cubes[i].x - projection_correction, cubes[i].y - projection_correction);
          offscreen.rotate(cubes[i].deg * PI/180);
          offscreen.rect(-10, -10, 20, 20);
          offscreen.rect(0, -5, 20, 10);
          offscreen.popMatrix();
        }
      }
    }


    if (checkbox.getArrayValue()[0] == 1) {
      grab_release();
    }


    offscreen.endDraw();

    background(0);
    // render the scene, transformed using the corner pin surface
    surface.render(offscreen);
  }

  



  if (chase) {
    cubes[0].targetx = cubes[0].x;
    cubes[0].targety = cubes[0].y;
    cubes[1].targetx = cubes[0].x;
    cubes[1].targety = cubes[0].y;
  }
  //makes a circle with n cubes
  if (mouseDrive) {
    float mx = (mouseX);
    float my = (mouseY);
    float cx = 45+410/2;
    float cy = 45+410/2;

    float mulr = 180.0;

    float aMouse = atan2( my-cy, mx-cx);
    float r = sqrt ( (mx - cx)*(mx-cx) + (my-cy)*(my-cy));
    r = min(mulr, r);
    for (int i = 0; i< nCubes; ++i) {
      if (cubes[i].isLost==false) {
        float angle = TWO_PI*i/nCubes;
        float na = aMouse+angle;
        float tax = cx + r*cos(na);
        float tay = cy + r*sin(na);
        fill(255, 0, 0);
        ellipse(tax, tay, 10, 10);
        cubes[i].targetx = tax;
        cubes[i].targety = tay;
      }
    }
  }

  if (spin) {
    motorControl(0, -100, 100, 30);
  }

  if (chase || mouseDrive) {
    //do the actual aim
    for (int i = 0; i< nCubes; ++i) {
      if (cubes[i].isLost==false) {
        fill(0, 255, 0);
        ellipse(cubes[i].targetx, cubes[i].targety, 10, 10);
        aimCubeSpeed(i, cubes[i].targetx, cubes[i].targety);
      }
    }
  }


  //did we lost some cubes?
  for (int i=0; i<nCubes; ++i) {
    // 500ms since last update
    cubes[i].p_isLost = cubes[i].isLost;
    if (cubes[i].lastUpdate < now - 1500 && cubes[i].isLost==false) {
      cubes[i].isLost= true;
    }
  }
}




void keyPressed() {
  switch(key) {
  case 'c':
    // enter/leave calibration mode, where surfaces can be warped
    // and moved
    ks.toggleCalibration();
    break;

  case 'l':
    // loads the saved layout
    ks.load();
    break;

  case 's':
    // saves the layout
    ks.save();
    break;
  case 'd':
    drop = true;
    chase = false;
    spin = false;
    mouseDrive = false;
    break;

  case 'a':
    for (int i=0; i < nCubes; ++i) {
      aimMotorControl(i, 380, 260);
    }
    break;
  case 'k':
    light(0, 100, 255, 0, 0);
    break;
  default:
    break;
  }
}





void drawArrow(float x1, float y1, float x2, float y2, int i) {
  if (cubes[i].isLost==false) {
    float a = dist(x1, y1, x2, y2) / 50;
    offscreen.pushMatrix();
    offscreen.translate(x2 - projection_correction, y2- projection_correction);
    offscreen.rotate(atan2(y2 - y1, x2 - x1));
    offscreen.triangle(- a * 2, - a, 0, 0, - a * 2, a);
    offscreen.popMatrix();
    offscreen.line(x1- projection_correction, y1- projection_correction, x2- projection_correction, y2- projection_correction);
  }
}


float calculateSpringForce(float springConstant, float deltaX){
  float force = springConstant * deltaX;
  return force;
}
