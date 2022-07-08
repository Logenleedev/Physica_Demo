

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


  for (int i = 0; i< 1; ++i) {

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
