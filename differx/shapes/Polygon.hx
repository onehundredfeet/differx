package differx.shapes;

import differx.math.*;
import differx.shapes.*;
import differx.data.*;
import differx.sat.*;

import hvector.*;

/** A polygonal collision shape */
class Polygon extends Shape {

        /** The vertices of this shape */
    public var vertices ( get, never ) : Float2Array;

    var _vertices : Float2Array;
    var _edgeData : Array<Dynamic>;
    var _boundingRadius : Float;

        /** Create a new polygon with a given set of vertices at position x,y. */
    public function new( vertices:Float2Array, ?original : Polygon ) {
        super(original);
        #if differ_autoname name = 'polygon(sides:${vertices.length})'; #end
        _vertices = vertices;

        _boundingRadius = 0.;

        for (i in 0...vertices.length) {
            var v = vertices[i];
            var l = v.length();
            if (l > _boundingRadius) _boundingRadius = l;
        }

    } //new

        /** Destroy this polygon and clean up. */
    override public function destroy() : Void {

        var _count : Int = _vertices.length;
       
        _vertices = null;

        super.destroy();

    } //destroy

//Public static API

    public static function allocate(verts:Int):Polygon {
        return new Polygon( Float2Array.allocate(verts));
    }
    public function setVertex( i, x, y ) {
        vertices[i] = new Float2(x,y);
        var d = vertices[i].length();
        if (d > _boundingRadius) _boundingRadius = d;
    }
    public function setEdgeData(i, d : Dynamic) {
        if (_edgeData == null) _edgeData = new Array<Dynamic>();
        _edgeData[i] = d;
    }
        /** Helper to create an Ngon at x,y with given number of sides, and radius.
            A default radius of 100 if unspecified. Returns a ready made `Polygon` collision `Shape` */
    public static function create(sides:Int, radius:Float=100):Polygon {

        if(sides < 3) {
            throw 'Polygon - Needs at least 3 sides';
        }

        var rotation:Float = (Math.PI * 2) / sides;
        var angle:Float;
        var Float2:Float2;
        var vertices:Float2Array = Float2Array.allocate(sides);

        for(i in 0 ... sides) {
            angle = (i * rotation) + ((Math.PI - rotation) * 0.5);
            var v = new Float2(Math.cos(angle) * radius, Math.sin(angle) * radius);
            vertices[i] = v;
        }

        return new Polygon(vertices);

    } //create

        /** Helper generate a rectangle at x,y with a given width/height and centered state.
            Centered by default. Returns a ready made `Polygon` collision `Shape` */
    public static function rectangle( width:Float, height:Float, centered:Bool = true):Polygon {

        var vertices:Float2Array = Float2Array.allocate(4);

        if(centered) {

            vertices[0] = ( new Float2( -width / 2, -height / 2) );
            vertices[1] = ( new Float2(  width / 2, -height / 2) );
            vertices[2] = ( new Float2(  width / 2,  height / 2) );
            vertices[3] = ( new Float2( -width / 2,  height / 2) );

        } else {

            vertices[0] = ( new Float2( 0, 0 ) );
            vertices[1] = ( new Float2( width, 0 ) );
            vertices[2] = ( new Float2( width, height) );
            vertices[3] = ( new Float2( 0, height) );

        }

        return new Polygon(vertices);

    } //rectangle

        /** Helper generate a square at x,y with a given width/height with given centered state.
            Centered by default. Returns a ready made `Polygon` collision `Shape` */
    public static inline function square( width:Float, centered:Bool = true) : Polygon {

        return rectangle(width, width, centered);

    } //square

        /** Helper generate a triangle at x,y with a given radius.
            Returns a ready made `Polygon` collision `Shape` */
    public static function triangle( radius:Float) : Polygon {

        return create(3, radius);

    } //triangle

//Internal



    public function transform(t : Transform, ? into : Polygon)   : Polygon {
        if (into == null) {
            into = new Polygon( Float2Array.allocate( vertices.length), cast _original);
        } else {
            into.vertices.resize(vertices.length);
            into._original = _original;
        }
        var tv = into.vertices;
        var boundingRadius = 0.;

        for(i in 0...vertices.length) {
            tv[i] = t.matrix.transform(_vertices[i]);

            var l = tv[i].length();
            if (l > boundingRadius) boundingRadius = l;
        }

        into._boundingRadius = boundingRadius;

        return into;
    }

    function get_vertices() : Float2Array {
        return _vertices;
    }

    public override function getBoundingRadius() : Float {
        return _boundingRadius;
    }
    
} //Polygon
