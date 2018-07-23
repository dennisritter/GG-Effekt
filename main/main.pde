import peasy.*;

import ddf.minim.*;
import ddf.minim.analysis.*;

import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

import de.looksgood.ani.*;

PVector light = new PVector();  // Light direction for shading
PeasyCam cam;   // Useful camera library

Minim minim;
AudioPlayer song;
AudioInput input;
BeatDetect beatAMP;
BeatDetect beatSENS;

PostFX fx;

int SONG_SKIP_MILLISECONDS = 5000;
int BASE_RADIUS = 300;
int MAX_POS_DELTA = 5;
float MAX_COLOR_DELTA = 1.0;
ColorFactory colorFactory = new ColorFactory();

PVector camRotationAngle = new PVector(0.5, 1.0, 2.0);
int radius = BASE_RADIUS;

// The main Sphere in Center
PShape sphere;

float forceStr = 0.0f;
int bloomSize = radius / 20;
ArrayList<Particle> particles = new ArrayList<Particle>();

void setup() {
  
    fullScreen(P3D);
    //size(1920, 1080, P3D);
    //size(1024, 720, P3D);
    
    // init PostFX
    fx = new PostFX(this);
    
    Ani.init(this);
    
    // Setup camera
    cam = new PeasyCam(this, 2500);
    cam.setWheelScale(0.1);
    
    // Setup Sound
    minim = new Minim(this);
    song = minim.loadFile("../assets/levitation.mp3");
    beatAMP = new BeatDetect();
    beatAMP.setSensitivity(200);
    beatAMP.detectMode(BeatDetect.SOUND_ENERGY);
    beatSENS = new BeatDetect();
    beatSENS.setSensitivity(10);
    beatSENS.detectMode(BeatDetect.SOUND_ENERGY);
    input = minim.getLineIn();

    song.play();
}

void draw() {
  background(0);
  beatAMP.detect(song.mix);
  beatSENS.detect(song.mix);
  
  noStroke();
  fill(255,255,255);
  sphere = createShape(SPHERE, radius);
  shape(sphere);
  

  int pColor = colorFactory.randomBrightColor(100);
  int pRadius = (int) random(BASE_RADIUS / 40.0f, BASE_RADIUS / 5.0f);
  int spawnBias =  5;
  Particle p = new Particle(pRadius, pColor);
  p.move(p.getDirection().mult(BASE_RADIUS - pRadius - spawnBias));
  particles.add(p);

  if (beatSENS.isOnset()) {
    if (forceStr <= 0.0f) forceStr += 1.0f;
    else forceStr += 0.25f;
    if(forceStr > 2.5f) forceStr = 2.5f;
  }
  
  // If Amplitude Peak is detected
  if (beatAMP.isOnset()) {
    Ani.to(this, .5, "radius", BASE_RADIUS * 1.5);
    Ani.to(this, .5, "bloomSize", radius / 2);
    
  } else {
    Ani.to(this, .5, "radius", BASE_RADIUS);
    Ani.to(this, .5, "bloomSize", radius / 20);
  }
  
  // Animate all particles
  for(Particle particle : new ArrayList<Particle>(particles)){
    if (particle.distanceFromSpawn >= 4000) {
      particle.setColor(colorFactory.darken(particle.getColor(), 10));
    }
    if (particle.distanceFromSpawn >= 5000) {
      particles.remove(particle);
    }
    
    if (beatSENS.isOnset()) {
      particle.setColor(colorFactory.darken(particle.getColor(), 3));
    }
    
    if (beatAMP.isOnset()) {
      // Init Force with direction and current force strengh
      PVector pDirection = particle.getDirection();
      PVector force = pDirection.copy().mult(forceStr);
      
      particle.applyForce(force);
    }
 
    particle.update();
  }
  
  // Apply Bloom Effect
  fx.render().bloom(.5, bloomSize, 30).compose();
  //println(frameRate);
  //println(particles.size());
}

void keyPressed() {
  if (key == CODED) {
    // Left/right arrow keys: seek song
    if (keyCode == LEFT) {
      song.skip(-SONG_SKIP_MILLISECONDS);
    } 
    else if (keyCode == RIGHT) {
      song.skip(SONG_SKIP_MILLISECONDS);
    }
  }
  // Space bar: play/pause
  else if (key == ' ') {
    if (song.isPlaying())
      song.pause();
    else
      song.play();
  }
  // Enter: spit out the current position
  // (for syncing)
  else if (key == ENTER) {
    print(song.position() + ", ");
  }
}
