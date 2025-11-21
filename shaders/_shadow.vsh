#version 430 compatibility

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;

in vec2 mc_Entity; // contains block id as x defined in block.properties

#include "/lib/voxel_utils_spaces.glsl"

layout (rgba16f) uniform image3D jellyVelImg;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

	vec3 pos = vertexShadowPosToVoxelGridPos(gl_Vertex);
	float dist = getDistToVoxelGridEdge(pos);
	if (dist > 0.0) {
		ivec3 iPos = ivec3(pos);
		int blockId = int(mc_Entity.x + 0.25);
		if (blockId == 5) {
			vec4 prev = imageLoad(jellyVelImg, iPos);
			prev = mix(prev, vec4(0.0, 0.1, 0.0, 1.0), 1.0);
			imageStore(jellyVelImg, iPos, prev);
		} else {
			// imageStore(jellyPosImg, iPos, vec4(1.0, 1.0, 1.0, 1.0));
		}
	}
}