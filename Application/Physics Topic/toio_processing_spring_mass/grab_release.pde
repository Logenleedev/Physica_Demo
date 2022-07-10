

void setup_grab_release() {
  println("triggered!");
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
}

void grab_release() {
  /* update the particle system */
  final float mDeltaTime = 1.0f / frameRate;
  mPhysics.step(mDeltaTime);


  if (cubes[0].isLost==false && cubes[0].pre_press == 0 && cubes[0].press == 128) {
    mSpring.a().position().set(cubes[0].x, cubes[0].y);
  }


  println(mSpring.strength());



  for (int i = 0; i< nCubes; ++i) {
    // draw history path
    if (checkbox2.getArrayValue()[2] == 1) {
      offscreen.fill(26, 82, 118);
      offscreen.stroke(26, 82, 118);
      for (int j = 0; j < cubes[i].aveFrameNumPosition; j++) {

        offscreen.ellipse(cubes[i].cube_position_x[j] - projection_correction, cubes[i].cube_position_y[j] - projection_correction, 2, 2);
      }
    }
    
    
    if (checkbox3.getArrayValue()[0] == 1) {
      // draw velocity vector
      offscreen.pushMatrix();
      offscreen.translate(cubes[i].x, cubes[i].y);
      offscreen.stroke(255, 0, 0);
      drawArrow(0, 0, cubes[i].ave_speedX, cubes[i].ave_speedY, 0);
      offscreen.popMatrix();
    }

    if (checkbox3.getArrayValue()[1] == 1) {
      // draw mParticle vector
      offscreen.pushMatrix();
      offscreen.translate(cubes[i].x, cubes[i].y);
      offscreen.stroke(155, 89, 182);
      drawArrow(0, 0, mSpring.b().velocity().x - projection_correction, mSpring.b().velocity().y - projection_correction, 0);
      offscreen.popMatrix();
    }
    if (cubes[i].isLost == true) {
      cubes[i].pre_press = 0;
      cubes[i].press = 0;

      // draw spring
      if (checkbox2.getArrayValue()[0] == 1 ) {
        offscreen.stroke(0, 0, 0);
        offscreen.fill(0, 0, 0);
        offscreen.ellipse(mSpring.a().position().x - projection_correction, mSpring.a().position().y - projection_correction, 5, 5);
        offscreen.line(mSpring.a().position().x - projection_correction, mSpring.a().position().y - projection_correction,
          mSpring.b().position().x - projection_correction, mSpring.b().position().y - projection_correction);
      }
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


        // draw spring
        if (checkbox2.getArrayValue()[0] == 1 ) {
          // Spring and anchor
          offscreen.stroke(0, 0, 0);
          offscreen.fill(0, 0, 0);
          offscreen.ellipse(mSpring.a().position().x - projection_correction, mSpring.a().position().y - projection_correction, 5, 5);
        }

        aimCubePosVel(cubes[i].id, mSpring.b().position().x, mSpring.b().position().y, mSpring.b().velocity().x, mSpring.b().velocity().y);
        if ( eventDetection(cubes[i].x, cubes[i].y, cubes[i].prex, cubes[i].prey, cubes[i].speedX, cubes[i].speedY) ) {
          mSpring.b().position().set(cubes[i].x, cubes[i].y);
        
        }


     

      
    }
  }
}
