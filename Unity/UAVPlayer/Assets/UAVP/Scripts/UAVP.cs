using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using UnityEngine.Events;
using UAVPlayerUtility;

namespace UAVPAPI
{
    public class UAVP : MonoBehaviour
    {
        /*
        Properties
        */
        [SerializeField]
        public bool autoPlay = true;
        [SerializeField]
        public bool loop = false;
        [SerializeField]
        public bool mute = false;

        /*
        Unity Object which is assign Video Texture
        */
        [SerializeField]
        public Material videoMat = null;
        [SerializeField]
        public RawImage videoRawImage = null;
        [SerializeField]
        public Text elapsedTime;
        [SerializeField]
        public Text totalTime;
        [SerializeField]
        public Slider seekbar;

        /*
        If the media type is Streaming, 
        mediaURI is like http://~~~~.mpd or .m3u8
        If the media type is Local or StreamingAssets,
        mediaURI is like [directoryName]/[FileName].mp4 or .avi
        */
        [Tooltip("If you want to play Streaming video, you should input the URL, But if you play the video in StreamingAssets or Local, you should put the Location Path")]
        [SerializeField]
        public string mediaURI = null;      // use Streaming & Local type

        [SerializeField]
        public string assetFileURI = null;

        [SerializeField]
        public int assetFileIndex = 0;

        [SerializeField]
        public string localURI = null;

        private string URI = null;

        [SerializeField]
        public UAVPMediaType mediaPlayType;

        [SerializeField]
        public UAVPLogLevel logLevel;

        [SerializeField]
        public UnityEvent openEvent = new UnityEvent();

        [SerializeField]
        public UnityEvent playEvent = new UnityEvent();

        [SerializeField]
        public UnityEvent pauseEvent = new UnityEvent();

        [SerializeField]
        public UnityEvent endEvent = new UnityEvent();

        private bool videoTexAssigned = false;
        private UAVPFoundation player = (UAVPFoundation)UAVPFactory.GetUAVPlayer();

        private bool isSeeking = false;

        private string uavp_version = "0.1.0";

        // Start is called before the first frame update
        void Start()
        {
            Debug.Log("UAVP Version: " + uavp_version);
            // Initialize the property
            if(seekbar != null) 
            {
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
            }
            if (player != null)
            {
                if (autoPlay)
                {
                    player.setProperty(UAVPProperty.UAVP_AUTOPLAY, 1);
                }
                else
                {
                    player.setProperty(UAVPProperty.UAVP_AUTOPLAY, 0);
                }

                if (loop)
                {
                    player.setProperty(UAVPProperty.UAVP_LOOP, 1);
                }
                else
                {
                    player.setProperty(UAVPProperty.UAVP_LOOP, 0);
                }

                if (mute)
                {
                    player.setProperty(UAVPProperty.UAVP_MUTE, 1);
                }
                else
                {
                    player.setProperty(UAVPProperty.UAVP_MUTE, 0);
                }
            }

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

                UAVPError error = player.InitPlayer(logLevel);
                if(error == UAVPError.UAVP_ERROR_NONE)
                {
                    if (mediaPlayType == UAVPMediaType.UAVP_Streaming_Media)            // Streaming
                    {
                        Debug.Log("Play Streaming");
                        URI = mediaURI;
                    }
                    else if (mediaPlayType == UAVPMediaType.UAVP_StreamingAsset_Media)  // StreamingAsset
                    {
                        if (Application.platform == RuntimePlatform.OSXEditor)
                        {
                            Debug.Log("Play StreamingAsset Media");
                            if (assetFileURI != null)
                                URI = UAVPUtility.GetLocalURI(Application.dataPath + "/StreamingAssets/" + assetFileURI);
                            else
                                URI = null;
                        }
                        else if(Application.platform == RuntimePlatform.IPhonePlayer)
                        {
                            URI = assetFileURI;
                        }
                    }
                    else if (mediaPlayType == UAVPMediaType.UAVP_Local_Media)           // Local
                    {
                        if (Application.platform == RuntimePlatform.OSXEditor)
                        {
                            Debug.Log("Play Local Media");
                            if (localURI != null)
                                URI = UAVPUtility.GetLocalURI(localURI);
                            else
                                URI = null;
                        }
                        else if(Application.platform == RuntimePlatform.IPhonePlayer)
                        {
                            URI = localURI;
                        }
                    }

                    if (URI != null)
                    {
                        Debug.Log("Start to play [" + URI + "]");
                        player.OpenMedia(URI, mediaPlayType);
                    }
                    else
                    {
                        Debug.Log("URI is null");
                    }
                    
                    openEvent.Invoke();
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

        void OnApplicationQuit()
        {
            Debug.Log("Quit the Player");
            if (player != null)
            {
                player.Release();

                player = null;
            }
        }

        private void OnDestroy()
        {
            Debug.Log("Destroy the Player");
            if (player != null)
            {
                player.Release();

                player = null;
            }
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
            if(player != null)
            {
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

                    case UAVPStatus.UAVP_OPEN:
                        {
                            OnPlay();
                        }
                    break;
                }
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
                    if(totalTime != null)
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

                    if(elapsedTime != null)
                        elapsedTime.text = e_hour.ToString() + ":" + e_minuteStr + ":" + e_secondStr;

                    if(seekbar != null)
                    {
                        if (!isSeeking)
                            seekbar.value = elapsedTimeSeconds;
                    }
                break;

                case 2:     // End of Content
                    endEvent.Invoke();
                break;

                case 3:     // Play Event
                    playEvent.Invoke();
                break;

                case 4:     // Pause Event
                    pauseEvent.Invoke();
                break;

                default:

                break;
            }
        }
    }
}