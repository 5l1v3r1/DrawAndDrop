//
//  ANConvexPath.m
//  DrawAndDrop
//
//  Created by Alex Nichol on 12/22/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "ANConvexPath.h"

static CGPoint orthogonalPoint(CGPoint vec);
static CGFloat dotProduct(CGPoint v1, CGPoint v2);
static BOOL sameSide(CGPoint p1, CGPoint p2, CGPoint a, CGPoint b);
static BOOL triContains(CGPoint p1, CGPoint p2, CGPoint p3, CGPoint a);

@interface ANConvexPath (Private)

- (CGPoint)maxAtAngle:(CGFloat)angle;
- (void)recreatePath;

@end

@implementation ANConvexPath

#pragma mark - Init -

- (id)initWithStart:(CGPoint)start dest:(CGPoint)dest {
    if ((self = [super init])) {
        pointAlloc = kANConvexPathBuffer;
        points = (CGPoint *)malloc(pointAlloc * sizeof(CGPoint));
        pointCount = 2;
        points[0] = start;
        points[1] = dest;
        path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, start.x, start.y);
        CGPathAddLineToPoint(path, NULL, dest.x, dest.y);
    }
    return self;
}

#pragma mark - Properties -

- (CGRect)boundingBox {
    return CGRectInset(CGPathGetBoundingBox(self.path), -5, -5);
}

- (CGPathRef)path {
    return path;
}

- (NSInteger)pointCount {
    return pointCount;
}

- (const CGPoint *)points {
    return points;
}

#pragma mark - Methods -

- (void)addPoint:(CGPoint)p {
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    if ([self containsPoint:p]) return;
    if (pointCount == pointAlloc) {
        pointAlloc += kANConvexPathBuffer;
        points = realloc(points, sizeof(CGPoint) * pointAlloc);
    }
    points[pointCount++] = p;
}

- (CGPoint)centralPoint {
    // TODO: find a point in the center of mass or something
    CGPoint midPoint = CGPointMake((points[0].x + points[1].x) / 2.0,
                                   (points[0].y + points[1].y) / 2.0);;
    if (pointCount == 2) return midPoint;
    return CGPointMake((points[2].x + midPoint.x) / 2.0,
                       (points[2].y + midPoint.y) / 2.0);
}

- (BOOL)containsPoint:(CGPoint)point {
    for (int p1 = 0; p1 < pointCount - 2; p1++) {
        for (int p2 = p1 + 1; p2 < pointCount - 1; p2++) {
            for (int p3 = p2 + 1; p3 < pointCount; p3++) {
                if (CGPointEqualToPoint(points[p1], point)) return YES;
                if (CGPointEqualToPoint(points[p2], point)) return YES;
                if (CGPointEqualToPoint(points[p3], point)) return YES;
                if (triContains(points[p1], points[p2], points[p3], point)) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (void)convexPathForCount:(NSInteger)count {
    CGPoint * newPoints = (CGPoint *)malloc(sizeof(CGPoint) * count);
    
    // go around in a circle
    CGFloat inc = M_PI * 2.0 / (CGFloat)count;
    for (int i = 0; i < count; i++) {
        CGFloat angle = inc / 2.0 + (inc * (CGFloat)i);
        newPoints[i] = [self maxAtAngle:angle];
        NSLog(@"%f,%f", newPoints[i].x, newPoints[i].y);
    }
    
    // reassign points
    free(points);
    points = newPoints;
    pointCount = count;
    pointAlloc = count;
    
    for (int i = 0; i < pointCount; i++) {
        if (![self isPointNecessary:i]) {
            [self removePointAtIndex:i];
            i--;
        }
    }
    
    // recreate path
    [self recreatePath];
}

- (CGPathRef)createTranslatedPath:(CGPoint)point {
    CGMutablePathRef aPath = CGPathCreateMutable();
    for (int i = 0; i < pointCount; i++) {
        if (i == 0) CGPathMoveToPoint(aPath, NULL, points[0].x + point.x, points[0].y + point.y);
        else CGPathAddLineToPoint(aPath, NULL, points[i].x + point.x, points[i].y + point.y);
    }
    return aPath;
}

- (void)dealloc {
    free(points);
    CGPathRelease(path);
}

- (UIImage *)generateImage {
    CGRect rect = self.boundingBox;
    UIGraphicsBeginImageContext(CGSizeMake(rect.size.width, rect.size.height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, 1, 1, 0, 1);
    CGContextSetLineWidth(context, 3);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, rect.size.height);
    CGContextConcatCTM(context, flipVertical);
    CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
    CGContextBeginPath(context);
    CGContextAddPath(context, self.path);
    CGContextStrokePath(context);
    
    CGImageRef image = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();
    UIImage * _image = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    return _image;
}

- (BOOL)isPointNecessary:(NSInteger)index {
    CGPoint p = points[index];
    for (int p1 = 0; p1 < pointCount - 2; p1++) {
        if (p1 == index) continue;
        for (int p2 = p1 + 1; p2 < pointCount - 1; p2++) {
            if (p2 == index) continue;
            for (int p3 = p2 + 1; p3 < pointCount; p3++) {
                if (p3 == index) continue;
                if (CGPointEqualToPoint(points[p1], p)) return NO;
                if (CGPointEqualToPoint(points[p2], p)) return NO;
                if (CGPointEqualToPoint(points[p3], p)) return NO;
                if (triContains(points[p1], points[p2], points[p3], p)) {
                    return NO;
                }
            }
        }
    }
    return YES;
}

- (void)removePointAtIndex:(NSInteger)index {
    NSInteger getIndex = 0;
    for (NSInteger i = 0; i < pointCount; i++) {
        if (i == index) continue;
        points[getIndex++] = points[i];
    }
    pointCount = getIndex;
}

- (void)translate:(CGPoint)translation {
    CGPathRelease(path);
    path = CGPathCreateMutable();
    for (int i = 0; i < pointCount; i++) {
        points[i].x += translation.x;
        points[i].y += translation.y;
        if (i == 0) CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
        else CGPathAddLineToPoint(path, NULL, points[i].x, points[i].y);
    }
}

#pragma mark - Private -

- (CGPoint)maxAtAngle:(CGFloat)angle {
    CGFloat maxDist = 1000; // TODO: use some sort of radius here
    CGFloat minDist = 0;
    for (int i = 0; i < 10; i++) {
        CGFloat dist = (maxDist + minDist) / 2.0;
        if ([self containsPoint:CGPointMake(cos(angle) * dist, sin(angle) * dist)]) {
            minDist = dist;
        } else {
            maxDist = dist;
        }
    }
    CGFloat scale = (maxDist + minDist) / 2.0;
    return CGPointMake(scale * cos(angle), scale * sin(angle));
}

- (void)recreatePath {
    CGPathRelease(path);
    path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
    for (int i = 1; i < pointCount; i++) {
        CGPathAddLineToPoint(path, NULL, points[i].x, points[i].y);
    }
    CGPathCloseSubpath(path);
}

@end

static CGPoint orthogonalPoint(CGPoint vec) {
    CGPoint p = CGPointMake(-vec.y, vec.x);
    CGFloat mag = sqrt(dotProduct(p, p));
    if (mag < 0.00001) return CGPointZero;
    return CGPointMake(p.x / mag, p.y / mag);
}

static CGFloat dotProduct(CGPoint v1, CGPoint v2) {
    return v1.x * v2.x + v1.y * v2.y;
}

static BOOL sameSide(CGPoint p1, CGPoint p2, CGPoint a, CGPoint b) {
    CGPoint norm = orthogonalPoint(CGPointMake(p2.x - p1.x, p2.y - p1.y));
    if (norm.x == 0 && norm.y == 0) return NO;
    CGFloat f1 = dotProduct(norm, CGPointMake(a.x - p1.x, a.y - p1.y));
    CGFloat f2 = dotProduct(norm, CGPointMake(b.x - p1.x, b.y - p1.y));
    if (f1 == 0 || f2 == 0) return NO;
    if (f1 < 0 && f2 < 0) return YES;
    if (f1 > 0 && f2 > 0) return YES;
    return NO;
}

static BOOL triContains(CGPoint p1, CGPoint p2, CGPoint p3, CGPoint a) {
    return sameSide(p1, p2, a, p3) && sameSide(p1, p3, a, p2) && sameSide(p2, p3, a, p1);
}
