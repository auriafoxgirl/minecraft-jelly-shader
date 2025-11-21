#version 430 compatibility

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;

uniform mat4 gbufferModelView;
in vec4 at_midBlock;

#include "/lib/settings.glsl"
#include "/lib/voxel_utils_spaces.glsl"

uniform sampler3D jellyPosTexCopy;

uniform float onGroundSmooth;

in vec2 mc_Entity; // contains block id as x defined in block.properties

layout (rgba8) uniform image3D blockMapImg;

uniform vec3 currentSelectedBlockPos;

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	// voxelPos = vertexPosToVoxelGridPos(gl_Vertex);

	vec3 viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	vec3 eyePlayerPos = mat3(gbufferModelViewInverse) * viewPos;

	vec3 voxelMapPos = eyePlayerPosToVoxelGridPos(eyePlayerPos);
	vec3 voxelPos = voxelMapPos + JELLY_GRID_SHIFT;
	float dist = getDistToVoxelGridEdge(voxelPos);
	if (dist > 0.0) {
		ivec3 iPos = ivec3(voxelPos);
		// vec3 offset = imageLoad(jellyPosImg, iPos).xyz;
		vec3 offset = texture(jellyPosTexCopy, voxelPos * GRID_SIZE_INV).xyz;
		offset = mix(vec3(0.0), offset, min(dist * 0.2, 1.0));
		// offset = (sqrt(abs(offset) + 1.0) -1.0) * sign(offset);
		// offset = (sqrt(abs(offset) + 1.0) -1.0) * sign(offset);
		// offset = (sqrt(abs(offset) + 1.0) -1.0) * sign(offset);
		eyePlayerPos += offset;

		// voxelize
		voxelMapPos += at_midBlock.xyz / 64.0;
		float blockId = mc_Entity.y > 0.9 ? 10.0 : mc_Entity.x;
		ivec3 mapIPos = ivec3(voxelMapPos);
		vec4 prevBlockData = imageLoad(blockMapImg, mapIPos);
		vec4 blockData = vec4(
			(blockId + 0.1) / 255.0,
			0.0,
			prevBlockData.z,
			1.0
		);
		imageStore(blockMapImg, ivec3(mapIPos), blockData);
	}

	viewPos = mat3(gbufferModelView) * eyePlayerPos;
	gl_Position = gl_ProjectionMatrix * vec4(viewPos, 1.0);
}