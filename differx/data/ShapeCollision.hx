package differx.data;

import differx.math.*;
import differx.shapes.*;
import differx.data.*;

/** Collision data, obtained by testing two shapes for a collision. */
@:publicFields
class ShapeCollision {
        /** The overlap amount */
    var overlap : Float = 0.0;

    // User defined notion of time
    var time : Float = 0.;

        /** X component of the separation Float2, when subtracted from shape 1 will separate it from shape 2 */
    var separationX : Float = 0.0;
        /** Y component of the separation Float2, when subtracted from shape 1 will separate it from shape 2 */
    var separationY : Float = 0.0;
        /** X component of the unit Float2, on the axis of the collision (i.e the normal of the face that was collided with) */
    var unitVectorX : Float = 0.0;
        /** Y component of the unit Float2, on the axis of the collision (i.e the normal of the face that was collided with) */
    var unitVectorY : Float = 0.0;

    var otherOverlap : Float = 0.0;
    var otherSeparationX : Float = 0.0;
    var otherSeparationY : Float = 0.0;
    var otherunitVectorX : Float = 0.0;
    var otherunitVectorY : Float = 0.0;

        /** The shape that was tested */
    var shape1 : Shape;
    var shape1_x : Float;
    var shape1_y : Float;
    
        /** The shape that shape1 was tested against */
    var shape2 : Shape;

    var shape2_x : Float;
    var shape2_y : Float;

    public var data : std.Any;

    @:noCompletion
    inline function new() {

    } //

    inline function reset() {

        shape1 = shape2 = null;
        overlap = separationX = separationY = unitVectorX = unitVectorY = 0.0;
        otherOverlap = otherSeparationX = otherSeparationY = otherunitVectorX = otherunitVectorY = 0.0;
        
        return this;

    } //reset

    inline function clone() {

        var _clone = new ShapeCollision();

        _clone.copy_from(this);

        return _clone;

    } //clone

    inline function copy_from(_other:ShapeCollision) {

        data = _other.data;
        overlap = _other.overlap;
        time = _other.time;
        separationX = _other.separationX;
        separationY = _other.separationY;
        unitVectorX = _other.unitVectorX;
        unitVectorY = _other.unitVectorY;
        otherOverlap = _other.otherOverlap;
        otherSeparationX = _other.otherSeparationX;
        otherSeparationY = _other.otherSeparationY;
        otherunitVectorX = _other.otherunitVectorX;
        otherunitVectorY = _other.otherunitVectorY;
        shape1 = _other.shape1;
        shape2 = _other.shape2;

    } //copy_from

} //ShapeCollision