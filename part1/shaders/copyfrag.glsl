// ==================================================================
#version 330 core

// The final output color of each 'fragment' from our fragment shader.
out vec4 FragColor;

// Take in our previous texture coordinates.
in vec3 FragPos;
in vec2 v_texCoord;
in vec3 TangentLightPos;
in vec3 TangentViewPos;
in vec3 TangentFragPos;


// If we have texture coordinates, they are stored in this sampler.
uniform sampler2D u_DiffuseMap; 
uniform sampler2D u_NormalMap; 
uniform sampler2D u_DepthMap; 

// Control toggles
uniform bool u_UseNormalMap; // toggle normal mapping
uniform bool u_UseParallaxMapping; // toggle parallax mapping

// Depth scaling factor
uniform float u_DepthScale;

// Function for parallax mapping
vec2 ParallaxMapping(vec2 texCoords, vec3 viewDir)
{ 
    float height = texture(u_DepthMap, texCoords).r;    
    vec2 offset = viewDir.xy / viewDir.z * (height * u_DepthScale);
    return texCoords - offset;    
}

void main()
{
    // Declare normal outside the conditional scope
    vec3 normal;

    vec3 viewDir = normalize(TangentViewPos - TangentFragPos);

    vec2 texCoord = v_texCoord;
    // Apply parallax mapping if enabled
    if (u_UseParallaxMapping) {
        texCoord = ParallaxMapping(texCoord, viewDir);
        // Ensure texture coordinates are clamped within valid range
        texCoord = clamp(texCoord, 0.0, 1.0);
    }

    if(u_UseNormalMap)
    {
        // Store the texture coordinates
        normal = texture(u_NormalMap, v_texCoord).rgb;
        normal = normalize(normal * 2.0 - 1.0); // Transform from [0, 1] to [-1, 1]
    } else {
        // Use the interpolated normals
        normal = vec3(0.0, 0.0, 1.0); // Default normal pointing up
    }

	// Sample the diffuse color
	vec3 color =  texture(u_DiffuseMap, v_texCoord).rgb;

	//if(v_texCoord.y > 0.5){
	//    FragColor = vec4(normal,1.0);
	//}else{
	//    FragColor = vec4(color,1.0);
	//}
	
	// Calculate the light direction and view direction in tangent space
    vec3 lightDir = normalize(TangentLightPos - TangentFragPos);

    // Diffuse lighting
    float diff = max(dot(normal, lightDir), 0.0);
    vec3 diffuse = diff * color;

    // Specular lighting (simple approximation)
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32.0); // assuming a shininess value of 32
    vec3 specular = spec * vec3(1.0); // white specular light

    // Combine results
    vec3 result = diffuse + specular;
    FragColor = vec4(result, 1.0);

}
// ==================================================================
