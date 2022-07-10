boolean shoot(float current_pos_x, float previous_pos_x, float current_pos_y, float previous_pos_y){
  

  
  if (dist(current_pos_x,  current_pos_y, previous_pos_x, previous_pos_y) > 20){
    
    return true;
  } else {
    return false;
  }
}
