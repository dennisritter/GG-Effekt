import peasy.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
 
PVector light = new PVector();  // Light direction for shading
PeasyCam cam;   // Useful camera library
Minim minim;
AudioPlayer song;
AudioInput input;
BeatDetect beatFRQ;
BeatDetect beatAMP;

void setup() {
    //fullScreen(P3D);
    size(1024, 720, P3D);
    
    // Setup camera
    cam = new PeasyCam(this, 1000);
    cam.setWheelScale(0.1);
    
    // Setup Sound
    minim = new Minim(this);
    song = minim.loadFile("../assets/levitation.mp3", 1024);
    beatFRQ = new BeatDetect(song.bufferSize(), song.sampleRate());
    beatAMP = new BeatDetect(song.bufferSize(), song.sampleRate());
    input = minim.getLineIn();
    
    
    // Play the loaded song
    song.play();
}

void drawWaveform() {
  stroke(255);
  // we draw the waveform by connecting neighbor values with a line
  // we multiply each of the values by 50 
  // because the values in the buffers are normalized
  // this means that they have values between -1 and 1. 
  // If we don't scale them up our waveform 
  // will look more or less like a straight line.
  for(int i = 0; i < song.bufferSize() - 1; i++)
  {
    line(i - width/2, 50 + song.left.get(i)*50, i+1 - width/2, 50 + song.left.get(i+1)*50);
    line(i - width/2, 150 + song.right.get(i)*50, i+1 - width/2, 150 + song.right.get(i+1)*50);
  }
}

void draw() {
  background(0);
  // Calculate the light position
  final float t = TWO_PI * (millis() / 1000.0) / 10.0;
  light.set(sin(t) * 160, -160, cos(t) * 160);
  
  drawWaveform();
  
  // Beat Detection Setup
  beatFRQ.detect(song.mix);
  beatFRQ.detectMode(BeatDetect.FREQ_ENERGY);
  translate(0, -200, 0);
  PVector colorRGB = new PVector(0, 0, 0);
  if(beatFRQ.isKick()) {
    colorRGB.x = 255;
  };
  if(beatFRQ.isHat()) {
    //colorRGB.y = 255;
  };
  if(beatFRQ.isSnare()) {
    //colorRGB.z = 255;
  };
  if(colorRGB.x + colorRGB.y + colorRGB.z == 0) colorRGB.add(255, 255, 255);
  color c = color(colorRGB.x, colorRGB.y, colorRGB.z);
  
  beatAMP.detectMode(BeatDetect.SOUND_ENERGY);
  beatAMP.detect(song.mix);
  int radius = beatAMP.isOnset() ? 100 : 50;
  //int radius = beat.isRange(0,1024,1) ? 100 : 50;
  
  lights();
  noStroke();
  fill(c);
  sphere(radius);
}