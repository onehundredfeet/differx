package ;

import differx.Collision;
import differx.math.*;
import differx.shapes.*;

import hvector.Float2Array;
import hvector.Float2;

class Test {
    public static function main() {
        var b =  Float2Array.allocate(4);
        var p = Polygon.square( 1., false);
        var c = new Circle( 1., new Float2(0., 0.));
        var t1 = new Transform();
        var t2 = new Transform();
        
        var tp = p.transform(t1);
        var tc = c.transform(t2);
        // Where do we want to do the transform?
        var i0 = Collision.shapeWithShape( c,  p);
        var i1 = Collision.shapeWithShape( tc,  tp);
    }

}