//
//  ANConvexPath.h
//  DrawAndDrop
//
//  Created by Alex Nichol on 12/22/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kANConvexPathBuffer 64

@interface ANConvexPath : NSObject {
    CGPoint * points;
    NSInteger pointCount;
    NSInteger pointAlloc;
    CGMutablePathRef path;
}

- (id)initWithStart:(CGPoint)start dest:(CGPoint)dest;
- (void)addPoint:(CGPoint)point;
- (CGPoint)centralPoint;
- (BOOL)containsPoint:(CGPoint)point;
- (void)convexPathForCount:(NSInteger)count;
- (CGPathRef)createTranslatedPath:(CGPoint)point;
- (UIImage *)generateImage;
- (BOOL)isPointNecessary:(NSInteger)index;
- (void)removePointAtIndex:(NSInteger)index;
- (void)translate:(CGPoint)translation;

- (CGRect)boundingBox;
- (CGPathRef)path;
- (const CGPoint *)points;
- (NSInteger)pointCount;

@end
