using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

public class RenderTargetCreator : UIBehaviour
{
    public Camera worldCamera;
    public int verticalResolution = 256;

    private RenderTexture renderTarget;

    void SetTarget()
    {
        if (!worldCamera)
            return;

        var targetImage = GetComponent<RawImage>();
        var rect = targetImage.rectTransform.rect;
        float aspect = rect.width / rect.height;
        int width = Mathf.RoundToInt(aspect * verticalResolution);

        if (renderTarget)
            renderTarget.Release();

        RenderTextureDescriptor desc = new RenderTextureDescriptor(width, verticalResolution, RenderTextureFormat.DefaultHDR);

        desc.useMipMap = false;
        desc.depthBufferBits = 16;

        renderTarget = new RenderTexture(desc);
        renderTarget.filterMode = FilterMode.Point;
        renderTarget.anisoLevel = 0;
        renderTarget.Create();

        worldCamera.targetTexture = renderTarget;
        targetImage.texture = renderTarget;
    }

#if UNITY_EDITOR
    protected override void OnValidate()
    {
        base.OnValidate();
        if (enabled)
            SetTarget();
    }
#endif

    protected override void Awake()
    {
        base.Awake();
        if (enabled)
            SetTarget();
    }

    protected override void OnRectTransformDimensionsChange()
    {
        base.OnRectTransformDimensionsChange();
        if (enabled)
            SetTarget();
    }
}
