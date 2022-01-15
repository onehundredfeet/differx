package differx.shapes;

import hl.I64;
import differx.math.*;
import differx.shapes.*;
import differx.data.*;

/** A base collision shape */
class Shape {

        /** The name of this shape, to help in debugging */
    public var name(get,set) : String ;
        /** A generic data object where you can store anything you want, for later use */
    public var data(get,set) : Dynamic;

    /** The upstream shape if this is a cached shape */
    public var original(get,never) : Shape;

    // user provided flags to allow for fast rejection
    public var memberOfFlags : UInt = 0xffffffff;
    public var collidesWithFlags : UInt = 0xffffffff;

    /** The state of this shape, if inactive can be ignored in results */
     var _active : Bool = true;
    /** The name of this shape, to help in debugging */
     var _name : String = null;
        /** A generic data object where you can store anything you want, for later use */
     var _data : std.Any;

    /** The upstream shape if this is a cached shape */
     var _original : Shape;
        
//Public API


    /** Create a new shape at give position x,y */
    public function new( ? orig : Shape) {
        //tags = new Map();
        _original = orig == null ? this : orig;
    } //new

        /** clean up and destroy this shape */
    public function destroy():Void {
       

    } //destroy

//Getters/Setters

    function get_original() : Shape {
        return _original;
    }


    inline function get_name() : String {
        return _original._name;
    }

    inline function set_name(v : String) : String {
        return _original._name = v;
    }
   
    inline function get_data() : std.Any {
        return _original._data;
    }

    inline function set_data(v : std.Any) : std.Any {
        return _original._data = v;
    }

}
