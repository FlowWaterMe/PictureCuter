//
//  CropImageView.m
//  PictureCuter
//
//  Created by Intelligent on 16/5/14.
//  Copyright © 2016年 com.Intelligent. All rights reserved.
//

//
//  CropImageView.m
//  RotationAndCropTest
//
#import "CropImageView.h"

@implementation CropImageView

@synthesize cropMidPoint;
@synthesize cropRect;
@synthesize delegate;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      //  NSLog(@"init cropimageview");
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    NSPoint p1, p2, p3, p4;
    NSRect tbounds;
    tbounds = [self bounds];
    p1 = NSMakePoint(NSMinX(cropRect), NSMinY(cropRect));//创建一个新的坐标点
    p2 = NSMakePoint(NSMinX(cropRect), NSMaxY(cropRect));
    p3 = NSMakePoint(NSMaxX(cropRect), NSMaxY(cropRect));
    p4 = NSMakePoint(NSMaxX(cropRect), NSMinY(cropRect));
    p1 = [self convertPoint:p1 fromView:[self superview]];
    p2 = [self convertPoint:p2 fromView:[self superview]];
    p3 = [self convertPoint:p3 fromView:[self superview]];
    p4 = [self convertPoint:p4 fromView:[self superview]];
    
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGMutablePathRef pathRef = CGPathCreateMutable();//初始化一个可变的路径
    CGPathAddRect(pathRef, nil, tbounds);
    
    CGPathMoveToPoint(pathRef, &CGAffineTransformIdentity, p1.x, p1.y);// 旧点移除
    CGPathAddLineToPoint(pathRef, &CGAffineTransformIdentity, p1.x, p1.y);
    CGPathAddLineToPoint(pathRef, &CGAffineTransformIdentity, p2.x, p2.y);
    CGPathAddLineToPoint(pathRef, &CGAffineTransformIdentity, p3.x, p3.y);
    CGPathAddLineToPoint(pathRef, &CGAffineTransformIdentity, p4.x, p4.y);
    CGPathCloseSubpath(pathRef);
    
    CGContextSetRGBFillColor(context, 0.5f, 0.5f, 0.5f,0.4f);
    CGContextAddPath(context, pathRef);
    CGContextDrawPath(context, kCGPathEOFill);
    
}

@end
