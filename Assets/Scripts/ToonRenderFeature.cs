using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ToonRenderFeature : ScriptableRendererFeature
{
    class ToonPass : ScriptableRenderPass
    {
        public RenderTargetIdentifier srcTarget;
        public RenderTargetHandle dstTarget;
        public Material material = null;
        private RenderTargetHandle tmpTarget;

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get("_OutlinePass");

            RenderTextureDescriptor opaqueDescriptor = renderingData.cameraData.cameraTargetDescriptor;
            opaqueDescriptor.depthBufferBits = 0;

            if (dstTarget == RenderTargetHandle.CameraTarget)
            {
                cmd.GetTemporaryRT(tmpTarget.id, opaqueDescriptor, FilterMode.Point);

                Blit(cmd, srcTarget, tmpTarget.Identifier(), material, 0);
                Blit(cmd, tmpTarget.Identifier(), srcTarget);
            }
            else
                Blit(cmd, srcTarget, dstTarget.Identifier(), material, 0);

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            if (dstTarget == RenderTargetHandle.CameraTarget)
                cmd.ReleaseTemporaryRT(tmpTarget.id);
        }
    }

    public Material material = null;
    private ToonPass m_outlinePass;

    public override void Create()
    {
        m_outlinePass = new ToonPass();
        m_outlinePass.material = material;
        m_outlinePass.renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        m_outlinePass.srcTarget = renderer.cameraColorTarget;
        m_outlinePass.dstTarget = RenderTargetHandle.CameraTarget;
        renderer.EnqueuePass(m_outlinePass);
    }
}
