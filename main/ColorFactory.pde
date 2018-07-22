/** Returns a completly random color */

public class ColorFactory{

  public ColorFactory() {};
  
  /** Returns a random color */
  public int randomColor() {
    return color(random(150, 255), random(150, 255), random(150, 255));
  }
  
  /**
   * Returns a random color within the given ranges of each color
   * @param r {PVector} (from int{0-255}, to int{0-255})
   * @param g {PVector} (from int{0-255}, to int{0-255})
   * @param b {PVector} (from int{0-255}, to int{0-255})
   * @example randomColorRange(PVector(100, 255), PVector(100, 255), PVector(100, 255))
   */
  public int randomColorRange(PVector r, PVector g, PVector b) {
    return color(random(r.x, r.y), random(g.x, g.y), random(b.x, b.y));
  }

  public int randomBrightColor(int minLightness) {
    return color(random(minLightness, 255), random(minLightness, 255), random(minLightness, 255));
  }
  
}
