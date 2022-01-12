package ;

import differ.Collision;
import differ.math.*;
import differ.shapes.*;

import hvector.Float2Array;
import hvector.Float2;

class Test {
    public static function main() {
        var b =  Float2Array.allocate(4);
        var p = Polygon.square( 1., false);
        var c = new Circle(new Float2(0., 0.), 1.);
        var t1 = new Transform(0., 0.);
        var t2 = new Transform(0., 0.);
        
        var tp = p.transform(t1);
        var tc = c.transform(t2);
        // Where do we want to do the transform?
        var i0 = Collision.shapeWithShape( c,  p);
        var i1 = Collision.shapeWithShape( tc,  tp);
    }

}