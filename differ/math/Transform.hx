package differ.math;
import differ.data.*;

import hvector.*;

class Transform {
   
    public var position ( get, set ) : Float2;
        /** The x position of this shape */
    public var x ( get, set ) : Float;
        /** The y position of this shape */
    public var y ( get, set ) : Float;
        /** The rotation of this shape, in degrees */
    public var rotation ( get, set ) : Float;
        /** The scale in the all direction of this shape */
    public var scale ( get, set ) : Float;

    public var matrix (get, never ) : Matrix;

    var _position : Float2;
    var _rotation : Float = 0;
    var _rotation_radians : Float = 0;

    var _scale : Float = 1;

    var _transformMatrix : Matrix;
    var _dirty = false;
//Public API


    /** Create a new shape at give position x,y */
    public function new( _x:Float = 0., _y:Float = 0., angle : Float = 0., scale = 1. ) {

        _position = new Float2(_x,_y);
        _rotation = angle;

        _scale = scale;

        _transformMatrix = new Matrix();
        _transformMatrix.makeTranslation( _position.x, _position.y );

    } //new

        /** clean up and destroy this shape */
    public function destroy():Void {

        _position = null;
        _transformMatrix = null;

    } //destroy

//Getters/Setters

    function refresh_transform() {

        _transformMatrix.compose( _position, _rotation_radians, _scale );
        _dirty = false;

    }

//.position

    function get_position() : Float2 {
        return _position;
    }

    function set_position( v : Float2 ) : Float2 {
        _position = v;
        _dirty = true;
        return _position;
    }

//.x

    function get_x() : Float {
        return _position.x;
    }

    function set_x(x : Float) : Float {
        _position.x = x;
        _dirty = true;
        return _position.x;
    }

//.y

    function get_y() : Float {
        return _position.y;
    }

    function set_y(y : Float) : Float {
        _position.y = y;
        _dirty = true;
        return _position.y;
    }

//.rotation

    function get_rotation() : Float {
        return _rotation;
    }

    function set_rotation( v : Float ) : Float {

        _rotation_radians = v * (Math.PI / 180);

        _dirty = true;

        return _rotation = v;

    } //set_rotation

//.scale

    function get_scale():Float {
        return _scale;
    }

    function set_scale( scale : Float ) : Float {
        _dirty = true;
        return _scale = scale;
    }


    //.matrix

    function get_matrix(): Matrix {
        if (_dirty) {
            refresh_transform();
        }
        return _transformMatrix;
    }

    // full set
    public function set( tx, ty, rot, s ) {
        _position.x = tx;
        _position.y = ty;
        _rotation = rot;
        _rotation_radians  = rot * (Math.PI / 180);
        _scale = s;

        _dirty = true;
    }


}