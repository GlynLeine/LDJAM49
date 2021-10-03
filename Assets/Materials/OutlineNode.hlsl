TEXTURE2D(_CameraColorTexture);
SAMPLER(sampler_CameraColorTexture);
float4 _CameraColorTexture_TexelSize;

TEXTURE2D(_CameraDepthTexture);
SAMPLER(sampler_CameraDepthTexture);

void Outline_float(float2 texCoords, float thickness, float depthScalar, float colorScalar, float4 outlineColor, out float4 result)
{
    float halfScaleFloor = floor(thickness * 0.5);
    float halfScaleCeil = ceil(thickness * 0.5);
    float2 texelSize = (1.0) / float2(_CameraColorTexture_TexelSize.z, _CameraColorTexture_TexelSize.w);

    float2 sampleCoords[4];
    float depthSamples[4];
    float3 colorSamples[4];

    sampleCoords[0] = texCoords - float2(texelSize.x, texelSize.y) * halfScaleFloor;
    sampleCoords[1] = texCoords + float2(texelSize.x, texelSize.y) * halfScaleCeil;
    sampleCoords[2] = texCoords + float2(texelSize.x * halfScaleCeil, -texelSize.y * halfScaleFloor);
    sampleCoords[3] = texCoords + float2(-texelSize.x * halfScaleFloor, texelSize.y * halfScaleCeil);

    for(int i = 0; i < 4 ; i++)
    {
        depthSamples[i] = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, sampleCoords[i]).r;
        colorSamples[i] = SAMPLE_TEXTURE2D(_CameraColorTexture, sampler_CameraColorTexture, sampleCoords[i]).rgb;
    }

    float depthDiff0 = depthSamples[1] - depthSamples[0];
    float depthDiff1 = depthSamples[3] - depthSamples[2];
    float edgeDepth = sqrt(pow(depthDiff0, 2.0) + pow(depthDiff1, 2.0)) * 100.0;
    float depthThreshold = (1.0 / depthScalar) * depthSamples[0];
    edgeDepth = edgeDepth > depthThreshold ? 1.0 : 0,0;

    float3 colorDiff0 = colorSamples[1] - colorSamples[0];
    float3 colorDiff1 = colorSamples[3] - colorSamples[2];
    float edge = sqrt(dot(colorDiff0, colorDiff0) + dot(colorDiff1, colorDiff1));
	edge = edge > (1.0/colorScalar) ? 1.0 : 0.0;

    edge = max(edgeDepth, edge);

    float4 original = SAMPLE_TEXTURE2D(_CameraColorTexture, sampler_CameraColorTexture, sampleCoords[0]);
    result = ((1.0 - edge) * original) + (edge * lerp(original, outlineColor,  outlineColor.a));
}
