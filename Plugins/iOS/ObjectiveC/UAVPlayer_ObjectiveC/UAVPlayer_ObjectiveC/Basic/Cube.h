//
//  Cube.h
//  UAVPlayer_ObjectiveC
//
//  Created by HanGyo Jeong on 2020/03/08.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"

NS_ASSUME_NONNULL_BEGIN

@interface Cube : Node

- (instancetype)init:(id<MTLDevice>)device commandQ:(id<MTLCommandQueue>)commandQ;
@end

NS_ASSUME_NONNULL_END
