#version 430 compatibility

// 32 * 4 = 128
layout (local_size_x = 32) in;
const ivec3 workGroups = ivec3(4, 128, 128);

layout (rgba8) uniform image3D blockMapImg;
layout (rgba8) uniform image3D anyMapImgCopy;

layout (rgba16f) uniform image3D jellyVelImg;

uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;

uniform vec3 currentSelectedBlockPos;

uniform float frameTimeCounter;

#include "/lib/voxel_utils.glsl"

uniform vec3 deltaCameraPos;

int getBlockId(float x) {
   return int(x * 255.0 + 0.1);
}

int getBlockIdAt(ivec3 pos) {
   vec4 blockData = imageLoad(blockMapImg, pos);
   return getBlockId(blockData.x);
}

bool blockExists(ivec3 pos) {
   vec4 blockData = imageLoad(blockMapImg, pos);
   return blockData.w > 0.95;
}

void applyVelocity(ivec3 pos, vec3 vel) {
   vec4 myVel = imageLoad(jellyVelImg, pos);
   myVel.xyz += vel;
   imageStore(jellyVelImg, pos, myVel);
}

void explosion(ivec3 pos, float strength) {
   applyVelocity(pos, vec3(-1.0, -1.0, -1.0) * strength);
   applyVelocity(pos + ivec3(1, 0, 0), vec3(1.0, -1.0, -1.0) * strength);
   applyVelocity(pos + ivec3(0, 1, 0), vec3(-1.0, 1.0, -1.0) * strength);
   applyVelocity(pos + ivec3(1, 1, 0), vec3(1.0, 1.0, -1.0) * strength);
   applyVelocity(pos + ivec3(0, 0, 1), vec3(-1.0, -1.0, 1.0) * strength);
   applyVelocity(pos + ivec3(1, 0, 1), vec3(1.0, -1.0, 1.0) * strength);
   applyVelocity(pos + ivec3(0, 1, 1), vec3(-1.0, 1.0, 1.0) * strength);
   applyVelocity(pos + ivec3(1, 1, 1), vec3(1.0, 1.0, 1.0) * strength);
}

void blockRemoved(int blockId, vec4 blockData, ivec3 pos) {
   // if (blockId == 5) {
   //    explosion(pos, 1.0);
   //    return;
   // }
   explosion(pos, 0.05);
}

void blockPlaced(int blockId, vec4 blockData, ivec3 pos) {
	if (length(vec3(pos) - currentSelectedBlockPos - GRID_SIZE_HALF) > 2.5) {
		return;
	}
   explosion(pos, 0.05);
}

void main() {
   ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
   ivec3 prevPos = pos + ivec3(deltaCameraPos);
   float edgeDist = getDistToVoxelGridEdge(vec3(prevPos));


   vec4 blockData = vec4(0.0);
   if (edgeDist > 2.5) {
      blockData = imageLoad(blockMapImg, prevPos);
   }


   if (blockData.a > 0.05) {
      int blockId = getBlockId(blockData.x);
      if (blockData.a > 0.5) {
         // if (
         //    blockId == 10 &&
         //    getBlockIdAt(prevPos + ivec3(1, 1, 1)) == 10 &&
         //    getBlockIdAt(prevPos + ivec3(1, -1, 1)) != 10
         //    ) {
         //    applyVelocity(prevPos, vec3(0.0, cos(frameTimeCounter * 10.0) * 0.1, 0.0));
         // }
         if (blockData.z < 0.4) {
            blockPlaced(blockId, blockData, prevPos);
         }
      } else {
         blockRemoved(blockId, blockData, prevPos);
      }
   }
   blockData.a -= 0.6; // timeout
   blockData.z += 0.5;
   if (blockData.a < 0.0) {
      blockData = vec4(0.0);
   }


   imageStore(anyMapImgCopy, pos, blockData);
}