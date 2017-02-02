import remixlab.proscene.*;
import remixlab.dandelion.core.*;
import remixlab.dandelion.geom.*;

final static float PHI = 1.618033989;
float lastTick, // time of last frame
      dTime; // time since last frame

Scene scene;
PGraphics mainRenderer;
Multiverse one, two;
GUIControls gui;
final static int levels = 8; // number of levels in a single multiverse
boolean shouldRotate = true; // if the whole form should rotate

// controls
float spatialFactor = 0.00260126, // 0.-.03
      timeFactor = 0.4, // 0.-1.
      glitchFactor = 0.0; // 0.-.4
boolean rotateToRatio = false; // controls motion function

void setup() {
  size(1000, 720, P3D);
  frameRate(60);
  rectMode(CENTER);

  mainRenderer = createGraphics(width, height, P3D);
  scene = new Scene(this, mainRenderer);
  scene.removeKeyBindings();
  scene.setAxesVisualHint(false); // hide axis
  scene.setGridVisualHint(false); // hide grid
  scene.setCameraType(Camera.Type.ORTHOGRAPHIC);
  scene.setRadius(height / PHI);
  scene.camera().lookAt(new Vec(0, 0, 0));
  scene.showAll();

  one = new Multiverse(height / 2);
  two = new Multiverse(height / 2);

  gui = new GUIControls(this, createGraphics(300, height, P2D));

  lastTick = millis();
}

void update() {
    dTime = millis() - lastTick;
    lastTick = millis();
    if (keyPressed == true && (key == CODED || key == '1' || key == '2')) // allow continious for certain keys
        keyPressed();
    one.update(lastTick / 1000.);
    two.update(lastTick / 1000.);
}

void draw() {
    update();
    background(0);
    surface.setTitle("" + int(frameRate));

    scene.beginDraw();
        blendMode(ADD);
        mainRenderer.clear();
        mainRenderer.pushMatrix();
            if (shouldRotate) rotateAll();
            one.render();
            mainRenderer.pushMatrix();
                mainRenderer.rotateZ(PI); // upside down
                two.render();
            mainRenderer.popMatrix();
        mainRenderer.popMatrix();
    scene.endDraw();
    scene.display();

    gui.render();
}

void rotateAll() {
    float rotation1Time = lastTick + 100000;
    float rotation2Time = lastTick + 320000;
    if (rotation1Time >= 120000)
        mainRenderer.rotateY(map(rotation1Time % 120000.,0, 119999, 0, TWO_PI));
    if (rotation2Time >=  340000)
        mainRenderer.rotateX(map(rotation2Time % 340000.,0, 339999, 0, TWO_PI));
}

void keyPressed() {
    switch (key) {
        case 'c':
            gui.toggleVisibility();
            break;
        case 'p':
            gui.printAll();
            break;
        // alternative for costy ControlP5 rendering
        case 'n':
            rotateToRatio = !rotateToRatio;
        case '1':
            glitchFactor = glitchFactor - 0.005 < 0? 0 : glitchFactor - 0.005;
            break;
        case '2':
            glitchFactor = glitchFactor + 0.005 > 0.4? 0.4 : glitchFactor + 0.005;
            break;
        case '0':
            saveFrame("data/frames/time-######.png");
        default:
            if (key == CODED && keyCode == RIGHT)
                timeFactor = timeFactor + 0.003 > 1.? 1. : timeFactor + 0.003;
            else if (key == CODED && keyCode == LEFT)
                timeFactor = timeFactor - 0.003 < 0? 0 : timeFactor - 0.003;
            else if (key == CODED && keyCode == UP)
                glitchFactor = glitchFactor + 0.005 > 0.4? 0.4 : glitchFactor + 0.005;
            else if (key == CODED && keyCode == DOWN)
                glitchFactor = glitchFactor - 0.005 < 0? 0 : glitchFactor - 0.005;
    }

    gui.update();
}

float smoothstep(float x) { // x: 0.-1.
    return x * x * (3 - (2 * x));
}

float smootherstep(float x) { // x: 0.-1.
    return   x * x * x * ((x * ((x * 6) - 15)) + 10);
}
