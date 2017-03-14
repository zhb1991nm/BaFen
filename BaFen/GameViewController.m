//
//  GameViewController.m
//  BaFen
//
//  Created by zhb on 2017/2/25.
//  Copyright © 2017年 zhb. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"


@implementation GameViewController{
    }

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    
    // Load the SKScene from 'GameScene.sks'
    GameScene *scene = [[GameScene alloc] initWithSize:self.view.frame.size];
    
    // Set the scale mode to scale to fit the window
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    SKView *skView = (SKView *)self.view;
    
    // Present the scene
    [skView presentScene:scene];
    
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
}



- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
