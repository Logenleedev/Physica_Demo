// APP TEMPLATE Software (V3) for toio 'Actuated Tangible Interface Toolkit'
// MIT Media Lab, Tangible Media Group
// http://tangible.media.mit.edu/
// Updated Dec 29, 2020
// Contributer: Ken Nakagaki and João Wilbert
// contact: ken_n@media.mit.edu


// "Instruction"
// This code is a template for developing application for toio toolkit 'Actuated Tangible Interface Toolkit'.
// See the accompanied documentation for detail.
// check the tab "server_sen_cmd" to find all commands to control toios

// "for quick prototyping"
// edit myCustomFunction()

import processing.net.*;
Client myClient;

//we'll keep the cubes here
Cube[] cubes;

int controlCubeSwitching = 0;

import peasy.PeasyCam;
PeasyCam cam;



void settings() {
  if (!enable3Dview) {
    size(700, 1000);
  } else {
    size(700, 1000, P3D);
  }
}

void setup() {

  cam = new PeasyCam(this, 400);
  cam.setDistance(800);

  myClient = new Client(this, "localhost", 8000);

  //create cubes
  cubes = new Cube[nCubes];
  for (int i = 0; i< cubes.length; ++i) {
    cubes[i] = new Cube(i, true);
  }
  setupPhysica();

  frameRate(appFrameRate);
  textSize(10);
}

void draw() {
  serverReceive();

  displayDebug();

  ////** do something to control cube **////
  myCustomFunction();

  if (mouseDrive) {
    mouseDrive_();
  }

  checkLostCube();
  serverSend();
}


float rotationDegree = 0;
int radius = 150;

void myCustomFunction() {

  if (drop) {

   

   
    motorControl(0,60,60,200);
    
    //println(counter);
    for (int i = 0; i < cubes.length; ++i) {
      if (cubes[i].isLost==false && cubes[i].p_isLost == true) {
        start = System.currentTimeMillis();
      }
      if (cubes[i].isLost==false) {
        float x_coord = cubes[i].x;
        float y_coord = cubes[i].y;
        X_storage[counter] = x_coord;
        Y_storage[counter] = y_coord;
        float dist = sqrt(sq(x_coord - X_storage[0])+sq(y_coord - Y_storage[0]));
        if(dist > 50){
          // finding the time after the operation is executed
          long end = System.currentTimeMillis();
          // finding the time difference
          long msec = end - start;
          //println("Start is " + start);
          println(msec);
          
        } else {
          
          counter += 1;
          
 
        }
        
        
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

    break;

  case ' ':
    motorControl(0, 115, 115, 200);

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



void checkLostCube() {
  //did we lost some cubes?
  long now = System.currentTimeMillis();
  for (int i = 0; i< nCubes; ++i) {
    cubes[i].p_isLost  = cubes[i].isLost;
    // 500ms since last update
    if (cubes[i].lastUpdate < now - 500 && cubes[i].isLost==false) {
      cubes[i].isLost= true;
    }
  }
}
