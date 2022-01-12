package differ.shapes;

import differ.math.*;
import differ.shapes.*;
import differ.data.*;

import hvector.Float2;

/** A ray with a start, end, direction 
    and infinite state for collision queries. */
class Ray {

        /** The start point of the ray. */
    public var start:Float2;
        /** The end point of the ray. */
    public var end:Float2;
        /** The direction of the ray.
            Returns a cached Float2, so modifying it will affect this instance.
            Updates only when the dir value is accessed. */
    public var dir (get, never):Float2;
        /** Whether or not the ray is infinite. */
    public var infinite:InfiniteState;

        /** Create a new ray with the start and end point,
            which determine the direction of the ray, and optionally specifying
            that this ray is infinite in some way. */
    public function new(_start:Float2, _end:Float2, ?_infinite:InfiniteState) {

        start = _start;
        end = _end;
        infinite = _infinite == null ? not_infinite : _infinite;

        //internal
        dir_cache = new Float2(end.x - start.x, end.y - start.y);

    } //

//properties

    var dir_cache : Float2;
    function get_dir() {
        dir_cache.x = end.x - start.x;
        dir_cache.y = end.y - start.y;
        return dir_cache;
    }

}

    /** A flag for the infinite state of a Ray. */
enum InfiniteState {

        /** The line is a fixed length 
            between the start and end points. */
    not_infinite;
        /** The line is infinite 
            from it's starting point. */
    infinite_from_start;
        /** The line is infinite in both 
            directions from it's starting point. */
    infinite;

} //InfiniteState