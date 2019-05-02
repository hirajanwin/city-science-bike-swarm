/**
 * 
 * PixelFlow | Copyright (C) 2016 Thomas Diewald - http://thomasdiewald.com
 * 
 * A Processing/Java library for high performance GPU-Computing (GLSL).
 * MIT License: https://opensource.org/licenses/MIT
 * 
 */


import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.imageprocessing.filter.DwFilter;
import processing.core.PApplet;
import processing.opengl.PGraphics2D;

DwPixelFlow context;


DwFilter filter;

PGraphics2D pg_src_A;
PGraphics2D pg_src_B;
PGraphics2D pg_src_C; // just another buffer for temporary results

//Particles
ParticleManager mParticles;

int maxPoints = 1;

public void settings() {
  size(1200, 800, P2D);
  smooth(0);
}


public void setup() {
  context = new DwPixelFlow(this);
  context.print();
  context.printGL();

  filter = new DwFilter(context);

  pg_src_A = (PGraphics2D) createGraphics(width, height, P2D);
  pg_src_A.smooth(8);

  pg_src_B = (PGraphics2D) createGraphics(width, height, P2D);
  pg_src_B.smooth(8);

  pg_src_C = (PGraphics2D) createGraphics(width, height, P2D);
  pg_src_C.smooth(8);



  //    frameRate(60);
  frameRate(1000);

  mParticles = new ParticleManager();
  for (int i = 0; i < maxPoints; i++) {
    float x = 50;
    float y = height/2.0;
    Particle p = new Particle(x, y);
    mParticles.add(p);
  }
  
}


float anim_rotate = 0;

public void draw() {

  int mx = mouseX;
  int my = mouseY;
  mx = width/2;
  my = height/2;


  pg_src_A.beginDraw();
  {
    pg_src_A.background(0);
    mParticles.draw(pg_src_A);
  }
  pg_src_A.endDraw();


  pg_src_B.beginDraw();
  pg_src_B.clear();
  pg_src_B.endDraw();

  DwFilter filter = DwFilter.get(context);

  filter.bloom.param.mult   = map(mouseX, 0, width, 0, 20);
  filter.bloom.param.radius = map(mouseY, 0, height, 0, 1);

  filter.luminance_threshold.param.threshold = 0.3f;
  filter.luminance_threshold.param.exponent = 10;

  //    System.out.println("mult/radius: "+filter.bloom.param.mult+"/"+filter.bloom.param.radius);
  if (keyPressed) {
    filter.bloom.apply(pg_src_A, pg_src_A, null);
  } else {
    filter.luminance_threshold.apply(pg_src_A, pg_src_B);
    filter.bloom.apply(pg_src_B, pg_src_B, pg_src_A);
  }

  //    blendMode(REPLACE);
  background(0);
  image(pg_src_A, 0, 0);


  // info
  String txt_fps = String.format(getClass().getName()+ "   [size %d/%d]   [frame %d]   [fps %6.2f]", pg_src_A.width, pg_src_A.height, frameCount, frameRate);
  surface.setTitle(txt_fps);
}
