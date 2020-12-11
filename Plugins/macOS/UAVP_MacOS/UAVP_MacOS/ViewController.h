//
//  ViewController.h
//  UAVP_MacOS
//
//  Created by HanGyo Jeong on 2020/12/11.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
#import <Metal/Metal.h>
#import <VideoToolbox/VideoToolbox.h>

#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#define ONE_FRAME_DURAATION 0.03

static void* AVPlayerItemStatusContext = &AVPlayerItemStatusContext;

@interface ViewController : NSViewController<AVPlayerItemOutputPullDelegate>

@property (weak) IBOutlet NSView *videoPreview;


@end

