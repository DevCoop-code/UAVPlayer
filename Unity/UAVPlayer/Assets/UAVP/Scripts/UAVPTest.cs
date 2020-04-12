using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UAVPTest : MonoBehaviour
{
    public Material videoMat = null;
    public RawImage videoRaw = null;

    public string videoPath = null;

    private bool videoMatTexAssigned = false;

    private UAVPlayer player = new UAVPlayer();

    // Start is called before the first frame update
    void Start()
    {
        if(videoMat != null)
        {
            videoMat.mainTexture = null;
        }

        if(player != null)
        {
            Debug.Log("Start to play [" + videoPath + "]");
            player.play(videoPath);
        }
        else
        {
            Debug.Log("Player is null");
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (!videoMatTexAssigned && player.videoTexture)
        {
            if (videoMat != null)
                videoMat.mainTexture = player.videoTexture;

            if (videoRaw != null)
                videoRaw.GetComponent<RawImage>().texture = player.videoTexture;
            
            videoMatTexAssigned = true;
        }
        if (videoMatTexAssigned && !player.videoTexture)
        {
            if (videoMat != null)
                videoMat.mainTexture = null;
            if (videoRaw != null)
                videoRaw.GetComponent<RawImage>().texture = player.videoTexture;

            videoMatTexAssigned = false;
        }
    }
}
