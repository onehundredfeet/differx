package differ.shapes;

import differ.math.Transform;

class CachedShape {
    public var transform(get,never) : Transform;
    public var x(get,never) : Float;
    public var y(get,never) : Float;
    public var shape(get,never) : Shape;
    public var transformedShape(get,never) : Shape;

    var _transform : Transform;
    var _polygon : Polygon;
    var _polygonTransformed : Polygon;
    var _circle : Circle;
    var _circleTransformed : Circle;
    var _shape : Shape;

    public function new( shape : Shape = null, x : Float = 0., y : Float = 0., rot : Float = 0., scale : Float = 1. ) {
        _transform = new Transform(x, y, rot, scale);
        if (shape != null) bind(shape);
    }

    public function bind(shape : Shape) {
        _shape = shape;
    }
    public function cache(t : Transform = null) : Shape{
        if (t == null) t = _transform;

        if (Std.isOfType(shape, Polygon)) {
            _polygonTransformed = _polygon.transform(t, _polygonTransformed);
            return _polygonTransformed;
        } else {
            _circleTransformed = _circle.transform(t, _circleTransformed);
            return _circleTransformed;
        }
    }


    inline function get_transform() : Transform return _transform;
    inline function get_x() : Float return _transform.x;
    inline function get_y() : Float return _transform.y;
    inline function get_shape() : Shape return _shape;
    inline function get_transformedShape() : Shape return Std.isOfType(_shape, Polygon) ? _polygonTransformed : _circleTransformed;

}