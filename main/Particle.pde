public class Particle {
  
  private static final int BASE_RADIUS = 20;
  PVector shapeDelta = new PVector(random(-MAX_POS_DELTA, MAX_POS_DELTA), random(-MAX_POS_DELTA, MAX_POS_DELTA), random(-MAX_POS_DELTA, MAX_POS_DELTA));
  
  private int radius;
  private int color;
  private PVector direction;
  
  public Particle() {
    this(BASE_RADIUS);
  }
  
  public Particle(int radius) {
    this(radius, color(random(0, 255), random(0, 255), random(0, 255)));
  }
  
  public Particle(int radius, int color) {
    this(radius, color, PVector.random3D());
  }
  
  public Particle(int radius, int color, PVector direction) {
    this.radius = radius;
    this.color = color;
    this.direction = direction;
  }
  
  
  
}
