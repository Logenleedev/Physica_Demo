class Cube {
  int x;
  int y;
  int prex;
  int prey;
  float targetx =-1;
  float targety =-1;
  
  float currentMotL = 0;
  float currentMotR = 0;

  float speedX;
  float speedY;


  boolean buttonState = false;
  boolean targetMode = false;


  boolean collisionState = false;
  boolean tiltState = false;


  boolean isLost = true;
  boolean p_isLost = true;


  int id;
  int deg;
  long lastUpdate;
  int count=0;

  int aveFrameNum = 10;
  float pre_speedX[] = new float [aveFrameNum];
  float pre_speedY[] = new float [aveFrameNum];

  float ave_speedX;
  float ave_speedY;

  Cube(int i, boolean lost) {
    id = i;
    isLost=lost;

    lastUpdate = System.currentTimeMillis();

    for (int j = 0; j< aveFrameNum; j++) {
      pre_speedX[j] = 0;
      pre_speedY[j] = 0;
    }
  }
  void resetCount() {
    count =0;
  }

  boolean isAlive(long now) {
    return(now < lastUpdate+200);
  }



  //This function defines how the cubes aims at something
  //the perceived behavior will strongly depend on this
  int[] aim(float tx, float ty) {

    int left = 0;
    int right = 0;
    float angleToTarget = atan2(ty-y, tx-x);
    float thisAngle = deg*PI/180;
    float diffAngle = thisAngle-angleToTarget;
    if (diffAngle > PI) diffAngle -= TWO_PI;
    if (diffAngle < -PI) diffAngle += TWO_PI;
    //if in front, go forward and
    //println(diffAngle);
    if (abs(diffAngle) < HALF_PI) { //in front
      
      float frac = cos(diffAngle);

      //println(frac);
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
        left  = -floor(maxMotorSpeed*frac);
        right =  -maxMotorSpeed;
      } else {
        left  =  -maxMotorSpeed;
        right = -floor(maxMotorSpeed*frac);
      }
    }


    //println(left +" " + right);
    int[] res = new int[2];
    res[0] = left;
    res[1] = right;
    return res;
  }
  float distance(Cube o) {
    return distance(o.x, o.y);
  }

  float distance(float ox, float oy) {
    return sqrt ( (x-ox)*(x-ox) + (y-oy)*(y-oy));
  }
}
