package differx.shapes;

import differx.math.*;
import differx.shapes.*;
import differx.data.*;

import hvector.Float2;

@:enum
abstract TraceFlags(UInt) to UInt from UInt {
	var ALL = 1 << 0; // Default is single hit
	var CLOSEST = 1 << 1; // Default is first hit
	var CONE = 1 << 2; // when stepping, it will use circles to emulate thickness, default is an infinitely thin ray
    var INFINITE = 1 << 3; // Unbounded, default is bounded by distance
    var BIDIRECTIONAL = 1 << 4; // Allows for negative results, default is positive only
    var CONTACT_INFO = 1 << 5;
}

/** A ray with a origin, end, direction 
    and infinite state for collision queries. */
#if !macro @:build(hvector.macro.VectorBuilder.embed()) #end
class Ray {
    public var flags : UInt = 0;
    public var maxDistance : Float;
    public var origin : Float2;
    public var end : Float2;
    public var dir : Float2;

	public var startRadius:Float;
	public var endRadius:Float;
	public var coneSteps:Int = 1;
    public var collideWith:UInt = 0xffffffff;

    public function new() {

    } //

    public function setLine( start : Float2, end : Float2, flags : UInt = 0) {
        this.origin = start;
        this.end = end;
        this.maxDistance = (end - start).length();
        this.dir = (end - start) * (1. / maxDistance);
        this.flags = flags;
    }

    public function setRay( start : Float2, dir : Float2, max : Float, flags : UInt = 0) {
        this.origin = start;
        this.dir = dir;
        this.end = start + dir * max;
        this.maxDistance = max;
        this.flags = flags;
    }

    public function setCone( start : Float2, dir : Float2, max : Float, r0 : Float, r1 : Float, steps : Int, flags : UInt = 0) {
        this.origin = start;
        this.dir = dir;
        this.end = start + dir * max;
        this.maxDistance = max;
        this.flags = flags;
        this.startRadius = r0;
        this.endRadius = r1;
        this.coneSteps = steps;
    }

    public inline function getPoint01( t : Float) :Float2 {
        return origin * (1. - t) + end * t;
    }

    public inline function getPoint( t : Float) :Float2 {
        return origin + dir * t;
    }

    //properties
}
