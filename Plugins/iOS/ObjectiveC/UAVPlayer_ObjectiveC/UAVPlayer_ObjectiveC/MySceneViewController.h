//
//  ViewController.h
//  UAVPlayer_ObjectiveC
//
//  Created by HanGyo Jeong on 2020/03/04.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetalViewController.h"
#import "Matrix4.h"
#import "Cube.h"

@interface MySceneViewController : MetalViewController<MetalViewControllerDelegate>

@property(nonatomic) Matrix4 *worldModelMatrix;
@property(nonatomic) Cube *objectToDraw;

@end

