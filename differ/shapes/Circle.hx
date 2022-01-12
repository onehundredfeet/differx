package differ.shapes;

import differ.math.*;
import differ.shapes.*;
import differ.data.*;
import differ.sat.*;

import hvector.Float2;

/** A circle collision shape */
class Circle extends Shape {

        /** The radius of this circle. Set on construction */
    public var radius( get, never ) : Float;
    public var center( get, never ) : Float2;
    

    var _center : Float2;
    var _radius:Float;
    
    public function new( radius:Float, ?center : Float2, ?original : Circle) {
        super( original );
        _radius = radius;
        _center = center == null ? new Float2(0., 0.) : center;
        #if differ_autoname  name = 'circle ' + _radius; #end
    } //new

   

    inline function get_radius():Float {

        return _radius;

    } //get_radius

    inline function get_center() : Float2 {
        return _center;
    }

    inline function set_center(v : Float2) : Float2 {
        return _center = v;
    }

    public inline function transform(t : Transform, ?c : Circle) : Circle {
        if (c == null) {
            return new Circle(_radius * t.scale, t.matrix.transform(_center), cast _original );
        }
        c._center = t.matrix.transform(_center);
        c._radius = _radius * t.scale;
        c._original = _original;

        return c;
    } //get_transformedRadius

} //Circle
