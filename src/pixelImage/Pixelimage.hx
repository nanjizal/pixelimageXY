package pixelimage;
/*
// Example use.. currently set only for canvas.

-js bin/test.js
-lib htmlHelper
-lib pixelimage
-main Main
-D js-flatten 
-dce full
#--no-traces
--next
-cmd echo '<!DOCTYPE html><meta charset="UTF-8"><html><body><script src="test.js"></script></body></html>' >bin/index.html
# open html on linux.
-cmd cd bin/
-cmd firefox "./index.html"

import htmlHelper.canvas.CanvasSetup;
import htmlHelper.canvas.Surface;
import pixelimage.Pixelimage;
function main() new Main();
class Main {
    public var canvasSetup = new CanvasSetup();
    public function new(){
        trace( 'Pixelimage example on Canvas' );
        var g   = canvasSetup.surface;
        var p = new Pixelimage( 1024, 768 );
        p.fillRect( 100, 100, 300, 200, 0xff4211bc );
        p.fillTri( 100, 100, 200, 120, 150, 300, 0xffF000c0 );
        p.fillGradTri( 100, 100, 0xffff0000
                     , 500, 300, 0xFF00ff00
                     , 300, 500, 0xFF0000ff);
        p.fillRegPoly( 300, 300, 90, 200, 0xFF00Ffcc );// circles and ellipses
        p.drawToContext( g.me, 0, 0 );
        p.drawFromContext( g.me, 0, 0 );
        trace( p.getPixelString( 101, 101) );
   }
}

*/
import haxe.io.UInt32Array;
final isLittleEndian = (() -> {
    final a8 = new js.lib.Uint8Array(4);
    final a32 = (new js.lib.Uint32Array(a8.buffer)[0]=0xFFcc0011);
    return !(a8[0]==0xff);
})();
@:structInit
class Pixelimage_ {
  public var width:  Int;
  public var height: Int;
  public var image:  UInt32Array;
  public var isLittle: Bool;
  public function new( width: Int, height: Int, image: UInt32Array ){
    this.width = width;
    this.height = height;
    this.image = image;
    this.isLittle = isLittleEndian;
  }
}
@:transient
abstract Pixel32( Int ){
    inline public function new( v: Int ){
        this = v;
    }
    inline public function toCanvas():Int{
        var c = this;
        // abgr
        return if( isLittleEndian ){
            var a = c >> 24 & 0xFF;
            var r = c >> 16 & 0xFF;
            var g = c >> 8 & 0xFF;
            var b = c & 0xFF;
            a << 24 | b << 16 | g << 8 | r;
        } else { 
            c;
        }
    }
    inline public function fromCanvas():Int {
        var c = this;
        return if( isLittleEndian ){
            var a = c >> 24 & 0xFF;
            var b = c >> 16 & 0xFF;
            var g = c >> 8 & 0xFF;
            var r = c & 0xFF;
            // argb
            a << 24 | r << 16 | g << 8 | b;
        } else {
            c;
        }
    }
    inline public function rgbToCanvas():Int {
        var rgb = this;
        var r = rgb >> 16 & 0xFF;
        var g = rgb >> 8 & 0xFF;
        var b = rgb & 0xFF;
        // abgr
        return b << 16 | g << 8 | r; 
    }
    inline public function rgbFromCanvas():Int {
        var c = this;
        var b = c >> 16 & 0xFF;
        var g = c >> 8 & 0xFF;
        var r = c & 0xFF;
        // rgb
        return r << 16 | g << 8 | b << 0;
    }
}
@:transient
abstract Pixelimage( Pixelimage_ ) from Pixelimage_ {
    public var width( get, never ): Int;
    inline function get_width(): Int {
       return this.width;
    }
    public var height( get, never ): Int;
    inline function get_height(): Int {
        return this.height;
    }
    inline
    public function new( w: Int, h: Int ){
       this = ( 
        { width:  w
        , height: h
        , image:  new haxe.io.UInt32Array( Std.int( w * h  ) ) 
        }: Pixelimage_ 
        );
    }
    inline 
    function position( x: Int, y: Int ){
       return Std.int( y * this.width + x );
    }
    inline
    public function setARGB( x: Int, y: Int, color: Int ){
       this.image[ position( x, y ) ] = new Pixel32( color ).toCanvas();
    }
    inline
    public function getARGB( x: Int, y: Int ): Int {
       return new Pixel32( this.image[ position( x, y ) ] ).fromCanvas();
    }
    inline
    function pos4( x: Int, y: Int, ?off: Int = 0 ): Int {
        return Std.int( position( x, y ) * 4 ) + off;
    }     
    inline 
    function view8():js.lib.Uint8Array {
        var dataimg: js.lib.Uint32Array = cast this.image;
        return new js.lib.Uint8Array( dataimg.buffer ); // TODO make more generic
    }  
    inline
    public function setIalpha( x: Int, y: Int, alpha: Int ) {
        view8()[ pos4( x, y, 0 ) ] = alpha;    
    }
    inline
    public function getIalpha( x: Int, y: Int ): Int {
        return view8()[ pos4( x, y, 0 )];   
    }
    inline
    public function setIrgb( x: Int, y: Int, rgb: Int ) {
        var a = getIalpha( x, y );
        // abgr
        this.image[ position( x, y ) ] = a << 24 | new Pixel32( rgb ).rgbToCanvas();   
    }
    inline
    public function getIrgb( x: Int, y: Int ): Int {
        var c = this.image[ position( x, y ) ];
        // rgb
        return new Pixel32(c).rgbFromCanvas();
    }
    inline public
    function stringHash8( col: Int ): String
        return '#' + StringTools.hex( col, 8 );
    inline public
    function stringHash6( col: Int ): String 
        return '#' + StringTools.hex( col, 6 );
    inline public
    function getPixelString( x: Int, y: Int )
        return stringHash8( getARGB( x, y ) );
    inline public
    function getRGBString( x: Int, y: Int )
        return stringHash6( getIrgb( x, y ) );
    inline public 
    function simpleRect( x: Float, y: Float
                       , w: Float, h: Float
                       , color: Int ){
        var p = Std.int( x );
        var xx = p;
        var q = Std.int( y );
        var maxX = Std.int( x + w );
        var maxY = Std.int( y + h );
        while( true ){
            setARGB( p++, q, color );
            if( p > maxX ){
                p = xx;
                q++;
            } 
            if( q > maxY ) break;
        }
    }
    /*
        Used for bounding box iteration, calculates lo...hi iterator from 3 values. 
    */
    // TODO: swap floor and ceil and test
    inline 
    function boundIterator3( a: Float, b: Float, c: Float ): Iterator<Int> {
        return if( a > b ){
            if( a > c ){ // a,b a,c
                (( b > c )? Std.int( c ): Std.int( b ))...Std.int( a );
            } else { // c,a,b
                Std.int( b )...Std.int( c );
            }
        } else {
            if( b > c ){ // b,a, b,c 
                (( a > c )? Std.int( c ): Std.int( a ))...Std.int( b );
            } else { // c,b,a
                Std.int( a )...Std.int( c );
            }
        }
    }
    inline
    function boundIterator4( a: Float, b: Float, c: Float, d: Float ): Iterator<Int> {
        var min = Math.floor( a );
        var max = Math.ceil( a );
        if( b < min ){
            min = Math.floor( b );
        } else if( b > max ){
            max = Math.ceil( b );
        }
        if( c < min ){
            min = Math.floor( c );
        } else if( c > max ){
            max = Math.ceil( c );
        }
        if( d < min ){
            min = Math.floor( d );
        } else if( d > max ){
            max = Math.ceil( d );
        }
        return min...max;
    }
    public inline
    function fillTri( ax: Float, ay: Float
                    , bx: Float, by: Float
                    , cx: Float, cy: Float
                    , color: Int ){
        var adjustWinding = ( (ax * by - bx * ay) + (bx * cy - cx * by) + (cx * ay - ax * cy) )>0;
        if( !adjustWinding ){// TODO: this is inverse of cornerContour needs thought, but provides required protection
            // swap b and c
            // probably wrong way as y is down?
            var bx_ = bx;
            var by_ = by;
            bx = cx;
            by = cy;
            cx = bx_;
            cy = by_;
        }
        fillTriUnsafe( ax, ay, bx, by, cx, cy, color ); 
    }
    public inline 
    function fillTriUnsafe( ax: Float, ay: Float
                          , bx: Float, by: Float
                          , cx: Float, cy: Float
                          , color: Int ){
        var s0 = ay*cx - ax*cy;
        var sx = cy - ay;
        var sy = ax - cx;
        var t0 = ax*by - ay*bx;
        var tx = ay - by;
        var ty = bx - ax;
        var A = -by*cx + ay*(-bx + cx) + ax*(by - cy) + bx*cy;
        for( x in boundIterator3( ax, bx, cx ) ){
            var sxx = sx*x;
            var txx = tx*x;
            for( y in boundIterator3( ay, by, cy ) ){
                if( triCalc( x, y, s0, t0, sxx, sy, txx, ty, A ) ) setARGB( x, y, color );
            }
        }
    }
    inline
    function triCalc( x:    Float,  y:    Float
                    , s0:   Float,  t0:   Float
                    , sxx:  Float,  sy:   Float
                    , txx:  Float,  ty:   Float
                    , A:    Float      ): Bool {
        var s = s0 + sxx + sy*y;
        var t = t0 + txx + ty*y;
        return ( s <= 0 || t <= 0 )? false: (s + t) < A;
    }
    public inline
    function fillGradTri( ax: Float, ay: Float, colA: Int
                        , bx: Float, by: Float, colB: Int
                        ,  cx: Float, cy: Float, colC: Int ){
        var aA = ( colB >> 24 ) & 0xFF;
        var rA = ( colB >> 16 ) & 0xFF;
        var gA = ( colB >> 8 ) & 0xFF;
        var bA = colB & 0xFF;
        var aB = ( colA >> 24 ) & 0xFF;
        var rB = ( colA >> 16 ) & 0xFF;
        var gB = ( colA >> 8 ) & 0xFF;
        var bB = colA & 0xFF;
        var aC = ( colC >> 24 ) & 0xFF;
        var rC = ( colC >> 16 ) & 0xFF;
        var gC = ( colC >> 8 ) & 0xFF;
        var bC = colC & 0xFF;
        var bcx = bx - cx;
        var bcy = by - cy;
        var acx = ax - cx; 
        var acy = ay - cy;
        // Had to re-arrange algorithm to work so dot names may not quite make sense.
        var dot11 = dotSame( bcx, bcy );
        var dot12 = dot( bcx, bcy, acx, acy );
        var dot22 = dotSame( acx, acy );
        var denom1 = 1/( dot11 * dot22 - dot12 * dot12 );
        for( px in boundIterator3( cx, bx, ax ) ){
            var pcx = px - cx;
            for( py in boundIterator3( cy, by, ay ) ){
                var pcy = py - cy;
                var dot31 = dot( pcx, pcy, bcx, bcy );
                var dot32 = dot( pcx, pcy, acx, acy );
                var ratioA = (dot22 * dot31 - dot12 * dot32) * denom1;
                var ratioB = (dot11 * dot32 - dot12 * dot31) * denom1;
                var ratioC = 1.0 - ratioB - ratioA;
                if( ratioA >= 0 && ratioB >= 0 && ratioC >= 0 ){
                    var a = boundChannel( aA*ratioA + aB*ratioB + aC*ratioC );
                    var r = boundChannel( rA*ratioA + rB*ratioB + rC*ratioC );
                    var g = boundChannel( gA*ratioA + gB*ratioB + gC*ratioC );
                    var b = boundChannel( bA*ratioA + bB*ratioB + bC*ratioC );
                    // re-ordered for canvas abgr
                    this.image[ position( px, py ) ] = ( this.isLittle )? a << 24 | b << 16 | g << 8 | r: a << 24 | r << 16 | g << 8 | b;
                }
            }
        }
    }
    /*
    // NOT WORKING YET!!
    // inverse bilinear interpolation
    public inline 
    function fillGradQuad( ax: Float, ay: Float, colA: Int
                         , bx: Float, by: Float, colB: Int
                         , cx: Float, cy: Float, colC: Int
                         , dx: Float, dy: Float, colD: Int 
                         ){
        var ex = bx - ax;
        var ey = by - ay;
        var fx = dx - ax;
        var fy = dy - ay;
        var gx = ax - bx + cx - dx;
        var gy = ay - by + cy - dy;
        var ratioX: Float = 0.;
        var ratioY: Float = 0.;
        for( px in boundIterator4( ax, bx, cx, dx ) ){
            var hx = px - ax;
            for( py in boundIterator4( ay, by, cy, dy ) ){
                var hy = py - ay;
                var k2 = cross2d( gx, gy, fx, fy );
                var k1 = cross2d( ex, ey, fx, fy ) + cross2d( hx, hy, gx, gy );
                var k0 = cross2d( hx, hy, ex, ey );
                // if edges are parallel, this is a linear equation
                if( Math.abs( k2 ) < 0.001 ){
                    ratioX = ( hx * k1 + fx * k0 ) / ( ex * k1 - gx * k0 );
                    ratioY = -k0 / k1;
                } else {
                    var w = k1*k1 - 4.0*k0*k2;
                    if( w < 0.0 ){
                        // unsure
                        // return vec2(-1.0);  ??
                    } else {
                        w = Math.sqrt( w );
                        var ik2 = 0.5/k2;
                        var v = ( -k1 - w )*ik2;
                        var u = ( hx - fx * v ) / ( ex + gx * v );
                        if( u < 0.0 || u > 1.0 || v < 0.0 || v > 1.0 ){
                            v = ( -k1 + w )*ik2;
                            u = ( hx - fx * v )/( ex + gx * v );
                        } 
                        ratioX = u;
                        ratioY = v;       
                    }

                }
                var rgba = lerp4Colors( colA, colB, colC, colD, ratioX, ratioY );
                setARGB( px, py, rgba );
            }
        }
    }
    */
    // Ken Perlin smoothStep 
    inline 
    function smootherStep( t: Float ): Float {
        return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
    }
    inline 
    function lerp( a: Float, b: Float, t: Float ): Float
        return b + ( b - a ) * t;
    public inline
    function lerp4Colors( colorhiA, colorhiB
                        , colorloC, colorloD
                        , u: Float, v: Float
                        , smooth: Bool = true ):Int {
        var hiColor = lerp2Colors( colorhiA, colorhiB, u, smooth );
        var loColor = lerp2Colors( colorloC, colorloD, u, smooth );
        return lerp2Colors( hiColor, loColor, v, smooth );
    }
    // HSL better, but this for initial test.
    public inline
    function lerp2Colors( colA: Int, colB: Int, t: Float, smooth: Bool = true ): Int {
        var aA = ( colB >> 24 ) & 0xFF;
        var rA = ( colB >> 16 ) & 0xFF;
        var gA = ( colB >> 8 ) & 0xFF;
        var bA = colB & 0xFF;
        var aB = ( colA >> 24 ) & 0xFF;
        var rB = ( colA >> 16 ) & 0xFF;
        var gB = ( colA >> 8 ) & 0xFF;
        var bB = colA & 0xFF;
        var v = ( smooth )? smootherStep( t ): t;
        // check if values same.
        var af = lerp( aA/255, aB/255, v );
        var rf = lerp( rA/255, rB/255, v );
        var gf = lerp( gA/255, gB/255, v );
        var bf = lerp( bA/255, bB/255, v );
        return from_argb( af, rf, gf, bf );
    }
    inline  
    function from_argb( a: Float, r: Float, g: Float, b: Float ): Int
        return ( toHexInt( a ) << 24 ) 
             | ( toHexInt( r ) << 16 ) 
             | ( toHexInt( g ) << 8 ) 
             |   toHexInt( b );
    inline
    function toHexInt( c: Float ): Int
        return Math.round( c * 255 );
    inline
    function cross2d( ax: Float, ay: Float, bx: Float, by: Float ): Float
        return ax * by - ay * bx;
    inline function boundChannel( f: Float ): Int {
        var i = Std.int( f );
        if( i > 0xFF ) i = 0xFF;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
        if( i < 0 ) i = 0;
        return i;
    }
    // equation from math.stackexchange from TeM
    inline
    function circleError( radius: Float, ?targetE: Float = 1.05, ?minN: Int = 12, ?maxN: Int = 500 ): Int {
        var result = Math.ceil( Math.PI/( Math.acos( 1 - targetE/radius ) ) );
        return if( result < minN ){
            minN;
        } else if( result > maxN ){
            maxN;
        } else {
            result;
        }
    }
    // setup so large ellipses automatically use more sides.
    inline
    function fillEllipseTri( cx: Float, cy: Float
                           , rx: Float, ry: Float
                           , color: Int, ?phi: Float = 0, ?printSides: Bool = false, ?targetE: Float = 1.05 ){
        var rSmall = ( rx > ry )? ry: rx;
        var noSides = circleError( rSmall, targetE );
        if( printSides ) trace( noSides );
        fillPolyBuild( cx, cy, rx, ry, color, phi, noSides );
    }
    // phi controls rotation
    // cornerUp is to rotate the structure before phi so top is flat.
    inline public
    function fillPolyBuild( cx: Float,  cy: Float
                        , rx: Float,  ry: Float
                        , color: Int, ?phi: Float = 0.
                        , ?sides: Int = 36, cornerUp: Bool = true ){
        var theta = 2*Math.PI/sides;
        var omega = if( cornerUp ){
             0.;
        } else {
            // allow top the be flat
            if( Std.int( sides/2) == sides/2 ){
                Math.PI/sides;
            } else {
                var v = (sides/2-0.5);
                if( Std.int( v/2 ) == v/2 ){
                    0.5*Math.PI/sides - Math.PI;
                } else {
                    0.5*Math.PI/sides;
                }
                
            }
        }
        // can be solved by including edges .. not implemented yet
        var lastX: Float = 0.;
        var lastY: Float = 0.;
        if( phi != 0 ){
            lastX = rx * Math.cos( sides*theta  + omega) * Math.cos( phi ) - ry * Math.sin( sides*theta + omega ) * Math.sin( phi ) + cx;
            lastY = rx * Math.cos( sides*theta  + omega ) * Math.sin( phi ) + ry * Math.sin( sides*theta + omega ) * Math.cos( phi ) + cy;
        } else {
            lastX = cx + rx*Math.cos( sides*theta + omega );
            lastY = cy + ry*Math.sin( sides*theta + omega );
        }
        if( phi != 0 ){
            var cphi = Math.cos( phi );
            var sphi = Math.sin( phi );
            for( i in 0...sides + 1 ){
                var stheta = Math.sin( i*theta + omega );
                var ctheta = Math.cos( i*theta + omega );
                var nextX = rx * ctheta * cphi - ry * stheta * sphi + cx;
                var nextY = rx * ctheta * sphi + ry * stheta * cphi + cy;
                fillTri( cx, cy, lastX, lastY, nextX, nextY, color );
                lastX = nextX;
                lastY = nextY;
            }
        } else { 
            for( i in 0...sides + 1 ){
                var nextX = cx + rx*Math.cos( i*theta + omega );
                var nextY = cy + ry*Math.sin( i*theta + omega );
                fillTri( cx, cy, lastX, lastY, nextX, nextY, color );
                lastX = nextX;
                lastY = nextY;
            }
        }
    }
    inline public
    function distanceSquarePointToSegment( x:  Float, y: Float
                                                , x1: Float, y1:Float
                                                , x2: Float, y2:Float
                                                ): Float
    {
        var p1_p2_squareLength = (x2 - x1)*(x2 - x1) + (y2 - y1)*(y2 - y1);
        var dotProduct = ((x - x1)*(x2 - x1) + (y - y1)*(y2 - y1)) / p1_p2_squareLength;
        return if ( dotProduct < 0 ){
            return (x - x1)*(x - x1) + (y - y1)*(y - y1);
        } else if ( dotProduct <= 1 ){
            var p_p1_squareLength = (x1 - x)*(x1 - x) + (y1 - y)*(y1 - y);
            return p_p1_squareLength - dotProduct * dotProduct * p1_p2_squareLength;
        } else {
            return (x - x2)*(x - x2) + (y - y2)*(y - y2);
        }
    }
    inline function dot( ax: Float, ay: Float, bx: Float, by: Float ): Float
        return ax * bx + ay * by;
    inline function dotSame( ax: Float, ay: Float ): Float
        return dot( ax, ay, ax, ay );
    #if js
    inline
    public function drawToContext( ctx: js.html.CanvasRenderingContext2D, x: Int, y: Int  ){
        var data = new js.lib.Uint8ClampedArray( view8().buffer );
        var imageData = new js.html.ImageData( data, this.width, this.height );
        ctx.putImageData( imageData, x, y);
    }
    inline
    public function drawFromContext( ctx: js.html.CanvasRenderingContext2D, x: Int, y: Int ){
        var imageData = ctx.getImageData( x, y, this.width, this.height);
        var data = imageData.data;
        var temp = new js.lib.Uint32Array( data.buffer );
        this.image = cast temp;
    }
    #end
}
// references
// http://totologic.blogspot.com/2014/01/accurate-point-in-triangle-test.html
// https://codeplea.com/triangular-interpolation *
// https://gamedev.stackexchange.com/questions/23743/whats-the-most-efficient-way-to-find-barycentric-coordinates    
// https://stackoverflow.com/questions/39213661/canvas-using-uint32array-wrong-colors-are-being-rendered
// https://stackoverflow.com/questions/26513712/algorithm-for-coloring-a-triangle-by-vertex-color
// https://iquilezles.org/articles/ibilinear/ - todo add MIT details if quad runs.
// https://www.shadertoy.com/view/lsBSDm
// https://math.stackexchange.com/questions/4132060/compute-number-of-regular-polgy-sides-to-approximate-circle-to-defined-precision