//
//  GroundNode.m
//  BaFen
//
//  Created by zhb on 2017/2/25.
//  Copyright © 2017年 zhb. All rights reserved.
//

#import "GroundNode.h"

@implementation GroundNode

-(instancetype)init{
    if (!self) {
        self = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor] size:CGSizeMake(8,8)];
    }
    return self;
}

@end
