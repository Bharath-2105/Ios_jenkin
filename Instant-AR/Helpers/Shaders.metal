#include <metal_stdlib>
#include <RealityKit/RealityKit.h>
using namespace metal;

[[visible]]
void basicShader(realitykit::surface_parameters params)
{
    float lineThickness = 0.01;
    
    realitykit::surface::surface_properties ssh = params.surface();
    float time = params.uniforms().time();
    
    float2 uv = params.geometry().uv0();
    float oscillatingValue = 0.5 * sin(time * 2.0 + -1.0) + 0.5 ;
    if( uv.x > (oscillatingValue - lineThickness) && uv.x < (oscillatingValue + lineThickness)){
        ssh.set_base_color(half3(0, 1, 0));
    } else {
        discard_fragment();
    }
}

[[visible]]
void basicModifier(realitykit::geometry_parameters modifier)
{
//    float3 pose = modifier.geometry().model_position();
////    float time = modifier.uniforms().time();
////    float speed = 1.5f;
////    float amplitude = 0.1f;
////    float offset = 0.05f;
////    float cosTime = (cos(time * speed)) * amplitude;
////    float sinTime = (sin(time * speed)) * (amplitude + offset);
////    modifier.geometry().set_model_position_offset(
////        float3(pose.y,pose.z, pose.z + 0.1 )
////    );
}

