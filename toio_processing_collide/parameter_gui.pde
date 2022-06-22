void parameter_gui(){
  cp5 = new ControlP5(this);
  
  // group number 1, contains 2 bangs
  Group g1 = cp5.addGroup("environment parammeter")
                .setBackgroundColor(color(0, 64))
                .setBackgroundHeight(150)
                ;
   cp5.addSlider("gravity")
     .setPosition(40,60)
     .setSize(100,20)
     .setRange(0, 200)
     .setValue(30)
     .moveTo(g1);
    
  accordion = cp5.addAccordion("acc")
                 .setPosition(600,40)
                 .setWidth(200)
                 .addItem(g1)
                 ;
}
