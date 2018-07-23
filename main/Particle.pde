public class Particle {
  
  private static final int BASE_RADIUS = 20;
  PVector shapeDelta = new PVector(random(-MAX_POS_DELTA, MAX_POS_DELTA), random(-MAX_POS_DELTA, MAX_POS_DELTA), random(-MAX_POS_DELTA, MAX_POS_DELTA));
  
  private int radius;
  private int col;
  private PVector direction;
  private PVector velocity;
  private float distanceFromSpawn;
  
  private PVector acceleration;
  private PShape shape;
  private PVector pos;
  
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
    this(radius, col, direction, new PVector(0, 0, 0));
  }
  
  private Particle(int radius, int col, PVector direction, PVector velocity) {
    this.radius = radius;
    this.col = col;
    this.direction = direction;
    this.velocity = velocity;
    this.acceleration = new PVector(0, 0, 0);
    this.distanceFromSpawn = 0.0f;
    this.pos = new PVector (0, 0, 0);
    this.createParticleShape();
  }
  
  public void createParticleShape(){
    PShape particleShape = createShape(SPHERE, this.radius);
    particleShape.setFill(this.col);
    particleShape.setStroke(false);
    this.shape = particleShape;
  }
  
  public void drawParticle(){
    shape(this.shape);
  }
  
  public void move(PVector velocity){
    //PVector transVector = this.direction.mult(this.velocity);
    distanceFromSpawn += PVector.dist(new PVector(0, 0, 0), new PVector(velocity.x, velocity.y, velocity.z));
    this.pos.add(velocity);
    this.shape.translate(velocity.x, velocity.y, velocity.z);
  }
  
  public void applyForce(PVector force){
    PVector f = PVector.div(force, this.radius);
    this.acceleration.add(f);
  }
  
  public void createTrail(PVector from, PVector to, int col) {
    beginShape(LINES);
    vertex(from.x, from.y, from.z);
    vertex(to.x, to.y, to.z);
    strokeWeight(1);
    stroke(col);
    endShape();
  }
  
  public void update(){
    shape.setFill(this.col);
    this.velocity.add(this.acceleration);
    this.move(this.velocity);
    if(this.velocity.mag() > 75.0) {
      this.createTrail(this.pos.copy().sub(this.velocity.copy().mult(10.0f)), this.pos, this.col);
    }
    this.drawParticle();
    this.acceleration.mult(0);
    this.velocity.mult(0.98f);
  }
  
  public int getColor() { return this.col; }
  public void setColor(int col) { this.col = col; }
  public PVector getDirection() { return this.direction; }
  public void setDirection(PVector direction) { this.direction = direction; }
  public float getDistanceFromSpawn() { return this.distanceFromSpawn; }
  public PVector getPos() { return this.pos; }
  public void setPos(PVector pos) { this.pos = pos; }
  public int getRadius() { return this.radius; }
  public void setRadius(int r) { this.radius = r; }
  public void setVelocity(PVector velocity){ this.velocity = velocity; }
}
