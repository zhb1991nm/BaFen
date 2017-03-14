//
//  GameScene.m
//  BaFen
//
//  Created by zhb on 2017/2/25.
//  Copyright © 2017年 zhb. All rights reserved.
//

//skaudionode

#import "GameScene.h"
#import "BaFenNode.h"
#import "GroundNode.h"
#import <AVFoundation/AVFoundation.h>

//static NSArray *groudArray = @[];
static NSString *groudId = @"GROUND";

static CGFloat currentLevel = 0;

static CGFloat moveLevel = 35.0f;

static CGFloat jumpLevel = 60.0f;

static CGFloat bf_acceleration = 0.25f;//加速

static CGFloat bf_start_speed = 0.15f;//初速度系数

static CGFloat bf_speed_walk = 2.0f;//行走速度

static CGFloat bf_speed_jump = 0;

typedef NS_ENUM(NSUInteger, BF_STATE) {
    BF_STATE_GROUND,
    BF_STATE_JUMP,
    BF_STATE_HANG,
};

@implementation GameScene {
//    SKShapeNode *_spinnyNode;
//    SKLabelNode *_label;
    NSArray *groudArray;
    CGFloat location;
    AVAudioRecorder *recorder;
    NSTimer *levelTimer;
    BOOL bf_center;
//    BOOL jumping;
    BOOL walking;
    SKSpriteNode *bfNode;
    BF_STATE bfState;
    NSMutableArray *walkingFrames;
    NSMutableArray *jumpingFrames;
}

#pragma mark - life cycle

-(instancetype)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor whiteColor];
//        self.physicsWorld.contactDelegate = self;
        groudArray = @[@[@0.5,@0.35],@0.15,
                       @[@0.5,@0.35],@0.15,
                       @[@0.1,@0.35],@0.2,
                       @[@0.3,@0.40],@0.2,
                       @[@0.2,@0.45],@0.3,
                       @[@0.2,@0.30],@0.2,
                       @[@0.3,@0.35],@0.2,
                       @[@0.1,@0.45],@0.3];
        walkingFrames = [NSMutableArray array];
        SKTextureAtlas *bfAnimatedAtlas = [SKTextureAtlas atlasNamed:@"bf"];
        NSString *textureName = [NSString stringWithFormat:@"BF%d", 2];
        SKTexture *temp = [bfAnimatedAtlas textureNamed:textureName];
        [walkingFrames addObject:temp ];
        textureName = [NSString stringWithFormat:@"BF%d", 1];
        [bfAnimatedAtlas textureNamed:textureName];
        temp = [bfAnimatedAtlas textureNamed:textureName];
        [walkingFrames addObject:temp];
        textureName = [NSString stringWithFormat:@"BF%d", 3];
        [bfAnimatedAtlas textureNamed:textureName];
        temp = [bfAnimatedAtlas textureNamed:textureName];
        [walkingFrames addObject:temp];
        textureName = [NSString stringWithFormat:@"BF%d", 1];
        [bfAnimatedAtlas textureNamed:textureName];
        temp = [bfAnimatedAtlas textureNamed:textureName];
        [walkingFrames addObject:temp];
        jumpingFrames = [NSMutableArray array];
        for (NSInteger i=5; i <= 6; i++) {
            NSString *textureName = [NSString stringWithFormat:@"BF%ld", i];
            SKTexture *temp = [bfAnimatedAtlas textureNamed:textureName];
            [jumpingFrames addObject:temp];
        }
        
        
        [[AVAudioSession sharedInstance]
         setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
        
        /* 不需要保存录音文件 */
        NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
        
        NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat: 44100.0], AVSampleRateKey,
                                  [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                                  [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
                                  [NSNumber numberWithInt: AVAudioQualityMax], AVEncoderAudioQualityKey,
                                  nil];
        NSError *error;
        recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
        if (recorder)
        {
            [recorder prepareToRecord];
            recorder.meteringEnabled = YES;
            [recorder record];
            levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
        }
        else
        {
            NSLog(@"%@", [error description]);
        }

        
        [self startGame];
    }
    return self;
}


- (void)didMoveToView:(SKView *)view {
    // Setup your scene here
//    NSArray *groudArray = @[@[@1,@1],@[@],@[]];
//    NSArray *gapArray =@[];
    
//    // Get label node from scene and store it for use later
//    _label = (SKLabelNode *)[self childNodeWithName:@"//helloLabel"];
//    
//    _label.alpha = 0.0;
//    [_label runAction:[SKAction fadeInWithDuration:2.0]];
//    
//    CGFloat w = (self.size.width + self.size.height) * 0.05;
//    
//    // Create shape node to use during mouse interaction
//    _spinnyNode = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(w, w) cornerRadius:w * 0.3];
//    _spinnyNode.lineWidth = 2.5;
//    
//    [_spinnyNode runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:M_PI duration:1]]];
//    [_spinnyNode runAction:[SKAction sequence:@[
//                                                [SKAction waitForDuration:0.5],
//                                                [SKAction fadeOutWithDuration:0.5],
//                                                [SKAction removeFromParent],
//                                                ]]];
}

#pragma mark - game control
- (void)startGame
{
    bfState = BF_STATE_GROUND;
    location = 0;
    bf_center = NO;
    walking = NO;
    bf_speed_jump = 0;
    [self removeAllChildren];
    [self createGrounds];
    [self createBaFen];
    [self putBfOnTheGround];
    [self standBaFen];
}

-(void)gameOver{
//    NSError *error;
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    SKAction *sound = [SKAction playSoundFileNamed:@"ding.m4a" waitForCompletion:NO];
    [self runAction:sound];
    [bfNode removeFromParent];
    [self startGame];
}

#pragma mark - create node
-(void)createBack{
    
}

-(void)createGrounds{
    CGFloat x = 0;
    for (NSInteger i = 0; i < groudArray.count ; i++) {
        NSObject *obj = groudArray[i];
        if ([obj isKindOfClass:[NSNumber class]]) {//gap
            CGFloat width = ((NSNumber *)obj).floatValue * self.frame.size.width;
            x += width;
        }else if([obj isKindOfClass:[NSArray class]]){
            NSArray *groundWH = (NSArray *)obj;
            CGFloat width = ((NSNumber *)groundWH[0]).floatValue * self.frame.size.width;
            CGFloat height = ((NSNumber *)groundWH[1]).floatValue * self.frame.size.height;
            [self addGroudWithWidth:width hight:height left:x];
            x += width;
        }
    }
}

-(void)createBaFen{
    if (!bfNode) {
        SKTexture *temp = walkingFrames[1];
        bfNode = [SKSpriteNode spriteNodeWithTexture:temp];
    }
    [self addChild:bfNode];
    bfNode.position = CGPointMake(50, self.frame.size.height * 0.5f);
}

-(void)walkingBaFen{
    [bfNode removeAllActions];
    [bfNode runAction:[SKAction repeatActionForever:
                      [SKAction animateWithTextures:walkingFrames
                                       timePerFrame:0.2f
                                             resize:NO
                                            restore:YES]] withKey:@"walkingInBF"];
    NSLog(@"walk");
}

-(void)jumpingBaFen{
    [bfNode removeAllActions];
    [bfNode runAction:[SKAction repeatActionForever:
                       [SKAction animateWithTextures:jumpingFrames
                                        timePerFrame:0.1f
                                              resize:NO
                                             restore:YES]] withKey:@"jumpingInBF"];
    NSLog(@"jump");
}

-(void)standBaFen{
    [bfNode removeAllActions];
    NSLog(@"stand");
}

#pragma mark - add node
-(void)addGroudWithWidth:(CGFloat)width hight:(CGFloat)height left:(CGFloat)left{
    SKSpriteNode *groud = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor] size:CGSizeMake(width, height)];
    groud.position = CGPointMake(left + width *0.5f, height * 0.5);
    groud.name = [groudId copy];
    [self addChild:groud];
}

#pragma mark - judgement
-(BF_STATE)checkBFState{
    CGFloat bfMaxX = CGRectGetMaxX(bfNode.frame);
    CGFloat bfMinX = CGRectGetMinX(bfNode.frame);
    CGFloat bfMaxY = CGRectGetMaxY(bfNode.frame);
    CGFloat bfMinY = CGRectGetMinY(bfNode.frame);
    CGFloat bfWidth = CGRectGetWidth(bfNode.frame);
    CGFloat bfHeight = CGRectGetHeight(bfNode.frame);
    
    if(bfState == BF_STATE_HANG){
        return BF_STATE_HANG;
    }
    
    __block BF_STATE state = BF_STATE_JUMP;
    [self enumerateChildNodesWithName:groudId usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
        if ([node.name isEqualToString:groudId]) {
            CGFloat nodeMaxX = CGRectGetMaxX(node.frame);
            CGFloat nodeMinX = CGRectGetMinX(node.frame);
            CGFloat nodeMaxY = CGRectGetMaxY(node.frame);
            CGFloat nodeMinY = CGRectGetMinY(node.frame);
            if (bfMaxX >= nodeMinX && bfMaxX<= nodeMaxX + bfWidth) {
                *stop = YES;
                
                if (bfMaxX <= nodeMinX + 5 && bfMinY <= nodeMaxY) {//可挣扎状态
                    state = BF_STATE_HANG;
                    bfNode.position = CGPointMake(nodeMinX - bfWidth * 0.5f, bfNode.position.y);//设置在边缘
                }else if (bfMinY <= nodeMaxY){
                    state = BF_STATE_GROUND;
                    bfNode.position = CGPointMake(bfNode.position.x, nodeMaxY + bfHeight * 0.5f);
                }
            }
        }
    }];
    return state;
    
}


-(BOOL)bfOnTheGround{
    __block BOOL ret = NO;
    [self enumerateChildNodesWithName:groudId usingBlock:^(SKNode *node, BOOL *stop) {
        if (CGRectGetMinX(node.frame) < CGRectGetMaxX(bfNode.frame)
            && CGRectGetMaxX(node.frame) > CGRectGetMinX(bfNode.frame)
            && CGRectGetMaxY(node.frame) >= CGRectGetMinY(bfNode.frame)){
            ret = YES;
            *stop = YES;
            bfNode.position = CGPointMake(bfNode.position.x, CGRectGetMaxY(node.frame) + bfNode.frame.size.height * 0.5f);
        }
    }];
    return ret;
}

-(void)putBfOnTheGround{
    CGFloat bfNodeHeight = bfNode.frame.size.height;
    bfNode.position = CGPointMake(bfNode.position.x, self.frame.size.height * 0.35 + bfNodeHeight * 0.5f);
}

#pragma mark - update
-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered8
    //设置横向移动
    if (bfState != BF_STATE_HANG) {
        if (currentLevel > moveLevel) {
            if (bf_center) {
                [self updateGrounds];
            }else{
                [self updateBF];
            }
            location ++;
            if (bfState != BF_STATE_JUMP) {
                if (currentLevel < jumpLevel) {
                    if(!walking){
                        
                        [self walkingBaFen];
                        walking = YES;
                    }
                }
            }
        }else{
            if (bfState != BF_STATE_JUMP) {
                if (walking) {
                    [self standBaFen];
                    walking = NO;
                }
            }
        }
    }
    
}

-(void)updateBF {
    bfNode.position = CGPointMake(bfNode.position.x + bf_speed_walk, bfNode.position.y);
    if (bfNode.position.x >= self.frame.size.width * 0.5) {
        bf_center = true;
    }
}

-(void)updateGrounds{
    [self enumerateChildNodesWithName:groudId usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x + node.frame.size.width / 2 < 0)
            [node removeFromParent];
        node.position = CGPointMake(node.position.x - bf_speed_walk, node.position.y);
    }];
    
}
//BF_STATE_GROUND,
//BF_STATE_JUMP,
//BF_STATE_HANG,
-(void)didEvaluateActions{
    
    
    
    BF_STATE _bfState = [self checkBFState];
    //状态判断
    if (_bfState == BF_STATE_GROUND) {
        if (bfState == BF_STATE_JUMP) {//着陆
            bf_speed_jump = 0;
            walking = YES;
        }else if(currentLevel > jumpLevel) {
            NSLog(@"%f",currentLevel);
//            if (currentLevel - jumpLevel > 10) {
//                SKAction *sound = [SKAction playSoundFileNamed:@"jump.wav" waitForCompletion:NO];
//                [self runAction:sound];
//            }
            SKAction *sound = [SKAction playSoundFileNamed:@"jump.wav" waitForCompletion:NO];
            [self runAction:sound];
            CGFloat levelDif = currentLevel - jumpLevel;
            bf_speed_jump = levelDif * bf_start_speed;//跳跃初速
            bfNode.position = CGPointMake(bfNode.position.x , bfNode.position.y + bf_speed_jump);
            [self jumpingBaFen];
        }
    }else{
        if (bfState == BF_STATE_HANG && currentLevel > jumpLevel) {//挣扎
            bf_speed_jump = 0;
        }else{
            if (_bfState != BF_STATE_JUMP && bfState == BF_STATE_JUMP) {
                [self jumpingBaFen];
            }
            bf_speed_jump -= bf_acceleration;
            bfNode.position = CGPointMake(bfNode.position.x , bfNode.position.y + bf_speed_jump);
        }
    }
    bfState = _bfState;
    
    
//    if (onTheGround) {//不在跳跃状态中
//        if (jumping) {
//            jumping = NO;
//            bf_speed_jump = 0;
//        }else if (currentLevel > jumpLevel) {
//            if (!jumping && currentLevel - jumpLevel > 10) {
//                SKAction *sound = [SKAction playSoundFileNamed:@"jump.wav" waitForCompletion:NO];
//                [self runAction:sound];
//            }
//            jumping = YES;
//            CGFloat levelDif = currentLevel - jumpLevel;
//            bf_speed_jump = levelDif * bf_start_speed;//跳跃初速
//            bfNode.position = CGPointMake(bfNode.position.x , bfNode.position.y + bf_speed_jump);
//        }
//    }else{
//        jumping = YES;
//        bf_speed_jump -= bf_acceleration;
//        bfNode.position = CGPointMake(bfNode.position.x , bfNode.position.y + bf_speed_jump);
//    }
    
    //    if (!onTheGround) {
    //        if () {
    //            jumping = NO;
    //        }else{
    //
    //        }
    //    }
    //
    //    if (onTheGround && currentLevel > jumpLevel) {
    //        jumping = YES;
    //        CGFloat levelDif = currentLevel - jumpLevel;
    //        bf_speed_jump = levelDif * bf_start_speed;//跳跃初速
    //        bfNode.position = CGPointMake(bfNode.position.x , bfNode.position.y + bf_speed_jump);
    //    }
    if (CGRectGetMaxY(bfNode.frame) < 0) {
        [self gameOver];
    }
}

#pragma mark - event response
- (void)levelTimerCallback:(NSTimer *)timer {
    [recorder updateMeters];
    
    float   level;                // The linear 0.0 .. 1.0 value we need.
    float   minDecibels = -80.0f; // Or use -60dB, which I measured in a silent room.
    float   decibels    = [recorder averagePowerForChannel:0];
    
    if (decibels < minDecibels)
    {
        level = 0.0f;
    }
    else if (decibels >= 0.0f)
    {
        level = 1.0f;
    }
    else
    {
        float   root            = 2.0f;
        float   minAmp          = powf(10.0f, 0.05f * minDecibels);
        float   inverseAmpRange = 1.0f / (1.0f - minAmp);
        float   amp             = powf(10.0f, 0.05f * decibels);
        float   adjAmp          = (amp - minAmp) * inverseAmpRange;
        
        level = powf(adjAmp, 1.0f / root);
    }
    currentLevel = level * 120;
//    NSLog(@"%f",currentLevel);
}


@end
