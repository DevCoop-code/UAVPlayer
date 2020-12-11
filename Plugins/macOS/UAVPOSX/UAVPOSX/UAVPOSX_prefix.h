//
//  UAVPOSX_prefix.h
//  UAVPOSX
//
//  Created by HanGyo Jeong on 2020/12/11.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#ifndef UAVPOSX_prefix_h
#define UAVPOSX_prefix_h

#ifdef __uavposx
extern "C" {
bool UAVP_CanOutputToTexture(const char* filename);

bool UAVP_PlayerReady();

float UAVP_DurationSeconds();

float UAVP_CurrentSeconds();

void UAVP_VideoExtents(int* w, int* h);

intptr_t UAVP_CurFrameTexture();

int UAVP_InitPlayer();

int UAVP_OpenVideo(const char* filename);

int UAVP_PlayVideo();

int UAVP_PauseVideo();

void UAVP_SeekVideo(int time);

void UAVP_ReleasePlayer();

void UAVP_setUAVPTimeListener(UAVPTimeListener listener);

void UAVP_setUAVPProperty(int type, int param);

}
#endif

#endif /* UAVPOSX_prefix_h */
