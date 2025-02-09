// ==================================================================
#version 330 core
// Read in our attributes stored from our vertex buffer object
// We explicitly state which is the vertex information
// (The first 3 floats are positional data, we are putting in our vector)
layout(location=0)in vec3 position; 
layout(location=1)in vec3 normals; // Our second attribute - normals.
layout(location=2)in vec2 texCoord; // Our third attribute - texture coordinates.
layout(location=3)in vec3 tangents; // Our third attribute - texture coordinates.
layout(location=4)in vec3 bitangents; // Our third attribute - texture coordinates.

// If we have texture coordinates we can now use this as well
out vec3 FragPos;
out vec2 v_texCoord;
out vec3 TangentLightPos;
out vec3 TangentViewPos;
out vec3 TangentFragPos;

// If we are applying our camera, then we need to add some uniforms.
// Note that the syntax nicely matches glm's mat4!

uniform mat4 modelTransformMatrix; // Object space
uniform mat4 viewMatrix;           // World space to view (camera) space
uniform mat4 projectionMatrix;
uniform vec3 lightPos; // Our light source position from where light is hitting this object
uniform vec3 viewPos;  // Where our camera is

void main()
{
	// Transform vertex position into world space and store in FragPos
    vec4 FragPosWorld = modelTransformMatrix * vec4(position, 1.0);
    TangentFragPos = FragPosWorld.xyz;

	// Calculate TBN matrix to transform to tangent space
    vec3 T = normalize(mat3(modelTransformMatrix) * tangents);
    vec3 B = normalize(mat3(modelTransformMatrix) * bitangents);
    vec3 N = normalize(mat3(modelTransformMatrix) * normals);
    mat3 TBN = mat3(T, B, N);

	// Transform light and view positions to tangent space
    TangentLightPos = TBN * lightPos;
    TangentViewPos = TBN * viewPos;
    TangentFragPos = TBN * FragPosWorld.xyz;

	// gl_Position = projectionMatrix * modelTransformMatrix * vec4(position, 1.0f);;
	gl_Position = projectionMatrix * viewMatrix * FragPosWorld;
	
  	// Store the texture coordinaets which we will output to
  	// the next stage in the graphics pipeline.
  	v_texCoord = texCoord;
}
// ==================================================================
