package pixelimageXY.textureImage;

function testMonster(): String {
    return 'data:image/png;base64,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';
}