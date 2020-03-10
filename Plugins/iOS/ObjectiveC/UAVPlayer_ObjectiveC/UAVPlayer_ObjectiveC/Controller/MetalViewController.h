//
//  MetalViewController.h
//  UAVPlayer_ObjectiveC
//
//  Created by HanGyo Jeong on 2020/03/04.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

@import UIKit;
@import MetalKit;
#include "Matrix4.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MetalViewControllerDelegate <NSObject>

- (void) updateLogic:(CFTimeInterval) timeSinceLastUpdate;
- (void) renderObject:(id<CAMetalDrawable>) drawable;

@end

@interface MetalViewController : UIViewController

@property(nonatomic) id<MTLDevice>              device;
@property(nonatomic) CAMetalLayer               *metalLayer;
@property(nonatomic) id<MTLRenderPipelineState> pipelineState;
@property(nonatomic) id<MTLCommandQueue>        commandQueue;
@property(nonatomic) id<MetalViewControllerDelegate> metalViewControllerDelegate;
@property(nonatomic) Matrix4 *projectionMatrix;

@end

NS_ASSUME_NONNULL_END
