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
uniform bool u_UseSelfShadowing; // toggle shadow

// Depth scaling factor
uniform float u_DepthScale;

// Function for parallax mapping
vec2 ParallaxOcclusionMapping(vec2 texCoords, vec3 viewDir)
{ 
    //Dynamically determine the number of layers based on view angle
    const float minLayers = 8.0;
    const float maxLayers = 32.0;
    float numLayers = mix(maxLayers, minLayers, abs(dot(vec3(0.0, 0.0, 1.0), viewDir)));

    // Step size and initialization
    float layerDepth = 1.0 / numLayers;
    vec2 deltaTexCoords = viewDir.xy * u_DepthScale / numLayers;

    // Initialize variables
    vec2 currentTexCoords = texCoords;
    float currentLayerDepth = 0.0;
    float currentDepthMapValue = texture(u_DepthMap, currentTexCoords).r;

    // Steep parallax iteration loop
    while (currentLayerDepth < currentDepthMapValue)
    {
        currentTexCoords -= deltaTexCoords;          // Move to the next layer
        currentDepthMapValue = texture(u_DepthMap, currentTexCoords).r; // Fetch new depth
        currentLayerDepth += layerDepth;             // Increment depth
    }

    // Linear interpolation between the last two steps
    vec2 prevTexCoords = currentTexCoords + deltaTexCoords;
    float afterDepth = currentDepthMapValue - currentLayerDepth;
    float beforeDepth = texture(u_DepthMap, prevTexCoords).r - currentLayerDepth + layerDepth;

    float weight = afterDepth / (afterDepth - beforeDepth);
    vec2 finalTexCoords = prevTexCoords * weight + currentTexCoords * (1.0 - weight);

    return finalTexCoords;

}

float ShadowCalc(vec2 texCoord, vec3 lightDir)
{
    float minLayers = 8.0;
    float maxLayers = 32;
    float numLayers = mix(maxLayers, minLayers, abs(dot(vec3(0.0, 0.0, 1.0), lightDir)));

    vec2 currentTexCoords = texCoord;
    float currentDepthMapValue = 1.0 - texture(u_DepthMap, currentTexCoords).r;
    float currentLayerDepth = currentDepthMapValue;

    float layerDepth = 1.0 / numLayers;
    vec2 P = lightDir.xy / lightDir.z * u_DepthScale * 0.3;
    vec2 deltaTexCoords = P / numLayers;

    while (currentLayerDepth <= currentDepthMapValue && currentLayerDepth > 0.0)
    {
        currentTexCoords += deltaTexCoords;
        currentDepthMapValue = 1.0 - texture(u_DepthMap, currentTexCoords).r;
        currentLayerDepth -= layerDepth;
    }
    float bias = max(0.005 * (1.0 - abs(dot(vec3(0.0, 0.0, 1.0), lightDir))), 0.0001);
    currentLayerDepth -= bias;
    float r = currentLayerDepth > currentDepthMapValue ? 0.0 : 1.0;
    return r;
}

void main()
{
    // Declare normal outside the conditional scope
    vec3 viewDir = normalize(TangentViewPos - TangentFragPos);

    // Adjust texture coordinates using Parallax Ollusion Mapping if enabled
    vec2 texCoords = v_texCoord;
    if (u_UseParallaxMapping) {
        texCoords = ParallaxOcclusionMapping(texCoords, viewDir);
        // Ensure texture coordinates are clamped within valid range
        texCoords = clamp(texCoords, 0.0, 1.0);
    }

    vec3 normal = vec3(0.0, 0.0, 1.0);
    if(u_UseNormalMap)
    {
        // Store the texture coordinates
        normal = texture(u_NormalMap, texCoords).rgb;
        normal = normalize(normal * 2.0 - 1.0); // Transform from [0, 1] to [-1, 1]
    } 

	// Sample the diffuse color
	vec3 color =  texture(u_DiffuseMap, texCoords).rgb;
	
	// Calculate the light direction and view direction in tangent space
    vec3 lightDir = normalize(TangentLightPos - TangentFragPos);

    // Diffuse lighting
    float diff = max(dot(normal, lightDir), 0.0);
    vec3 diffuse = diff * color * 0.5;

    // Specular lighting (simple approximation)
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 25.0); // assuming a shininess value of 32
    vec3 specular = spec * vec3(0.3); // white specular light

    // Self-shadowing calculation
    float shadow = 1.0;
    if (u_UseSelfShadowing) {
        shadow = ShadowCalc(texCoords, lightDir);
    }

    // Combine results
    float ambient = 0.4; // Adjust ambient light intensity (0.0 - 1.0)
    shadow = mix(1.0, shadow, 0.8); // Blend shadow with ambient
    vec3 result = (ambient * color) + (diffuse + specular) * shadow;
    FragColor = vec4(result, 1.0);


}
// ==================================================================
