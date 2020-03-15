//
//  ViewController.m
//  UAVPlayer_ObjectiveC
//
//  Created by HanGyo Jeong on 2020/03/04.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import "MySceneViewController.h"

@interface MySceneViewController ()

@end

@implementation MySceneViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _worldModelMatrix = [[Matrix4 alloc] init];
    [_worldModelMatrix translate:0.0 y:0.0 z:-4.0];
    [_worldModelMatrix rotateAroundX:[Matrix4 degreesToRad:25] y:0.0 z:0.0];
    
    _objectToDraw = [[Cube alloc]init:[super device] commandQ:[super commandQueue]];
    super.metalViewControllerDelegate = self;
}

- (void)renderObject:(id<CAMetalDrawable>)drawable
{
    if(nil != drawable && nil != [super commandQueue] && nil != [super pipelineState])
    {
        [_objectToDraw render:[super commandQueue]
          renderPipelineState:[super pipelineState]
                     drawable:drawable
                     mvMatrix:_worldModelMatrix
             projectionMatrix:[super projectionMatrix]
                   clearColor:nil];
    }
    else
    {
        NSLog(@"some variables are not setted");
    }
}

@end
