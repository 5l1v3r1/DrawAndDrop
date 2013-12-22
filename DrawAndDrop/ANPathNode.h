//
//  ANPathNode.h
//  DrawAndDrop
//
//  Created by Alex Nichol on 12/22/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "ANConvexPath.h"

#define kANPathNodeBuffer 512

@interface ANPathNode : SKSpriteNode {
    ANConvexPath * path;
    CGPoint globalTranslation;
}

- (id)initWithPoint:(CGPoint)initialPoint toPoint:(CGPoint)point;

/**
 * After editing the path, this will create
 * and assign the physicsBody property.
 */
- (void)createPhysicsBody;

/**
 * Adds a point to the path.
 */
- (void)addPoint:(CGPoint)p;

@end
