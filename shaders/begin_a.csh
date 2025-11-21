#version 430 compatibility

// 32 * 4 = 128
layout (local_size_x = 32) in;
const ivec3 workGroups = ivec3(4, 128, 128);

layout (rgba8) uniform image3D entityMapImg;
layout (rgba8) uniform image3D anyMapImgCopy;

layout (rgba16f) uniform image3D jellyVelImg;

uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;

#include "/lib/voxel_utils.glsl"

uniform vec3 deltaCameraPos;

int getEntityId(float x) {
   return int(x * 255.0 + 0.1);
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

void entityMoved(int entityId, vec4 entityData, ivec3 pos, ivec3 dir) {
   if (abs(dir.y) == 1) {
      applyVelocity(pos, vec3(dir) * 0.1);
   } else {
      applyVelocity(pos, vec3(dir) * -0.05);
   }
}

bool checkIfEntityMoved(int entityId, vec4 entityData, ivec3 pos, ivec3 dir) {
   vec4 entityData2 = imageLoad(entityMapImg, pos + dir);
   int entityId2 = getEntityId(entityData2.x);
   if (entityId2 != entityId) {
      return false;
   }
   if (entityData2.w < 0.9) {
      return false;
   }
   entityMoved(entityId, entityData, pos, dir);
   return true;
}

void entityRemoved(int entityId, vec4 entityData, ivec3 pos) {
   if (
      checkIfEntityMoved(entityId, entityData, pos, ivec3(1, 0, 0)) ||
      checkIfEntityMoved(entityId, entityData, pos, ivec3(-1, 0, 0)) ||
      checkIfEntityMoved(entityId, entityData, pos, ivec3(0, 1, 0)) ||
      checkIfEntityMoved(entityId, entityData, pos, ivec3(0, -1, 0)) ||
      checkIfEntityMoved(entityId, entityData, pos, ivec3(0, 0, 1)) ||
      checkIfEntityMoved(entityId, entityData, pos, ivec3(0, 0, -1))
   ) {
      return;
   }
   if (entityId == 49) {
      explosion(pos, 0.025);
      return;
   }
   if (entityId == 50) {
      explosion(pos, 0.16);
      return;
   }
   if (entityId == 51) {
      explosion(pos, -0.5);
      return;
   }
   if (entityId == 60) {
      return;
   }
   explosion(pos, 0.1);
}

void main() {
   ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
   ivec3 prevPos = pos + ivec3(deltaCameraPos);
   float edgeDist = getDistToVoxelGridEdge(vec3(prevPos));


   vec4 entityData = vec4(0.0);
   if (edgeDist > 2.5) {
      entityData = imageLoad(entityMapImg, prevPos);
   }


   if (entityData.a > 0.05) {
      int entityId = getEntityId(entityData.x);
      if (entityData.a > 0.5) {
         if (entityId == 60) {
            applyVelocity(pos, vec3(0.0, -1.0, 0.0));
         }
      } else {
         entityRemoved(entityId, entityData, prevPos);
      }
   }
   entityData.a -= 0.6; // timeout
   if (entityData.a < 0.0) {
      entityData = vec4(0.0);
   }


   imageStore(anyMapImgCopy, pos, entityData);
}