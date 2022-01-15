package differ;

import differx.math.*;
import differx.shapes.*;
import differx.data.*;

import hvector.Float2Array;
import hvector.Float2;

/** To implement your own debug drawing class, you only need to override drawLine function and implement it
    the rest is handled internally. You can override specifics if you want, but it's not required */
class ShapeDrawer {

//Public API

    public function new() {

    } //new

        /** Draw a line between p0 and p1. Implement this function at minimum in custom drawing handlers */
    public function drawLine( p0x:Float, p0y:Float, p1x:Float, p1y:Float, ?startPoint:Bool = true ) {

    } //drawLine

        /** Draw a `Shape`, it will determine the type and draw it for you. */
    public function drawShape( t : Transform, shape:Shape ) {

        if(Std.is(shape, Polygon)) {
            drawPolygon(t, cast shape);
        } else {
            drawCircle(t, cast shape);
        }

    } //drawShape

        /** Draw a `Polygon` */
    public function drawPolygon( t: Transform, poly:Polygon ) {

        var p2 = Polygon.create(4);
        drawVertList(poly.vertices);

    } //drawPolygon

        /** Draw a circle `Shape` */
    public function drawCircle( t: Transform,circle:Circle ) {
            //from :
        //http://slabode.exofire.net/circle_draw.shtml

        var _smooth : Float = 10;
        var _steps : Int = Std.int(_smooth * Math.sqrt( circle.radius ));

            //Precompute the value based on segments
        var theta = 2 * 3.1415926 / _steps;

        var tangential_factor = Math.tan( theta );
        var radial_factor = Math.cos( theta );

        var x : Float = circle.radius;
        var y : Float = 0;

        var _verts : Float2Array = [];

        for( i in 0 ... _steps ) {

            var __x = x + t.x;
            var __y = y + t.y;

            _verts.push(new Float2(__x,__y));

                var tx = -y;
                var ty = x;

                x += tx * tangential_factor;
                y += ty * tangential_factor;

                x *= radial_factor;
                y *= radial_factor;

        } //for

            //now draw it
        drawVertList( _verts );

    } //drawCircle

    public function drawPoint( x:Float, y:Float, size:Float = 4 ) {

        var xs = x - size;
        var xe = x + size;
        var ys = y;
        var ye = y;

        drawLine(xs, ys, xe, ye);

        xs = xe = x;
        ys = y - size;
        ye = y + size;

        drawLine(xs, ys, xe, ye);

    } //drawPoint

    public function drawShapeCollision( c:ShapeCollision, ?length:Float = 30 ) {

        //origins

        drawPoint(c.shape1_x, c.shape1_y);
        drawPoint(c.shape2_x, c.shape2_y);

        //unit Float2s

        drawLine( c.shape1_x, c.shape1_y, c.shape1_x + (c.unitVectorX * length), c.shape1_y + (c.unitVectorY * length) );

        //ghosts

        drawPoint(c.shape1_x + c.separationX, c.shape1_y + c.separationY);
        
        if(c.otherOverlap != 0.0) {
            drawLine(c.shape1_x, c.shape1_y, c.shape1_x + (c.otherunitVectorX * length), c.shape1_y + (c.otherunitVectorY * length));
            drawPoint(c.shape1_x + c.otherSeparationX, c.shape1_y + c.otherSeparationY);
        }

    } //drawShapeCollision


//Internal API


        /** Draw a list of points as lines */
    function drawVertList( _verts : Float2Array ) {

        var _count : Int = _verts.length;

        if(_count == 2) {
            drawLine(_verts[0].x, _verts[0].y, _verts[1].x, _verts[1].y, true);
            return;
        }

        if(_count == 1) {
            drawPoint(_verts[0].x, _verts[0].y);
            return;
        }

            //start the polygon by drawing this start point
        drawLine(_verts[0].x, _verts[0].y, _verts[1].x, _verts[1].y, true);

            //draw the rest of the points
        for(i in 1 ... _count-1) {
            drawLine(_verts[i].x, _verts[i].y, _verts[i+1].x, _verts[i+1].y, false);
        }
            //join last point to first point
        drawLine(_verts[_count-1].x, _verts[_count-1].y, _verts[0].x, _verts[0].y, false);

    } //drawVertList


} //ShapeDrawer
