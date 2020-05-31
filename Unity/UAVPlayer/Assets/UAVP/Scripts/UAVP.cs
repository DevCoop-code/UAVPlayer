using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UAVP : MonoBehaviour
{
    public Material videoMat = null;
    public RawImage videoRawImage = null;

    /*
    If the media type is Streaming, 
    mediaURI is like http://~~~~.mpd or .m3u8
    If the media type is Local or StreamingAssets,
    mediaURI is like [directoryName]/[FileName].mp4 or .avi
    */
    public string mediaURI = null;

    public UAVPLogLevel logLevel;

    private bool videoTexAssigned = false;

    private UAVPlayerSource player = new UAVPlayerSource();

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

    private void OnDestroy()
    {
        if (player != null)
        {
            player.Release();
        }

        player = null;
    }

    public void OnPause()
    {
        if (player != null)
        {
            player.Pause();
        }
    }

    public void OnResume()
    {
        if (player != null)
        {
            player.Resume();
        }
    }
}
