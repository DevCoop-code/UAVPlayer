using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Runtime.InteropServices;

public class UAVPlayerSource
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
    private static void UAVP_InitPlayer() { }

    [DllImport("__Internal")]
    private static extern bool UAVP_PlayVideo(string videoPath);

    [DllImport("__Internal")]
    private static void UAVP_PauseVideo() { }

    [DllImport("__Internal")]
    private static void UAVP_ResumeVideo() { }

    [DllImport("__Internal")]
    private static void UAVP_ReleasePlayer() { }

#else
    private static bool UAVP_CanOutputToTexture(string videoPath) { return false;  }

    private static bool UAVP_PlayerReady() { return false;  }

    private static float UAVP_DurationSeconds() { return 0.0f; }

    private static void UAVP_VideoExtents(ref int w, ref int h) { }

    private static System.IntPtr UAVP_CurFrameTexture() { return System.IntPtr.Zero; }

    private static void UAVP_InitPlayer() { }

    private static bool UAVP_PlayVideo(string videoPath) { return false;  }

    private static void UAVP_PauseVideo() { }

    private static void UAVP_ResumeVideo() { }

    private static void UAVP_ReleasePlayer() { }
#endif
    
     public UAVPlayerSource()
    {
        Debug.Log("[UAVPlayer_Souce] Init");

        UAVP_InitPlayer();
    }

    // Check whether the Media is playing or not
    public bool videoReady
    {
        get
        {
            return UAVP_PlayerReady();
        }
    }

    // Return the whole playable time of the media
    public float videoDuration
    {
        get
        {
            return UAVP_DurationSeconds();
        }
    }

    // Return the media texture width
    public int videoWidth
    {
        get
        {
            int w = 0, h = 0;
            UAVP_VideoExtents(ref w, ref h);
            return w;
        }
    }

    // Return the media texture height
    public int videoHeight
    {
        get
        {
            int w = 0, h = 0;
            UAVP_VideoExtents(ref w, ref h);
            return h;
        }
    }

    // Video Texture
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
                    Debug.Log("[UAVPlayer] Create Texture width: " + videoWidth + ", height: " + videoHeight);
                    _videoTexture = Texture2D.CreateExternalTexture(videoWidth, videoHeight, TextureFormat.BGRA32, false, false, nativeTex);
                    _videoTexture.filterMode = FilterMode.Bilinear;
                    _videoTexture.wrapMode = TextureWrapMode.Repeat;
                }

                Debug.Log("[UAVPlayer] try update Texture");
                _videoTexture.UpdateExternalTexture(nativeTex);
            }
            else
            {
                Debug.Log("[UAVPlayer] native texture is zero");
                _videoTexture = null;
            }

            return _videoTexture;
        }
    }

    // Check the whether player can play media or not
    public static bool CanOutputToTexture(string videoPath)
    {
        bool canOutputTexture = UAVP_CanOutputToTexture(videoPath);
        if(canOutputTexture)
        {
            Debug.Log("[UAVPlayer] Player can play the media");
        }
        else
        {
            Debug.Log("[UAVPlayer] Player cannot play the media");
        }
        return canOutputTexture;
    }

    // Play the Player
    public void play(string videoPath)
    {
        Debug.Log("[UAVPlayer_Play] URL[" + videoPath + "]");
        if (CanOutputToTexture(videoPath))
            UAVP_PlayVideo(videoPath);
    }

    // Pause the Player
    public void pause()
    {
        Debug.Log("[UAVPlayer_Pause]");
        if (videoReady)
            UAVP_PauseVideo();
    }

    // Resume the Player
    public void resume()
    {
        Debug.Log("[UAVPlayer_Resume]");

        UAVP_ResumeVideo();
    }

    // Release the Player
    public void release()
    {
        Debug.Log("[UAVPlayer_Release]");
        UAVP_ReleasePlayer();
    }
}
