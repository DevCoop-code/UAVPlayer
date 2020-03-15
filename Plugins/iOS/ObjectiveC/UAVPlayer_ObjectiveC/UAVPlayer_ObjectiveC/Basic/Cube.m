//
//  Cube.m
//  UAVPlayer_ObjectiveC
//
//  Created by HanGyo Jeong on 2020/03/08.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import "Cube.h"
#import "MetalTexture.h"

@implementation Cube

- (instancetype)init:(id<MTLDevice>)device commandQ:(id<MTLCommandQueue>)commandQ
{
    //Front
    Vertex *A = [[Vertex alloc] init:-1.0 y: 1.0 z:1.0 r:1.0 g:0.0 b:0.0 a:1.0 s:0.25 t:0.25];
    Vertex *B = [[Vertex alloc] init:-1.0 y:-1.0 z:1.0 r:0.0 g:1.0 b:0.0 a:1.0 s:0.25 t:0.50];
    Vertex *C = [[Vertex alloc] init: 1.0 y:-1.0 z:1.0 r:0.0 g:0.0 b:1.0 a:1.0 s:0.50 t:0.50];
    Vertex *D = [[Vertex alloc] init: 1.0 y: 1.0 z:1.0 r:0.1 g:0.6 b:0.4 a:1.0 s:0.50 t:0.25];

    //Left
    Vertex *E = [[Vertex alloc] init:-1.0 y: 1.0 z:-1.0 r:1.0 g:0.0 b:0.0 a:1.0 s:0.00 t:0.25];
    Vertex *F = [[Vertex alloc] init:-1.0 y:-1.0 z:-1.0 r:0.0 g:1.0 b:0.0 a:1.0 s:0.00 t:0.50];
    Vertex *G = [[Vertex alloc] init:-1.0 y:-1.0 z: 1.0 r:0.0 g:0.0 b:1.0 a:1.0 s:0.25 t:0.50];
    Vertex *H = [[Vertex alloc] init:-1.0 y: 1.0 z: 1.0 r:0.1 g:0.6 b:0.4 a:1.0 s:0.25 t:0.25];
    
    //Right
    Vertex *I = [[Vertex alloc] init:1.0 y: 1.0 z: 1.0 r:1.0 g:0.0 b:0.0 a:1.0 s:0.50 t:0.25];
    Vertex *J = [[Vertex alloc] init:1.0 y:-1.0 z: 1.0 r:0.0 g:1.0 b:0.0 a:1.0 s:0.50 t:0.50];
    Vertex *K = [[Vertex alloc] init:1.0 y:-1.0 z:-1.0 r:0.0 g:0.0 b:1.0 a:1.0 s:0.75 t:0.50];
    Vertex *L = [[Vertex alloc] init:1.0 y: 1.0 z:-1.0 r:0.1 g:0.6 b:0.4 a:1.0 s:0.75 t:0.25];
    
    //Top
    Vertex *M = [[Vertex alloc] init:-1.0 y: 1.0 z:-1.0 r:1.0 g:0.0 b:0.0 a:1.0 s:0.25 t:0.00];
    Vertex *N = [[Vertex alloc] init:-1.0 y: 1.0 z: 1.0 r:0.0 g:1.0 b:0.0 a:1.0 s:0.25 t:0.25];
    Vertex *O = [[Vertex alloc] init: 1.0 y: 1.0 z: 1.0 r:0.0 g:0.0 b:1.0 a:1.0 s:0.50 t:0.25];
    Vertex *P = [[Vertex alloc] init: 1.0 y: 1.0 z:-1.0 r:0.1 g:0.6 b:0.4 a:1.0 s:0.50 t:0.00];
    
    //Bottom
    Vertex *Q = [[Vertex alloc] init:-1.0 y:-1.0 z: 1.0 r:1.0 g:0.0 b:0.0 a:1.0 s:0.25 t:0.50];
    Vertex *R = [[Vertex alloc] init:-1.0 y:-1.0 z:-1.0 r:0.0 g:1.0 b:0.0 a:1.0 s:0.25 t:0.75];
    Vertex *S = [[Vertex alloc] init: 1.0 y:-1.0 z:-1.0 r:0.0 g:0.0 b:1.0 a:1.0 s:0.50 t:0.75];
    Vertex *T = [[Vertex alloc] init: 1.0 y:-1.0 z: 1.0 r:0.1 g:0.6 b:0.4 a:1.0 s:0.50 t:0.50];
    
    //Back
    Vertex *U = [[Vertex alloc] init: 1.0 y: 1.0 z:-1.0 r:1.0 g:0.0 b:0.0 a:1.0 s:0.75 t:0.25];
    Vertex *V = [[Vertex alloc] init: 1.0 y:-1.0 z:-1.0 r:0.0 g:1.0 b:0.0 a:1.0 s:0.75 t:0.50];
    Vertex *W = [[Vertex alloc] init:-1.0 y:-1.0 z:-1.0 r:0.0 g:0.0 b:1.0 a:1.0 s:1.00 t:0.50];
    Vertex *X = [[Vertex alloc] init:-1.0 y: 1.0 z:-1.0 r:0.1 g:0.6 b:0.4 a:1.0 s:1.00 t:0.25];
    
    NSArray<Vertex *> *verticesArray = @[
    A,B,C ,A,C,D,   //Front
    E,F,G ,E,G,H,   //Left
    I,J,K ,I,K,L,   //Right
    M,N,O ,M,O,P,   //Top
    Q,R,S ,Q,S,T,   //Bottom
    U,V,W ,U,W,X    //Back
    ];

    self = [super init:@"Cube" vertex:verticesArray device:device];
    return self;
}
@end
