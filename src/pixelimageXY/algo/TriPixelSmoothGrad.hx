package pixelimageXY.algo;
import pixelimageXY.iter.BoundIterator;
import pixelimageXY.iter.IteratorRange;
import pixelimageXY.algo.GeomPix;
import pixelimageXY.pixel.Pixel32;
import pixelimageXY.pixel.PixelChannel;
import pixelimageXY.algo.HitTri;
import pixelimageXY.algo.PentagonSampler;
import pixelimageXY.algo.HitTriScalar;
import pixelimageXY.algo.Barycentric;

inline
function quadGradPentBary( pixelImage: Pixelimage
                        , ax: Float, ay: Float
                        , bx: Float, by: Float
                        , cx: Float, cy: Float
                        , dx: Float, dy: Float 
                        , color: Int
                        , hasHit: Bool = false ): Null<HitQuad>{
    // tri e - a b d
    // tri f - b c d
    var alpha = 0xFF000000 ;
    var colors = 0xFFFFFF;
    var col = alpha + Std.random( colors );
    var colorA: Pixel32 = col;
    var colorB: Pixel32 = col;
    var colorC: Pixel32 = col;
    var colorD: Pixel32 = col;

    triGradPentBaryBottom( pixelImage, ax, ay, colorA, bx, by, colorB, dx, dy, colorD, false );                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
    triGradPentBaryTop(    pixelImage, bx, by, colorB, cx, cy, colorC, dx, dy, colorD, false );
    // don't bother with hit as fillQuadrilateral in test will return.
    return null;
}
inline
function triGradPentBaryBottom( pixelImage: Pixelimage
                                    , ax: Float, ay: Float, colorA: Pixel32
                                    , bx: Float, by: Float, colorB: Pixel32
                                    , cx: Float, cy: Float, colorC: Pixel32
                                    , hasHit: Bool = false, hasUndo: Bool = true ): Null<HitTri>{
    // tri e - a b d
    // don't smooth diagonal
    var softAB = true;
    var softBC = false;
    var softCA = true;
    var adjustWinding = ( (ax * by - bx * ay) + (bx * cy - cx * by) + (cx * ay - ax * cy) )>0;
    if( !adjustWinding ){
        var bx_ = bx;
        var by_ = by;
        bx = cx;
        by = cy;
        cx = bx_;
        cy = by_;
        var softAB = true;
        var softBC = true;
        var softCA = false;
    }
    return triGradPentBary( pixelImage, ax, ay, colorA, bx, by, colorB, cx, cy, colorC, softAB, softBC, softCA, hasHit, hasUndo );
} 
inline
function triGradPentBaryTop( pixelImage: Pixelimage
                                    , ax: Float, ay: Float, colorA: Pixel32
                                    , bx: Float, by: Float, colorB: Pixel32
                                    , cx: Float, cy: Float, colorC: Pixel32
                                    , hasHit: Bool = false, hasUndo: Bool = true ): Null<HitTri>{
    // tri f - b c d   
    // don't smooth diagonal
    var softAB = true;
    var softBC = true;
    var softCA = false;
    var adjustWinding = ( (ax * by - bx * ay) + (bx * cy - cx * by) + (cx * ay - ax * cy) )>0;
    if( !adjustWinding ){
        var bx_ = bx;
        var by_ = by;
        bx = cx;
        by = cy;
        cx = bx_;
        cy = by_;
        var softAB = true;
        var softBC = false;
        var softCA = true;
    }
    return triGradPentBary( pixelImage, ax, ay, colorA, bx, by, colorB, cx, cy, colorC, softAB, softBC, softCA, hasHit, hasUndo );
} 
inline
function triGradPentBary( pixelImage: Pixelimage
                    , ax: Float, ay: Float, colA: Pixel32
                    , bx: Float, by: Float, colB: Pixel32
                    , cx: Float, cy: Float, colC: Pixel32
                    , softAB = true
                    , softBC = true
                    , softCA = true
                    , hasHit: Bool = false, hasUndo: Bool = true ): Null<HitTri>{
    // decompose channels
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
    
    var a = 0;
    var r = 0;
    var g = 0;
    var b = 0;  

    var hitTriScalar = ( { ax: ax, ay: ay, bx: bx, by: by, cx: cx, cy: cy }: HitTriScalar );
    //var hitTriScalar = hitTriScalar.scaled( 1.1, 1.1, 1.1 );
    var barycentric  = hitTriScalar.barycentric;
    var scaleA = ( softAB || softCA )? 1.5: 1.;
    var scaleB = ( softAB || softBC )? 1.5: 1.;
    var scaleC = ( softBC || softCA )? 1.5: 1.;
    // scale down slightly
    var scaled = hitTriScalar.scaled( 0.999, 0.999, 0.999 );
    scaled = scaled.scaled( scaleA, scaleB, scaleC );
    for( px in hitTriScalar.xIter3 ){
        // pcx, sxx and txx not optimised yet.
        for( py in hitTriScalar.yIter3 ){
            var ratios: BaryCoordinates = barycentric.getRatios( px, py );
            var isSoft: Bool = ratios.isSoft( softAB, softBC, softCA );
            var sampleData = hitTriScalar.pentagonSample( px, py );
            var aScale = sampleData.fractionTotal;
            aScale = ( aScale > 0.9 )? aScale: aScale*0.8 + 0.2;
            a = 0;
            r = 0;
            g = 0;
            b = 0;
            if( isSoft ){    
                if( !sampleData.notHit  ){
                    var ratiosAvg = barycentric.getRatios( sampleData.averageX, sampleData.averageY );
                    var ratioA_ = ratiosAvg.ratioA;
                    var ratioB_ = ratiosAvg.ratioB;
                    var ratioC_ = ratiosAvg.ratioC;
                    a = PixelChannel.boundChannel( ( aA*ratioA_ + aB*ratioB_ + aC*ratioC_ ) );
                    r = PixelChannel.boundChannel( ( rA*ratioA_ + rB*ratioB_ + rC*ratioC_ ) );
                    g = PixelChannel.boundChannel( ( gA*ratioA_ + gB*ratioB_ + gC*ratioC_ ) );
                    b = PixelChannel.boundChannel( ( bA*ratioA_ + bB*ratioB_ + bC*ratioC_ ) );
                    pixelImage.set_argbPixel( 
                            ( aScale > 0.9 )? a: PixelChannel.boundChannel( a*aScale )
                            , r, g, b, pixelImage.position( px, py ) ); 
                }
            } else { 
                
                var ratioA = ratios.ratioA;
                var ratioB = ratios.ratioB;
                var ratioC = ratios.ratioC;
                /*
                a = PixelChannel.boundChannel( aA*ratioA + aB*ratioB + aC*ratioC );
                r = PixelChannel.boundChannel( rA*ratioA + rB*ratioB + rC*ratioC );
                g = PixelChannel.boundChannel( gA*ratioA + gB*ratioB + gC*ratioC );
                b = PixelChannel.boundChannel( bA*ratioA + bB*ratioB + bC*ratioC );
                */

                
                var hitTotal = sampleData.fractionTotal;
                if( sampleData.notHit ){
                    // no draw if there is no hit atall.
                } else {
                    var sampleScaled = scaled.pentagonSample( px, py );
                    var scaledTotal = sampleScaled.fractionTotal;
                    
                    if( scaledTotal > hitTotal || hitTotal == 1. ){
                        // assume hard side, as scaledTotal has more hits or total hit anyway.
                        // pentagon sample soft side
                        var ratiosAvg = barycentric.getRatios( sampleData.averageX, sampleData.averageY );
                        var ratioA_ = ratiosAvg.ratioA;
                        var ratioB_ = ratiosAvg.ratioB;
                        var ratioC_ = ratiosAvg.ratioC;
                        a = PixelChannel.boundChannel( ( aA*ratioA_ + aB*ratioB_ + aC*ratioC_ ) );
                        r = PixelChannel.boundChannel( ( rA*ratioA_ + rB*ratioB_ + rC*ratioC_ ) );
                        g = PixelChannel.boundChannel( ( gA*ratioA_ + gB*ratioB_ + gC*ratioC_ ) );
                        b = PixelChannel.boundChannel( ( bA*ratioA_ + bB*ratioB_ + bC*ratioC_ ) );
                        pixelImage.set_argbPixel( a, r, g, b, pixelImage.position( px, py ) ); 
                    } else {
                        // pentagon sample soft side
                        var ratiosAvg = barycentric.getRatios( sampleData.averageX, sampleData.averageY );
                        var ratioA_ = ratiosAvg.ratioA;
                        var ratioB_ = ratiosAvg.ratioB;
                        var ratioC_ = ratiosAvg.ratioC;
                        a = PixelChannel.boundChannel( ( aA*ratioA_ + aB*ratioB_ + aC*ratioC_ ) );
                        r = PixelChannel.boundChannel( ( rA*ratioA_ + rB*ratioB_ + rC*ratioC_ ) );
                        g = PixelChannel.boundChannel( ( gA*ratioA_ + gB*ratioB_ + gC*ratioC_ ) );
                        b = PixelChannel.boundChannel( ( bA*ratioA_ + bB*ratioB_ + bC*ratioC_ ) );
                        pixelImage.set_argbPixel( 
                            ( aScale > 0.9 )? a: PixelChannel.boundChannel( a*aScale )
                            , r, g, b, pixelImage.position( px, py ) ); 
                    }
                }
                
                
                /*
                if( ratioA >= 0 && ratioB >= 0 && ratioC >= 0 ){
                    pixelImage.set_argbPixel( a, r, g, b, pixelImage.position( px, py ) );
                }
                */
            }
        }
    }
    return if( hasHit == false ){
        var v: HitTri = ( { ax: ax, ay: ay, bx: bx, by: by, cx: cx, cy: cy } : HitTri );
        /*if( hasUndo ){
            v.undoImage = undoImage;
            v.undoX = xIter3.start;
            v.undoY = yIter3.start;
        }*/
        v;
    } else {
        null;
    }   
}