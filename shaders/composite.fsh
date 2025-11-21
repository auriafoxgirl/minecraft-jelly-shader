#version 330 compatibility

uniform sampler2D colortex0;
// uniform sampler2D shadowtex0;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(colortex0, texcoord);

	// if (texcoord.x > 2.0) { // force shadow pass
		// color = texture(shadowtex0, texcoord);
	// }
}