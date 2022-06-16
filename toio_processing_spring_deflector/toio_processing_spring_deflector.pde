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
PlaneDeflector mDeflector;

Spring mSpring;




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

  /* create a particle system */
  mPhysics = new Physics();
  mDeflector = new PlaneDeflector();
  /* create a viscous force that slows down all motion; 0 means no slowing down. */
  ViscousDrag myDrag = new ViscousDrag(0.02f);
  mPhysics.add(myDrag);
  mPhysics.add(new Gravity());




  mDeflector.plane().origin.set(width / 2.0f, height / 2.0f + 300, 0);
  mDeflector.plane().normal.set(0, -1, 0);
  mDeflector.coefficientofrestitution(0.9f);

  mPhysics.add(mDeflector);
  /* create two particles that we can connect with a spring */
  Particle myA = mPhysics.makeParticle();
  myA.position().set(width / 2.0f - 50, height / 2.0f);
  Particle myB = mPhysics.makeParticle();
  myB.position().set(width / 2.0f + 50, height / 2.0f);
  /* create a spring force that connects two particles.
   * note that there is more than one way to create a spring.
   * in our case the restlength of the spring is defined by the
   * particles current position.
   */

  mSpring = mPhysics.makeSpring(myA, myB);
}

void draw() {
  background(255);
  stroke(0);
  long now = System.currentTimeMillis();

  //draw the "mat"
  fill(255);
  rect(45, 45, 415, 410);



  int midPointX = (cubes[2].x + cubes[3].x)/2;
  int midPointY = (cubes[2].y + cubes[3].y)/2;

  final float myAngle = atan2(cubes[3].y-cubes[2].y, cubes[3].x-cubes[2].x);
  
  

  mDeflector.plane().origin.set(midPointX, midPointY, 0);
  mDeflector.plane().normal.set(sin(myAngle), -cos(myAngle), 0);


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


    if (mousePressed) {

      mSpring.b().position().set(mouseX, mouseY);
    }
    final float mDeltaTime = 1.0f / frameRate;
    mPhysics.step(mDeltaTime);

    stroke(255, 255, 0);
    fill(255, 0, 0);





    if (cubes[0].isLost==false && cubes[0].p_isLost == true) {
      mSpring.a().position().set(cubes[0].x, cubes[0].y);
    }
    if (cubes[0].isLost==false) {
      aimCubePosVel(cubes[0].id, mSpring.a().position().x, mSpring.a().position().y, mSpring.a().velocity().x, mSpring.a().velocity().y);
    }

    if (cubes[1].isLost==false && cubes[1].p_isLost == true) {
      mSpring.b().position().set(cubes[1].x, cubes[1].y);
    }
    if (cubes[1].isLost==false) {
      aimCubePosVel(cubes[1].id, mSpring.b().position().x, mSpring.b().position().y, mSpring.b().velocity().x, mSpring.b().velocity().y);
    }
    ellipse(mSpring.a().position().x, mSpring.a().position().y, 5, 5);
    ellipse(mSpring.b().position().x, mSpring.b().position().y, 15, 15);
    line(mSpring.a().position().x, mSpring.a().position().y,
      mSpring.b().position().x, mSpring.b().position().y);
  }
  // toio drop code end


  //  if (mousePressed) {
  //        final float myAngle = 2 * PI * (float) mouseX / width - PI;
  //        mDeflector.plane().normal.set(sin(myAngle), -cos(myAngle), 0);
  //    }


  //did we lost some cubes?
  for (int i=0; i<nCubes; ++i) {
    // 500ms since last update
    cubes[i].p_isLost = cubes[i].isLost;
    if (cubes[i].lastUpdate < now - 1500 && cubes[i].isLost==false) {
      cubes[i].isLost= true;
    }
  }

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
