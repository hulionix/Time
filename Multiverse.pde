/*
  class Multiverse manages the creation and motion of a hierarchy
  of universes through a single point, the Master Universe.
  A Multiverse has the form of a tetrahedron, made of smaller
  tetrahedrons, Universes.
 */
public class Multiverse {
    private PShape form;
    private PMatrix3D transform;
    private HashMap<Float, PVector> apexes;
    private PVector[] masterBasePoints;
    private Universe masterUniverse;
    private Field field;

    public Multiverse(float multiverseHeight) {
        float universeHeight     = multiverseHeight / levels;
        float universeEdgeLength = universeHeight  * 3. / sqrt(6) ;

        this.form             = createShape();
        this.transform        = new PMatrix3D();
        this.apexes           = new HashMap<Float, PVector>();
        this.masterBasePoints = new PVector[3];
        this.field            = new Field(
            int(multiverseHeight), int(multiverseHeight), // width and height of the texture
            universeEdgeLength, // sub field base
            universeHeight ); // sub field height

        // Master Universe is a tetrahedron at the apex of the Multiverse
        this.masterBasePoints[0] = new PVector(0., universeHeight, universeEdgeLength * 2. / 3.);
        this.masterBasePoints[1] = new PVector();
        this.masterBasePoints[2] = new PVector();

        this.transform.rotateY(TWO_PI / 3.);
        this.transform.mult(masterBasePoints[0], masterBasePoints[1]);
        this.transform.mult(masterBasePoints[1], masterBasePoints[2]);

        // +y pointing down
        this.createForm(-multiverseHeight);
    }

    /*
      creates the supporting shape and the Master Universe
     */
    private void createForm(float up) {
        PVector masterApex = new PVector(0., up, 0.);

        this.form.beginShape(POINTS);
        this.form.stroke(200, 70);
        this.form.strokeWeight(2);
        this.masterUniverse = this.createUniverse(masterApex, levels);
        this.form.endShape();
    }

    /*
      recursively create Universes
     */
    private Universe createUniverse(PVector apex, int subLevels) {
        PVector[] bounds = {apex, new PVector(), new PVector(), new PVector()};

        this.apexes.put(this.hash(apex), apex); // hash the apex for checking later on duplicates
        this.form.vertex(apex.x, apex.y, apex.z);

        this.transform.reset();
        this.transform.translate(apex.x, apex.y, apex.z);
        this.transform.mult(this.masterBasePoints[0], bounds[1]);
        this.transform.mult(this.masterBasePoints[1], bounds[2]);
        this.transform.mult(this.masterBasePoints[2], bounds[3]);

        Universe universe = new Universe(bounds);
        universe.createForm(this.field);

        for (int i = 1; i < 4; i++)
            if (this.apexes.get(hash(bounds[i])) == null && subLevels-1 > 0)
                universe.addChild(this.createUniverse(bounds[i], subLevels-1));

        if (subLevels-1 == 0) {
            this.form.vertex(bounds[1].x, bounds[1].y, bounds[1].z);
            this.form.vertex(bounds[2].x, bounds[2].y, bounds[2].z);
            this.form.vertex(bounds[3].x, bounds[3].y, bounds[3].z);
        }

        return universe;
    }

    /*
      update all Universes by updating Master Universe
     */
    public void update(float time) {
        this.field.render(time);
        this.masterUniverse.update(time);
    }

    /*
      render all Universes by rendering Master Universe
     */
    public void render() {
        this.masterUniverse.render();
        mainRenderer.shape(this.form);
    }

    /*
      hashe a vector based on integer values for its x,y and z.
      allows same value hash for slightly nearby vectors.
     */
    private float hash(PVector v) {
        return sin(round(v.x) % PI) * 75733 +
               cos(round(v.y) % TWO_PI) * 37311 +
               sin(round(v.z)) * 31;
    }
}
