//helper functions to drive the cubes
//not used for the class

boolean rotateCube(int id, float ta) {
  float diff = ta-cubes[id].deg;
  if (diff>180) diff-=360;
  if (diff<-180) diff+=360;
  if (abs(diff)<10) return true;
  int dir = 1;
  float strength = int(abs(diff) / 14);
  println("diff = " + diff + ", strength = " + strength);
  //strength = 1;//
  if (diff<0)dir=-1;

  float left = ( 6*(1*strength)*dir);
  float right = (-6*(1+strength)*dir);
  int duration = 100;
  motorControl(id, left, right, duration);
  println("rotatae false "+diff +" "+ id+" "+ta +" "+cubes[id].deg);
  return false;
}


// the most basic way to move a cube to target position
// speed is constant
boolean aimCube(int id, float tx, float ty) {
  fill(0, 255, 0);
  ellipse(tx, ty, 10, 10);

  if (cubes[id].distance(tx, ty)<25) return true;
  int[] lr = cubes[id].aim(tx, ty);

  float left = (lr[0]*.5);
  float right = (lr[1]*.5);
  int duration = (100);
  motorControl(id, left, right, duration);
  return false;
}


// the most basic way to move a cube to target position
// speed is variable
boolean aimCubeSpeed(int id, float tx, float ty) {
  //fill(0, 255, 0);
  //ellipse(tx, ty, 10, 10);

  float dd = cubes[id].distance(tx, ty)/50.0;
  dd = min(dd, 1);
  if (dd <.10) return true;


  int[] lr = cubes[id].aim(tx, ty);

  float left = (lr[0]*dd);
  float right = (lr[1]*dd);
  int duration = (100);
  motorControl(id, left, right, duration);
  return false;
}


boolean aimCubePosVel(int id, float tx, float ty, float vx, float vy) {
  
  /////previously defined as .aim
  int left = 0;
  int right = 0;
  float angleToTarget = atan2(ty-cubes[id].y, tx-cubes[id].x);
  float thisAngle = cubes[id].deg*PI/180;
  float diffAngle = thisAngle-angleToTarget;
  if (diffAngle > PI) diffAngle -= TWO_PI;
  if (diffAngle < -PI) diffAngle += TWO_PI;

  //if in front, go forward and
  if (abs(diffAngle) < HALF_PI) { //in front
    float frac = cos(diffAngle);

    if (diffAngle > 0) {
      //up-left
      left = floor(maxMotorSpeed*pow(frac, 2));
      right = maxMotorSpeed;
    } else {
      left = maxMotorSpeed;
      right = floor(maxMotorSpeed*pow(frac, 2));
    }
  } else { //face back

    float frac = -cos(diffAngle);
    if (diffAngle > 0) {
      left  = -floor(maxMotorSpeed*pow(frac, 2));
      right =  -maxMotorSpeed;
    } else {
      left  =  -maxMotorSpeed;
      right = -floor(maxMotorSpeed*pow(frac, 2));
    }
  }
  int[] lr = {left, right};
  //////

  float angleToVelocity = atan2(vy, vx);
  float diffVAngle = thisAngle-angleToVelocity;
  if (diffVAngle > PI) diffVAngle -= TWO_PI;
  if (diffVAngle < -PI) diffVAngle += TWO_PI;

  if (diffAngle > 0) {
    diffVAngle = -diffVAngle;
  }



  float velIntegrate = sqrt(sq(vx)+sq(vy)); // integrate velocity x + y

  float veltoioIntegrate = sqrt(sq(cubes[id].ave_speedX)+sq(cubes[id].ave_speedY));
  float aimMotSpeed = velIntegrate / 2.0; // translate the speed (pixel/s)  to motor control command /// Maximum is 115 =>

  //println("diffVAngle = ", degrees(diffVAngle));
  float aa = 0;
  if (lr[0]<0) { //facing back
    aa = -aimMotSpeed;
    //if (diffVAngle<0) {
    //  aa = aimMotSpeed;
    //} else {
    //  aa = -aimMotSpeed;
    //}
  } else { //facing front
    aa = aimMotSpeed;
    //if (diffVAngle<0) {
    //  aa = -aimMotSpeed;
    //} else {
    //  aa = aimMotSpeed;
    //}
  }


  float dd = cubes[id].distance(tx, ty)/50.0;
  dd = min(dd, 1);
  //  if (dd <.10) return true; // keep the motor moving


  //int[] lr = cubes[id].aim(tx, ty);



  float left_ = constrain(aa + (lr[0]*dd), -115, 115);
  float right_ = constrain(aa + (lr[1]*dd), -115, 115);
  int duration = (50);
  
  
  
  
  
  motorControl(id, left_, right_, duration);
  
  

  float d = dist(cubes[id].x, cubes[id].y, tx, ty);

  float targetV_a = atan2( vy, vx);

  //println(degrees(targetV_a), cubes[id].deg);

  //println("targetV: ", velIntegrate, "intendedMotor: ", aimMotSpeed, "  actualSpeed: ", veltoioIntegrate, "|  MotorOutput: ", left_, right_, "| distance: ", dd, d);
  return false;
}
