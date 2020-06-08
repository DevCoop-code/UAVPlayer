using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UAVP : MonoBehaviour
{
    public bool autoPlay = true;

    public bool loop = false;

    public bool mute = false;

    public Material videoMat = null;
    public RawImage videoRawImage = null;

    /*
    If the media type is Streaming, 
    mediaURI is like http://~~~~.mpd or .m3u8
    If the media type is Local or StreamingAssets,
    mediaURI is like [directoryName]/[FileName].mp4 or .avi
    */
    [Tooltip("If you want to play Streaming video, you should input the URL, But if you play the video in StreamingAssets or Local, you should put the Location Path")]
    public string mediaURI = null;

    public Sprite playBtnSpirte;

    public Sprite pauseBtnSpirte;

    public Image startPauseBtn;

    public UAVPLogLevel logLevel;

    private bool videoTexAssigned = false;

    private UAVPlayerSource player = (UAVPlayerSource)UAVPFactory.GetUAVPlayer();

    // Start is called before the first frame update
    void Start()
    {
        if(videoMat != null)
        {
            videoMat.mainTexture = null;
        }

        if(player != null)
        {
            Debug.Log("Start to play [" + mediaURI + "]");
            UAVPError error = player.InitPlayer(logLevel);
            if(error == UAVPError.UAVP_ERROR_NONE)
            {
                player.OpenMedia(mediaURI, UAVPMediaType.UAVP_Local_Media);
            }
            else
            {
                player = null;
            }
        }
        else
        {
            Debug.Log("Player is null");
        }
    }

    // Update is called once per frame
    void Update()
    {
        if(player != null)
        {
            if (!videoTexAssigned && player.videoTexture)
            {
                if (videoMat != null)
                    videoMat.mainTexture = player.videoTexture;

                if (videoRawImage != null)
                    videoRawImage.GetComponent<RawImage>().texture = player.videoTexture;
                
                videoTexAssigned = true;
            }
            if (videoTexAssigned && !player.videoTexture)
            {
                if (videoMat != null)
                    videoMat.mainTexture = null;
                if (videoRawImage != null)
                    videoRawImage.GetComponent<RawImage>().texture = null;

                videoTexAssigned = false;
            }
        }
    }

    private void OnDestroy()
    {
        if (player != null)
        {
            player.Release();
        }

        player = null;
    }

    public void OnPlay()
    {
        Debug.Log("OnPlay");
        if (player != null)
        {
            player.Start();
        }
    }

    public void OnPause()
    {
        Debug.Log("OnPause");
        if (player != null)
        {
            player.Pause();
        }
    }

    public void OnResume()
    {
        Debug.Log("OnResume");
        if (player != null)
        {
            player.Resume();
        }
    }

    public void ToggleStartPause()
    {
        Debug.Log("OnToggleStartPause");
        switch(player.playerStatus)
        {
            case UAVPStatus.UAVP_START:
                {
                    OnPause();

                    if (startPauseBtn != null && playBtnSpirte != null)
                    {
                        startPauseBtn.sprite = playBtnSpirte;
                    }
                }
            break;

            case UAVPStatus.UAVP_PAUSE:
                {
                    OnPlay();

                    if (startPauseBtn != null && pauseBtnSpirte != null)
                    {
                        startPauseBtn.sprite = pauseBtnSpirte;
                    }
                }
            break;
        }
    }
}
