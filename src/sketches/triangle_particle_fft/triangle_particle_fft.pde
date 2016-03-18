// Some real-time FFT! This visualizes music in the frequency domain using a
// polar-coordinate particle system. Particle size and radial distance are modulated
// using a filtered FFT. Color is sampled from an image.

import ddf.minim.analysis.*;
import ddf.minim.*;

FadecandySketch driver = new FadecandySketch(this, 250, 250);

PImage dot;
PImage colors;
PImage colors1;
PImage colors2;
PImage colors3;
Minim minim;
AudioInput in;
FFT fft;
float[] fftFilter;

//String filename = "083_trippy-ringysnarebeat-3bars.mp3";
String filename = "/Users/Shen/kafkaf.mp3";
float spin = 0.001;
float radiansPerBucket = radians(2);
float decay = 0.97;
float opacity = 40;
float minSize = 0.1;
float sizeScale = 0.2;

void setup() {
  driver.init();

  minim = new Minim(this); 

  // Small buffer size!
  in = minim.getLineIn();

  fft = new FFT(in.bufferSize(), in.sampleRate());
  fftFilter = new float[fft.specSize()];

  dot = loadImage("dot.png");
  colors1 = loadImage("colors.png");
  colors2 = loadImage("colors2.png");
  colors3 = loadImage("colors3.png");
  
  colors = colors1;
}

void draw()
{
  background(0);

  if (keyPressed) {
    if (key == '1') {
      colors = colors1;
    } else if (key == '2') {
      colors = colors2;
    } else if (key == '3') {
      colors = colors3;
    }
  }

  fft.forward(in.mix);
  for (int i = 0; i < fftFilter.length; i++) {
    fftFilter[i] = max(fftFilter[i] * decay, log(1 + fft.getBand(i)));
  }

  for (int i = 0; i < fftFilter.length; i += 3) {   
    color rgb = colors.get(int(map(i, 0, fftFilter.length-1, 0, colors.width-1)), colors.height/2);
    tint(rgb, fftFilter[i] * opacity);
    blendMode(ADD);

    float size = height * (minSize + sizeScale * fftFilter[i]);
    PVector center = new PVector(width * (fftFilter[i] * 0.2), 0);
    center.rotate(millis() * spin + i * radiansPerBucket);
    center.add(new PVector(width * 0.5, height * 0.5));

    image(dot, center.x - size/2, center.y - size/2, size, size);
  }
}
