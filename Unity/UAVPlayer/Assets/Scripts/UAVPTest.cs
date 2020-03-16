using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UAVPTest : MonoBehaviour
{
    public Material videoMat = null;
    public string videoPath = null;

    private bool videoMatTexAssigned = false;

    private UAVPlayer player = new UAVPlayer();

    // Start is called before the first frame update
    void Start()
    {
        videoMat.mainTexture = null;
        player.play(videoPath);
    }

    // Update is called once per frame
    void Update()
    {
        if(!videoMatTexAssigned && player.videoTexture)
        {
            videoMat.mainTexture = player.videoTexture;
            videoMatTexAssigned = true;
        }
        if(videoMatTexAssigned && !player.videoTexture)
        {
            videoMat.mainTexture = null;
            videoMatTexAssigned = false;
        }
    }
}
