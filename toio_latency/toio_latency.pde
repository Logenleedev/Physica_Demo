import oscP5.*;
import netP5.*;



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


float X_storage[] =  new float [200];
float Y_storage[] =  new float [200];
long start;

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

  
  // toio drop code start
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
        if(dist >= 5){
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
