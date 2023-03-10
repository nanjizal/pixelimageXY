package pixelimageXY.algo;

import pixelimageXY.Pixelimage;
import pixelimageXY.Pixelshape;
import pixelimageXY.pixel.Pixel32;

    /**
        x, y      - position
        hi, wid   - the outside dimensions
        dx, dy    - define the 9-slice distance in from x, y, dy can default to dx
        fat, tall - the inner dimensions of the 9-slice centre, optional
    **/
    inline
    function fillRoundRectangle( pixelshape: Pixelshape
                          , x:     Float,        y:     Float
                          , wid:    Float,       hi:   Float
                          , color: Int
                          , ?dx:   Float = -1.,  ?dy: Float = -1.
                          , ?fat:  Float = -1.,  ?tall:  Float = -1. 
                          ){ // phi not implemented
        // if no dx set
        // use smallest dimension and assume three parts
        // with the middle section the goldenRatio larger!
        if( dx < 0. ){
            var smallest = ( hi < wid )? hi: wid;
            var goldenRatio = 1.61803398875;
            dx = smallest / ( goldenRatio + 2 );
        }
        if( dy < 0. )   dy = dx;
        if( fat < 0. )  fat = wid - 2*dx;
        if( tall < 0. ) tall = hi - 2*dy;
        var rightRadius  = wid - fat - dx;
        var bottomRadius = hi - tall - dy;
        var farX = x + dx + fat;
        var lowerY = y + dy + tall;
        // top row
        pixelshape.fillQuadrantII( x + dx, y + dy, dx, dy, color );
        pixelshape.simpleRect(  x + dx, y, fat, dy, color );
        pixelshape.fillQuadrantI(  farX, y + dy, rightRadius, dy, color );
        // middle row  ( will need more splitting with gradient )
        pixelshape.simpleRect(  x, y + dy, wid, tall, color );
        // bottom row
        pixelshape.fillQuadrantIII( x + dx, lowerY, dx, bottomRadius, color );
        pixelshape.simpleRect(   x + dx, lowerY, fat, bottomRadius, color );
        pixelshape.fillQuadrantIV(  farX,   lowerY, rightRadius, bottomRadius, color );
    }
    /**
        x, y      - position
        hi, wid   - the outside dimensions
        dx, dy    - define the 9-slice distance in from x, y, dy can default to dx
        fat, tall - the inner dimensions of the 9-slice centre, optional
    **/
    inline
    function tileRoundRectangle( pixelshape: Pixelshape
                          , x:     Float,        y:     Float
                          , wid:    Float,       hi:   Float
                          , tileImage: Pixelimage
                          , ?dx:   Float = -1.,  ?dy: Float = -1.
                          , ?fat:  Float = -1.,  ?tall:  Float = -1. 
                          ){ // phi not implemented
        // if no dx set
        // use smallest dimension and assume three parts
        // with the middle section the goldenRatio larger!
        if( dx < 0. ){
            var smallest = ( hi < wid )? hi: wid;
            var goldenRatio = 1.61803398875;
            dx = smallest / ( goldenRatio + 2 );
        }
        if( dy < 0. )   dy = dx;
        if( fat < 0. )  fat = wid - 2*dx;
        if( tall < 0. ) tall = hi - 2*dy;
        var rightRadius  = wid - fat - dx;
        var bottomRadius = hi - tall - dy;
        var farX = x + dx + fat;
        var lowerY = y + dy + tall;
        // top row
        pixelshape.tileQuadrantII( x + dx, y + dy, dx, dy, tileImage );
        pixelshape.tileRect(  x + dx, y, fat, dy, tileImage );
        pixelshape.tileQuadrantI(  farX, y + dy, rightRadius, dy, tileImage );
        // middle row  ( will need more splitting with gradient )
        pixelshape.tileRect(  x, y + dy, wid, tall, tileImage );
        // bottom row
        pixelshape.tileQuadrantIII( x + dx, lowerY, dx, bottomRadius, tileImage );
        pixelshape.tileRect(   x + dx, lowerY, fat, bottomRadius, tileImage );
        pixelshape.tileQuadrantIV(  farX,   lowerY, rightRadius, bottomRadius, tileImage );
    }
        /**
        x, y      - position
        hi, wid   - the outside dimensions
        dx, dy    - define the 9-slice distance in from x, y, dy can default to dx
        fat, tall - the inner dimensions of the 9-slice centre, optional
    **/
    inline
    function fillGrad4RoundRectangle( pixelshape: Pixelshape
                               , x:     Float,        y:     Float
                               , hi:    Float,        wid:   Float
                               , colorA: Pixel32, colorB: Pixel32, colorC: Pixel32, colorD: Pixel32
                               , ?dx:   Float = -1.,  ?dy: Float = -1.
                               , ?fat:  Float = -1.,  ?tall:  Float = -1. 
                               ){ // phi not implemented
        // if no dx set
        // use smallest dimension and assume three parts
        // with the middle section the goldenRatio larger!
        if( dx < 0. ){
            var smallest = ( hi < wid )? hi: wid;
            var goldenRatio = 1.61803398875;
            dx = smallest / ( goldenRatio + 2 );
        }
        if( dy < 0. )   dy = dx;
        if( fat < 0. )  fat = wid - 2*dx;
        if( tall < 0. ) tall = hi - 2*dy;
        var rightRadius  = wid - fat - dx;
        var bottomRadius = hi - tall - dy;
        var farX = x + dx + fat;
        var lowerY = y + dy + tall;
        // top row
        pixelshape.fillQuadrantII( x + dx, y + dy, dx, dy, colorA );
        pixelshape.fillGradRect(  x + dx, y, fat, dy, colorA, colorB, colorB, colorA );
        pixelshape.fillQuadrantI(  farX, y + dy, rightRadius, dy, colorB );
        // middle row  ( will need more splitting with gradient )
        pixelshape.fillGradRect(  x, y + dy, dx, tall, colorA, colorA, colorD, colorD );
        pixelshape.fillGradRect(  x + dx, y + dy, fat, tall, colorA, colorB, colorC, colorD );
        pixelshape.fillGradRect(  farX, y + dy, rightRadius, tall, colorB, colorB, colorC, colorC );
        // bottom row
        pixelshape.fillQuadrantIII( x + dx, lowerY, dx, bottomRadius, colorD );
        pixelshape.fillGradRect(   x + dx, lowerY, fat, bottomRadius, colorD, colorC, colorC, colorD );
        pixelshape.fillQuadrantIV(  farX,   lowerY, rightRadius, bottomRadius, colorC );
    }

class RoundRecPixel {
    /**
       <font color="LightPink" font-weight:"Bold">fillRoundRectangle</font> module level field
    **/
    public var _fillRoundRectangle:( pixelshape: Pixelshape
        , x:     Float,        y:     Float
        , wid:    Float,       hi:   Float
        , color: Int
        , ?dx:   Float,  ?dy: Float
        , ?fat:  Float,  ?tall:  Float 
        ) -> Void = fillRoundRectangle;

    /**
       <font color="LightPink" font-weight:"Bold">tileRoundRectangle</font> module level field
    **/
    public var _tileRoundRectangle:( pixelshape: Pixelshape
        , x:     Float,        y:     Float
        , wid:    Float,       hi:   Float
        , tileImage: Pixelimage
        , ?dx:   Float,  ?dy: Float
        , ?fat:  Float,  ?tall:  Float 
        ) -> Void = tileRoundRectangle;

    /**
       <font color="LightPink" font-weight:"Bold">fillGrad4RoundRectangle</font> module level field
    **/
    public var _fillGrad4RoundRectangle:( pixelshape: Pixelshape
        , x:     Float,        y:     Float
        , hi:    Float,        wid:   Float
        , colorA: Pixel32, colorB: Pixel32, colorC: Pixel32, colorD: Pixel32
        , ?dx:   Float,  ?dy: Float
        , ?fat:  Float,  ?tall:  Float 
        ) -> Void = fillGrad4RoundRectangle;
}