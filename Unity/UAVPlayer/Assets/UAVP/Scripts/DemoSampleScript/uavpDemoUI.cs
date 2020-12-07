using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class uavpDemoUI : MonoBehaviour
{
    public Text playPauseBtn;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void ChangePlayStateButton()
    {
        playPauseBtn.text = "Pause";
    }

    public void ChangePauseStateButton()
    {
        playPauseBtn.text = "Play";
    }
}
