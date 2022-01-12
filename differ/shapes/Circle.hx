package differ.shapes;

import differ.math.*;
import differ.shapes.*;
import differ.data.*;
import differ.sat.*;

import hvector.Float2;

/** A circle collision shape */
@:build(hvector.VectorBuilder.Float2("center")) //integrates it as flat members instead of a new object
class Circle extends Shape {

        /** The radius of this circle. Set on construction */
    public var radius( get, never ) : Float;
    

    var _radius:Float;
    
    public function new( radius:Float, ?center : Float2, ?original : Circle) {
        super( original );
        _radius = radius;
        if (center != null) {
            this.center = center;
        }

        #if differ_autoname  name = 'circle ' + _radius; #end
    } //new

   

    inline function get_radius():Float {

        return _radius;

    } //get_radius

   

    public inline function transform(t : Transform, ?c : Circle) : Circle {
        if (c == null) {
            return new Circle(_radius * t.scale, t.matrix.transform(center), cast _original );
        }
        c.center = t.matrix.transform(center);
        c._radius = _radius * t.scale;
        c._original = _original;

        return c;
    } //get_transformedRadius

} //Circle
