TEXTURE2D(_CameraColorTexture);
SAMPLER(sampler_CameraColorTexture);
float4 _CameraColorTexture_TexelSize;

void Outline_float(float2 UV, float OutlineThickness, float Sensitivity, float4 OutlineColor, out float4 Out)
{
    float halfScaleFloor = floor(OutlineThickness * 0.5);
    float halfScaleCeil = ceil(OutlineThickness * 0.5);
    float2 texelSize = (1.0) / float2(_CameraColorTexture_TexelSize.z, _CameraColorTexture_TexelSize.w);

    float2 uvSamples[4];
    float3 colorSamples[4];

    uvSamples[0] = UV - float2(texelSize.x, texelSize.y) * halfScaleFloor;
    uvSamples[1] = UV + float2(texelSize.x, texelSize.y) * halfScaleCeil;
    uvSamples[2] = UV + float2(texelSize.x * halfScaleCeil, -texelSize.y * halfScaleFloor);
    uvSamples[3] = UV + float2(-texelSize.x * halfScaleFloor, texelSize.y * halfScaleCeil);

    for(int i = 0; i < 4 ; i++)
    {
        colorSamples[i] = SAMPLE_TEXTURE2D(_CameraColorTexture, sampler_CameraColorTexture, uvSamples[i]).rgb;
    }

    float3 finiteDiff0 = colorSamples[1] - colorSamples[0];
    float3 finiteDiff1 = colorSamples[3] - colorSamples[2];
    float edge = sqrt(dot(finiteDiff0, finiteDiff0) + dot(finiteDiff1, finiteDiff1));
	edge = edge > (1/Sensitivity) ? 1 : 0;

    float4 original = SAMPLE_TEXTURE2D(_CameraColorTexture, sampler_CameraColorTexture, uvSamples[0]);
    Out = ((1 - edge) * original) + (edge * lerp(original, OutlineColor,  OutlineColor.a));
}
