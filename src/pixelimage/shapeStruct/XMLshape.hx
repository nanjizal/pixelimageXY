package pixelimage.shapeStruct;
//import haxe.xml.Access;
import pixelimage.Pixelimage;

class XMLshape {
    var pixelImage: Pixelimage;
    var xml: Xml;
    public function new( pixelImage: Pixelimage, xml: Xml ){
        this.pixelImage = pixelImage;
        this.xml = xml;
        process();
    }
    public static inline function withString( pixelImage: Pixelimage, str: String ): XMLshape {
        trace(str);
        var xml = Xml.parse( '<node>'+str+'</node>' ).firstElement();
        trace( xml );
        return new XMLshape( pixelImage, xml );
    }
    function process(){
        //trace( xml );
        for( e in xml.elements() ) processShape( e );
    }
    function processShape( x: Xml ){
        var s: ShapeInterface = 
        switch( x.nodeName ){
            case 'ChordArcShape':
                new ChordArcShape();
            case 'CircleShape':
                new CircleShape();
            case 'CubicCurveShape':
                new CubicCurveShape();
            case 'EllipseArcShape':
                new EllipseArcShape();
            case 'EllipseShape':
                new EllipseShape(); 
            case 'LineGradient':
                new LineGradient();
            case 'LineShape':
                new LineShape();
            case 'PathElementShape':
                new PathElementShape();
            case 'PieArcShape':
                new PieArcShape();
            case 'PolyLineGradient':
                new PolyLineGradient();
            case 'PolyLineShape':
                new PolyLineShape();
            case 'QuadCurveShape':
                new QuadCurveShape();
            case 'QuadShape':
                new QuadShape();
            case 'RectangleShape':
                new RectangleShape();
            case 'SquareShape':
                new SquareShape();
            case 'TriangleGradient':
                trace('triangle gradient');
                new TriangleGradient();
            case 'TriangleShape':
                new TriangleShape();
            case 'ComponentShape':
                // this is like a default shape drawn on, if/when nesting gets setup
                new ComponentShape();
            case _:
                throw( 'shape unfound' );
        }
        for( att in x.attributes() ){
            trace( att + ' ' + x.get(att) );
            s.setParameter( att, x.get( att ) );
        }
        s.render( pixelImage );
    }
}