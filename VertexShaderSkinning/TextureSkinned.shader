Shader "Custom/TextureSkinned"
{
    Properties
    { 
        _BaseMap("Base Map", 2D) = "white" {}
        _BaseColor("Main Color", Color) = (.5,.5,.5,1)
        _BoneCount("Bone Bount", Int) = 0
        _TexWidth("Tex Width", Int) = 256
    }
        // The SubShader block containing the Shader code. 
        SubShader
    {
        // SubShader Tags define when and under which conditions a SubShader block or
        // a pass is executed.
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline" }

        Pass
        {
            Tags
        {
            "LightMode" = "UniversalForward"
           }
            // The HLSL code block. Unity SRP uses the HLSL language.
            HLSLPROGRAM
            // This line defines the name of the vertex shader. 
            #pragma vertex vert
            // This line defines the name of the fragment shader. 
            #pragma fragment frag
            #pragma target 5.0
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"            
            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            CBUFFER_START(UnityPerMaterial)
            half4 _BaseColor;
            float4 _BaseMap_ST;
            int _BoneCount;
            int _TexWidth;
            CBUFFER_END
        
            // The structure definition defines which variables it contains.
            // This example uses the Attributes structure as an input structure in
            // the vertex shader.
            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS : NORMAL;
                float2 indices : TEXCOORD1; // Custom attribute for bone indices
                float2 indices2 : TEXCOORD2; // Custom attribute for bone indices
                float4 boneWeights : COLOR; // Custom attribute for bone weights
            };

            struct Varyings
            {
                // The positions in this struct must have the SV_POSITION semantic.
                float4 positionHCS  : SV_POSITION;
                float3 normalOS : NORMAL;
            };

            // The vertex shader definition with properties defined in the Varyings 
            // structure. The type of the vert function must match the type (struct)
            // that it returns.
            Varyings vert(Attributes IN)
            {
                // Declaring the output object (OUT) with the Varyings struct.
                Varyings OUT;
                // The TransformObjectToHClip function transforms vertex positions
                // from object space to homogenous space
                float inc = 1.0 / _TexWidth;
                float4 boneIndices = float4(IN.indices, IN.indices2);
                float4 boneWeights = IN.boneWeights;
                float4 uvX = float4(boneIndices.x, boneIndices.x, boneIndices.x, boneIndices.x) + float4(0, 1, 2, 3) * inc;
                float4 uvY = float4(boneIndices.y, boneIndices.y, boneIndices.y, boneIndices.y) + float4(0, 1, 2, 3) * inc;
                float4 uvZ = float4(boneIndices.z, boneIndices.z, boneIndices.z, boneIndices.z) + float4(0, 1, 2, 3) * inc;
                float4 uvW = float4(boneIndices.w, boneIndices.w, boneIndices.w, boneIndices.w) + float4(0, 1, 2, 3) * inc;
                float4x4 boneMat0;
                boneMat0._m00_m10_m20_m30 = SAMPLE_TEXTURE2D_LOD(_BaseMap, sampler_BaseMap, float2(uvX.x, 0), 0);
                boneMat0._m01_m11_m21_m31 = SAMPLE_TEXTURE2D_LOD(_BaseMap, sampler_BaseMap, float2(uvX.y, 0), 0);
                boneMat0._m02_m12_m22_m32 = SAMPLE_TEXTURE2D_LOD(_BaseMap, sampler_BaseMap, float2(uvX.z, 0), 0);
                boneMat0._m03_m13_m23_m33 = SAMPLE_TEXTURE2D_LOD(_BaseMap, sampler_BaseMap, float2(uvX.w, 0), 0);
                float4x4 boneMat1;
                boneMat1._m00_m10_m20_m30 = SAMPLE_TEXTURE2D_LOD(_BaseMap, sampler_BaseMap, float2(uvY.x, 0), 0);
                boneMat1._m01_m11_m21_m31 = SAMPLE_TEXTURE2D_LOD(_BaseMap, sampler_BaseMap, float2(uvY.y, 0), 0);
                boneMat1._m02_m12_m22_m32 = SAMPLE_TEXTURE2D_LOD(_BaseMap, sampler_BaseMap, float2(uvY.z, 0), 0);
                boneMat1._m03_m13_m23_m33 = SAMPLE_TEXTURE2D_LOD(_BaseMap, sampler_BaseMap, float2(uvY.w, 0), 0);
                float4x4 boneMat2;
                boneMat2._m00_m10_m20_m30 = SAMPLE_TEXTURE2D_LOD(_BaseMap, sampler_BaseMap, float2(uvZ.x, 0), 0);
                boneMat2._m01_m11_m21_m31 = SAMPLE_TEXTURE2D_LOD(_BaseMap, sampler_BaseMap, float2(uvZ.y, 0), 0);
                boneMat2._m02_m12_m22_m32 = SAMPLE_TEXTURE2D_LOD(_BaseMap, sampler_BaseMap, float2(uvZ.z, 0), 0);
                boneMat2._m03_m13_m23_m33 = SAMPLE_TEXTURE2D_LOD(_BaseMap, sampler_BaseMap, float2(uvZ.w, 0), 0);
                float4x4 boneMat3;
                boneMat3._m00_m10_m20_m30 = SAMPLE_TEXTURE2D_LOD(_BaseMap, sampler_BaseMap, float2(uvW.x, 0), 0);
                boneMat3._m01_m11_m21_m31 = SAMPLE_TEXTURE2D_LOD(_BaseMap, sampler_BaseMap, float2(uvW.y, 0), 0);
                boneMat3._m02_m12_m22_m32 = SAMPLE_TEXTURE2D_LOD(_BaseMap, sampler_BaseMap, float2(uvW.z, 0), 0);
                boneMat3._m03_m13_m23_m33 = SAMPLE_TEXTURE2D_LOD(_BaseMap, sampler_BaseMap, float2(uvW.w, 0), 0);
                //float4x4 boneMat0 = float4x4(tex2D(sampler_BaseMap, float2(uvX.x, 0)), tex2D(sampler_BaseMap, float2(uvX.y, 0)), tex2D(sampler_BaseMap, float2(uvX.z, 0)), tex2D(sampler_BaseMap, float2(uvX.w, 0)));
                //float4x4 boneMat1 = float4x4(tex2D(sampler_BaseMap, float2(uvY.x, 0)), tex2D(sampler_BaseMap, float2(uvY.y, 0)), tex2D(sampler_BaseMap, float2(uvY.z, 0)), tex2D(sampler_BaseMap, float2(uvY.w, 0)));
                //float4x4 boneMat2 = float4x4(tex2D(sampler_BaseMap, float2(uvZ.x, 0)), tex2D(sampler_BaseMap, float2(uvZ.y, 0)), tex2D(sampler_BaseMap, float2(uvZ.z, 0)), tex2D(sampler_BaseMap, float2(uvZ.w, 0)));
                //float4x4 boneMat3 = float4x4(tex2D(sampler_BaseMap, float2(uvW.x, 0)), tex2D(sampler_BaseMap, float2(uvW.y, 0)), tex2D(sampler_BaseMap, float2(uvW.z, 0)), tex2D(sampler_BaseMap, float2(uvW.w, 0)));
                float4x4 sumBone = boneMat0 * boneWeights.x + boneMat1 * boneWeights.y + boneMat2 * boneWeights.z + boneMat3 * boneWeights.w;
                //float4x4 sumBone = boneMat0;
                float4 positionOS = mul(sumBone, float4(IN.positionOS.xyz, 1.0));
                OUT.positionHCS = TransformObjectToHClip(positionOS.xyz);
                OUT.normalOS = IN.normalOS;
                // Returning the output.
                return OUT;
            }

            // The fragment shader definition.            
            half4 frag(Varyings IN) : SV_Target
            {
                // Defining the color variable and returning it.
                half4 customColor;
                customColor = _BaseColor * (dot(IN.normalOS, float3(0, 1, 0) * 0.5 + 0.5));
                return customColor;
            }
            ENDHLSL
        }
    }
}