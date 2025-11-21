const int GRID_SIZE = 128;

const float JELLY_GRID_SHIFT = 0.5001;

const float GRID_SIZE_FLOAT = float(GRID_SIZE);
const float GRID_SIZE_INV = 1.0 / GRID_SIZE_FLOAT;
const float GRID_SIZE_HALF = GRID_SIZE * 0.5;
const ivec3 GRID_MIDDLE = ivec3(GRID_SIZE / 2);

float getDistToVoxelGridEdge(vec3 pos) {
   vec3 p = abs(pos - GRID_SIZE_HALF);
   float dist = max(max(p.x, p.y), p.z);
   return GRID_SIZE_HALF - dist;
}