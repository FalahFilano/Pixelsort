import controlP5.*;
ControlP5 cp5;
Range range;
RadioButton radio, orientation;
Accordion accordion;
Button button;

PImage origin;
PImage img;
PImage bw;
PImage sorted;

int dark = 105;
int light = 40;
int sortMode;
int orientationMode;

void thresholdPass(){
  bw = img.get();
  color highpass = color(dark, dark, dark);
  color lowpass = color(light, light, light);
  bw.filter(GRAY);
  for (int i=0 ; i<bw.pixels.length ; i++){
    if(bw.pixels[i] >= lowpass && bw.pixels[i] <= highpass)
      bw.pixels[i] = color(0, 0, 0);
    else 
      bw.pixels[i] = color(255, 255, 255);
  }
  bw.filter(INVERT);
}

void checkRange(){
  int start = 0;
  int finish = 0;
  sorted = img.get();
  
  for(int i=0; i<bw.pixels.length; i++){
    //print(bw.pixels[i], "\n");
    if (bw.pixels[i] == color(0,0,0)){  //black
      if (i==0 || bw.pixels[i-1] != color(0,0,0)){ //awal point
        start = i;
        finish = i; 
      }else finish = i;
    }
    if (bw.pixels[i] == color(255,255,255)){ //white
      pixelsort(start, finish);
      start = 0;
      finish = 0;
    }
  }
}

void pixelsort(int s, int f){
  sorted.loadPixels();
  for(int i=s ; i<=f; i++){
    float record;
    switch(orientationMode){
      case(2): record = -1; break;
      case(4): record = 2000; break;
      default: record = -1;
    }
    
    int selectedPixel = i;
    for(int j=i ; j<f ; j++){
      //if(j %(sorted.width) == 0) break; 
      color pix = sorted.pixels[j];
      
      float b;
      switch(sortMode){
        case(1): b = hue(pix); break;
        case(2): b = saturation(pix); break;
        case(3): b = brightness(pix); break;
        default: b = brightness(pix);
      }
      
      switch(orientationMode){
        case(2):if(b > record){
                  selectedPixel = j;
                  record = b;
                }; break;
        case(4):if(b < record){
                  selectedPixel = j;
                  record = b;
                }; break;  
        default:if(b > record){
                  selectedPixel = j;
                  record = b;
                };
      }
      
    }
    color temp = sorted.pixels[i];
    sorted.pixels[i] = sorted.pixels[selectedPixel];
    sorted.pixels[selectedPixel] = temp;
  }
  sorted.updatePixels();
}

void horizontalcheckRange(){
  int start = 0;
  int finish = 0;
  sorted = img.get();
  
  for(int i=0; i<bw.width; i++){
    for(int j=i; j<bw.pixels.length; j+=bw.width){
      
      if (bw.pixels[j] == color(0,0,0)){  //black
        if (j-bw.width<0 || bw.pixels[j-bw.width] != color(0,0,0)){ //awal point
          start = j;
          finish = j; 
        }else finish = j;
      }
      if (bw.pixels[j] == color(255,255,255)){ //white
        horizontalpixelsort(start, finish);
        start = 0;
        finish = 0;
      }  
    }
    
  } 
}

void horizontalpixelsort(int s, int f){
  sorted.loadPixels();
  for(int i=s ; i<=f; i+=sorted.width){
    float record;
    switch(orientationMode){
      case(1): record = -1; break;
      case(3): record = 2000; break;
      default: record = -1;
    }
    
    int selectedPixel = i;
    for(int j=i ; j<f ; j+=sorted.width){
      //if(j %(sorted.width) == 0) break; 
      color pix = sorted.pixels[j];
      
      float b;
      switch(sortMode){
        case(1): b = hue(pix); break;
        case(2): b = saturation(pix); break;
        case(3): b = brightness(pix); break;
        default: b = brightness(pix);
      }
      
      switch(orientationMode){
        case(1):if(b > record){
                  selectedPixel = j;
                  record = b;
                }; break;
        case(3):if(b < record){
                  selectedPixel = j;
                  record = b;
                }; break;  
        default:if(b > record){
                  selectedPixel = j;
                  record = b;
                };
      }
      
    }
    color temp = sorted.pixels[i];
    sorted.pixels[i] = sorted.pixels[selectedPixel];
    sorted.pixels[selectedPixel] = temp;
  }
  sorted.updatePixels();
}

void controlEvent(ControlEvent theControlEvent) {
  if(theControlEvent.isFrom("Threshold")) {
    light = int(theControlEvent.getController().getArrayValue(0));
    dark = int(theControlEvent.getController().getArrayValue(1));
  }
  if(theControlEvent.isFrom(radio)){
    sortMode = int(theControlEvent.getValue());
    println(sortMode);
  }
  if(theControlEvent.isFrom(orientation)){
    orientationMode = int(theControlEvent.getValue());
    println(orientationMode);
  }
  if(theControlEvent.isFrom(button)){
    selectInput("Select a file to process:", "fileSelected");
  }
}

void GUI(){
  cp5 = new ControlP5 (this);
  Group g1 = cp5.addGroup("Control")
                .setBackgroundColor(color(0, 100))
                .setBackgroundHeight(150)
                ;
                
  range = cp5.addRange("Threshold")
             // disable broadcasting since setRange and setRangeValues will trigger an event
             .setBroadcast(false) 
             .setPosition(10,10)
             .setSize(200,20)
             .setHandleSize(10)
             .setRange(0,255)
             .setRangeValues(50,100)
             // after the initialization we turn broadcast back on again
             .setBroadcast(true)
             .moveTo(g1);
             ;
            
  
  radio = cp5.addRadioButton("radioButton")
         .setPosition(10,40)
         .setSize(15,15)
         .setColorForeground(color(120))
         .setColorLabel(color(255))
         .setItemsPerRow(3)
         .setSpacingColumn(55)
         .addItem("Hue",1)
         .addItem("Saturation",2)
         .addItem("Lightness",3)
         .setNoneSelectedAllowed(false)
         .moveTo(g1);
         ;
      for(Toggle t:radio.getItems()) {
       t.getCaptionLabel().setColorBackground(color(0,50));
       t.getCaptionLabel().getStyle().moveMargin(-7,0,0,-3);
       t.getCaptionLabel().getStyle().movePadding(7,0,0,3);
       t.getCaptionLabel().getStyle().backgroundWidth = 45;
       t.getCaptionLabel().getStyle().backgroundHeight = 13;
     }
  
  orientation = cp5.addRadioButton("orientation")
                   .setPosition(10,80)
                   .setSize(15,15)
                   .setColorForeground(color(120))
                   .setColorLabel(color(255))
                   .setItemsPerRow(2)
                   .setSpacingColumn(55)
                   .addItem("Up",1)
                   .addItem("Left",2)
                   .addItem("Down",3)
                   .addItem("Right",4)
                   .setNoneSelectedAllowed(false)
                   .moveTo(g1);
                   ;
      for(Toggle t:orientation.getItems()) {
       t.getCaptionLabel().setColorBackground(color(0,100));
       t.getCaptionLabel().getStyle().moveMargin(-7,0,0,-3);
       t.getCaptionLabel().getStyle().movePadding(7,0,0,3);
       t.getCaptionLabel().getStyle().backgroundWidth = 45;
       t.getCaptionLabel().getStyle().backgroundHeight = 13;
     }
button = cp5.addButton("Select File")
     .setValue(0)
     .setPosition(20,20)
     .setSize(100,20)
     ;     
accordion = cp5.addAccordion("acc")
               .setPosition(20,50)
               .setSize(300,20)
               .addItem(g1)
               ;
      cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.open(0,1,2);}}, 'o');
      cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.close(0,1,2);}}, 'c');
      cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setWidth(300);}}, '1');
      cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setPosition(0,0);accordion.setItemHeight(190);}}, '2'); 
      cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setCollapseMode(ControlP5.ALL);}}, '3');
      cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setCollapseMode(ControlP5.SINGLE);}}, '4');
      cp5.mapKeyFor(new ControlKey() {public void keyEvent() {cp5.remove("myGroup1");}}, '0');
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    img = loadImage(selection.getAbsolutePath());
    surface.setSize(img.width*2, img.height);
  }
}

void setup(){
  
  img = createImage(400, 400, RGB); //load initial pixel
  surface.setSize(img.width*2, img.height);
  //selectInput("Select a file to process:", "fileSelected");
  GUI();
}

void draw(){
  background(0);
  
    thresholdPass();
    switch(orientationMode){
      case(3):
      case(1): horizontalcheckRange(); break;
      case(4):
      case(2): checkRange(); break;
      default: horizontalcheckRange();
    }
    
  image(bw, 0, 0);
  image(sorted, img.width, 0);
  //image(img, 0, img.height-img.height/3, img.width/3, img.height/3);
}