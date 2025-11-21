#version 430 compatibility

layout (local_size_x = 32) in;
const ivec3 workGroups = ivec3(4, 128, 128);

layout (rgba8) uniform image3D entityMapImg;
layout (rgba8) uniform image3D anyMapImgCopy;

void main() {
   ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
   imageStore(entityMapImg, pos, imageLoad(anyMapImgCopy, pos));
}