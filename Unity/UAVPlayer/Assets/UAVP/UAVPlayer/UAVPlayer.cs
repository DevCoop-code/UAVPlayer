using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Runtime.InteropServices;

public class UAVPlayer
{
#if UNITY_IPHONE && !UNITY_EDITOR
    [DllImport("__Internal")]
    private static extern bool UAVP_CanOutputToTexture(string videoPath);

    [DllImport("__Internal")]
    private static extern bool UAVP_PlayerReady();

    [DllImport("__Internal")]
    private static extern float UAVP_DurationSeconds();

    [DllImport("__Internal")]
    private static extern void UAVP_VideoExtents(ref int w, ref int h);

    [DllImport("__Internal")]
    private static extern System.IntPtr UAVP_CurFrameTexture();

    [DllImport("__Internal")]
    private static extern bool UAVP_PlayVideo(string videoPath);
#else
    private static bool UAVP_CanOutputToTexture(string videoPath) { return false;  }

    private static bool UAVP_PlayerReady() { return false;  }

    private static float UAVP_DurationSeconds() { return 0.0f; }

    private static void UAVP_VideoExtents(ref int w, ref int h) { }

    private static System.IntPtr UAVP_CurFrameTexture() { return System.IntPtr.Zero; }

    private static bool UAVP_PlayVideo(string videoPath) { return false;  }
#endif

    /*
     *===Properties===
     */
    public bool videoReady
    {
        get
        {
            return UAVP_PlayerReady();
        }
    }

    public float videoDuration
    {
        get
        {
            return UAVP_DurationSeconds();
        }
    }

    public int videoWidth
    {
        get
        {
            int w = 0, h = 0;
            UAVP_VideoExtents(ref w, ref h);
            return w;
        }
    }

    public int videoHeight
    {
        get
        {
            int w = 0, h = 0;
            UAVP_VideoExtents(ref w, ref h);
            return h;
        }
    }

    private Texture2D _videoTexture = null;
    public Texture2D videoTexture
    {
        get
        {
            System.IntPtr nativeTex = videoReady ? UAVP_CurFrameTexture() : System.IntPtr.Zero;
            if(nativeTex != System.IntPtr.Zero)
            {
                if(_videoTexture == null && videoWidth != 0 && videoHeight != 0)
                {
                    Debug.Log("Create Texture width: " + videoWidth + ", height: " + videoHeight);
                    _videoTexture = Texture2D.CreateExternalTexture(videoWidth, videoHeight, TextureFormat.BGRA32, false, false, nativeTex);
                    _videoTexture.filterMode = FilterMode.Bilinear;
                    _videoTexture.wrapMode = TextureWrapMode.Repeat;
                }

                Debug.Log("try update Texture");
                _videoTexture.UpdateExternalTexture(nativeTex);
            }
            else
            {
                Debug.Log("native texture is zero");
                _videoTexture = null;
            }

            return _videoTexture;
        }
    }

    /*
     *===[Functions]===
     */
     public static bool CanOutputToTexture(string videoPath)
    {
        bool canOutputTexture = UAVP_CanOutputToTexture(videoPath);
        if(canOutputTexture)
        {
            Debug.Log("[Unity Player] CanOutputTexture");
        }
        else
        {
            Debug.Log("[Unity Player] Problem to output texture");
        }
        return canOutputTexture;
    }

    public void play(string videoPath)
    {
        Debug.Log("[Unity Player] Player Start to play [" + videoPath + "]");
        if (CanOutputToTexture(videoPath))
            UAVP_PlayVideo(videoPath);
    }
}
