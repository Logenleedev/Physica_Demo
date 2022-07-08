void toio_collision() {
  final float mDeltaTime = 1.0f / frameRate;
  mPhysics.step(mDeltaTime);

  stroke(255, 255, 0);
  fill(255, 0, 0);

  ellipse(mParticle.position().x, mParticle.position().y, 10, 10);



  stroke(204, 102, 0);


  for (int i = 0; i< nCubes; ++i) {





    if (cubes[i].isLost==false && cubes[i].p_isLost == true) {
      mParticle.position().set(cubes[i].x, cubes[i].y);
      mParticle.velocity().set(0, 0);
    }
    if (cubes[i].isLost==false) {
      if (cubes[i].state == 1) {
        aimCubePosVel(cubes[i].id, mParticle.position().x, mParticle.position().y, mParticle.velocity().y, mParticle.velocity().x);
      }

      println("current: "+ cubes[i].speedY);
      //println("pre: "+ cubes[i].preSpeedY);
      println("----------------");
      if (dist(cubes[i].x, cubes[i].y, mParticle.position().x, mParticle.position().y) > 20 && sqrt(pow(cubes[i].speedY, 2) + pow(cubes[i].speedX, 2)) == 0) {
        mParticle.position().set(cubes[i].x, cubes[i].y);
        mParticle.velocity().set(mParticle.velocity().x, -1*(mParticle.velocity().y));

        cubes[i].state += 1;
      }
      if (cubes[i].state >= 2) {

        aimCubePosVel(cubes[i].id, mParticle.position().x, mParticle.position().y, mParticle.velocity().y, mParticle.velocity().x);
      }
    }
  }
}
