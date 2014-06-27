//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by Kevin Li on 6/25/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"

#import "CCPhysics+ObjectiveChipmunk.h"

@implementation Gameplay {
    
    CCNode *_catapultArm;
    CCNode *_levelNode;
    CCNode *_mouseJointNode;
    CCNode *_contentNode;
    CCNode *_pullbackNode;
    CCNode *_currentPenguin;
    
    CCPhysicsJoint *_penguinCatapultJoint;
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
    _mouseJointNode.physicsBody.collisionMask = @[];
    
    _physicsNode.collisionDelegate = self;
    
}


- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGPoint touchLocation = [touch locationInNode: _contentNode];
    
    // Start catapult dragging when a touch inside of the catapult arm occurs
    if (CGRectContainsPoint([_catapultArm boundingBox], touchLocation)) {
        
        // Move the mouseJointNode to the touch position
        _mouseJointNode.position = touchLocation;
        
        // Setup a spring joint between the mouseJointNode and the catapultArm
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0, 0) anchorB:ccp(34, 138) restLength:0.f stiffness:3000.f damping:150.f];
        
        
        // Create a penguin from the ccb-file
        _currentPenguin = [CCBReader load:@"Penguin"];
        // Initially position it on the scoop. 34, 138 is the postition in the node space of the _catapultArm
        CGPoint penguinPosition = [_catapultArm convertToWorldSpace: ccp(34, 138)];
        // Transform the world postition to the node space to which the penguin will be added (_physicsNode)
        _currentPenguin.position = [_physicsNode convertToNodeSpace:penguinPosition];
        // Add it to the physics world
        [_physicsNode addChild: _currentPenguin];
        // We don't want the penguin to rotate in the scoop
        _currentPenguin.physicsBody.allowsRotation = FALSE;
        
        // Create a joint to keep the penguin fixed to the scoop until the catapult is released
        _penguinCatapultJoint = [CCPhysicsJoint connectedPivotJointWithBodyA: _currentPenguin.physicsBody bodyB: _catapultArm.physicsBody anchorA: _currentPenguin.anchorPointInPoints];
        
    }
    
}


- (void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    
    //Whenever touches move, update the position of the mouseJointNode to the touch position
    CGPoint touchLocation = [touch locationInNode: _contentNode];
    _mouseJointNode.position = touchLocation;
    
}


- (void) releaseCatapult {
    if (_mouseJoint != nil) {
        // Releases the joint and lets the catapult snap back
        [_mouseJoint invalidate];
        _mouseJoint = nil;
        
        // Releases the joint and lets the penguin fly
        [_penguinCatapultJoint invalidate];
        _penguinCatapultJoint = nil;
        
        // After snapping rotation is fine
        _currentPenguin.physicsBody.allowsRotation = TRUE;
        
        // Follow the flying penguin
        CCActionFollow *follow = [CCActionFollow actionWithTarget:_currentPenguin worldBoundary:self.boundingBox];
        [_contentNode runAction:follow];
    }
}


- (void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    // When touches end, meaning the user releases their finger, release the catapult
    [self releaseCatapult];
}


- (void) touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    //When touches are cancelled, meaning the user drags their finger off the screen or onto something else, release the catapult
    [self releaseCatapult];
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


- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair seal:(CCNode *)nodeA wildcard:(CCNode *)nodeB {
    float energy = [pair totalKineticEnergy];
    
    // if energy is large enough, remove the seal
    if (energy > 5000.f) {
        [[_physicsNode space] addPostStepBlock:^{
            [self sealRemoved:nodeA];
        } key:nodeA];
    }
}


- (void) sealRemoved:(CCNode *)seal {
    // Load particle effect
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"SealExplosion"];
    // Make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    // Place the particle effect on the seals position
    explosion.position = seal.position;
    // Add the particle effect to the same node the seal is on
    [seal.parent addChild:explosion];
    
    // finally, remove the destroyed seal
    [seal removeFromParent];
}


- (void) startBlinkAndJump {
    // the animation manager of each node is stored in the 'animationManager' property
    CCAnimationManager* animationManager = self.animationManager;
    // timelines can be referenced and run by name
    [animationManager runAnimationsForSequenceNamed:@"BlinkAndJump"];
}

@end
