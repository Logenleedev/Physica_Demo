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

//for OSC
OscP5 oscP5;
//where to send the commands to
NetAddress[] server;
int cubesPerHost = 4; // each BLE bridge can have up to 4 cubes

//we'll keep the cubes here
Cube[] cubes;
int nCubes =  4;
int frameNum = 5;


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

  mPhysics = new Physics();
  mDeflector = new PlaneDeflector();
  /* set plane origin into the center of the screen */
  mDeflector.plane().origin.set(width / 2.0f, height / 2.0f + 50, 0);
  mDeflector.plane().normal.set(0, -1, 0);
  /* the coefficient of restitution defines how hard particles bounce of the deflector */
  mDeflector.coefficientofrestitution(0.7f);
  mPhysics.add(mDeflector);
  Gravity mGravity = new Gravity();
  mGravity.force().y = 40;//50;
  mPhysics.add(mGravity);
  /* create a particle and add it to the system */
  mParticle = mPhysics.makeParticle();
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

    ellipse(mParticle.position().x, mParticle.position().y, 5, 5);

    for (int i = 0; i< nCubes; ++i) {

      if (cubes[i].isLost==false && cubes[i].p_isLost == true) {
        mParticle.position().set(cubes[i].x, cubes[i].y);
        mParticle.velocity().set(0, 0);
        mParticle.velocity().mult(10);
      }
      if (cubes[i].isLost==false) {

        aimCubeSpeed(cubes[i].id, mParticle.position().x, mParticle.position().y);
        //println("Velocity is:" + mParticle.velocity());
        float[] f = mParticle.velocity().array();
        float velocity_mag = sqrt(pow(f[0], 2)+pow(f[1], 2));
        //println(velocity_mag);
      }
    }
    

  }

  // toio drop code end


  if (mousePressed) {
        final float myAngle = 2 * PI * (float) mouseX / width - PI;
        mDeflector.plane().normal.set(sin(myAngle), -cos(myAngle), 0);
    }


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

//helper functions to drive the cubes

boolean rotateCube(int id, float ta) {
  float diff = ta-cubes[id].deg;
  if (diff>180) diff-=360;
  if (diff<-180) diff+=360;
  if (abs(diff)<8) return true;
  int dir = 1;
  int strength = int(abs(diff) / 10);
  strength = 1;//
  if (diff<0)dir=-1;
  float left = ( 5*(1*strength)*dir);
  float right = (-5*(1+strength)*dir);
  int duration = 100;
  motorControl(id, left, right, duration);

  //println("rotate false "+diff +" "+ id+" "+ta +" "+cubes[id].deg);
  return false;
}



// the most basic way to move a cube
boolean aimCube(int id, float tx, float ty) {
  if (cubes[id].distance(tx, ty)<25) return true;
  int[] lr = cubes[id].aim(tx, ty);
  float left = (lr[0]*.5);
  float right = (lr[1]*.5);
  int duration = (0);
  motorControl(id, left, right, duration);
  return false;
}



//boolean aimCubeSpeed(int id, float tx, float ty) {
//  float dd = cubes[id].distance(tx, ty)/100.0;
  
//  println("dd is:" + dd);
  
//  dd = min(dd, 1);
//  if (dd <.15) return true;

//  int[] lr = cubes[id].aim(tx, ty);
//  float left = (lr[0]*dd);
//  float right = (lr[1]*dd);
//  println("left: "+ lr[0] + ";" + "right: " + lr[1]);
//  int duration = (100);
//  motorControl(id, left, right, duration);
//  return false;
//}

boolean aimCubeSpeed(int id, float tx, float ty) {
  float dd = cubes[id].distance(tx, ty)/100.0;
  
  //println("dd is:" + dd);
  
  dd = min(dd, 1);
  if (dd <.15) return true;

  int[] lr = cubes[id].aim(tx, ty);
  float left = (lr[0])*dd;
  float right = (lr[1])*dd;
  println("left: "+ lr[0] + ";" + "right: " + lr[1]);
  int duration = (100);
  motorControl(id, left, right, duration);
  return false;
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



//OSC messages (send)

void aimMotorControl(int cubeId, float x, float y) {
  int hostId = cubeId/cubesPerHost;
  int actualcubeid = cubeId % cubesPerHost;
  OscMessage msg = new OscMessage("/aim");
  msg.add(actualcubeid);
  msg.add((int)x);
  msg.add((int)y);
  oscP5.send(msg, server[hostId]);
}

void motorControl(int cubeId, float left, float right, int duration) {
  int hostId = cubeId/cubesPerHost;
  int actualcubeid = cubeId % cubesPerHost;
  OscMessage msg = new OscMessage("/motor");
  msg.add(actualcubeid);
  msg.add((int)left);
  msg.add((int)right);
  msg.add(duration);
  oscP5.send(msg, server[hostId]);
}

void light(int cubeId, int duration, int red, int green, int blue) {
  int hostId = cubeId/cubesPerHost;
  int actualcubeid = cubeId % cubesPerHost;
  OscMessage msg = new OscMessage("/led");
  msg.add(actualcubeid);
  msg.add(duration);
  msg.add(red);
  msg.add(green);
  msg.add(blue);
  oscP5.send(msg, server[hostId]);
}



//OSC message handling (receive)

void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/position") == true) {
    int hostId = msg.get(0).intValue();
    int id = msg.get(1).intValue();
    //int matId = msg.get(1).intValue();
    int posx = msg.get(2).intValue();
    int posy = msg.get(3).intValue();

    int degrees = msg.get(4).intValue();
    //println("Host "+ hostId +" id " + id+" "+posx +" " +posy +" "+degrees);

    id = cubesPerHost*hostId + id;

    if (id < cubes.length) {
      cubes[id].count++;
      int elapsedTime = millis() - cubes[id].lastTime;

      cubes[id].prex = cubes[id].x;
      cubes[id].prey = cubes[id].y;

      //cubes[id].oidx = posx;
      //cubes[id].oidy = posy;


      cubes[id].lastTime = millis();
      cubes[id].x = posx;
      cubes[id].y = posy;



      cubes[id].deg = degrees;
      

      //for (int i = 0; i< cubes[id].frameNum-1; i++) {
      //  pre_speed[cubes[id].frameNum - i] = pre_speed[i];
      //}

      cubes[id].lastUpdate = System.currentTimeMillis();
      if (cubes[id].isLost == true) {
        cubes[id].isLost = false;
      }


    }
  } else if (msg.checkAddrPattern("/button") == true) {
    int hostId = msg.get(0).intValue();
    int relid = msg.get(1).intValue();
    int id = cubesPerHost*hostId + relid;
    int pressValue =msg.get(2).intValue();
    println("Button pressed for id : "+id);
  } else if (msg.checkAddrPattern("/motion") == true) {
    int hostId = msg.get(0).intValue();
    int relid = msg.get(1).intValue();
    int id = cubesPerHost*hostId + relid;
    int flatness =msg.get(2).intValue();
    int hit =msg.get(3).intValue();
    int double_tap =msg.get(4).intValue();
    int face_up =msg.get(5).intValue();
    int shake_level =msg.get(6).intValue();
    println("motion for id "+id +": " + flatness +", "+ hit+", "+ double_tap+", "+ face_up+", "+ shake_level);
  }
}
