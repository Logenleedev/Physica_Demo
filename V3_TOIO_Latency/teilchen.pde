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

boolean chase = false;
boolean spin = false;
boolean drop = false;


void setupPhysica(){
  
  //mPhysics = new Physics();
  ///* create a gravitational force */
  //Gravity mGravity = new Gravity();
  ///* the direction of the gravity is defined by the 'force' vector */
  //mGravity.force().set(0, 30); //30
  ///* forces, like gravity or any other force, can be added to the system. they will be automatically applied to
  // all particles */
  //mPhysics.add(mGravity);
  ///* create a particle and add it to the system */
  //mParticle = mPhysics.makeParticle();
  mPhysics = new Physics();
  mDeflector = new PlaneDeflector();
  /* set plane origin into the center of the screen */
  mDeflector.plane().origin.set(width / 2.0f, height / 2.0f + 150, 0);
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
