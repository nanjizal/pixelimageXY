
package pixelimage.algo;
import pixelimage.pixel.Pixel32;
import pixelimage.algo.TriPixel;
import pixelimage.algo.HitTri;
import pixelimage.algo.GeomPix;

inline
function fillQuadrilateral( pixelImage: Pixelimage, ax: Float, ay: Float
                 , bx: Float, by: Float
                 , cx: Float, cy: Float
                 , dx: Float, dy: Float 
                 , color: Int
                 , hasHit: Bool = false ): Null<HitQuad>{
    // tri e - a b d
    // tri f - b c d
    fillTriangle( pixelImage, ax, ay, bx, by, dx, dy, color, hasHit );
    fillTriangle( pixelImage, bx, by, cx, cy, dx, dy, color, hasHit );
    return if( hasHit == true ){
        var v: HitQuad = { ax: ax, ay: ay, bx: bx, by: by, cx: cx, cy: cy, dx: dx, dy: dy };
        v;
    } else {
        null;
    }
}

inline
function tileQuadrilateral( pixelImage: Pixelimage, ax: Float, ay: Float
                 , bx: Float, by: Float
                 , cx: Float, cy: Float
                 , dx: Float, dy: Float 
                 , tileImage: Pixelimage
                 , hasHit: Bool = false ): Null<HitQuad>{
    // tri e - a b d
    // tri f - b c d
    tileTriangle( pixelImage, ax, ay, bx, by, dx, dy, tileImage, hasHit );
    tileTriangle( pixelImage, bx, by, cx, cy, dx, dy, tileImage, hasHit );
    return if( hasHit == true ){
        var v: HitQuad = { ax: ax, ay: ay, bx: bx, by: by, cx: cx, cy: cy, dx: dx, dy: dy };
        v;
    } else {
        null;
    }
}

inline
function fillGradQuadrilateral( pixelImage: Pixelimage
                                , ax: Float, ay: Float, colorA: Pixel32
                                , bx: Float, by: Float, colorB: Pixel32
                                , cx: Float, cy: Float, colorC: Pixel32 
                                , dx: Float, dy: Float, colorD: Pixel32
                                , hasHit: Bool = false ): Null<HitQuad>{
    // tri e - a b d
    // tri f - b c d
    fillGradTriangle( pixelImage, ax, ay, colorA, bx, by, colorB, dx, dy, colorD, hasHit );
    fillGradTriangle( pixelImage, bx, by, colorB, cx, cy, colorC, dx, dy, colorD );
    return if( hasHit == true ){
        var v: HitQuad = { ax: ax, ay: ay, bx: bx, by: by, cx: cx, cy: cy, dx: dx, dy: dy };
        v;
    } else {
        null;
    }
}
// No longer used, depreciate likely remove if not useful for any strange edge cases.
inline
function imgQuadrilateralFudge( pixelImage: Pixelimage
                         , texture: Pixelimage, win: RectangleWindow
                         , ax: Float, ay: Float
                         , bx: Float, by: Float
                         , cx: Float, cy: Float
                         , dx: Float, dy: Float 
                         , hasHit: Bool = false ): Null<HitQuad>{
    topRightImgTriFudge(   pixelImage, texture, win, ax, ay, bx, by, cx, cy, hasHit );
    bottomLeftImgTriFudge( pixelImage, texture, win, dx, dy, cx, cy, ax, ay, hasHit );
    return if( hasHit == true ){
        var v: HitQuad = { ax: ax, ay: ay, bx: bx, by: by, cx: cx, cy: cy, dx: dx, dy: dy };
        v;
    } else {
        null;
    }
}

inline
function imgQuadrilateral( pixelImage: Pixelimage
                         , texture: Pixelimage, win: RectangleWindow
                         , ax: Float, ay: Float
                         , bx: Float, by: Float
                         , cx: Float, cy: Float
                         , dx: Float, dy: Float
                         , au: Float = 0., av: Float = 0.
                         , bu: Float = 1., bv: Float = 0.
                         , cu: Float = 1., cv: Float = 1.
                         , du: Float = 0., dv: Float = 1.  
                         , hasHit: Bool = false ): Null<HitQuad>{
    // tri e - a b d
    // tri f - b c d                           
    uvTriangle( pixelImage, texture, win, ax, ay, au, av, bx, by, bu, bv, dx, dy, du, dv, hasHit );
    uvTriangle( pixelImage, texture, win, bx, by, bu, bv, cx, cy, cu, cv, dx, dy, du, dv, hasHit );
    return if( hasHit == true ){
        var v: HitQuad = { ax: ax, ay: ay, bx: bx, by: by, cx: cx, cy: cy, dx: dx, dy: dy };
        v;
    } else {
        null;
    }
}

inline
function imageNineSlice( pixelImage: Pixelimage
                        , texture: Pixelimage, win: RectangleWindow
                        , x: Float,   y: Float
                        , wid:           Float,      hi:       Float
                        , left:          Float,      top:      Float
                        , fat:           Float,      tall:     Float 
                        , widNew:        Float,      hiNew:       Float
                        , leftNew:       Float,      topNew:      Float
                        , fatNew:        Float,      tallNew:     Float 
                        , hasHit: Bool = false ): Null<HitQuad>{
    // tri e - a b d
    // tri f - b c d 
    // calculate hit shape. 
    var ax = x;
    var ay = y;
    var bx = ax + widNew;
    var by = y;
    var cx = bx;
    var cy = ay + hiNew;
    var dx = x;
    var dy = cx;
    // helper coordinates.                        
    var rightW = widNew - leftNew - fatNew;
    var bottomH = hiNew - topNew - tallNew;
    var leftX   = x + leftNew;
    var topY    = y + topNew;
    var rightX  = x + leftNew + fatNew;
    var bottomY = y + topNew + tallNew;
    var au = 0.;
    var av = 0.;
    var bu = 0.;
    var cv = 0.;
    var sw = 1/(wid+1);
    var sh = 1/(hi+1);
    // q0 q1 q2
    // q3 g4 q5
    // q6 q7 q8 
    //
    // q0
    bu = left*sw;
    cv = top*sh;
    imgQuadrilateral( pixelImage, texture, win
        , x, y, leftX, y, leftX, topY, x, topY
        , 0., 0., bu, 0., bu, cv, 0., cv
        , hasHit );
    // q1
    au = bu;
    bu = (left+fat)*sw;
    imgQuadrilateral( pixelImage, texture, win
        , leftX, y, rightX, y, rightX, topY, leftX, topY
        , au, 0., bu, 0., bu, cv, au, cv
        , hasHit );  
    // q2
    au = bu;
    bu = 1.;
    imgQuadrilateral( pixelImage, texture, win
        , rightX, y, x + widNew, y, x + widNew, topY, rightX, topY
        , au, 0., bu, 0, bu, cv, au, cv
        , hasHit );
    ////
    // q3
    av = top*sh;
    bu = left*sw;
    cv = (top+tall)*sh;
    imgQuadrilateral( pixelImage, texture, win
        , x, topY-1, leftX, topY-1, leftX, bottomY+1, x, bottomY
        , 0., av, bu, av, bu, cv, 0., cv
        , hasHit );
    // q4
    au = bu;
    bu = (left+fat)*sw;
    imgQuadrilateral( pixelImage, texture, win
        , leftX, topY-1, rightX, topY-1, rightX, bottomY+1, leftX, bottomY
        , au, av, bu, av, bu, cv, au, cv
        , hasHit );
    // q5
    au = bu;
    bu = 1.;    
    imgQuadrilateral( pixelImage, texture, win
        , rightX, topY-1, x + widNew, topY-1, x + widNew, bottomY+1, rightX, bottomY
        , au, av, bu, av, bu, cv, au, cv
        , hasHit ); 
    ///////////
    // q6
    av = (top+tall)*sh;
    bu = left*sw;
    cv = 1.;
    imgQuadrilateral( pixelImage, texture, win
        , x, bottomY, leftX, bottomY, leftX, y + hiNew, x, y + hiNew
        , 0., av, bu, av, bu, cv, 0., cv
        , hasHit ); 
    // q7
    au = bu;
    bu = (left+fat)*sw;
    imgQuadrilateral( pixelImage, texture, win
        , leftX, bottomY, rightX, bottomY, rightX, y + hiNew, leftX, y + hiNew
        , au, av, bu, av, bu, cv, au, cv
        , hasHit );       
    // q8
    au = bu;
    bu = 1.;
    imgQuadrilateral( pixelImage, texture, win
        , rightX, bottomY, x + widNew, bottomY, x + widNew, y + hiNew, rightX, y + hiNew
        , au, av, bu, av, bu, cv, au, cv
        , hasHit ); 
        
    return if( hasHit == true ){
            var v: HitQuad = { ax: ax, ay: ay, bx: bx, by: by, cx: cx, cy: cy, dx: dx, dy: dy };
            v;
        } else {
            null;
        }
}
class QuadPixel {
    /**
       <font color="LightPink" font-weight:"Bold">rotateGradLine</font> module level field
       @param hasHit defaults false, since a HitTri has runtime overhead.
    **/
    public var _fillQuadrilateral:( pixelImage: Pixelimage, ax: Float, ay: Float
        , bx: Float, by: Float
        , cx: Float, cy: Float
        , dx: Float, dy: Float 
        , color: Int
        , hasHit: Bool ) -> Null<HitQuad> = fillQuadrilateral;
    /**
       <font color="LightPink" font-weight:"Bold">rotateGradLine</font> module level field
       @param hasHit defaults false, since a HitTri has runtime overhead.
    **/
    public var _tileQuadrilateral:( pixelImage: Pixelimage, ax: Float, ay: Float
        , bx: Float, by: Float
        , cx: Float, cy: Float
        , dx: Float, dy: Float 
        , tileImage: Pixelimage
        , hasHit: Bool ) -> Null<HitQuad> = tileQuadrilateral;
    /**
       <font color="LightPink" font-weight:"Bold">rotateGradLine</font> module level field
       @param hasHit defaults false, since a HitTri has runtime overhead.
    **/
    public var _fillGradQuadrilateral:( pixelImage: Pixelimage
        , ax: Float, ay: Float, colorA: Pixel32
        , bx: Float, by: Float, colorB: Pixel32
        , cx: Float, cy: Float, colorC: Pixel32 
        , dx: Float, dy: Float, colorD: Pixel32
        , hasHit: Bool ) -> Null<HitQuad> = fillGradQuadrilateral;
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
