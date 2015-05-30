PImage source;           // Source image
PImage thresholdFilter;  // Threhold Filter image
String imgName;

// Simple Point Class
public class Point
{
 int x, y; 
 public Point(int x, int y)
 {
   this.x = x;
   this.y = y;
 }
}

// 
// Program starts here.
//
void setup() {
  // Load the image.
  imgName = "6";
  source = loadImage("" + imgName + ".jpg");  
  
  // The threshold filter image is created as a blank image the same size as the source.
  thresholdFilter = createImage(source.width, source.height, RGB);
  
  // Set the size of the canvas to the image size
  size(source.width, source.height);
  
  // Only draw once.
  noLoop();
}

//
// Called after setup() finishes.
//
void draw() {  
  // 0.) Draw original image to the screen.
  image(source,0,0);  
  
  // 1.) Apply Black/White threshold filter.
  applyThresholdFilter(source, thresholdFilter);
  
  // 2.) Find the bounding box via the minimum and maximums of white pixels.
  //     This is not guarunteed to be a square, but will probably be a
  //     square-like set of 4 points.
  Point[] boundingBox = getBoundingBox(thresholdFilter);
  
  // 3.) Draw Vector from Center of Image to Center of Target
  //     This will also dump the text for the offset for the center vector
  //     This will also dump the text for the distance to ground and target
  drawCenterOffsetVector(source, boundingBox);  
  
  // 4.) Draw the visual overlay of the bounding box
  drawBoxOverTarget(boundingBox);
  
  // 5.) Save Final Image
  save("" + imgName + "_final.jpg");
}


///////////////////////
// Subfunctions.
///////////////////////


///////////////////////
void drawBoxOverTarget(Point [] a)
{
  // Draw Bounding Box
  strokeWeight(2);
  stroke(color(255, 0, 0));
  for (int i=0; i<a.length-1; ++i)
  {
    line(a[i].x, a[i].y, a[i+1].x, a[i+1].y);
  }
  line(a[0].x, a[0].y, a[3].x, a[3].y);
  
  // Draw crossing lines
  strokeWeight(1);
  stroke(color(255, 0, 255));
  line(a[0].x, a[0].y, a[2].x, a[2].y);
  line(a[1].x, a[1].y, a[3].x, a[3].y);
  
  // Draw circle around the center of the target
  Point center = getBoxCenter(a);
  fill(255, 0, 255);
  ellipse(center.x,center.y,8,8);
}

///////////////////////
Point getBoxCenter(Point [] a)
{
  // Instead of doing line intersection, since this approximates a square
  // I'm just averaging the center points of the 2 diagonals.
  int x1 = (a[0].x + a[2].x) / 2;
  int y1 = (a[0].y + a[2].y) / 2;
  int x2 = (a[1].x + a[3].x) / 2;
  int y2 = (a[1].y + a[3].y) / 2;
  int x = (x1+x2) / 2;
  int y = (y1+y2) / 2;
  return new Point(x,y);
}

///////////////////////
void drawCenterOffsetVector(PImage source, Point[] boundingBox)
{
  // Draw an line from the center of the image to the center of the box. 
  int x1 = source.width/2;
  int y1 = source.height/2;
  Point p = getBoxCenter(boundingBox);
  strokeWeight(2);
  stroke(color(0,255,255));
  ellipse(x1,y1,10,10);
  strokeWeight(4);
  line(x1,y1,p.x,p.y);
  
  // Calculate Offset to Target and Distance to Target.
  // Display this on the screen in the center.
  textSize(16);
  float pixelToRealWorldRatio = getPixelToWorldRatio(boundingBox);
  float xOffset = (p.x - x1) / pixelToRealWorldRatio;
  float yOffset = (p.y - y1) / pixelToRealWorldRatio;
  float distance = getDistance(p, new Point(x1,y1)) / pixelToRealWorldRatio; 
  String s = "Offset=[" + fourDigits(xOffset) + "\", "+fourDigits(yOffset)+"\"]\nDistance="+fourDigits(distance)+"\"";
  int textYOffset = 30;
  if (p.y > y1) textYOffset -= 60;
  text(s, x1 - 30, y1 + textYOffset);
 
 
  // Calculate distance to the ground and the distance to the target.
  // Then Display on the screen.
  double heightInches = (double)(source.height / pixelToRealWorldRatio);
  float distanceToGround = (float)((heightInches/2.0)/(Math.tan(Math.toRadians(10.5)))); // DistanceToGround = HeightOfImg / 2*sin(21 Degrees / 2)
  float distanceToTarget = getHypotenuse(distance, distanceToGround);
  String strToGround = "Distance to ground: " + fourDigits(distanceToGround) + "\"";
  String strToTarget = "Distance to target: " + fourDigits(distanceToTarget) + "\"";
  text(strToGround + "\n" + strToTarget, 10,20);
}

///////////////////////
// Formats floats to a 4 digits string.
String fourDigits(float f)
{
  return String.format("%.4g", f);
}

///////////////////////
// Averages all 4 sides of the bounding box and then divides by 8.5 inches/side.
float getPixelToWorldRatio(Point[] box)
{
  // Get average of sides to be the pixel length of a square's side.  
    float sum = 0;
    sum += getDistance(box[0],box[1]);
    sum += getDistance(box[1],box[2]);
    sum += getDistance(box[2],box[3]);
    sum += getDistance(box[3],box[0]);
    float avgPixelSide = sum/4.0; // This is equal to 8.5 inches    
    
    return avgPixelSide / 8.5; // Pixels / inch
}

///////////////////////
float getDistance(Point a, Point b)
{
  return (float)Math.sqrt(((a.x-b.x)*(a.x-b.x)) + ((a.y-b.y)*(a.y-b.y)));
}

///////////////////////
float getHypotenuse(float a, float b)
{
  return (float)Math.sqrt((a*a) + (b*b));
}

///////////////////////
// Very simple algorithm to return 4 points correlating to the
// 4 bounding outer points of the target.
//
// Top Left  is the white pixel whose coordinates maximize this function:    f(x,y) = (width - x) + (height - y)
// Top Right is the white pixel whose coordinates maximize this function:    f(x,y) = (x) + (height - y)
// Bottom Left is the white pixel whose coordinates maximize this function:  f(x,y) = (width - x) + (y)
// Bottom Right is the white pixel whose coordinates maximize this function: f(x,y) = (x) + (y)
//
Point[] getBoundingBox(PImage img)
{
  Point[] a = new Point[4];
  a[0] = new Point(0,0);
  a[1] = new Point(0,0);
  a[2] = new Point(0,0);
  a[3] = new Point(0,0);
  
  int upLeft = 0;
  int upRight = 0;
  int downRight = 0;
  int downLeft = 0;
  
  int w = img.width;
  int h = img.height;
  
  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++ ) {
      int loc = x + y*w;
      
      if (brightness(img.pixels[loc]) == 255)
      {
        int potentialUpLeft = (w - x) + (h - y); 
        if (potentialUpLeft > upLeft)
        {
          upLeft = potentialUpLeft;
          a[0] = new Point(x,y);
        }
        
        int potentialUpRight = (x) + (h - y); 
        if (potentialUpRight > upRight)
        {
          upRight = potentialUpRight;
          a[1] = new Point(x,y);
        }
        
        int potentialDownRight = (x) + (y); 
        if (potentialDownRight > downRight)
        {
          downRight = potentialDownRight;
          a[2] = new Point(x,y);
        }
        
        int potentialDownLeft = (w - x) + (y); 
        if (potentialDownLeft > downLeft)
        {
          downLeft = potentialDownLeft;
          a[3] = new Point(x,y);
        }
      } 
    }
  }
   
  return a;
}

///////////////////////
// Thresholds all pixels to black or white. 
void applyThresholdFilter(PImage src, PImage dest)
{
  float threshold = 127; // half of the max brightness (255)

  // Loop over each pixel
  for (int x = 0; x < src.width; x++) {
    for (int y = 0; y < src.height; y++ ) {
        
      // Get location in 1-D Pixel Array
      int loc = x + y*src.width;
      
      // Test the brightness against the threshold
      if (brightness(src.pixels[loc]) > threshold)
        dest.pixels[loc]  = color(255);  // White
      else
        dest.pixels[loc]  = color(0);    // Black
    }
  }
}


