package pi_xy.triangleGML;

import pi_xy.Pixelimage;
import triangleGML.shape.gradient.LineGradient_;
import pi_xy.algo.TriPixelSmoothGrad;

class LineGradient extends LineGradient_<Pixelimage,Pixelimage>{
    public var luxury: Bool;
    public override function setParameter( name: String, value: String ){
        switch( name ){
            case 'luxury':
                luxury = ( StringTools.trim( value ).toLowerCase() == 'true' )? true: false; 
                trace('setting luxury '+ value );
            case _:
                super.setParameter( name, value );
        }
    }
    public function render( pixelImage: Pixelimage ): Pixelimage {
        var px = x1 + offX;
        var qx = x2 + offX;
        var py = y1 + offY;
        var qy = y2 + offY;
        if( luxury ){
            lineXYGradPentBary( pixelImage, px, py, qx, qy, strokeWidth
                            , cornerColors[0], cornerColors[1], cornerColors[2], cornerColors[3] );
        } else {
            pixelImage.gradientShape.line( px, py, qx, qy, strokeWidth
                , cornerColors[0], cornerColors[1], cornerColors[2], cornerColors[3] );
        }
        return pixelImage;
    }
}