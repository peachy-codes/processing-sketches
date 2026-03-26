#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif
uniform sampler2D texture;
uniform sampler2D regionMapTex;
uniform int regionAssignments[100];
uniform int myFaceIndex;
uniform float dimFactor;
uniform bool isMosaicCenter;
varying vec4 vertColor;
varying vec4 vertTexCoord;
void main() {
vec4 texColor = texture2D(texture, vertTexCoord.st);
if (texColor.a < 0.05) discard;
vec4 regionColor = texture2D(regionMapTex, vertTexCoord.st);
int rId = int(floor(regionColor.r * 255.0 + 0.5));
if (rId >= 0 && rId < 100) {
int assignedFace = regionAssignments[rId];
if (assignedFace == myFaceIndex) {
gl_FragColor = texColor;
} else {
if (isMosaicCenter) {
discard;
} else {
float g = (texColor.r + texColor.g + texColor.b) / 3.0;
gl_FragColor = vec4(g * dimFactor, g * dimFactor, g * dimFactor, texColor.a);
}
}
} else {
gl_FragColor = texColor;
}
}
