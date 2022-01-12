package differ.math;

import differ.math.Matrix;

//NOTE : Only implements the basics required for the collision code.
//The goal is to make this library as simple and unencumbered as possible, making it easier to integrate
//into an existing codebase. This means that using abstracts or similar you can add a function like "toMyEngineFloat2Format()"
//or simple an adapter pattern to convert to your preferred format. It simplifies usage and handles internals, nothing else.
//This also means that ALL of these functions are used and are needed.

#if false
    /** 2D Float2 class */
class Float2 {

        /** The x component */
    public var x  : Float = 0;
        /** The y component */
    public var y  : Float = 0;

        /** The length of the Float2 */
    public var length ( get, set ) : Float;
        /** The length, squared, of the Float2 */
    public var lengthsq ( get, never ) : Float;

    public function new( _x:Float = 0, _y:Float = 0 ) {

        x = _x;
        y = _y;

    } //new

        /** Copy, returns a new Float2 instance from this Float2. */
    public inline function clone() : Float2 {

        return new Float2(x, y);

    } //clone

        /** Transforms Float2 based on the given Matrix. Returns this Float2, modified. */
    public function transform(matrix:Matrix):Float2 {

        var v:Float2 = clone();

            v.x = x*matrix.a + y*matrix.c + matrix.tx;
            v.y = x*matrix.b + y*matrix.d + matrix.ty;

        return v;

    } //transform

        /** Sets the Float2's length to 1. Returns this Float2, modified. */
    public function normalize() : Float2 {

        if(length == 0){
            x = 1;
            return this;
        }

        var len:Float = length;

            x /= len;
            y /= len;

        return this;

    } //normalize

        /** Sets the length to fit under the given maximum value.
            Nothing is done if the Float2 is already shorter.
            Returns this Float2, modified. */
    public function truncate( max:Float ) : Float2 {

        length = Math.min(max, length);

        return this;

    } //truncate

        /** Invert this Float2. Returns this Float2, modified. */
    public function invert() : Float2 {

            x = -x;
            y = -y;

        return this;

    } //invert

        /** Return the dot product of this Float2 and another Float2. */
    public function dot( other:Float2 ) : Float {

        return x * other.x + y * other.y;

    } //dot

        /** Return the cross product of this Float2 and another Float2. */
    public function cross( other:Float2 ) : Float {

        return x * other.y - y * other.x;

    } //cross

        /** Add a Float2 to this Float2. Returns this Float2, modified. */
    public function add(other:Float2):Float2 {

            x += other.x;
            y += other.y;

        return this;

    } //add

        /** Subtract a Float2 from this one. Returns this Float2, modified. */
    public function subtract( other:Float2 ) : Float2 {

            x -= other.x;
            y -= other.y;

        return this;

    } //subtract

        /** Return a string representation of this Float2. */
    public function toString() : String return "Float2 x:" + x + ", y:" + y;

//Internal


    inline function set_length(value:Float) : Float {

        var ep:Float = 0.00000001;
        var _angle:Float = Math.atan2(y, x);

            x = Math.cos(_angle) * value;
            y = Math.sin(_angle) * value;

        if(Math.abs(x) < ep) x = 0;
        if(Math.abs(y) < ep) y = 0;

        return value;

    } //set_length

    inline function get_length() : Float return Math.sqrt(lengthsq);
    inline function get_lengthsq() : Float return x * x + y * y;


} //Float2

#end