//
//  MetalViewController.h
//  UAVPlayer_ObjectiveC
//
//  Created by HanGyo Jeong on 2020/03/04.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

@import UIKit;
@import MetalKit;

NS_ASSUME_NONNULL_BEGIN

@protocol MetalViewControllerDelegate <NSObject>

- (void) updateLogic:(CFTimeInterval) timeSinceLastUpdate;
- (void) renderObject:(id<CAMetalDrawable>) drawable;

@end

@interface MetalViewController : UIViewController

@property(nonatomic, strong) id<MTLDevice>              device;
@property(nonatomic, strong) CAMetalLayer               *metalLayer;
@property(nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property(nonatomic, strong) id<MTLCommandQueue>        commandQueue;

@end

NS_ASSUME_NONNULL_END
