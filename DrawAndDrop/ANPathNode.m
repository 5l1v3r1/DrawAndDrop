//
//  ANPathNode.m
//  DrawAndDrop
//
//  Created by Alex Nichol on 12/22/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "ANPathNode.h"

@interface ANPathNode (Private)

- (void)updateFromPath;

@end

@implementation ANPathNode

- (id)initWithPoint:(CGPoint)initialPoint toPoint:(CGPoint)point {
    if ((self = [super init])) {
        path = [[ANConvexPath alloc] initWithStart:initialPoint dest:point];
        [self updateFromPath];
    }
    return self;
}

- (void)createPhysicsBody {
    CGPoint central = [path centralPoint];
    globalTranslation = central;
    central.x *= -1;
    central.y *= -1;
    [path translate:central];
    [path convexPathForCount:12];
    [self updateFromPath];
    
    CGRect bounding = path.boundingBox;
    CGPathRef bodyPath = [path createTranslatedPath:CGPointMake(-(bounding.size.width / 2.0) - bounding.origin.x,
                                                                -(bounding.size.height / 2.0) - bounding.origin.y)];
    self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:bodyPath];
    CGPathRelease(bodyPath);
}

- (void)addPoint:(CGPoint)p {
    [path addPoint:p];
    [self updateFromPath];
}

#pragma mark - Private -

- (void)updateFromPath {
    UIImage * image = path.generateImage;
    if (image) {
        CGRect bounding = path.boundingBox;
        self.texture = [SKTexture textureWithImage:image];
        self.position = CGPointMake(bounding.origin.x + (bounding.size.width / 2.0) + globalTranslation.x,
                                    bounding.origin.y + (bounding.size.height / 2.0) + globalTranslation.y);
        self.size = bounding.size;
    } else self.texture = nil;
}

@end
