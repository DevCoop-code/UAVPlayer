using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// Debugging Log Level
public enum UAVPLogLevel
{
    Debug = 0,      // Level of UAVP Script
    Source = 1,     // Level of Unity Script
    Porting = 2,    // Level of Plugin
    System = 3      // Level of Frameworks
};

// Error Types
public enum UAVPError
{
    UAVP_ERROR_NONE = 0         // No Error
}

// Media Types
public enum UAVPMediaType
{
    UAVP_Streaming_Media = 0,       // Streaming Media(like HLS, Dash, ....)
    UAVP_Local_Media = 1            // Local Media(Media in StreamingAssets Directory)
}