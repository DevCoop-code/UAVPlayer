//
//  UAVPOSX_prefix.h
//  UAVPOSX
//
//  Created by HanGyo Jeong on 2020/12/11.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//
#ifndef UAVPOSX_prefix_h
#define UAVPOSX_prefix_h

#include "UAVP.h"

#ifdef __cplusplus
extern "C" {
#endif
    bool UAVP_CanOutputToTexture(const char* filename);

    bool UAVP_PlayerReady(void);

    float UAVP_DurationSeconds(void);

    float UAVP_CurrentSeconds(void);

    void UAVP_VideoExtents(int* w, int* h);

    intptr_t UAVP_CurFrameTexture(void);

    int UAVP_InitPlayer(void);

    int UAVP_OpenVideo(const char* filename);

    int UAVP_PlayVideo(void);

    int UAVP_PauseVideo(void);

    void UAVP_SeekVideo(int time);

    void UAVP_ReleasePlayer(void);

    void UAVP_setUAVPTimeListener(UAVPTimeListener listener);

    void UAVP_setUAVPProperty(int type, int param);

    float UAVP_TestCode(void);
#ifdef __cplusplus
}
#endif

#endif /* UAVPOSX_prefix_h */
