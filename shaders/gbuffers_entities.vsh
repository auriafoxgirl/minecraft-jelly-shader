#version 430 compatibility

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;

uniform mat4 gbufferModelView;

#include "/lib/settings.glsl"
#include "/lib/voxel_utils_spaces.glsl"

uniform sampler3D jellyPosTexCopy;

uniform float onGroundSmooth;

uniform int entityId;

layout (rgba8) uniform image3D entityMapImg;

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

	vec3 viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	vec3 eyePlayerPos = mat3(gbufferModelViewInverse) * viewPos;

	vec3 voxelMapPos = eyePlayerPosToVoxelGridPos(eyePlayerPos);
	vec3 voxelPos = voxelMapPos + JELLY_GRID_SHIFT;
	float dist = getDistToVoxelGridEdge(voxelPos);
	if (dist > 0.0) {
		ivec3 iPos = ivec3(voxelPos);
		vec3 offset = texture(jellyPosTexCopy, voxelPos * GRID_SIZE_INV).xyz;
		offset = mix(vec3(0.0), offset, min(dist * 0.2, 1.0));
		eyePlayerPos += offset;
		ivec3 mapIPos = ivec3(voxelMapPos);
		vec4 entityData = vec4(
			float(entityId) / 255.0, // id
			0.0,
			0.0,
			1.0 // keep alive
		);
		imageStore(entityMapImg, mapIPos, entityData);
	}
	#ifdef MOVE_CAMERA
	eyePlayerPos -= texture(jellyPosTexCopy, vec3(0.5)).xyz * onGroundSmooth;
	#endif
	viewPos = mat3(gbufferModelView) * eyePlayerPos;
	gl_Position = gl_ProjectionMatrix * vec4(viewPos, 1.0);
}