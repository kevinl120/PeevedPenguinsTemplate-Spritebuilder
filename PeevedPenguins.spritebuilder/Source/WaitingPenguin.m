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
    self.physicsBody.collisionType = @"seal";
}

@end
