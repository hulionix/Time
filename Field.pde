public class Field {
    public PGraphics renderer;
    private PShader look; // shader that renders the field look
    private PVector resolution; // (width, height) of the field
    // a sub field is a triangular part of the field, defined by base and hight lengths
    private float subFieldBase;
    private float subFieldHeight;

    public Field(int width, int height, float subFieldBase, float subFieldHeight) {
        this.resolution = new PVector(width, height);
        this.renderer = createGraphics(width, height, P2D);
        this.look = loadShader("shaders/frag.glsl");
        this.subFieldBase = subFieldBase;
        this.subFieldHeight = subFieldHeight;
    }

    public void render(float time){
        this.look.set("u_resolution", this.resolution.x, this.resolution.y);
        this.look.set("u_time", time);

        this.renderer.beginDraw();
            this.renderer.beginShape(QUADS);
                this.renderer.shader(this.look);
                this.renderer.fill(255,0,0);

                this.renderer.vertex(0,0);
                this.renderer.vertex(this.resolution.x, 0);
                this.renderer.vertex(this.resolution.x, this.resolution.y);
                this.renderer.vertex(0, this.resolution.y);
            this.renderer.endShape();
        this.renderer.endDraw();
    }

    /*
      for better visibility of rendering output
     */
    public void show() {

        image(this.renderer, 0, 0);
    }

    /*
      return normalized coords for use as texture
     */
    public PVector[] getRandomCoords() {
        PVector[] texCoords = new PVector[3];
        texCoords[0] = new PVector(
            random(0, (this.resolution.x - this.subFieldBase) / this.resolution.x),
            random(0, (this.resolution.y - this.subFieldHeight) / this.resolution.y));
        texCoords[1] = new PVector(
            texCoords[0].x + (this.subFieldBase / this.resolution.x),
            texCoords[0].y);
        texCoords[2] = new PVector(
            ((this.subFieldBase * 0.5) / this.resolution.x) + texCoords[0].x,
            texCoords[0].y + (this.subFieldHeight / this.resolution.y));
        return texCoords;
    }
}
