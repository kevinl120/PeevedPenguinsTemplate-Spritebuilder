//
//  WaitingPenguin.m
//  PeevedPenguins
//
//  Created by Kevin Li on 6/27/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "WaitingPenguin.h"

@implementation WaitingPenguin

- (void)didLoadFromCCB {
    
    // Generate a random number between 0.0 and 2.0
    float delay = (arc4random() % 2000) / 1000.f;
    // Call method to start animation after random delay
    [self performSelector:@selector(startBlinkAndJump) withObject:nil afterDelay:delay];
}


- (void)startBlinkAndJump {
    // The animation manager of each node is stored in the 'animationManager' property
    CCAnimationManager* animationManager = self.animationManager;
    // Timelines can be referenced and run by name
    [animationManager runAnimationsForSequenceNamed:@"BlinkAndJump"];
    
}


@end
