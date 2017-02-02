import controlP5.*;
import remixlab.proscene.*;

public class GUIControls {
    private Scene scene;
    private PGraphics renderer;
    private ControlP5 controls;
    private Slider spatialSlider;
    private Slider timeSlider;
    private Slider glitchSlider;
    private Toggle rotateToggle;
    private int controlWidth;
    private int labelWidth;
    private int panelWidth;
    private int panelX;
    private int controlSpace = 35;
    private float top = 10;
    public boolean isVisible = false;

    public GUIControls(PApplet sketch, PGraphics renderer) {
        this.renderer = renderer;
        this.panelWidth = this.renderer.width;
        this.controlWidth = (this.renderer.width - 40) * 3 / 4;
        this.labelWidth = (this.renderer.width - 40) / 4;
        this.panelX = sketch.width - this.panelWidth;
        this.scene = new Scene(sketch, this.renderer, this.panelX, 0);
        this.scene.setAxesVisualHint(false); // hide axis
        this.scene.setGridVisualHint(false); // hide grid
        this.controls = new ControlP5(sketch);

        this.make();
        this.controls.setAutoDraw(false);
    }

    private void make() {
        this.spatialSlider = this.controls.addSlider("spatialFactor")
            .setPosition(this.panelX + 20, this.top + 10)
            .setSize(this.controlWidth, this.controlSpace - 20)
            .setNumberOfTickMarks(10000)
            .setRange(0., 0.03)
            .setDecimalPrecision(6)
            .setValue(0.00260126)
            .setLabel("spatial")
            .setColorCaptionLabel(color(255));
        this.top += this.controlSpace;

        this.timeSlider = this.controls.addSlider("timeFactor")
            .setPosition(this.panelX + 20, this.top + 10)
            .setSize(this.controlWidth, this.controlSpace - 20)
            .setNumberOfTickMarks(10000)
            .setRange(0., 1.)
            .setDecimalPrecision(6)
            .setValue(0.4)
            .setLabel("time")
            .setColorCaptionLabel(color(255));
        this.top += this.controlSpace;

        this.glitchSlider = this.controls.addSlider("glitchFactor")
            .setPosition(this.panelX + 20, this.top + 10)
            .setSize(this.controlWidth, this.controlSpace - 20)
            .setNumberOfTickMarks(1000)
            .setRange(0., .4)
            .setDecimalPrecision(6)
            .setValue(0.0)
            .setLabel("glitch")
            .setColorCaptionLabel(color(255));
        this.top += this.controlSpace;

        this.rotateToggle = this.controls.addToggle("rotateToRatio")
             .setPosition(this.panelX + 20, this.top + 10)
             .setSize(50, this.controlSpace - 20)
             .setValue(false)
             .setLabel("noise")
             .setColorCaptionLabel(color(255))
             .setMode(ControlP5.SWITCH);
         this.top += this.controlSpace;
    }

    public void update(){
        this.spatialSlider.setValue(spatialFactor);
        this.timeSlider.setValue(timeFactor);
        this.glitchSlider.setValue(glitchFactor);
        this.rotateToggle.setValue(rotateToRatio);
    }

    public void render(){
        if (this.isVisible) {
            this.scene.beginDraw();
                this.renderer.clear();
                this.renderer.background(0,0,0,200);
            this.scene.endDraw();

            this.scene.display();
            this.controls.draw();
        }
    }

    public void toggleVisibility () {
        this.isVisible = !this.isVisible;
    }

    public void printAll() {
        println(
            "space: ", spatialSlider.getValue() ,
            "time", timeSlider.getValue(),
            "glitch", glitchSlider.getValue(),
            "noise", rotateToggle.getValue());
    }
}
