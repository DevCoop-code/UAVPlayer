using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class UAVPFoundation
{   
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
    public virtual UAVPError OpenMedia(string URI, UAVPMediaType mediaType) { return UAVPError.UAVP_ERROR_NONE; }

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
}
