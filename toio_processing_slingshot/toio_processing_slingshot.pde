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
/*
 * this sketch demonstrates how to create a `Spring` that connects two particles. it also
 * demonstrates how to create a `ViscousDrag` to slow down particle motion over time.
 *
 * drag mouse to move particle.
 */

Physics mPhysics;

Spring mSpring;

ControlP5 cp5;

Accordion accordion;




Particle mParticle;


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
    if (cubes[0].isLost==false && cubes[0].pre_press == 0 && cubes[0].press == 128) {
      mSpring.a().position().set(cubes[0].x, cubes[0].y);
    }
    

    println(mSpring.strength());

    stroke(255, 255, 0);
    fill(255, 0, 0);





    stroke(204, 102, 0);

    ellipse(mSpring.a().position().x, mSpring.a().position().y, 5, 5);



    ellipse(mSpring.b().position().x, mSpring.b().position().y, 15, 15);
    line(mSpring.a().position().x, mSpring.a().position().y,
      mSpring.b().position().x, mSpring.b().position().y);


    pushMatrix();
    translate(mSpring.b().position().x, mSpring.b().position().y);
    stroke(0, 255, 0);
    line(0, 0, mSpring.b().velocity().x, mSpring.b().velocity().y);
    popMatrix();


    for (int i = 0; i< nCubes; ++i) {

      if (cubes[i].isLost == true) {
        cubes[i].pre_press = 0;
        cubes[i].press = 0;
        cubes[i].state = 1;
      }





      if (cubes[i].isLost==false && cubes[i].p_isLost == true) {
        mSpring.b().position().set(cubes[i].x, cubes[i].y);
      }
      if (cubes[i].isLost==false) {
        cubes[i].pre_spring_length = cubes[i].current_spring_length;
        cubes[i].current_spring_length = mSpring.currentLength();


        //println(cubes[i].state);

        if (cubes[i].pre_press == 0 && cubes[i].press == 128 ) {
          mSpring.a().position().set(cubes[i].x, cubes[i].y);
          cubes[i].pre_spring_length = 10;
        }

        // anchor changing code
        if (cubes[i].current_spring_length < 50 && cubes[i].pre_spring_length < 50) {
          aimCubePosVel(cubes[i].id, mSpring.b().position().x, mSpring.b().position().y, mSpring.b().velocity().x, mSpring.b().velocity().y);
          if ( eventDetection(cubes[i].x, cubes[i].y, cubes[i].prex, cubes[i].prey, cubes[i].speedX, cubes[i].speedY) ) {
            mSpring.b().position().set(cubes[i].x, cubes[i].y);
            println("spring forth touch detected!");
          }
        }

        // slingshot release code
        if (cubes[i].current_spring_length > 50 && cubes[i].state == 1) {
          //println("1 count is:" + count);
          aimCubePosVel(cubes[i].id, mSpring.b().position().x, mSpring.b().position().y, mSpring.b().velocity().x, mSpring.b().velocity().y);
          if ( eventDetection(cubes[i].x, cubes[i].y, cubes[i].prex, cubes[i].prey, cubes[i].speedX, cubes[i].speedY) ) {
            mSpring.b().position().set(cubes[i].x, cubes[i].y);
            //println("cube 1 touch detected!");
          }
        }

        if (cubes[i].pre_spring_length > 50 && cubes[i].current_spring_length < 50 && cubes[i].state == 1) {
          //println("2 count is:" + count);
          mParticle.position().set(mSpring.b().position().x, mSpring.b().position().y);
          mParticle.velocity().set(mSpring.b().velocity().x, mSpring.b().velocity().y);

          cubes[i].state += 1;
        }

        if (cubes[i].state >= 2 ) {
          //println("3 count is:" + count);
          //println(mSpring.currentLength());
          aimCubePosVel(cubes[i].id, mParticle.position().x, mParticle.position().y, mParticle.velocity().x, mParticle.velocity().y);
          cubes[i].state += 1;
        }




        ellipse(mParticle.position().x, mParticle.position().y, 5, 5);
        pushMatrix();
        translate(mParticle.position().x, mParticle.position().y);
        stroke(0, 255, 0);
        line(0, 0, mParticle.velocity().x, mParticle.velocity().y);
        popMatrix();
      }
    }
  }

  // toio drop code end

  if (mousePressed) {
    mSpring.b().position().set(mouseX, mouseY);
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
  print("Release");



  //ellipse(mParticle.position().x, mParticle.position().y, 10, 10);
}
