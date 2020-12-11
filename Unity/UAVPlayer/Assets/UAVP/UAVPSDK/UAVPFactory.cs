using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

public class UAVPFactory
{
    public static UAVPFoundation GetUAVPlayer() 
    {
        UAVPFoundation player = null;
        if (Application.platform == RuntimePlatform.IPhonePlayer)
        {
            player = new UAVPlayerSource();
        }
        else if (Application.platform == RuntimePlatform.OSXEditor || Application.platform == RuntimePlatform.OSXPlayer)
        {
            player = new UAVPlayerMacOSX();
        }
        else 
        {
            player = null;
        }
        return player;
    }
}
