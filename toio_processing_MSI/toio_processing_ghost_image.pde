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

Particle mParticle;
Particle mParticle_2;
PlaneDeflector mDeflector;

float gravity_num;

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
  size(700, 700);
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
  mDeflector = new PlaneDeflector();
  
  mGravity.force().set(-30, 0);
  mPhysics.add(mGravity);
  /* set plane origin into the center of the screen */
  mDeflector.plane().origin.set(width / 2.0f, height / 2.0f + 50, 0);
  mDeflector.plane().normal.set(0, -1, 0);

  mDeflector.plane().origin.set(width / 2.0f, height / 2.0f + 50, 0);
  mDeflector.plane().normal.set(0, 1, 0);
  /* the coefficient of restitution defines how hard particles bounce of the deflector */
  mDeflector.coefficientofrestitution(0.7f);


  mPhysics.add(mDeflector);


  /* create a particle and add it to the system */
  mParticle = mPhysics.makeParticle();
  mParticle_2 = mPhysics.makeParticle();
  /* create drag */
  ViscousDrag myViscousDrag = new ViscousDrag();
  myViscousDrag.coefficient = 0.0001f;
  mPhysics.add(myViscousDrag);
}

void draw() {
  background(255);
  stroke(0);
  long now = System.currentTimeMillis();

  //draw the "mat"
  fill(255);
  rect(45, 45, 415, 410);





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
      mParticle.position().set(cubes[0].x, cubes[0].y);
      mParticle.velocity().set(0, 0);
      mParticle.velocity().mult(10);
    }
    if (cubes[0].isLost==false) {

      aimCubePosVel(cubes[0].id, mParticle.position().x, mParticle.position().y, mParticle.velocity().y, mParticle.velocity().x);
    }
    if (cubes[1].isLost==false && cubes[1].p_isLost == true) {
      mParticle_2.position().set(cubes[1].x, cubes[1].y);
      mParticle_2.velocity().set(0, 0);
      mParticle_2.velocity().mult(10);
    }
    if (cubes[1].isLost==false) {

      aimCubePosVel(cubes[1].id, mParticle_2.position().x, mParticle_2.position().y, mParticle_2.velocity().y, mParticle_2.velocity().x);
    }



    if ((cubes[4].x >= 902 & cubes[4].x <= 938 )& (cubes[4].y >= 260 & cubes[4].y <= 456 )) {
      gravity_num = 196.0-(cubes[4].y - 260);
      mGravity.force().set(-gravity_num, 0);
    }
    String a = "Gravity is: " + gravity_num;
    textSize(29);
    text(a, 30, 30);
  }

  // toio drop code end


  if (mousePressed) {
    final float myAngle = 2 * PI * (float) mouseX / width - PI;
    mDeflector.plane().normal.set(sin(myAngle), -cos(myAngle), 0);
  }


  int midPointX = (cubes[2].x + cubes[3].x)/2;
  int midPointY = (cubes[2].y + cubes[3].y)/2;

  final float myAngle = atan2(cubes[3].y-cubes[2].y, cubes[3].x-cubes[2].x);



  mDeflector.plane().origin.set(midPointX, midPointY, 0);
  mDeflector.plane().normal.set(sin(myAngle), -cos(myAngle), 0);



  //did we lost some cubes?
  for (int i=0; i<nCubes; ++i) {
    // 500ms since last update
    cubes[i].p_isLost = cubes[i].isLost;
    if (cubes[i].lastUpdate < now - 1500 && cubes[i].isLost==false) {
      cubes[i].isLost= true;
    }
  }

  /* draw deflector */
  stroke(0);
  strokeWeight(3.0f);
  line(mDeflector.plane().origin.x - mDeflector.plane().normal.y * -width,
    mDeflector.plane().origin.y + mDeflector.plane().normal.x * -width,
    mDeflector.plane().origin.x - mDeflector.plane().normal.y * width,
    mDeflector.plane().origin.y + mDeflector.plane().normal.x * width);
  strokeWeight(1.0f);
  line(mDeflector.plane().origin.x,
    mDeflector.plane().origin.y,
    mDeflector.plane().origin.x + mDeflector.plane().normal.x * 20,
    mDeflector.plane().origin.y + mDeflector.plane().normal.y * 20);
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
