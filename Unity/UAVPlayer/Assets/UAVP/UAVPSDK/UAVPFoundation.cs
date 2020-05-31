using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class UAVPFoundation
{   
    public bool mute;                       // Set whether to turn off the audio or not
    public bool loop;                       // Set the when the video reaches the end poosition it jumps to the start position and plays again
    public bool autoPlayback;               // Set the playing video automatically when app is started
    public UAVPLogLevel logLevelForDebugging;   // Set Log level for debugging
    // Set the audio volume
    private float _volume = 1.0f;
    public float volume
    {
        get
        {
            return _volume;
        }
        set
        {
            if(_volume > 100.0f)
            {
                _volume = 1.0f;
            }
            else if(_volume < 0.0f)
            {
                _volume = 0.0f;
            }
            else
            {
                _volume = value / 100.0f;
            }
        }
    }

    /*
    Initializes the player
    - logLevel: Set the LogLevel(Debug, Source, Porting, System)
    */
    public virtual UAVPError InitPlayer(UAVPLogLevel logLevel) { return UAVPError.UAVP_ERROR_NONE; }

    /*
    Open the media with player
    - URI: Media Location 
    - mediaType: Types of media
    */
    public virtual UAVPError OpenMediaStreaming(string URI, UAVPMediaType mediaType) { return UAVPError.UAVP_ERROR_NONE; }

    /*
    Playing the Media
    */
    abstract public void Start();

    /*
    Pause the Media
    */
    abstract public void Pause();

    /*
    Resumes the Media
    */
    abstract public void Resume();

    /*
    Release the Player
    */
    abstract public void Release();

    /*
    Returns the current time of the playback
    - return: Time currently being played
    */
    abstract public int GetCurrentTime();

    /*
    Returns the whole playable time of the media
    - return: Whole playable time
    */
    abstract public int GetTotalTime();
}
