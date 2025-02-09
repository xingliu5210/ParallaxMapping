/** @file Object.hpp
 *  @brief Sets up an OpenGL camera..
 *  
 *  More...
 */
#ifndef OBJECT_HPP
#define OBJECT_HPP

#include <glad/glad.h>

#include <vector>
#include <string>

#include "Shader.hpp"
#include "VertexBufferLayout.hpp"
#include "Texture.hpp"
#include "Transform.hpp"
#include "Geometry.hpp"

#include "glm/vec3.hpp"
#include "glm/gtc/matrix_transform.hpp"

// Purpose:
// An abstraction to create multiple objects
//
//
class Object{
public:
    // Object Constructor
    Object();
    // Object destructor
    ~Object();
    // Load a texture
    void LoadTexture(std::string fileName);
    // Create a textured quad
    void MakeTexturedQuad(std::string fileName);
    // Updates and transformations applied to object
    void Update(unsigned int screenWidth, unsigned int screenHeight, const glm::mat4& viewMatrix, const glm::mat4& projectionMatrix);
    // How to draw the object
    void Render();
    // Returns an objects transform
    Transform& GetTransform();
    // Decide if to implement normal map
    void SetUseNormalMap(bool useNormalMap);
    // Decide if to implement parallax map
    void SetUseParallaxMapping(bool useParallaxMapping);
    // Set the Depth scale
    void SetDepthScale(float depthScale);
    // Adjust the depth scale
    void AdjustDepthScale(float delta);
    // Set the shadow
    void SetUseSelfShadowing(bool useSelfShadowing);

private:
	// Helper method for when we are ready to draw or update our object
	void Bind();

    // Object vertices
    std::vector<GLfloat> m_vertices;
    // Object indices
    std::vector<GLuint> m_indices;

    // For now we have one shader per object.
    Shader m_shader;
    // For now we have one buffer per object.
    VertexBufferLayout m_vertexBufferLayout;
    // For now we have one texture per object
    Texture m_textureDiffuse;
    // NOTE: that we have a normal map per object as well!
    Texture m_normalMap;
    // Store the depthMap/Height Map
    Texture m_depthMap;
    // Store the objects transformations
    Transform m_transform; 
    // Store the 'camera' projection
    glm::mat4 m_projectionMatrix;
    // Store the objects Geometry
	Geometry m_geometry;

    // For interaction
    bool m_useNormalMap = true;
    bool m_useParallaxMapping = false;
    float m_depthScale = 0.05f;
    bool m_useSelfShadowing = false;
};


#endif
