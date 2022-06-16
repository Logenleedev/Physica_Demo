import oscP5.*;
import netP5.*;
import teilchen.*;
import teilchen.behavior.*;
import teilchen.constraint.*;
import teilchen.cubicle.*;
import teilchen.force.*;
import teilchen.integration.*;
import teilchen.util.*;


Physics mPhysics;

Particle mRoot;


Particle a;
Particle b;
Particle c;

//for OSC
OscP5 oscP5;
//where to send the commands to
NetAddress[] server;


//we'll keep the cubes here
Cube[] cubes;

float pre_speedX[];
float pre_speedY[];


boolean mouseDrive = false;
boolean chase = false;
boolean spin = false;
boolean drop = false;


Gravity mGravity = new Gravity();


void settings() {
  size(400, 400);
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

  //do not send TOO MANY PACKETS
  //we'll be updating the cubes every frame, so don't try to go too high
  frameRate(30);

  mPhysics = new Physics();

  /* use `RungeKutta` as it produces more stable results in applications like these */
  mPhysics.setIntegratorRef(new RungeKutta());
  Gravity myGravity = new Gravity();
  myGravity.force().y = 80.1f;
  mPhysics.add(myGravity);


  
  /* add drag to smooth the spring interaction */
  mPhysics.add(new ViscousDrag(0.2f));
  /* add a container */
  Box myBox = new Box();
  myBox.min().set(0, 0, 0);
  myBox.max().set(width, height, 0);
  mPhysics.add(myBox);
  /* create root */
  a = mPhysics.makeParticle(0, 0);
  b = mPhysics.makeParticle(100, 0);
  c = mPhysics.makeParticle(100, 100);

  /* create stable quad from springs */
  /* first the edge-springs ... */
  final float mSpringConstant = 100;
  final float mSpringDamping = 8;
  mPhysics.makeSpring(a, b, mSpringConstant, mSpringDamping);
  mPhysics.makeSpring(b, c, mSpringConstant, mSpringDamping);

  /* ... then the diagonal-springs */
  mPhysics.makeSpring(a, c, mSpringConstant, mSpringDamping);
  mPhysics.makeSpring(b, c, mSpringConstant, mSpringDamping).restlength();
  /* define 'a' as root particle for mouse interaction */
  mRoot = a;
  mRoot.fixed(true);
  mRoot.radius(10);
}

void draw() {
  background(255);
  stroke(0);
  long now = System.currentTimeMillis();

  //draw the "mat"
  fill(255);
  rect(45, 45, 415, 410);

  if (mousePressed) {
    mRoot.fixed(true);
    mRoot.position().set(mouseX, mouseY);
  } 



  //motorControl(0,80,80,200);
  //println(cubes[0].x + "  " + cubes[0].y);
  //if(mousePressed){
  //  motorControl(0,115,115,50);
  //} else {
  //  motorControl(0,100,100,50);
  //}


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


    final float mDeltaTime = 1.0f / frameRate;
    mPhysics.step(mDeltaTime);

    stroke(255, 255, 0);
    fill(255, 0, 0);
    //ellipse(mParticle.position().x, mParticle.position().y, 10, 10);
    //ellipse(mParticle_2.position().x, mParticle_2.position().y, 10, 10);

    stroke(204, 102, 0);

    // Plot velocity line
    //if (cubes[0].isLost==false) {
    //  line(cubes[0].x, cubes[0].y, cubes[0].x + mParticle.velocity().x, cubes[0].y+mParticle.velocity().y);
    //}

    //if (cubes[0].isLost==false) {
    //  line(cubes[1].x, cubes[1].y, cubes[1].x + mParticle_2.velocity().x, cubes[1].y+mParticle_2.velocity().y);
    //}


    //ellipse(mParticle.position().x, mParticle.position().y, 5, 5);


    // Aim
    if (cubes[0].isLost==false && cubes[0].p_isLost == true) {
      mRoot.position().set(cubes[0].x, cubes[0].y);
    }
    if (cubes[0].isLost==false) {

      aimCubePosVel(cubes[0].id, mRoot.position().x, mRoot.position().y, mRoot.velocity().x, mRoot.velocity().y);
      if ( eventDetection(cubes[0].x, cubes[0].y, mRoot.position().x, mRoot.position().y, cubes[0].speedX, cubes[0].speedY) ) {
        mRoot.position().set(cubes[0].x, cubes[0].y);
      }
    }

    if (cubes[1].isLost==false && cubes[1].p_isLost == true) {
    }
    if (cubes[1].isLost==false) {

      aimCubePosVel(cubes[1].id, b.position().x, b.position().y, b.velocity().x, b.velocity().y);
      //if ( eventDetection(cubes[1].x, cubes[1].y, b.position().x, b.position().y, cubes[1].speedX, cubes[1].speedY) ) {
      //  b.position().set(cubes[1].x, cubes[1].y);
      //}
    }

    if (cubes[2].isLost==false && cubes[2].p_isLost == true) {
      //c.position().set(cubes[2].x, cubes[2].y);
    }
    if (cubes[2].isLost==false) {

      aimCubePosVel(cubes[2].id, c.position().x, c.position().y, c.velocity().x, c.velocity().y);
      //if ( eventDetection(cubes[2].x, cubes[2].y, c.position().x, c.position().y, cubes[2].speedX, cubes[2].speedY) ) {
      //  c.position().set(cubes[2].x, cubes[2].y);
      //}
    }



    noStroke();
    fill(0);
    for (Particle p : mPhysics.particles()) {
      ellipse(p.position().x, p.position().y, 5, 5);
    }
    DrawLib.drawSprings(g, mPhysics, color(0, 63));
    /* highlight root particle */
    noStroke();
    fill(0);
    ellipse(mRoot.position().x, mRoot.position().y, 15, 15);
  }

  // toio drop code end





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
  case 'm':
    mouseDrive = !mouseDrive;
    chase = false;
    spin = false;
    break;
  case 'n':
    mouseDrive = false;
    chase = false;
    spin = false;
    drop = false;
    break;
  case 'c':
    chase = !chase;
    spin = false;
    mouseDrive = false;
    break;
  case 'd':
    drop = true;
    chase = false;
    spin = false;
    mouseDrive = false;
    break;
  case 's':
    chase = false;
    mouseDrive = false;
    spin = false;
    break;
  case 'p':
    spin = !spin;
    chase = false;
    mouseDrive=false;
  case 'a':
    for (int i=0; i < nCubes; ++i) {
      aimMotorControl(i, 380, 260);
    }
    break;
  case 'l':
    light(0, 100, 255, 0, 0);
    break;
  default:
    break;
  }
}



void mousePressed() {
  chase = false;
  spin = false;
  mouseDrive=true;
}

void mouseReleased() {
  mouseDrive=false;
}
