package differx;

import differx.math.*;
import differx.shapes.*;
import differx.data.*;
import differx.sat.*;
import UInt;
import hvector.Float2Array;

class Collision {

        /** Test a single shape against another shape.
            When no collision is found between them, this function returns null.
            Returns a `ShapeCollision` if a collision is found. */
    public static inline function shapeWithShape( shape1:Shape, shape2:Shape, temp:ShapeCollision, ?into:ShapeCollision, checkFlags : Bool = true ) : ShapeCollision {
        if ( checkFlags && ((shape1.collidesWithFlags & shape2.memberOfFlags) == 0)) return null;

        var c1 = Std.isOfType(shape1, Circle);
        var c2 = Std.isOfType(shape2, Circle);

        if (c1 ) {
            if (c2) return SAT2D.testCircleVsCircle( cast shape1, cast shape2, into, false );
            return SAT2D.testCircleVsPolygon(  cast shape1,cast shape2, into, false );
        } 

        if (c2) return SAT2D.testCircleVsPolygon(cast shape2, cast shape1, into, true );
            return SAT2D.testPolygonVsPolygon(cast shape1, cast shape2, temp, into, false );
    } //test

    #if false
        /** Test a single shape against multiple other shapes.
            When no collision is found, this function returns empty results, this function will never return null.
            Returns a list of `ShapeCollision` information for each collision found.
            `for(result in results) {  result... }` */
    public static function shapeWithShapes( shape1:Shape, shapes:Array<Shape>, temp : ShapeCollision, ?into:Results<ShapeCollision> ) : Results<ShapeCollision> {

        var results: Results<ShapeCollision> =
            if(into != null) {
                into.clear();
            } else {
                new Results<ShapeCollision>(shapes.length);
            }

        for(other_shape in shapes) {
            if ((shape1.collidesWithFlags & other_shape.memberOfFlags) == 0) continue;
            var value = results.pull();
            var result = shapeWithShape(shape1, other_shape, temp, value);
            if(result != null) {
                results.push(result);
            }

        } //for all shapes passed in

        return results;

    } //testShapes

    #end
        /** Test a line between two points against a list of shapes.
            When no collision is found, this function returns null.
            Returns a `RayCollision` if a collision is found. */
    public static inline function rayWithShape( ray:Ray,  shape:Shape, ?into:RayCollision ) : RayCollision {
        if ((ray.collideWith & shape.memberOfFlags) == 0) return null;

        if (Std.isOfType(shape, Circle)) {
            return SAT2D.testRayVsCircle(ray, cast shape, into);
        }
        return SAT2D.testRayVsPolygon(ray, cast shape, into);

    } //rayShape

    #if false
        /** Test a ray between two points against a list of shapes.
            When no collision is found, this function returns an empty array, this function will never return null.
            Returns a list of `RayCollision` information for each collision found.
            `for(result in results) {  result... }`  */
    public static function rayWithShapes( ray:Ray, shapes:Array<Shape>, ?into:Results<RayCollision> ) : Results<RayCollision> {

        var results: Results<RayCollision> =
            if(into != null) {
                into.clear();
            } else {
                new Results<RayCollision>(shapes.length);
            }

        for(shape in shapes) {
            if ((collideWith & shape.memberOfFlags) == 0) continue;

            var value = results.pull();
            var result = rayWithShape(ray, shape, value);
            if(result != null) {
                results.push(result);
            }
        }

        return results;

    } //rayShapes
#end
        /** Test a ray against another ray.
            When no collision is found, this function returns null.
            Returns a `RayIntersection` if a collision is found. */
    public static inline function rayWithRay( ray1:Ray, ray2:Ray, ?into:RayIntersection ) : RayIntersection {

        return SAT2D.testRayVsRay(ray1, ray2, into);

    } //rayRay

        /** Test a ray against a list of other rays.
            When no collision is found, this function returns an empty array, this function will never return null.
            Returns a list of `RayIntersection` information for each collision found.
            `for(result in results) {  result... }`  */
    public static function rayWithRays( ray:Ray, rays:Array<Ray>, ?into:Results<RayIntersection> ) : Results<RayIntersection> {

        var results: Results<RayIntersection> =
            if(into != null) {
                into.clear();
            } else {
                new Results<RayIntersection>(rays.length);
            }

        for(other in rays) {
            var value = results.pull();
            var result = rayWithRay(ray, other, value);
            if(result != null) {
                results.push(result);
            }
        }

        return results;

    } //rayRays

        /** Test if a given point lands inside the given polygon.
            Returns true if it does, false otherwise. */
    public inline static function pointInPoly( x:Float, y:Float, transform : Transform, poly:Polygon ) : Bool {
        return pointInVerts(x, y, transform, poly.vertices);
    } //pointInPoly


    // Uses the ray casting algorithm to test if a point is inside a polygon.
    // Counting the amount of times a ray from the point to infinity crosses a line segment.
    public static function pointInVerts( x:Float, y:Float, transform : Transform, verts:Float2Array ) : Bool {
        var sides:Int = verts.length; //amount of sides the polygon has

        var i:Int = 0;
        var j:Int = sides - 1;
        var oddNodes:Bool = false;

        for(i in 0 ... sides) {

            if( (verts[i].y < y && verts[j].y >= y) ||
                (verts[j].y < y && verts[i].y >= y))
            {
                if( verts[i].x +
                    (y - verts[i].y) /
                    (verts[j].y - verts[i].y) *
                    (verts[j].x - verts[i].x) < x)
                {
                    oddNodes = !oddNodes;
                }

            }

            j = i;

        } //for each side

        return oddNodes;

    } //pointInPoly

} //Collision


//Internal helpers

#if (haxe_ver < 3.3)
    private typedef Constructible = {
        public function new():Void;
    }
#end

/** 
    A result set container.
    Items in the container are preallocated, then pulled out and updated.
    The container will behave like a regular container, where iterating, 
    and get will only return values from the valid set. Pushing items
    will increase the valid set.
*/
@:generic
#if (haxe_ver >= 3.3)
class Results<T:haxe.Constraints.Constructible<Void->Void>> {
#else
class Results<T:Constructible> {
#end

    public var length (get, never) : Int;
    public var total (get, never) : Int;

        //internal
    var items:Array<T>;
    var count:Int = 0;

        /** Create a new set of results. 
            Preallocates `size` items into the list. */
    public function new(size:Int) {
        items = [for (i in 0...size) new T()];
    }

        /** Add an item to the container. */
    inline public function push(value:T) : Void {

        items[count] = value;
        
        count++;

    } //push

        /** Get the item at the given index. 
            If the index is < 0 and > length-1 it returns null; */
    inline public function get(index:Int) : T {

        if(index < 0 && index > length-1) return null;

        return items[index];

    } //get

        /** Grabs the last item from the cache to reuse.
            If there are no free items, it adds a new one.
            Typically internal use. */
    inline public function pull() : T {

            //no more?
        if(items.length == count) items.push(new T());
            //return the last item
        return items[count];

    } //pull

        /** Clear the container, which sets the length to 0. 
            This keeps the cached items but won't return them 
            while iterating or accessing them.
            Returns `this` for convience. */
    inline public function clear() : Results<T> {
        count = 0;
        return this;
    }

        /** Returns an iterator over the valid items in this set. */
    inline public function iterator() : ResultsIterator<T> {
        return new ResultsIterator<T>(this);
    }


        // getters
    inline function get_length() : Int return count;
    inline function get_total() : Int return items.length;

} //Results

@:generic
#if (haxe_ver >= 3.3)
class ResultsIterator<T:haxe.Constraints.Constructible<Void->Void>> {
#else
class ResultsIterator<T:Constructible> {
#end

    var index: Int = 0;
    var results: Results<T>;

    public inline function new(_results:Results<T>) {
        index = 0;
        results = _results;
    }

    public inline function hasNext() {
        return index < results.length;
    }

    public inline function next() {
        return results.get(index++);
    }

} //ResultsIterator