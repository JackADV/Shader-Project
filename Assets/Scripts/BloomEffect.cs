using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class BloomEffect : MonoBehaviour
{
    [Range(1, 16)]
    public int iterations = 1;
    // This method manages temporary textures. It creates, caching and destroy them as needed
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        int width = source.width / 2;
        int height = source.height / 2;
        RenderTextureFormat format = source.format;
        // Blurring does not require the use of the depth filter so thats why the 3rd parameter is a zero
        RenderTexture currentDestination = RenderTexture.GetTemporary(width, height, 0, format);

        for (int i = 1; i < iterations; i++)
        {
            width /= 2;
            height /= 2;
            currentDestination = RenderTexture.GetTemporary(width, height, 0, format);

        }
        // Graphics.Blit(source, destination);
        Graphics.Blit(source, currentDestination);
        RenderTexture currentSource = currentDestination;
        Graphics.Blit(currentSource, destination);
        RenderTexture.ReleaseTemporary(currentSource);
    }
}
