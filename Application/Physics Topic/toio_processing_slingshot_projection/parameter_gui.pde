void parameter_gui() {
  cp5 = new ControlP5(this);

  // group number 1, contains 2 bangs
  Group g1 = cp5.addGroup("environment parammeter")
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(250)
    ;

  // interaction technique group
  Group g2 = cp5.addGroup("interaction technique")
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(100)
    ;
  // group number 1, contains 2 bangs
  Group g3 = cp5.addGroup("Object Graphic")
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(300)
    ;
    
  // group number 1, contains 2 bangs
  Group g4 = cp5.addGroup("Motion")
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(200)
    ;


  cp5.addSlider("gravity")
    .setPosition(80, 60)
    .setSize(100, 20)
    .setRange(0, 200)
    .setValue(50)
    .moveTo(g1);

  cp5.addSlider("spring strength")
    .setPosition(80, 100)
    .setSize(100, 20)
    .setRange(0, 5)
    .setValue(2)
    .moveTo(g1);

  cp5.addSlider("spring damping")
    .setPosition(80, 140)
    .setSize(100, 20)
    .setRange(0, 1)
    .setValue(0.1)
    .moveTo(g1);

  cp5.addSlider("spring length")
    .setPosition(80, 180)
    .setSize(100, 20)
    .setRange(0, 70)
    .setValue(45)
    .moveTo(g1);


  // Interaction technique checkbox
  checkbox = cp5.addCheckBox("checkBox")
    .setPosition(40, 40)
    .setColorLabel(color(0))
    .setSize(20, 20)
    .setItemsPerRow(1)
    .setSpacingColumn(30)
    .setSpacingRow(20)
    .addItem("Grab and release", 0)
    .moveTo(g2)
    ;

  checkbox2 = cp5.addCheckBox("checkBox2")
    .setColorLabel(color(0))
    .setPosition(40, 60)
    .setSize(20, 20)
    .setItemsPerRow(1)
    .setSpacingColumn(30)
    .setSpacingRow(20)
    .addItem("Show spring", 0)
    .addItem("Show particle", 50)
    .addItem("Show object path", 100)
    .addItem("Show object position", 100)
    .moveTo(g3)
    ;
    
    
  checkbox3 = cp5.addCheckBox("checkBox3")
    .setColorLabel(color(0))
    .setPosition(40, 40)
    .setSize(20, 20)
    .setItemsPerRow(1)
    .setSpacingColumn(30)
    .setSpacingRow(20)
    .addItem("Object velocity", 0)
    .addItem("Particle velocity", 50)
    .addItem("Show force", 100)
    .moveTo(g4)
    ;

  accordion = cp5.addAccordion("acc")
    .setPosition(600, 100)
    .setWidth(300)
    .addItem(g1)
    .addItem(g2)
    .addItem(g3)
    .addItem(g4)
    ;
}
