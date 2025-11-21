#include "/lib/voxel_utils.glsl"

uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelViewInverse;
uniform vec3 cameraPositionFract;

vec3 eyePlayerPosToVoxelGridPos(vec3 pos) {
   return pos + GRID_SIZE_HALF + cameraPositionFract;
}

vec3 eyePlayerPosToShiftedVoxelGridPos(vec3 pos) {
   return pos + GRID_SIZE_HALF + cameraPositionFract + 0.5001;
}

vec3 vertexPosToVoxelGridPos(vec4 pos) {
   vec3 viewPos = (gl_ModelViewMatrix * pos).xyz;
	vec3 eyePlayerPos = mat3(gbufferModelViewInverse) * viewPos;
   return eyePlayerPosToVoxelGridPos(eyePlayerPos);
}

vec3 vertexShadowPosToVoxelGridPos(vec4 pos) {
   vec3 shadowViewPos = (gl_ModelViewMatrix * pos).xyz;
	vec3 feetPlayerPos = (shadowModelViewInverse * vec4(shadowViewPos, 1.0)).xyz;
   return eyePlayerPosToVoxelGridPos(feetPlayerPos - gbufferModelViewInverse[3].xyz);
}