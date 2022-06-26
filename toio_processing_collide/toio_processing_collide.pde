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

Physics mPhysics;

Particle mParticle;
Particle mParticle1;

ControlP5 cp5;

Accordion accordion;






//for OSC
OscP5 oscP5;
//where to send the commands to
NetAddress[] server;


//we'll keep the cubes here
Cube[] cubes;

boolean mouseDrive = false;
boolean chase = false;
boolean spin = false;
boolean drop = false;
boolean projectile = false;
float x_vel;
float y_vel;

CollisionManager mCollision;
Gravity mGravity = new Gravity();

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

  mCollision = new CollisionManager();
  mCollision.distancemode(CollisionManager.DISTANCE_MODE_FIXED);
  mCollision.minimumDistance(50);

  //create cubes
  cubes = new Cube[nCubes];
  for (int i = 0; i< cubes.length; ++i) {
    cubes[i] = new Cube(i, true);
  }

  //do not send TOO MANY PACKETS
  //we'll be updating the cubes every frame, so don't try to go too high
  frameRate(50);

  mPhysics = new Physics();
  mPhysics.add(new ViscousDrag(0.8f));
  /* create a gravitational force */

  /* the direction of the gravity is defined by the 'force' vector */
  mGravity.force().set(0, 30);
  /* forces, like gravity or any other force, can be added to the system. they will be automatically applied to
   all particles */
  mPhysics.add(mGravity);
  /* forces, like gravity or any other force, can be added to the system. they will be automatically applied to
   all particles */
  /* create a particle and add it to the system */
  mParticle = mPhysics.makeParticle();
  mParticle1 = mPhysics.makeParticle();

  parameter_gui();
}

void draw() {
  background(255);
  stroke(0);
  long now = System.currentTimeMillis();

  // change gravity using control p5 slider
  float s1 = cp5.getController("gravity").getValue();
  mGravity.force().set(0, s1);

  //draw the "mat"
  fill(255);
  rect(45, 45, 410, 410);






  //draw the cubes
  for (int i = 0; i < cubes.length; ++i) {
    if (cubes[i].isLost==false) {
      pushMatrix();
      translate(cubes[i].x, cubes[i].y);
      pushMatrix();
      rotate(cubes[i].deg * PI/180);
      stroke(0);
      rect(-10, -10, 20, 20);
      rect(0, -5, 20, 10);
      popMatrix();
      stroke(255, 0, 0);
      line(0, 0, cubes[i].speedX, cubes[i].speedY );

      popMatrix();
    }
  }

  int time = 0;
  // toio drop code start
  if (drop) {



    final float mDeltaTime = 1.0f / frameRate;
    mCollision.createCollisionResolvers();
    mCollision.loop(mDeltaTime);
    mPhysics.step(mDeltaTime);
    mCollision.removeCollisionResolver();


    stroke(255, 255, 0);
    fill(255, 0, 0);





    stroke(204, 102, 0);

    // first particle start
    if (cubes[0].isLost == true) {

      cubes[0].state = 1;
    }

    if (cubes[0].isLost==false) {

      if (cubes[0].state == 1) {
        cubes[0].origin_x = cubes[0].x;
        cubes[0].origin_y = cubes[0].y;
        cubes[0].state += 1;
      }
      //println(cubes[i].origin_x + " " + cubes[i].origin_y);
      //println(cubes[i].state);

      ellipse(cubes[0].origin_x, cubes[0].origin_y, 30, 30);
      //println(dist(cubes[i].origin_x, cubes[i].origin_y, cubes[i].x, cubes[i].prey) > 60 && dist(cubes[i].origin_x, cubes[i].origin_y, cubes[i].x, cubes[i].y) > 60);
      //println(cubes[i].state);
      boolean condition = dist(cubes[0].origin_x, cubes[0].origin_y, cubes[0].x, cubes[0].prey) > 15 && dist(cubes[0].origin_x, cubes[0].origin_y, cubes[0].x, cubes[0].y) > 15;
      if ((condition == true && cubes[0].state == 2)) {
        cubes[0].state += 1;
        mParticle.radius(35);
        mParticle.position().set(cubes[0].x, cubes[0].y);
        mParticle.velocity().set(cubes[0].speedX/2, cubes[0].speedY/2);
        mCollision.collision().add(mParticle);
        //mParticle.velocity().mult(10);
        //print("state 2 triggered!");
      }


      if (cubes[0].state > 2 ) {
        ellipse(mParticle.position().x, mParticle.position().y, 25, 25);

        aimCubePosVel(cubes[0].id, mParticle.position().x, mParticle.position().y, mParticle.velocity().y, mParticle.velocity().x);
        //print("state 3 triggered!");
      }
    }
    // first particle end

    // second particle start
    if (cubes[1].isLost == true) {

      cubes[1].state = 1;
    }

    if (cubes[1].isLost==false) {

      if (cubes[1].state == 1) {
        cubes[1].origin_x = cubes[1].x;
        cubes[1].origin_y = cubes[1].y;
        cubes[1].state += 1;
      }
      //println(cubes[i].origin_x + " " + cubes[i].origin_y);
      //println(cubes[i].state);

      ellipse(cubes[1].origin_x, cubes[1].origin_y, 30, 30);
      //println(dist(cubes[i].origin_x, cubes[i].origin_y, cubes[i].x, cubes[i].prey) > 60 && dist(cubes[i].origin_x, cubes[i].origin_y, cubes[i].x, cubes[i].y) > 60);
      //println(cubes[i].state);
      boolean condition = dist(cubes[1].origin_x, cubes[1].origin_y, cubes[1].x, cubes[1].prey) > 15 && dist(cubes[1].origin_x, cubes[1].origin_y, cubes[1].x, cubes[1].y) > 15;
      if ((condition == true && cubes[1].state == 2)) {
        cubes[1].state += 1;
        mParticle1.radius(35);
        mParticle1.position().set(cubes[1].x, cubes[1].y);
        mParticle1.velocity().set(cubes[1].speedX/2, cubes[1].speedY/2);
        mCollision.collision().add(mParticle1);
        //mParticle.velocity().mult(10);
        //print("state 2 triggered!");
      }


      if (cubes[1].state > 2 ) {
        ellipse(mParticle1.position().x, mParticle1.position().y, 25, 25);

        aimCubePosVel(cubes[1].id, mParticle1.position().x, mParticle1.position().y, mParticle1.velocity().y, mParticle1.velocity().x);
        //print("state 3 triggered!");
      }
      // second particle end
    }
  }

  // toio drop code end




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
  case 'q':
    projectile = true;
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




void mousePressed() {
  chase = false;
  spin = false;
  mouseDrive=true;
}

void mouseReleased() {
  mouseDrive=false;
}
