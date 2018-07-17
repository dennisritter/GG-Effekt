public class Particle {
  
  private static final int BASE_RADIUS = 20;
  PVector shapeDelta = new PVector(random(-MAX_POS_DELTA, MAX_POS_DELTA), random(-MAX_POS_DELTA, MAX_POS_DELTA), random(-MAX_POS_DELTA, MAX_POS_DELTA));
  
  private int radius;
  private int col;
  private PVector direction;
  private float velocity;
  
  private PShape shape;
  
  public Particle() {
    this(BASE_RADIUS);
  }
  
  public Particle(int radius) {
    this(radius, color(random(0, 255), random(0, 255), random(0, 255)));
  }
  
  public Particle(int radius, int col) {
    this(radius, col, PVector.random3D());
  }
  
  public Particle(int radius, int col, PVector direction) {
    this(radius, col, direction, 0.0f);
  }
  
  private Particle(int radius, int col, PVector direction, float velocity) {
    this.radius = radius;
    this.col = col;
    this.direction = direction;
    this.velocity = velocity;
    this.constructParticle();
  }
  
  public void constructParticle(){
    PShape particleShape = createShape(SPHERE, this.radius);
    particleShape.setFill(this.col);
    particleShape.setStroke(false);
    this.shape = particleShape;
  }
  
  public void drawParticle(){
    shape(this.shape);
  }
  
  public void moveParticle(){
  
  }
  
}
