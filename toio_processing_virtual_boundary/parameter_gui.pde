void parameter_gui() {
  cp5 = new ControlP5(this);

  // group number 1, contains 2 bangs
  Group g1 = cp5.addGroup("Motion")
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(200)
    ;
  checkbox = cp5.addCheckBox("checkBox")
    .setPosition(40, 40)
    .setSize(20, 20)
    .setItemsPerRow(1)
    .setSpacingColumn(30)
    .setSpacingRow(20)
    .addItem("Velocity", 0)
    .addItem("Acceleration", 50)
    .moveTo(g1)
    ;

  // group number 1, contains 2 bangs
  Group g2 = cp5.addGroup("Object Graphic")
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(300)
    ;
    
  checkbox1 = cp5.addCheckBox("checkBox1")
    .setPosition(40, 60)
    .setSize(20, 20)
    .setItemsPerRow(1)
    .setSpacingColumn(30)
    .setSpacingRow(20)
    .addItem("Show plane", 0)
    .addItem("Show object", 50)
    .addItem("Show object path", 100)
    .moveTo(g2)
    ;

  accordion = cp5.addAccordion("acc")
    .setPosition(600, 100)
    .setWidth(200)
    .addItem(g1)
    .addItem(g2)
    ;
}
