#version 430 compatibility

// 32 * 4 = 128
layout (local_size_x = 32) in;
const ivec3 workGroups = ivec3(4, 128, 128);

layout (rgba16f) uniform image3D jellyPosImg;
layout (rgba16f) uniform image3D jellyVelImg;

layout (rgba16f) uniform image3D jellyPosImgCopy;
layout (rgba16f) uniform image3D jellyVelImgCopy;


void main() {
   ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);

   imageStore(jellyPosImg, pos, imageLoad(jellyPosImgCopy, pos));
   imageStore(jellyVelImg, pos, imageLoad(jellyVelImgCopy, pos));
}