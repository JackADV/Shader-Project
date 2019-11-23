using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[AddComponentMenu("Camera/Blood")]
[RequireComponent(typeof(Camera))]
public class Blood : MonoBehaviour
{
    public Shader shader;
    public float intensity = 1;
    public float bloodFadeIn = 0;
    private Material bloodMaterial;
    public Texture2D blood;


    Material material
    {
        get
        {
            if (bloodMaterial == null)
            {
                bloodMaterial = new Material(shader);
                blood.hideFlags = HideFlags.HideAndDontSave;
            }
            return bloodMaterial;
        }
    }
    void Start()
    {
        if (!SystemInfo.supportsImageEffects)
        {
            enabled = false;
            return;
        }
    }

    private void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        if (shader != null)
        {
            material.SetFloat("_Value1", intensity);
            material.SetFloat("_Value2", bloodFadeIn);
            Graphics.Blit(sourceTexture, destTexture, material);
        }
        else
        {
            Graphics.Blit(sourceTexture, destTexture, material);
        }
    }
    private void OnDisable()
    {
        if (bloodMaterial)
        {
            DestroyImmediate(bloodMaterial);
        }
    }

}
