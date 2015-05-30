PImage source;       // Source image

void setup()
{
  source = loadImage("test.png");
  println("Img Loaded: Dim["+source.width + ", " +source.height +"]");
  
  int r = 2;
  //source.resize(source.width/r, source.height/r);
  //source.resize(2, 2);
  //size(source.width/r, source.height/r);
  size(400,400);
  
  //noLoop();
}

void draw()
{
  image(source,0,0);
}
