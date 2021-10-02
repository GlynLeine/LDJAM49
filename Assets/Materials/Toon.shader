// Shader targeted for low end devices. Single Pass Forward Rendering.
Shader "Toon"
{
	// Keep properties of StandardSpecular shader for upgrade reasons.
	Properties
	{
		[MainTexture] _BaseMap("Base Map (RGB) Smoothness / Alpha (A)", 2D) = "white" {}
		[MainColor]   _BaseColor("Base Color", Color) = (1, 1, 1, 1)
		_AmbientColor("Ambient Color", Color) = (0.4, 0.4, 0.4, 1)

		_Cutoff("Alpha Clipping", Range(0.0, 1.0)) = 0.5

		_SpecColor("Specular Color", Color) = (0.5, 0.5, 0.5, 0.5)
		_SpecGlossMap("Specular Map", 2D) = "white" {}
		[Enum(Specular Alpha,0,Albedo Alpha,1)] _SmoothnessSource("Smoothness Source", Float) = 0.0
		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0

		[HideInInspector] _BumpScale("Scale", Float) = 1.0
		[NoScaleOffset] _BumpMap("Normal Map", 2D) = "bump" {}

		[HDR] _EmissionColor("Emission Color", Color) = (0,0,0)
		[NoScaleOffset]_EmissionMap("Emission Map", 2D) = "white" {}

		// Blending state
		[HideInInspector] _Surface("__surface", Float) = 0.0
		[HideInInspector] _Blend("__blend", Float) = 0.0
		[HideInInspector] _AlphaClip("__clip", Float) = 0.0
		[HideInInspector] _SrcBlend("__src", Float) = 1.0
		[HideInInspector] _DstBlend("__dst", Float) = 0.0
		[HideInInspector] _ZWrite("__zw", Float) = 1.0
		[HideInInspector] _Cull("__cull", Float) = 2.0

		[ToggleOff] _ReceiveShadows("Receive Shadows", Float) = 1.0

			// Editmode props
			[HideInInspector] _QueueOffset("Queue offset", Float) = 0.0
			[HideInInspector] _Smoothness("Smoothness", Float) = 0.5

			// ObsoleteProperties
			[HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
			[HideInInspector] _Color("Base Color", Color) = (1, 1, 1, 1)
			[HideInInspector] _Shininess("Smoothness", Float) = 0.0
			[HideInInspector] _GlossinessSource("GlossinessSource", Float) = 0.0
			[HideInInspector] _SpecSource("SpecularHighlights", Float) = 0.0

			[HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
			[HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
			[HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
	}

		SubShader
	{
		Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "SimpleLit" "IgnoreProjector" = "True" "ShaderModel" = "2.0"}
		LOD 300

		Pass
		{
			Name "ForwardLit"
			Tags { "LightMode" = "UniversalForward" }

		// Use same blending / depth states as Standard shader
		Blend[_SrcBlend][_DstBlend]
		ZWrite[_ZWrite]
		Cull[_Cull]

		HLSLPROGRAM
		#pragma only_renderers gles gles3 glcore d3d11
		#pragma target 2.0

		// -------------------------------------
		// Material Keywords
		#pragma shader_feature_local_fragment _ALPHATEST_ON
		#pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
		#pragma shader_feature_local_fragment _ _SPECGLOSSMAP _SPECULAR_COLOR
		#pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA
		#pragma shader_feature_local _NORMALMAP
		#pragma shader_feature_local_fragment _EMISSION
		#pragma shader_feature_local _RECEIVE_SHADOWS_OFF

		// -------------------------------------
		// Universal Pipeline keywords
		#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
		#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
		#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
		#pragma multi_compile_fragment _ _SHADOWS_SOFT
		#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
		#pragma multi_compile _ SHADOWS_SHADOWMASK
		#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION


		// -------------------------------------
		// Unity defined keywords
		#pragma multi_compile _ DIRLIGHTMAP_COMBINED
		#pragma multi_compile _ LIGHTMAP_ON
		#pragma multi_compile_fog

		#pragma vertex LitPassVertexSimple
		#pragma fragment LitPassFragmentSimple
		#define BUMP_SCALE_NOT_SUPPORTED 1

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

CBUFFER_START(UnityPerMaterial)
	float4 _BaseMap_ST;
	half4 _BaseColor;
	half4 _AmbientColor;
	half4 _SpecColor;
	half4 _EmissionColor;
	half _Cutoff;
	half _Surface;
CBUFFER_END

#ifdef UNITY_DOTS_INSTANCING_ENABLED
	UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
		UNITY_DOTS_INSTANCED_PROP(float4, _BaseColor)
		UNITY_DOTS_INSTANCED_PROP(float4, _AmbientColor)
		UNITY_DOTS_INSTANCED_PROP(float4, _SpecColor)
		UNITY_DOTS_INSTANCED_PROP(float4, _EmissionColor)
		UNITY_DOTS_INSTANCED_PROP(float , _Cutoff)
		UNITY_DOTS_INSTANCED_PROP(float , _Surface)
	UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

	#define _BaseColor          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__BaseColor)
	#define _AmbientColor          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__BaseColor)
	#define _SpecColor          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__SpecColor)
	#define _EmissionColor      UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__EmissionColor)
	#define _Cutoff             UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Cutoff)
	#define _Surface            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Surface)
#endif

TEXTURE2D(_SpecGlossMap);       SAMPLER(sampler_SpecGlossMap);

half4 SampleSpecularSmoothness(half2 uv, half alpha, half4 specColor, TEXTURE2D_PARAM(specMap, sampler_specMap))
{
	half4 specularSmoothness = half4(0.0h, 0.0h, 0.0h, 1.0h);
#ifdef _SPECGLOSSMAP
	specularSmoothness = SAMPLE_TEXTURE2D(specMap, sampler_specMap, uv) * specColor;
#elif defined(_SPECULAR_COLOR)
	specularSmoothness = specColor;
#endif

#ifdef _GLOSSINESS_FROM_BASE_ALPHA
	specularSmoothness.a = exp2(10 * alpha + 1);
#else
	specularSmoothness.a = exp2(10 * specularSmoothness.a + 1);
#endif

	return specularSmoothness;
}

inline void InitializeSimpleLitSurfaceData(float2 uv, out SurfaceData outSurfaceData)
{
	outSurfaceData = (SurfaceData)0;

	half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
	outSurfaceData.alpha = albedoAlpha.a * _BaseColor.a;
	AlphaDiscard(outSurfaceData.alpha, _Cutoff);

	outSurfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;
#ifdef _ALPHAPREMULTIPLY_ON
	outSurfaceData.albedo *= outSurfaceData.alpha;
#endif

	half4 specularSmoothness = SampleSpecularSmoothness(uv, outSurfaceData.alpha, _SpecColor, TEXTURE2D_ARGS(_SpecGlossMap, sampler_SpecGlossMap));
	outSurfaceData.metallic = 0.0; // unused
	outSurfaceData.specular = specularSmoothness.rgb;
	outSurfaceData.smoothness = specularSmoothness.a;
	outSurfaceData.normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap));
	outSurfaceData.occlusion = 1.0; // unused
	outSurfaceData.emission = SampleEmission(uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
}

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/EntityLighting.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ImageBasedLighting.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/BSDF.hlsl"
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Deprecated.hlsl"
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"


		#if defined(UNITY_DOTS_INSTANCING_ENABLED)
		#define LIGHTMAP_NAME unity_Lightmaps
		#define LIGHTMAP_INDIRECTION_NAME unity_LightmapsInd
		#define LIGHTMAP_SAMPLER_NAME samplerunity_Lightmaps
		#define LIGHTMAP_SAMPLE_EXTRA_ARGS lightmapUV, unity_LightmapIndex.x
		#else
		#define LIGHTMAP_NAME unity_Lightmap
		#define LIGHTMAP_INDIRECTION_NAME unity_LightmapInd
		#define LIGHTMAP_SAMPLER_NAME samplerunity_Lightmap
		#define LIGHTMAP_SAMPLE_EXTRA_ARGS lightmapUV
		#endif

		// If lightmap is not defined than we evaluate GI (ambient + probes) from SH
		// We might do it fully or partially in vertex to save shader ALU
		#if !defined(LIGHTMAP_ON)
		// TODO: Controls things like these by exposing SHADER_QUALITY levels (low, medium, high)
			#if defined(SHADER_API_GLES) || !defined(_NORMALMAP)
				// Evaluates SH fully in vertex
				#define EVALUATE_SH_VERTEX
			#elif !SHADER_HINT_NICE_QUALITY
				// Evaluates L2 SH in vertex and L0L1 in pixel
				#define EVALUATE_SH_MIXED
			#endif
				// Otherwise evaluate SH fully per-pixel
		#endif

		#ifdef LIGHTMAP_ON
			#define DECLARE_LIGHTMAP_OR_SH(lmName, shName, index) float2 lmName : TEXCOORD##index
			#define OUTPUT_LIGHTMAP_UV(lightmapUV, lightmapScaleOffset, OUT) OUT.xy = lightmapUV.xy * lightmapScaleOffset.xy + lightmapScaleOffset.zw;
			#define OUTPUT_SH(normalWS, OUT)
		#else
			#define DECLARE_LIGHTMAP_OR_SH(lmName, shName, index) half3 shName : TEXCOORD##index
			#define OUTPUT_LIGHTMAP_UV(lightmapUV, lightmapScaleOffset, OUT)
			#define OUTPUT_SH(normalWS, OUT) OUT.xyz = SampleSHVertex(normalWS)
		#endif

		// We either sample GI from baked lightmap or from probes.
		// If lightmap: sampleData.xy = lightmapUV
		// If probe: sampleData.xyz = L2 SH terms
		#if defined(LIGHTMAP_ON)
		#define SAMPLE_GI(lmName, shName, normalWSName) SampleLightmap(lmName, normalWSName)
		#else
		#define SAMPLE_GI(lmName, shName, normalWSName) SampleSHPixel(shName, normalWSName)
		#endif


			// Abstraction over Light shading data.
			struct Light
			{
				half3   direction;
				half3   color;
				half    distanceAttenuation;
				half    shadowAttenuation;
			};


			Light GetMainLight()
			{
				Light light;
				light.direction = _MainLightPosition.xyz;
				light.distanceAttenuation = unity_LightData.z; // unity_LightData.z is 1 when not culled by the culling mask, otherwise 0.
				light.shadowAttenuation = 1.0;
				light.color = _MainLightColor.rgb;

				return light;
			}

			Light GetMainLight(float4 shadowCoord, float3 positionWS, half4 shadowMask)
			{
				Light light = GetMainLight();
				light.shadowAttenuation = MainLightShadow(shadowCoord, positionWS, shadowMask, _MainLightOcclusionProbes);
				return light;
			}

			void MixRealtimeAndBakedGI(inout Light light, half3 normalWS, inout half3 bakedGI)
			{
#if defined(LIGHTMAP_ON) && defined(_MIXED_LIGHTING_SUBTRACTIVE)
				bakedGI = SubtractDirectMainLightFromLightmap(light, normalWS, bakedGI);
#endif
			}

			half3 LightingLambert(half3 lightColor, half3 lightDir, half3 normal)
			{
				half NdotL = saturate(dot(normal, lightDir));
				return lightColor * smoothstep(0, 0.01, NdotL);
			}

			half3 LightingSpecular(half3 lightColor, half3 lightDir, half3 normal, half3 viewDir, half4 specular, half smoothness)
			{
				float3 halfVec = SafeNormalize(float3(lightDir)+float3(viewDir));
				half NdotH = saturate(dot(normal, halfVec));
				half modifier = pow(NdotH, smoothness);
				half3 specularReflection = specular.rgb * smoothstep(0.005, 0.01, modifier);
				return lightColor * specularReflection;
			}


		// Sample baked lightmap. Non-Direction and Directional if available.
		// Realtime GI is not supported.
		half3 SampleLightmap(float2 lightmapUV, half3 normalWS)
		{
		#ifdef UNITY_LIGHTMAP_FULL_HDR
			bool encodedLightmap = false;
		#else
			bool encodedLightmap = true;
		#endif

			half4 decodeInstructions = half4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0.0h, 0.0h);

			// The shader library sample lightmap functions transform the lightmap uv coords to apply bias and scale.
			// However, universal pipeline already transformed those coords in vertex. We pass half4(1, 1, 0, 0) and
			// the compiler will optimize the transform away.
			half4 transformCoords = half4(1, 1, 0, 0);

		#if defined(LIGHTMAP_ON) && defined(DIRLIGHTMAP_COMBINED)
			return SampleDirectionalLightmap(TEXTURE2D_LIGHTMAP_ARGS(LIGHTMAP_NAME, LIGHTMAP_SAMPLER_NAME),
				TEXTURE2D_LIGHTMAP_ARGS(LIGHTMAP_INDIRECTION_NAME, LIGHTMAP_SAMPLER_NAME),
				LIGHTMAP_SAMPLE_EXTRA_ARGS, transformCoords, normalWS, encodedLightmap, decodeInstructions);
		#elif defined(LIGHTMAP_ON)
			return SampleSingleLightmap(TEXTURE2D_LIGHTMAP_ARGS(LIGHTMAP_NAME, LIGHTMAP_SAMPLER_NAME), LIGHTMAP_SAMPLE_EXTRA_ARGS, transformCoords, encodedLightmap, decodeInstructions);
		#else
			return half3(0.0, 0.0, 0.0);
		#endif
		}

		// Samples SH L0, L1 and L2 terms
		half3 SampleSH(half3 normalWS)
		{
			// LPPV is not supported in Ligthweight Pipeline
			real4 SHCoefficients[7];
			SHCoefficients[0] = unity_SHAr;
			SHCoefficients[1] = unity_SHAg;
			SHCoefficients[2] = unity_SHAb;
			SHCoefficients[3] = unity_SHBr;
			SHCoefficients[4] = unity_SHBg;
			SHCoefficients[5] = unity_SHBb;
			SHCoefficients[6] = unity_SHC;

			return max(half3(0, 0, 0), SampleSH9(SHCoefficients, normalWS));
		}

		// SH Vertex Evaluation. Depending on target SH sampling might be
		// done completely per vertex or mixed with L2 term per vertex and L0, L1
		// per pixel. See SampleSHPixel
		half3 SampleSHVertex(half3 normalWS)
		{
#if defined(EVALUATE_SH_VERTEX)
			return SampleSH(normalWS);
#elif defined(EVALUATE_SH_MIXED)
			// no max since this is only L2 contribution
			return SHEvalLinearL2(normalWS, unity_SHBr, unity_SHBg, unity_SHBb, unity_SHC);
#endif

			// Fully per-pixel. Nothing to compute.
			return half3(0.0, 0.0, 0.0);
		}

		// SH Pixel Evaluation. Depending on target SH sampling might be done
		// mixed or fully in pixel. See SampleSHVertex
		half3 SampleSHPixel(half3 L2Term, half3 normalWS)
		{
		#if defined(EVALUATE_SH_VERTEX)
			return L2Term;
		#elif defined(EVALUATE_SH_MIXED)
			half3 L0L1Term = SHEvalLinearL0L1(normalWS, unity_SHAr, unity_SHAg, unity_SHAb);
			half3 res = L2Term + L0L1Term;
		#ifdef UNITY_COLORSPACE_GAMMA
			res = LinearToSRGB(res);
		#endif
			return max(half3(0, 0, 0), res);
		#endif

			// Default: Evaluate SH fully per-pixel
			return SampleSH(normalWS);
		}


		half3 VertexLighting(float3 positionWS, half3 normalWS)
		{
			half3 vertexLightColor = half3(0.0, 0.0, 0.0);

	#ifdef _ADDITIONAL_LIGHTS_VERTEX
			uint lightsCount = GetAdditionalLightsCount();
			for (uint lightIndex = 0u; lightIndex < lightsCount; ++lightIndex)
			{
				Light light = GetAdditionalLight(lightIndex, positionWS);
				half3 lightColor = light.color * light.distanceAttenuation;
				vertexLightColor += LightingLambert(lightColor, light.direction, normalWS);
			}
	#endif

			return vertexLightColor;
		}


		// Matches Unity Vanila attenuation
		// Attenuation smoothly decreases to light range.
		float DistanceAttenuation(float distanceSqr, half2 distanceAttenuation)
		{
			// We use a shared distance attenuation for additional directional and puctual lights
			// for directional lights attenuation will be 1
			float lightAtten = rcp(distanceSqr);

#if SHADER_HINT_NICE_QUALITY
			// Use the smoothing factor also used in the Unity lightmapper.
			half factor = distanceSqr * distanceAttenuation.x;
			half smoothFactor = saturate(1.0h - factor * factor);
			smoothFactor = smoothFactor * smoothFactor;
#else
			// We need to smoothly fade attenuation to light range. We start fading linearly at 80% of light range
			// Therefore:
			// fadeDistance = (0.8 * 0.8 * lightRangeSq)
			// smoothFactor = (lightRangeSqr - distanceSqr) / (lightRangeSqr - fadeDistance)
			// We can rewrite that to fit a MAD by doing
			// distanceSqr * (1.0 / (fadeDistanceSqr - lightRangeSqr)) + (-lightRangeSqr / (fadeDistanceSqr - lightRangeSqr)
			// distanceSqr *        distanceAttenuation.y            +             distanceAttenuation.z
			half smoothFactor = saturate(distanceSqr * distanceAttenuation.x + distanceAttenuation.y);
#endif

			return lightAtten * smoothFactor;
		}


		// Fills a light struct given a perObjectLightIndex
		Light GetAdditionalPerObjectLight(int perObjectLightIndex, float3 positionWS)
		{
			// Abstraction over Light input constants
#if USE_STRUCTURED_BUFFER_FOR_LIGHT_DATA
			float4 lightPositionWS = _AdditionalLightsBuffer[perObjectLightIndex].position;
			half3 color = _AdditionalLightsBuffer[perObjectLightIndex].color.rgb;
			half4 distanceAndSpotAttenuation = _AdditionalLightsBuffer[perObjectLightIndex].attenuation;
			half4 spotDirection = _AdditionalLightsBuffer[perObjectLightIndex].spotDirection;
#else
			float4 lightPositionWS = _AdditionalLightsPosition[perObjectLightIndex];
			half3 color = _AdditionalLightsColor[perObjectLightIndex].rgb;
			half4 distanceAndSpotAttenuation = _AdditionalLightsAttenuation[perObjectLightIndex];
			half4 spotDirection = _AdditionalLightsSpotDir[perObjectLightIndex];
#endif

			// Directional lights store direction in lightPosition.xyz and have .w set to 0.0.
			// This way the following code will work for both directional and punctual lights.
			float3 lightVector = lightPositionWS.xyz - positionWS * lightPositionWS.w;
			float distanceSqr = max(dot(lightVector, lightVector), HALF_MIN);

			half3 lightDirection = half3(lightVector * rsqrt(distanceSqr));
			half attenuation = DistanceAttenuation(distanceSqr, distanceAndSpotAttenuation.xy) * AngleAttenuation(spotDirection.xyz, lightDirection, distanceAndSpotAttenuation.zw);

			Light light;
			light.direction = lightDirection;
			light.distanceAttenuation = attenuation;
			light.shadowAttenuation = 1.0; // This value can later be overridden in GetAdditionalLight(uint i, float3 positionWS, half4 shadowMask)
			light.color = color;

			return light;
		}

		// Returns a per-object index given a loop index.
		// This abstract the underlying data implementation for storing lights/light indices
		int GetPerObjectLightIndex(uint index)
		{
			/////////////////////////////////////////////////////////////////////////////////////////////
			// Structured Buffer Path                                                                   /
			//                                                                                          /
			// Lights and light indices are stored in StructuredBuffer. We can just index them.         /
			// Currently all non-mobile platforms take this path :(                                     /
			// There are limitation in mobile GPUs to use SSBO (performance / no vertex shader support) /
			/////////////////////////////////////////////////////////////////////////////////////////////
#if USE_STRUCTURED_BUFFER_FOR_LIGHT_DATA
			uint offset = unity_LightData.x;
			return _AdditionalLightsIndices[offset + index];

			/////////////////////////////////////////////////////////////////////////////////////////////
			// UBO path                                                                                 /
			//                                                                                          /
			// We store 8 light indices in float4 unity_LightIndices[2];                                /
			// Due to memory alignment unity doesn't support int[] or float[]                           /
			// Even trying to reinterpret cast the unity_LightIndices to float[] won't work             /
			// it will cast to float4[] and create extra register pressure. :(                          /
			/////////////////////////////////////////////////////////////////////////////////////////////
#elif !defined(SHADER_API_GLES)
	// since index is uint shader compiler will implement
	// div & mod as bitfield ops (shift and mask).

	// TODO: Can we index a float4? Currently compiler is
	// replacing unity_LightIndicesX[i] with a dp4 with identity matrix.
	// u_xlat16_40 = dot(unity_LightIndices[int(u_xlatu13)], ImmCB_0_0_0[u_xlati1]);
	// This increases both arithmetic and register pressure.
			return unity_LightIndices[index / 4][index % 4];
#else
	// Fallback to GLES2. No bitfield magic here :(.
	// We limit to 4 indices per object and only sample unity_4LightIndices0.
	// Conditional moves are branch free even on mali-400
	// small arithmetic cost but no extra register pressure from ImmCB_0_0_0 matrix.
			half2 lightIndex2 = (index < 2.0h) ? unity_LightIndices[0].xy : unity_LightIndices[0].zw;
			half i_rem = (index < 2.0h) ? index : index - 2.0h;
			return (i_rem < 1.0h) ? lightIndex2.x : lightIndex2.y;
#endif
		}

		// Fills a light struct given a loop i index. This will convert the i
		// index to a perObjectLightIndex
		Light GetAdditionalLight(uint i, float3 positionWS)
		{
			int perObjectLightIndex = GetPerObjectLightIndex(i);
			return GetAdditionalPerObjectLight(perObjectLightIndex, positionWS);
		}

		Light GetAdditionalLight(uint i, float3 positionWS, half4 shadowMask)
		{
			int perObjectLightIndex = GetPerObjectLightIndex(i);
			Light light = GetAdditionalPerObjectLight(perObjectLightIndex, positionWS);

#if USE_STRUCTURED_BUFFER_FOR_LIGHT_DATA
			half4 occlusionProbeChannels = _AdditionalLightsBuffer[perObjectLightIndex].occlusionProbeChannels;
#else
			half4 occlusionProbeChannels = _AdditionalLightsOcclusionProbes[perObjectLightIndex];
#endif
			light.shadowAttenuation = AdditionalLightShadow(perObjectLightIndex, positionWS, light.direction, shadowMask, occlusionProbeChannels);

			return light;
		}

		int GetAdditionalLightsCount()
		{
			// TODO: we need to expose in SRP api an ability for the pipeline cap the amount of lights
			// in the culling. This way we could do the loop branch with an uniform
			// This would be helpful to support baking exceeding lights in SH as well
			return min(_AdditionalLightsCount.x, unity_LightData.y);
		}

		TEXTURE2D_X(_ScreenSpaceOcclusionTexture);
		SAMPLER(sampler_ScreenSpaceOcclusionTexture);

		struct AmbientOcclusionFactor
		{
			half indirectAmbientOcclusion;
			half directAmbientOcclusion;
		};

		half SampleAmbientOcclusion(float2 normalizedScreenSpaceUV)
		{
			float2 uv = UnityStereoTransformScreenSpaceTex(normalizedScreenSpaceUV);
			return SAMPLE_TEXTURE2D_X(_ScreenSpaceOcclusionTexture, sampler_ScreenSpaceOcclusionTexture, uv).x;
		}


		AmbientOcclusionFactor GetScreenSpaceAmbientOcclusion(float2 normalizedScreenSpaceUV)
		{
			AmbientOcclusionFactor aoFactor;
			aoFactor.indirectAmbientOcclusion = SampleAmbientOcclusion(normalizedScreenSpaceUV);
			aoFactor.directAmbientOcclusion = lerp(1.0, aoFactor.indirectAmbientOcclusion, _AmbientOcclusionParam.w);
			return aoFactor;
		}


		half4 UniversalFragmentBlinnPhong(InputData inputData, half3 diffuse, half4 specularGloss, half smoothness, half3 emission, half alpha)
		{
			// To ensure backward compatibility we have to avoid using shadowMask input, as it is not present in older shaders
#if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
			half4 shadowMask = inputData.shadowMask;
#elif !defined (LIGHTMAP_ON)
			half4 shadowMask = unity_ProbesOcclusion;
#else
			half4 shadowMask = half4(1, 1, 1, 1);
#endif

			Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, shadowMask);

#if defined(_SCREEN_SPACE_OCCLUSION)
			AmbientOcclusionFactor aoFactor = GetScreenSpaceAmbientOcclusion(inputData.normalizedScreenSpaceUV);
			mainLight.color *= aoFactor.directAmbientOcclusion;
			inputData.bakedGI *= aoFactor.indirectAmbientOcclusion;
#endif

			MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI);

			half3 attenuatedLightColor = mainLight.color * (mainLight.distanceAttenuation * mainLight.shadowAttenuation);
			half3 diffuseColor = inputData.bakedGI + LightingLambert(attenuatedLightColor, mainLight.direction, inputData.normalWS);
			half3 specularColor = LightingSpecular(attenuatedLightColor, mainLight.direction, inputData.normalWS, inputData.viewDirectionWS, specularGloss, smoothness);

#ifdef _ADDITIONAL_LIGHTS
			uint pixelLightCount = GetAdditionalLightsCount();
			for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
			{
				Light light = GetAdditionalLight(lightIndex, inputData.positionWS, shadowMask);
#if defined(_SCREEN_SPACE_OCCLUSION)
				light.color *= aoFactor.directAmbientOcclusion;
#endif
				half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
				diffuseColor += LightingLambert(attenuatedLightColor, light.direction, inputData.normalWS);
				specularColor += LightingSpecular(attenuatedLightColor, light.direction, inputData.normalWS, inputData.viewDirectionWS, specularGloss, smoothness);
			}
#endif

#ifdef _ADDITIONAL_LIGHTS_VERTEX
			diffuseColor += inputData.vertexLighting;
#endif

			half3 finalColor = diffuseColor * diffuse + emission;

#if defined(_SPECGLOSSMAP) || defined(_SPECULAR_COLOR)
			finalColor += specularColor;
#endif

			return half4(finalColor, alpha);
		}

			struct Attributes
			{
				float4 positionOS    : POSITION;
				float3 normalOS      : NORMAL;
				float4 tangentOS     : TANGENT;
				float2 texcoord      : TEXCOORD0;
				float2 lightmapUV    : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct Varyings
			{
				float2 uv                       : TEXCOORD0;
				DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);

				float3 posWS                    : TEXCOORD2;    // xyz: posWS

			#ifdef _NORMALMAP
				float4 normal                   : TEXCOORD3;    // xyz: normal, w: viewDir.x
				float4 tangent                  : TEXCOORD4;    // xyz: tangent, w: viewDir.y
				float4 bitangent                : TEXCOORD5;    // xyz: bitangent, w: viewDir.z
			#else
				float3  normal                  : TEXCOORD3;
				float3 viewDir                  : TEXCOORD4;
			#endif

				half4 fogFactorAndVertexLight   : TEXCOORD6; // x: fogFactor, yzw: vertex light

			#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord              : TEXCOORD7;
			#endif

				float4 positionCS               : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
			{
				inputData.positionWS = input.posWS;

			#ifdef _NORMALMAP
				half3 viewDirWS = half3(input.normal.w, input.tangent.w, input.bitangent.w);
				inputData.normalWS = TransformTangentToWorld(normalTS,
					half3x3(input.tangent.xyz, input.bitangent.xyz, input.normal.xyz));
			#else
				half3 viewDirWS = input.viewDir;
				inputData.normalWS = input.normal;
			#endif

				inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				viewDirWS = SafeNormalize(viewDirWS);

				inputData.viewDirectionWS = viewDirWS;

			#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				inputData.shadowCoord = input.shadowCoord;
			#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
				inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
			#else
				inputData.shadowCoord = float4(0, 0, 0, 0);
			#endif

				inputData.fogCoord = input.fogFactorAndVertexLight.x;
				inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
				inputData.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS);
				inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
				inputData.shadowMask = SAMPLE_SHADOWMASK(input.lightmapUV);
			}

			///////////////////////////////////////////////////////////////////////////////
			//                  Vertex and Fragment functions                            //
			///////////////////////////////////////////////////////////////////////////////

			// Used in Standard (Simple Lighting) shader
			Varyings LitPassVertexSimple(Attributes input)
			{
				Varyings output = (Varyings)0;

				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
				VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
				half3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
				half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
				half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

				output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
				output.posWS.xyz = vertexInput.positionWS;
				output.positionCS = vertexInput.positionCS;

			#ifdef _NORMALMAP
				output.normal = half4(normalInput.normalWS, viewDirWS.x);
				output.tangent = half4(normalInput.tangentWS, viewDirWS.y);
				output.bitangent = half4(normalInput.bitangentWS, viewDirWS.z);
			#else
				output.normal = NormalizeNormalPerVertex(normalInput.normalWS);
				output.viewDir = viewDirWS;
			#endif

				OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
				OUTPUT_SH(output.normal.xyz, output.vertexSH);

				output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

			#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				output.shadowCoord = GetShadowCoord(vertexInput);
			#endif

				return output;
			}

			// Used for StandardSimpleLighting shader
			half4 LitPassFragmentSimple(Varyings input) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

				float2 uv = input.uv;
				half4 diffuseAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
				half3 diffuse = diffuseAlpha.rgb * _BaseColor.rgb;

				half alpha = diffuseAlpha.a * _BaseColor.a;
				AlphaDiscard(alpha, _Cutoff);

				#ifdef _ALPHAPREMULTIPLY_ON
					diffuse *= alpha;
				#endif

				half3 normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap));
				half3 emission = SampleEmission(uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
				half4 specular = SampleSpecularSmoothness(uv, alpha, _SpecColor, TEXTURE2D_ARGS(_SpecGlossMap, sampler_SpecGlossMap));
				half smoothness = specular.a;

				InputData inputData;
				InitializeInputData(input, normalTS, inputData);

				half4 color = _AmbientColor + UniversalFragmentBlinnPhong(inputData, diffuse, specular, smoothness, emission, alpha);
				color.rgb = MixFog(color.rgb, inputData.fogCoord);
				color.a = OutputAlpha(color.a, _Surface);

				return color;
			}

			ENDHLSL
		}

		Pass
		{
			Name "ShadowCaster"
			Tags{"LightMode" = "ShadowCaster"}

			ZWrite On
			ZTest LEqual
			ColorMask 0
			Cull[_Cull]

			HLSLPROGRAM
			#pragma only_renderers gles gles3 glcore d3d11
			#pragma target 2.0

				// -------------------------------------
				// Material Keywords
				#pragma shader_feature_local_fragment _ALPHATEST_ON
				#pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA

				// -------------------------------------
				// Universal Pipeline keywords

				// This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
				#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

				#pragma vertex ShadowPassVertex
				#pragma fragment ShadowPassFragment

				#include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
				#include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
				ENDHLSL
			}

			Pass
			{
				Name "DepthOnly"
				Tags{"LightMode" = "DepthOnly"}

				ZWrite On
				ColorMask 0
				Cull[_Cull]

				HLSLPROGRAM
				#pragma only_renderers gles gles3 glcore d3d11
				#pragma target 2.0

				#pragma vertex DepthOnlyVertex
				#pragma fragment DepthOnlyFragment

				// Material Keywords
				#pragma shader_feature_local_fragment _ALPHATEST_ON
				#pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA

				#include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
				#include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
				ENDHLSL
			}

				// This pass is used when drawing to a _CameraNormalsTexture texture
				Pass
				{
					Name "DepthNormals"
					Tags{"LightMode" = "DepthNormals"}

					ZWrite On
					Cull[_Cull]

					HLSLPROGRAM
					#pragma only_renderers gles gles3 glcore d3d11
					#pragma target 2.0

					#pragma vertex DepthNormalsVertex
					#pragma fragment DepthNormalsFragment

				// -------------------------------------
				// Material Keywords
				#pragma shader_feature_local _NORMALMAP
				#pragma shader_feature_local_fragment _ALPHATEST_ON
				#pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA

				//--------------------------------------
				// GPU Instancing
				#pragma multi_compile_instancing

				#include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
				#include "Packages/com.unity.render-pipelines.universal/Shaders/DepthNormalsPass.hlsl"
				ENDHLSL
			}

				// This pass it not used during regular rendering, only for lightmap baking.
				Pass
				{
					Name "Meta"
					Tags{ "LightMode" = "Meta" }

					Cull Off

					HLSLPROGRAM
					#pragma only_renderers gles gles3 glcore d3d11
					#pragma target 2.0

					#pragma vertex UniversalVertexMeta
					#pragma fragment UniversalFragmentMetaSimple

					#pragma shader_feature_local_fragment _EMISSION
					#pragma shader_feature_local_fragment _SPECGLOSSMAP

					#include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
					#include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitMetaPass.hlsl"

					ENDHLSL
				}
				Pass
				{
					Name "Universal2D"
					Tags{ "LightMode" = "Universal2D" }
					Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }

					HLSLPROGRAM
					#pragma only_renderers gles gles3 glcore d3d11
					#pragma target 2.0

					#pragma vertex vert
					#pragma fragment frag
					#pragma shader_feature_local_fragment _ALPHATEST_ON
					#pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON

					#include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
					#include "Packages/com.unity.render-pipelines.universal/Shaders/Utils/Universal2D.hlsl"
					ENDHLSL
				}
	}
		Fallback "Hidden/Universal Render Pipeline/FallbackError"
		}
