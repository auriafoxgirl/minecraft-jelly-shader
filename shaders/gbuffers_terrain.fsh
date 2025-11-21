#version 430 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;


#include "/lib/voxel_utils_spaces.glsl"

layout (rgba16f) uniform image3D jellyPosImg;

// in vec3 voxelPos;

void main() {
	color = texture(gtexture, texcoord) * glcolor;
	color *= texture(lightmap, lmcoord);
	if (color.a < alphaTestRef) {
		discard;
	}
	// float dist = getDistToVoxelGridEdge(voxelPos);
	// if (dist > 0.0) {
	// 	ivec3 iPos = ivec3(voxelPos);
	// 	vec4 vertexColor = imageLoad(jellyPosImg, iPos);
	// 	vertexColor = mix(vec4(1.0), vertexColor, min(dist * 0.2, 1.0));
	// 	color *= vertexColor;
	// }
}