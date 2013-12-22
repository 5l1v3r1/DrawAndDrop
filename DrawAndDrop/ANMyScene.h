//
//  ANMyScene.h
//  DrawAndDrop
//

//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "ANPathNode.h"

@interface ANMyScene : SKScene {
    ANPathNode * currentNode;
    CGPoint initialPoint;
}

@end
