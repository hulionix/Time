/*
  class Universe manages the motion details of a single universe.
  A universe has a triangluar shape and it's motion is constrained by a
  tetrahedron form, defined by axis of rotation, start and end points as
  a single motion configuration.
 */
public class Universe {
    private PShape shape;
    private Axis axis; // axis of rotation
    private PVector start; // motion start position
    private PVector end; // motion end position
    private int movingVertex; // index for the vertex currently in motion
    private ArrayList<Universe> children; // child universes
    private PVector[] fieldCoords; // tex coords normalized
    private float cycleTime = 14000.; // time of a single rotation, edge to edge, in milli sec

    public Universe(PVector[] bounds) {
        this.axis     = new Axis(bounds[0], bounds[1]);
        this.start    = bounds[2];
        this.end      = bounds[3];
        this.children = new ArrayList<Universe>();
    }

    public void createForm(Field field) {
        PVector[] fieldCoords = field.getRandomCoords();

        this.shape = createShape();
        this.shape.beginShape(TRIANGLES);
            this.shape.textureMode(NORMAL);
            this.shape.noStroke();
            this.shape.texture(field.renderer);
            //this.shape.fill(int(random(100,250)));
            this.shape.vertex(this.axis.end.x, this.axis.end.y, this.axis.end.z,
                             fieldCoords[0].x, fieldCoords[0].y); // tex
            this.shape.vertex(this.axis.otherEnd.x, this.axis.otherEnd.y, this.axis.otherEnd.z,
                             fieldCoords[1].x, fieldCoords[1].y);
            this.shape.vertex(this.start.x, this.start.y, this.start.z,
                             fieldCoords[2].x, fieldCoords[2].y);
        this.shape.endShape();

        this.movingVertex = 2;
    }

    public void update(float time) {
        if (rotateToRatio) {
            float noise = noise(-timeFactor * time + (
                (spatialFactor * start.x) +
                (spatialFactor * start.y) +
                (spatialFactor * start.z)));

            this.rotateToRatio(smootherstep(noise));
        } else
            this.rotate();

        for (Universe child : this.children)
            child.update(time);
    }

    private void rotateToRatio(float ratio) {
        if (ratio + glitchFactor < 1.)
            this.shape.setVertex(
                this.movingVertex,
                PVector.mult(start, 1. - ratio).add(PVector.mult(end, ratio))); // start * (1. - ratio) + end * ratio
        else if(rotateToRatio)
            this.changeAxis();
    }

    private void rotate() {
        float elapsed = (lastTick % (cycleTime * timeFactor)), // 0-cycleTime
              ratio   = smoothstep(elapsed / (cycleTime * timeFactor)); // 0.-1., ratio start to end based on time

        this.rotateToRatio(ratio);

        if (elapsed - dTime < 0) // a new rotation cycle
            this.changeAxis();
    }

    /*
      changing axis of rotation by swaping previous rotation vertices
       positions based on following Rules:
      . apex vertex never moves, always on rotation axis
      . rotation axis 2nd vertex becomes the next moving vertex
      . previous moving vertex becomes an axis vertex
    */
    private void changeAxis() {
        PVector prevEnd    = end.copy();
        this.end           = start.copy();
        this.start         = axis.otherEnd.copy();
        this.axis.otherEnd = prevEnd;

        this.shape.setVertex(this.movingVertex, this.axis.otherEnd);
        this.movingVertex = 2 / this.movingVertex; // 1->2, 2->1
    }

    public void render() {
        mainRenderer.shape(this.shape);

        for (Universe child : this.children)
            child.render();
    }

    private void addChild(Universe child) {
        this.children.add(child);
    }

    // Axis of rotation for a Universe
    private class Axis {
        public PVector end;
        public PVector otherEnd;

        public Axis(PVector end, PVector otherEnd) {
            this.end = end;
            this.otherEnd = otherEnd;
        }
    }
}
