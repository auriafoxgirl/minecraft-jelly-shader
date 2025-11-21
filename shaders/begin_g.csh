#version 430 compatibility

// this shader is just for writing player to entity map while in first person

#include "/lib/voxel_utils.glsl"

layout (local_size_x = 1) in;
const ivec3 workGroups = ivec3(1, 2, 1);

layout (rgba8) uniform image3D entityMapImg;

uniform vec3 relativeEyePosition;

const vec4 entityData = vec4(
   2.0 / 255.0,
   0.0,
   0.0,
   1.0
);

void main() {
   ivec3 pos = -ivec3(gl_GlobalInvocationID.xyz);

   pos += GRID_MIDDLE;

   pos -= ivec3(relativeEyePosition);

   imageStore(entityMapImg, pos, entityData);
}