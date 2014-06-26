//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by Kevin Li on 6/25/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"

@implementation Gameplay {
    
    CCNode *_catapultArm;
    CCNode *_levelNode;
    CCNode *_mouseJointNode;
    CCNode* _contentNode;
    CCNode* _pullbackNode;
    
    CCPhysicsJoint *_mouseJoint;
    
    CCPhysicsNode *_physicsNode;
}

- (void) didLoadFromCCB {
    // Is called when CCB file has completed loading
    
    // Tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode addChild:level];
    
    // Visualize physics bodies and joints
    _physicsNode.debugDraw = TRUE;
    
    // Nothing shall collide with our invisible nodes
    _pullbackNode.physicsBody.collisionMask = @[];
    _mouseJointNode
}


- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    // Called on every touch in this scene
    [self launchPenguin];
}


- (void) launchPenguin {
    // Loads the Penguin.ccb  we have set up in Spritebuilder
    CCNode* penguin = [CCBReader load:@"Penguin"];
    // Position the penguin at the bowl of the catapult
    penguin.position = ccpAdd(_catapultArm.position, ccp(16, 50));
    
    // Add the penguin to the physicsNode of this scene (because it has physics enabled)
    [_physicsNode addChild:penguin];
    
    // Manually create and apply a force to launch the penguin
    CGPoint launchDirection = ccp(1,0);
    CGPoint force = ccpMult(launchDirection, 8000);
    [penguin.physicsBody applyForce:force];
    
    // Ensure followed object is in visible are when starting
    self.position = ccp(0, 0);
    CCActionFollow *follow = [CCActionFollow actionWithTarget:penguin worldBoundary:self.boundingBox];
    [_contentNode runAction:follow];
}


- (void) retry {
    // Reload this level
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
}

@end
