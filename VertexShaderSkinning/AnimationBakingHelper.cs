using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;

public class BakedAnimation
{
    public string Name;
    public Texture2D AnimeTexture;
    public float Length;
    public float Interval;
}

public class AnimationBakingHelper
{
    private static void SampleAnimation(
        GameObject go, AnimationClip clip, float time, SkinnedMeshRenderer smr,
        Color[] dest)
    {
        clip.SampleAnimation(go, time);
        var bones = smr.bones;
        var bindPoses = smr.sharedMesh.bindposes;
        var boneIndex = 0;
        var index = 0;
        foreach (var bone in bones)
        {
            var mat = bone.transform.localToWorldMatrix * bindPoses[boneIndex++];
            boneIndex++;
            dest[index++] = mat.GetColumn(0);
            dest[index++] = mat.GetColumn(1);
            dest[index++] = mat.GetColumn(2);
            dest[index++] = mat.GetColumn(3);
        }
    }

    public static BakedAnimation Bake(string name, GameObject rig, AnimationClip clip, float sampleRate = 30)
    {
        var smr = rig.GetComponentInChildren<SkinnedMeshRenderer>();
        if (smr == null)
        {
            throw new NullReferenceException("Cannot find SkinnedMeshRenderer");
        }
        float timeInc = 1.0f / sampleRate;
        float time = 0f;
        var boneMatrix = new Color[smr.bones.Length * 4];
        int sampleNum = Mathf.CeilToInt(clip.length / timeInc);
        var frameWidth = smr.bones.Length * 4;
        var tex = new Texture2D(frameWidth, sampleNum, TextureFormat.RGBAHalf, 0, true, false);
        int sampleIndex = 0;
        for (; time < clip.length; time += timeInc)
        {
            SampleAnimation(rig, clip, time, smr, boneMatrix);
            tex.SetPixels(0, sampleIndex++, frameWidth, 1, boneMatrix);
        }
        if (time != clip.length)
        {
            SampleAnimation(rig, clip, time, smr, boneMatrix);
            tex.SetPixels(0, sampleIndex++, frameWidth, 1, boneMatrix);
        }
        tex.Apply();
        var anime = new BakedAnimation();
        anime.Name = name;
        anime.Length = clip.length;
        anime.Interval = timeInc;
        anime.AnimeTexture = tex;
        return anime;
    }
}
