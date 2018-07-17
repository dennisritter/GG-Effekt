public class Particle {
  
  private static final int BASE_RADIUS = 20;
  
  private int radius;
  private int color;
  
  public Particle() {
    this(BASE_RADIUS);
  }
  
  public Particle(int radius) {
    this(radius, color(random(0, 255), random(0, 255), random(0, 255)));
  }
  
  public Particle(int radius, int color) {
    this.radius = radius;
    this.color = color;
  }
}
