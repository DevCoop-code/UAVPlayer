using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

public class UAVP : MonoBehaviour
{
    /*
    Properties
    */
    public bool autoPlay = true;
    public bool loop = false;
    public bool mute = false;

    /*
    Unity Object which is assign Video Texture
    */
    public Material videoMat = null;
    public RawImage videoRawImage = null;
    public Text elapsedTime;
    public Text totalTime;
    public Slider seekbar;

    /*
    If the media type is Streaming, 
    mediaURI is like http://~~~~.mpd or .m3u8
    If the media type is Local or StreamingAssets,
    mediaURI is like [directoryName]/[FileName].mp4 or .avi
    */
    [Tooltip("If you want to play Streaming video, you should input the URL, But if you play the video in StreamingAssets or Local, you should put the Location Path")]
    public string mediaURI = null;

    public UAVPLogLevel logLevel;

    private bool videoTexAssigned = false;
    private UAVPlayerSource player = (UAVPlayerSource)UAVPFactory.GetUAVPlayer();

    private bool isSeeking = false;

    // Start is called before the first frame update
    void Start()
    {
        // Initialize the property
        EventTrigger eventTrigger = seekbar.gameObject.AddComponent<EventTrigger>();

        // When Click the Slider
        EventTrigger.Entry entry_PointerDown = new EventTrigger.Entry();
        entry_PointerDown.eventID = EventTriggerType.PointerDown;
        entry_PointerDown.callback.AddListener((data) => { OnPointerDown((PointerEventData)data); });
        eventTrigger.triggers.Add(entry_PointerDown);

        // When Touch Up the Slider
        EventTrigger.Entry entry_EndDrag = new EventTrigger.Entry();
        entry_EndDrag.eventID = EventTriggerType.EndDrag;
        entry_EndDrag.callback.AddListener((data) => { OnEndDrag((PointerEventData)data); });
        eventTrigger.triggers.Add(entry_EndDrag);

        if(seekbar != null)
        {
            seekbar.minValue = 0;
        }

        if(videoMat != null)
        {
            videoMat.mainTexture = null;
        }

        if(player != null)
        {
            // Register the Event
            UAVPlayerSource.onEvent += EventNotify;

            Debug.Log("Start to play [" + mediaURI + "]");
            UAVPError error = player.InitPlayer(logLevel);
            if(error == UAVPError.UAVP_ERROR_NONE)
            {
                player.OpenMedia(mediaURI, UAVPMediaType.UAVP_Streaming_Media);
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
                Debug.Log("Assign the Texture");

                if (videoMat != null)
                    videoMat.mainTexture = player.videoTexture;

                if (videoRawImage != null)
                    videoRawImage.GetComponent<RawImage>().texture = player.videoTexture;
                
                videoTexAssigned = true;
            }
            if (videoTexAssigned && !player.videoTexture)
            {
                Debug.Log("Release the Texture");

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

    /*
    Player Behaviour
    */
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

    public void OnSeek()
    {
        Debug.Log("OnSeek");
        if (player != null && seekbar != null)
        {
            player.Seek((int)seekbar.value);
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
                }
            break;

            case UAVPStatus.UAVP_PAUSE:
                {
                    OnPlay();
                }
            break;
        }
    }

    void OnPointerDown(PointerEventData data)
    {
        Debug.Log("Seekbar Pointer Down");

        isSeeking = true;
    }

    void OnEndDrag(PointerEventData data)
    {
        Debug.Log("Seekbar Pointer Up");

        OnSeek();

        isSeeking = false;
    }

    // UAVP Event
    public void EventNotify(int type, float param1, float param2, float param3)
    {
        if (type != 1) 
        {
            Debug.Log("EventNotify, type: " + type + " ,param1: " + param1 + " ,param2: " + param2 + " ,param3: " + param3);
        }

        switch (type)
        {
            case 0:     // Total Media Time(seconds)
                string t_minuteStr = "00";
                string t_secondStr = "00";

                float totalTimeSeconds = param1;
                int t_hour = (int)totalTimeSeconds / 3600;
                int t_minute = (int)(totalTimeSeconds % 3600) / 60;
                int t_second = (int)(totalTimeSeconds % 3600) % 60;
                if(t_minute >=0 && t_minute < 10)
                {
                    t_minuteStr = "0" + t_minute.ToString();
                }
                else
                {
                    t_minuteStr = t_minute.ToString();
                }

                if(t_second >= 0 && t_second < 10)
                {
                    t_secondStr = "0" + t_second.ToString();
                }
                else
                {
                    t_secondStr = t_second.ToString();
                }
                totalTime.text = t_hour.ToString() + ":" + t_minuteStr + ":" + t_secondStr;

                if(seekbar != null)
                    seekbar.maxValue = totalTimeSeconds;
            break;

            case 1:     // Current Media Time(seconds)
                string e_minuteStr = "00";
                string e_secondStr = "00";

                float elapsedTimeSeconds = param1;
                int e_hour = (int)elapsedTimeSeconds / 3600;
                int e_minute = (int)(elapsedTimeSeconds % 3600) / 60;
                int e_second = (int)(elapsedTimeSeconds % 3600) % 60;
                if(e_minute >=0 && e_minute < 10)
                {
                    e_minuteStr = "0" + e_minute.ToString();
                }
                else
                {
                    e_minuteStr = e_minute.ToString();
                }

                if(e_second >= 0 && e_second < 10)
                {
                    e_secondStr = "0" + e_second.ToString();
                }
                else
                {
                    e_secondStr = e_second.ToString();
                }
                elapsedTime.text = e_hour.ToString() + ":" + e_minuteStr + ":" + e_secondStr;

                if(seekbar != null)
                {
                    if (!isSeeking)
                        seekbar.value = elapsedTimeSeconds;
                }
            break;

            default:

            break;
        }
    }
}
