#version 430 compatibility

// 32 * 4 = 128
layout (local_size_x = 32) in;
const ivec3 workGroups = ivec3(4, 128, 128);

layout (rgba16f) uniform image3D jellyPosImg;
layout (rgba16f) uniform image3D jellyVelImg;

layout (rgba16f) uniform image3D jellyPosImgCopy;
layout (rgba16f) uniform image3D jellyVelImgCopy;

uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;

#include "/lib/voxel_utils.glsl"

uniform vec3 deltaCameraPos;

const ivec3 DIRS[6] = {
   ivec3(1, 0, 0),
   ivec3(-1, 0, 0),
   ivec3(0, 1, 0),
   ivec3(0, -1, 0),
   ivec3(0, 0, 1),
   ivec3(0, 0, -1)
};

void main() {
   ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
   ivec3 prevPos = pos + ivec3(deltaCameraPos);
   // ivec3 prevPos = pos + ivec3(floor(cameraPosition) - floor(previousCameraPosition));
   float edgeDist = getDistToVoxelGridEdge(vec3(prevPos));

   vec3 jellyPos;
   vec3 jellyVel;
   if (edgeDist > 2.5) {
      jellyPos = imageLoad(jellyPosImg, prevPos).xyz;
      jellyVel = imageLoad(jellyVelImg, prevPos).xyz;
   } else { // default
      jellyPos = vec3(0.0);
      jellyVel = vec3(0.0);
   }

   vec3 targetPos = jellyPos;
   vec3 wobbleDirStrength = vec3(0.0);
   for (int i = 0; i < DIRS.length; i++) {
      ivec3 dir = DIRS[i];
      vec3 pos = imageLoad(jellyPosImg, prevPos + dir).xyz;
      wobbleDirStrength += length(pos) * vec3(dir);
      targetPos += pos;
   }
   targetPos *= 0.135; // needs to be below 1/7
   float targetPosLength = length(targetPos);
   if (targetPosLength > 0.001) {
      if (dot(wobbleDirStrength, wobbleDirStrength) > 0.001) {
         vec3 newWobble = targetPos - wobbleDirStrength * 0.1;
         float len = length(newWobble);
         if (len > 0.0001) {
            targetPos = newWobble / len * targetPosLength;
         }
      }
   }
   // targetPos = normalize(targetPos + wobbleDirStrength * 0.1) * length(targetPos);

   // jellyPos = mix(jellyPos, vec3(0.0), 0.05);

   jellyVel = jellyVel * 0.98 + (targetPos - jellyPos) * 0.1;
   jellyPos = jellyPos + jellyVel;

   imageStore(jellyPosImgCopy, pos, vec4(jellyPos, 0.0));
   imageStore(jellyVelImgCopy, pos, vec4(jellyVel, 0.0));
}