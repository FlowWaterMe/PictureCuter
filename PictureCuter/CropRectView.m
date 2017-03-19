//
//  CropRectView.m
//  PictureCuter
//
//  Created by Intelligent on 16/5/14.
//  Copyright © 2016年 com.Intelligent. All rights reserved.
//

//
//  CropRectView.m
//  RotationAndCropTest


#import "CropRectView.h"

#define CONTROL_WIDTH 20
#define MIN_WH  40


@implementation CropRectView

@synthesize delegate;
@synthesize downPoint, dragPoint;
@synthesize downRect;
@synthesize isScale, scaleWH;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       // NSLog(@"init rectview");
        isScale = NO;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];//由子类重写绘制视图的图像指定的矩形中。
    
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];//
    CGContextStrokeRectWithWidth(context, [self bounds], 3);//用指定的线宽画一个矩形路径。
}

#pragma mark - Mouse Event
- (void)mouseDown:(NSEvent *)theEvent
{
    BOOL isStraight;
    isStraight = [[NSUserDefaults standardUserDefaults] boolForKey:@"Straighten"];
    if (isStraight) {
        [[self superview] mouseDown:theEvent];
    }
    else {
        downPoint = [theEvent locationInWindow];
        downRect = [self frame];
        
        NSPoint point = [self convertPoint:downPoint fromView:nil];
        [self findAreaInRectsWithPoint:point];
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    BOOL isStraight;
    isStraight = [[NSUserDefaults standardUserDefaults] boolForKey:@"Straighten"];
    if (isStraight) {
        [[self superview] mouseDragged:theEvent];
    }
    else {
        //        NSLog(@"drag it on the way");
        dragPoint = [theEvent locationInWindow];
        if (nMousePointInAreaType >= 0) {
            if (isScale) {
                [self setFrameForScaleWithDownPoint:downPoint
                                    andCurrentPoint:dragPoint];// 裁剪
            }
            else{
                [self setFrameForFreeWithDownPoint:downPoint
                                   andCurrentPoint:dragPoint];//裁剪
            }
        }
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    BOOL isStraight;
    isStraight = [[NSUserDefaults standardUserDefaults] boolForKey:@"Straighten"];
    if (isStraight) {
        [[self superview] mouseUp:theEvent];
    }
    else {
        downRect = [self frame];// 当前框架
    }
}

// 判断点所在的区域
- (void)findAreaInRectsWithPoint:(CGPoint)point
{
    CGRect leftBottomRect, rightTopRect, rightBottomRect, leftTopRect;
    CGRect leftBorderRect, rightBorderRect, bottomBorderRect, topBorderRect;
    CGRect cropRect;
    cropRect = [self bounds];//视图的边界矩形，它表示在它自己的坐标系中的位置和大小。
    
    leftBottomRect = CGRectMake(CGRectGetMinX(cropRect)-CONTROL_WIDTH,
                                CGRectGetMinY(cropRect)-CONTROL_WIDTH,
                                2*CONTROL_WIDTH,
                                2*CONTROL_WIDTH);
    rightTopRect = CGRectMake(CGRectGetMaxX(cropRect)-CONTROL_WIDTH,
                              CGRectGetMaxY(cropRect)-CONTROL_WIDTH,
                              2*CONTROL_WIDTH,
                              2*CONTROL_WIDTH);
    rightBottomRect = CGRectMake(CGRectGetMaxX(cropRect)-CONTROL_WIDTH,
                                 CGRectGetMinY(cropRect)-CONTROL_WIDTH,
                                 2*CONTROL_WIDTH,
                                 2*CONTROL_WIDTH);
    leftTopRect = CGRectMake(CGRectGetMinX(cropRect)-CONTROL_WIDTH,
                             CGRectGetMaxY(cropRect)-CONTROL_WIDTH,
                             2*CONTROL_WIDTH,
                             2*CONTROL_WIDTH);
    leftBorderRect = CGRectMake(CGRectGetMinX(cropRect)-CONTROL_WIDTH,
                                CGRectGetMinY(cropRect)+CONTROL_WIDTH,
                                2*CONTROL_WIDTH,
                                CGRectGetHeight(cropRect)-2*CONTROL_WIDTH);
    rightBorderRect = CGRectMake(CGRectGetMaxX(cropRect)-CONTROL_WIDTH,
                                 CGRectGetMinY(cropRect)+CONTROL_WIDTH,
                                 2*CONTROL_WIDTH,
                                 CGRectGetHeight(cropRect)-2*CONTROL_WIDTH);
    bottomBorderRect = CGRectMake(CGRectGetMinX(cropRect)+CONTROL_WIDTH,
                                  CGRectGetMinY(cropRect)-CONTROL_WIDTH,
                                  CGRectGetWidth(cropRect)-2*CONTROL_WIDTH,
                                  2*CONTROL_WIDTH);
    topBorderRect = CGRectMake(CGRectGetMinX(cropRect)+CONTROL_WIDTH,
                               CGRectGetMaxY(cropRect)-CONTROL_WIDTH,
                               CGRectGetWidth(cropRect)-2*CONTROL_WIDTH,
                               2*CONTROL_WIDTH);
    
    if (CGRectContainsPoint(leftBottomRect, point)) {//判断两点是否有重合
        nMousePointInAreaType = LEFTBOTTOM;
    }
    else if (CGRectContainsPoint(rightTopRect, point)){
        nMousePointInAreaType = RIGHTTOP;
    }
    else if (CGRectContainsPoint(rightBottomRect, point)) {
        nMousePointInAreaType = RIGHTBOTTOM;
    }
    else if (CGRectContainsPoint(leftTopRect, point)) {
        nMousePointInAreaType = LEFTTOP;
    }
    else if (CGRectContainsPoint(leftBorderRect, point)) {
        nMousePointInAreaType = LEFTMID;
    }
    else if (CGRectContainsPoint(rightBorderRect, point)) {
        nMousePointInAreaType = RIGHTMID;
    }
    else if (CGRectContainsPoint(bottomBorderRect, point)) {
        nMousePointInAreaType = BOTTOMMID;
    }
    else if (CGRectContainsPoint(topBorderRect, point)) {
        nMousePointInAreaType = TOPMID;
    }
    else if (CGRectContainsPoint(cropRect, point)) {
        nMousePointInAreaType = CENTERROTATION;
    }
    else {
        nMousePointInAreaType = -1;
    }
}

//  调整左下点，保持右上点不变，左上点的Y和右下点的X不变
- (NSRect)makeRectFromDragLeftBottomWithX:(CGFloat)dx
                                     andY:(CGFloat)dy
{
    NSRect cropRect, newFrame;
    cropRect = downRect;
    
    cropRect.size.width -= dx;
    if (cropRect.size.width < MIN_WH) {
        cropRect.size.width = MIN_WH;
    }
    cropRect.size.height -= dy;
    if (cropRect.size.height < MIN_WH) {
        cropRect.size.height = MIN_WH;
    }
    cropRect.origin.x = NSMaxX(downRect)-cropRect.size.width;
    cropRect.origin.y = NSMaxY(downRect)-cropRect.size.height;
    
    //  条件：四个顶点都在imageView区域里
    NSPoint leftp, rightp, lefttopp, righttopp;
    leftp = NSMakePoint(NSMinX(cropRect), NSMinY(cropRect));
    rightp = NSMakePoint(NSMaxX(cropRect), NSMinY(cropRect));
    lefttopp = NSMakePoint(NSMinX(cropRect), NSMaxY(cropRect));
    righttopp = NSMakePoint(NSMaxX(cropRect), NSMaxY(cropRect));
    
    leftp = [delegate setPointWithFixPoint:righttopp andCrossPoint:leftp];
    rightp = [delegate setPointWithFixPoint:righttopp andCrossPoint:rightp];
    lefttopp = [delegate setPointWithFixPoint:righttopp andCrossPoint:lefttopp];
    
    //  计算左下点和左上点分别到右上点水平方向的距离，取小值作为新矩形的宽
    //  计算左下点和右下点分别到右上点垂直方向的距离，取小值作为新矩形的高
    //  根据右上点坐标和宽高值确定新矩形的原点
    newFrame.size.width = righttopp.x-fmaxf(leftp.x, lefttopp.x);
    newFrame.size.height = righttopp.y-fmaxf(leftp.y, rightp.y);
    newFrame.origin.x = righttopp.x-newFrame.size.width;
    newFrame.origin.y = righttopp.y-newFrame.size.height;
    
    return newFrame;
}

//  调整右上点，保持左下点不变，左上点的X和右下点的Y不变
- (NSRect)makeRectFromDragRightTopWithX:(CGFloat)dx
                                   andY:(CGFloat)dy
{
    NSRect cropRect, newFrame;
    cropRect = downRect;
    
    cropRect.size.width += dx;
    if (cropRect.size.width < MIN_WH) {
        cropRect.size.width = MIN_WH;
    }
    cropRect.size.height += dy;
    if (cropRect.size.height < MIN_WH) {
        cropRect.size.height = MIN_WH;
    }
    
    //  条件：四个顶点都在imageView区域里
    NSPoint leftp, rightp, lefttopp, righttopp;
    leftp = NSMakePoint(NSMinX(cropRect), NSMinY(cropRect));
    rightp = NSMakePoint(NSMaxX(cropRect), NSMinY(cropRect));
    lefttopp = NSMakePoint(NSMinX(cropRect), NSMaxY(cropRect));
    righttopp = NSMakePoint(NSMaxX(cropRect), NSMaxY(cropRect));
    
    righttopp = [delegate setPointWithFixPoint:leftp andCrossPoint:righttopp];
    rightp = [delegate setPointWithFixPoint:leftp andCrossPoint:rightp];
    lefttopp = [delegate setPointWithFixPoint:leftp andCrossPoint:lefttopp];
    
    //  计算右下点和右上点分别到左下点水平方向的距离，取小值作为新矩形的宽
    //  计算左上点和右上点分别到左下点垂直方向的距离，取小值作为新矩形的高
    //  根据左下点坐标确定新矩形的原点
    newFrame.size.width = fminf(rightp.x, righttopp.x)-leftp.x;
    newFrame.size.height = fminf(lefttopp.y, righttopp.y)-leftp.y;
    newFrame.origin.x = leftp.x;
    newFrame.origin.y = leftp.y;
    
    return newFrame;
}

//  调整右下点，保持左上点不变，左下点的X和右上点的Y不变
- (NSRect)makeRectFromDragRightBottomWithX:(CGFloat)dx
                                      andY:(CGFloat)dy
{
    NSRect cropRect, newFrame;
    cropRect = downRect;
    
    cropRect.size.width += dx;
    if (cropRect.size.width < MIN_WH) {
        cropRect.size.width = MIN_WH;
    }
    cropRect.size.height -= dy;
    if (cropRect.size.height < MIN_WH) {
        cropRect.size.height = MIN_WH;
    }
    cropRect.origin.y = NSMaxY(downRect)-cropRect.size.height;
    
    //  条件：四个顶点都在imageView区域里
    NSPoint leftp, rightp, lefttopp, righttopp;
    leftp = NSMakePoint(NSMinX(cropRect), NSMinY(cropRect));
    rightp = NSMakePoint(NSMaxX(cropRect), NSMinY(cropRect));
    lefttopp = NSMakePoint(NSMinX(cropRect), NSMaxY(cropRect));
    righttopp = NSMakePoint(NSMaxX(cropRect), NSMaxY(cropRect));
    
    leftp = [delegate setPointWithFixPoint:lefttopp andCrossPoint:leftp];
    righttopp = [delegate setPointWithFixPoint:lefttopp andCrossPoint:righttopp];
    rightp = [delegate setPointWithFixPoint:lefttopp andCrossPoint:rightp];
    
    //  计算右下点和右上点分别到左上点水平方向的距离，取小值作为新矩形的宽
    //  计算左下点和右下点分别到左上点垂直方向的距离，取小值作为新矩形的高
    //  根据左上点坐标和宽高值确定新矩形的原点
    newFrame.size.width = fminf(rightp.x, righttopp.x)-lefttopp.x;
    newFrame.size.height = lefttopp.y-fmaxf(leftp.y, rightp.y);
    newFrame.origin.x = lefttopp.x;
    newFrame.origin.y = lefttopp.y-newFrame.size.height;
    
    return newFrame;
}

//  调整左上点，保持右下点不变，左下点的Y和右上点的X不变
- (NSRect)makeRectFromDragLeftTopWithX:(CGFloat)dx
                                  andY:(CGFloat)dy
{
    NSRect cropRect, newFrame;
    cropRect = downRect;
    
    cropRect.size.width -= dx;
    if (cropRect.size.width < MIN_WH) {
        cropRect.size.width = MIN_WH;
    }
    cropRect.size.height += dy;
    if (cropRect.size.height < MIN_WH) {
        cropRect.size.height = MIN_WH;
    }
    cropRect.origin.x = NSMaxX(downRect)-cropRect.size.width;
    
    //  条件：四个顶点都在imageView区域里
    NSPoint leftp, rightp, lefttopp, righttopp;
    leftp = NSMakePoint(NSMinX(cropRect), NSMinY(cropRect));
    rightp = NSMakePoint(NSMaxX(cropRect), NSMinY(cropRect));
    lefttopp = NSMakePoint(NSMinX(cropRect), NSMaxY(cropRect));
    righttopp = NSMakePoint(NSMaxX(cropRect), NSMaxY(cropRect));
    
    
    leftp = [delegate setPointWithFixPoint:rightp andCrossPoint:leftp];
    righttopp = [delegate setPointWithFixPoint:rightp andCrossPoint:righttopp];
    lefttopp = [delegate setPointWithFixPoint:rightp andCrossPoint:lefttopp];
    
    //  计算左下点和左上点分别到右下点水平方向的距离，取小值作为新矩形的宽
    //  计算左上点和右上点分别到右下点垂直方向的距离，取小值作为新矩形的高
    //  根据右下点坐标和宽高值确定新矩形的原点
    newFrame.size.width = rightp.x-fmaxf(leftp.x, lefttopp.x);
    newFrame.size.height = fminf(lefttopp.y, righttopp.y)-rightp.y;
    newFrame.origin.x = rightp.x-newFrame.size.width;
    newFrame.origin.y = rightp.y;
    
    return newFrame;
}

// 自由模式下，调整裁剪区的大小
- (void)setFrameForFreeWithDownPoint:(NSPoint)dpoint andCurrentPoint:(NSPoint)cpoint
{
    CGFloat dx, dy;
    dx = cpoint.x-dpoint.x;
    dy = cpoint.y-dpoint.y;
    NSRect newFrame;
    switch (nMousePointInAreaType) {
        case LEFTBOTTOM:
            newFrame = [self makeRectFromDragLeftBottomWithX:dx andY:dy];
            if ((NSWidth(newFrame)>=MIN_WH) && (NSHeight(newFrame)>=MIN_WH)) {
                [delegate setArgumentsWithFrame:newFrame];
            }
            break;
        case RIGHTTOP:
            newFrame = [self makeRectFromDragRightTopWithX:dx andY:dy];
            if ((NSWidth(newFrame)>=MIN_WH) && (NSHeight(newFrame)>=MIN_WH)) {
                [delegate setArgumentsWithFrame:newFrame];
            }
            break;
        case RIGHTBOTTOM:
            newFrame = [self makeRectFromDragRightBottomWithX:dx andY:dy];
            if ((NSWidth(newFrame)>=MIN_WH) && (NSHeight(newFrame)>=MIN_WH)) {
                [delegate setArgumentsWithFrame:newFrame];
            }
            break;
        case LEFTTOP:
            newFrame = [self makeRectFromDragLeftTopWithX:dx andY:dy];
            if ((NSWidth(newFrame)>=MIN_WH) && (NSHeight(newFrame)>=MIN_WH)) {
                [delegate setArgumentsWithFrame:newFrame];
            }
            break;
        case LEFTMID:
        case RIGHTMID:
        case BOTTOMMID:
        case TOPMID:
        case CENTERROTATION:
            [delegate setFrameWithDrag];//裁剪
            break;
        default:
            break;
    }
}

//  调整左下点，只考虑水平方向的变化，保持右上点不变，左上点的Y和右下点的X不变
- (NSRect)makeRectFromDragLeftBottomWithX:(CGFloat)dx
                                 andScale:(CGFloat)scale
{
    // 以水平方向的变化计算新矩形
    NSRect cropRect, newFrame;
    cropRect = downRect;
    
    cropRect.size.width -= dx;
    if (cropRect.size.width < MIN_WH) {
        cropRect.size.width = MIN_WH;
    }
    cropRect.size.height = cropRect.size.width/scale;
    if (cropRect.size.height < MIN_WH) {
        cropRect.size.height = MIN_WH;
        cropRect.size.width = cropRect.size.height*scale;
    }
    cropRect.origin.x = NSMaxX(downRect)-cropRect.size.width;
    cropRect.origin.y = NSMaxY(downRect)-cropRect.size.height;
    
    //  条件：四个顶点都在imageView区域里
    NSPoint leftp, rightp, lefttopp, righttopp;
    leftp = NSMakePoint(NSMinX(cropRect), NSMinY(cropRect));
    rightp = NSMakePoint(NSMaxX(cropRect), NSMinY(cropRect));
    lefttopp = NSMakePoint(NSMinX(cropRect), NSMaxY(cropRect));
    righttopp = NSMakePoint(NSMaxX(cropRect), NSMaxY(cropRect));
    
    leftp = [delegate setPointWithFixPoint:righttopp andCrossPoint:leftp];
    rightp = [delegate setPointWithFixPoint:righttopp andCrossPoint:rightp];
    lefttopp = [delegate setPointWithFixPoint:righttopp andCrossPoint:lefttopp];
    
    //  计算左下点和左上点分别到右上点水平方向的距离，取小值作为新矩形的宽
    //  计算左下点和右下点分别到右上点垂直方向的距离，取小值minH
    //  根据宽按比例计算高，如果高>minH，将minH设置为新矩形的高，并根据比例计算宽
    //  根据右上点坐标和宽高值确定新矩形的原点
    newFrame.size.width = righttopp.x-fmaxf(leftp.x, lefttopp.x);
    newFrame.size.height = righttopp.y-fmaxf(leftp.y, rightp.y);
    if (newFrame.size.width/scale >= newFrame.size.height) {
        newFrame.size.width = newFrame.size.height*scale;
    }
    else {
        newFrame.size.height = newFrame.size.width/scale;
    }
    newFrame.origin.x = righttopp.x-newFrame.size.width;
    newFrame.origin.y = righttopp.y-newFrame.size.height;
//
    return newFrame;
}

//  调整右上点，只考虑水平方向的变化，保持左下点不变，右下点的Y和左上点的X不变
- (NSRect)makeRectFromDragRightTopWithX:(CGFloat)dx
                               andScale:(CGFloat)scale
{
    // 以水平方向的变化计算新矩形
    NSRect cropRect, newFrame;
    cropRect = downRect;
    
    cropRect.size.width += dx;
    if (cropRect.size.width < MIN_WH) {
        cropRect.size.width = MIN_WH;
    }
    cropRect.size.height = cropRect.size.width/scale;
    if (cropRect.size.height < MIN_WH) {
        cropRect.size.height = MIN_WH;
        cropRect.size.width = cropRect.size.height*scale;
    }
    cropRect.origin.x = NSMinX(downRect);
    cropRect.origin.y = NSMinY(downRect);
    
    //  条件：四个顶点都在imageView区域里
    NSPoint leftp, rightp, lefttopp, righttopp;
    leftp = NSMakePoint(NSMinX(cropRect), NSMinY(cropRect));
    rightp = NSMakePoint(NSMaxX(cropRect), NSMinY(cropRect));
    lefttopp = NSMakePoint(NSMinX(cropRect), NSMaxY(cropRect));
    righttopp = NSMakePoint(NSMaxX(cropRect), NSMaxY(cropRect));
    
    righttopp = [delegate setPointWithFixPoint:leftp andCrossPoint:righttopp];
    rightp = [delegate setPointWithFixPoint:leftp andCrossPoint:rightp];
    lefttopp = [delegate setPointWithFixPoint:leftp andCrossPoint:lefttopp];
    
    //  计算右下点和右上点分别到左下点水平方向的距离，取小值作为新矩形的宽
    //  计算左上点和右上点分别到左下点垂直方向的距离，取小值minH
    //  根据宽按比例计算高，如果高>minH，将minH设置为新矩形的高，并根据比例计算宽
    //  根据左下点坐标和宽高值确定新矩形的原点
    newFrame.size.width = fminf(rightp.x, righttopp.x)-leftp.x;
    newFrame.size.height = fminf(lefttopp.y, righttopp.y)-leftp.y;
    if (newFrame.size.width/scale >= newFrame.size.height) {
        newFrame.size.width = newFrame.size.height*scale;
    }
    else {
        newFrame.size.height = newFrame.size.width/scale;
    }
    newFrame.origin.x = leftp.x;
    newFrame.origin.y = leftp.y;
    
    return newFrame;
}

//  调整右下点，只考虑水平方向的变化，保持左上点不变，左下点的X和右上点的Y不变
- (NSRect)makeRectFromDragRightBottomWithX:(CGFloat)dx
                                  andScale:(CGFloat)scale
{
    // 以水平方向的变化计算新矩形
    NSRect cropRect, newFrame;
    cropRect = downRect;
//    
    cropRect.size.width += dx;
    if (cropRect.size.width < MIN_WH) {
        cropRect.size.width = MIN_WH;
    }
    cropRect.size.height = cropRect.size.width/scale;
    if (cropRect.size.height < MIN_WH) {
        cropRect.size.height = MIN_WH;
        cropRect.size.width = cropRect.size.height*scale;
    }
    cropRect.origin.x = NSMinX(downRect);
    cropRect.origin.y = NSMaxY(downRect)-cropRect.size.height;
    
    //  条件：四个顶点都在imageView区域里
    NSPoint leftp, rightp, lefttopp, righttopp;
    leftp = NSMakePoint(NSMinX(cropRect), NSMinY(cropRect));
    rightp = NSMakePoint(NSMaxX(cropRect), NSMinY(cropRect));
    lefttopp = NSMakePoint(NSMinX(cropRect), NSMaxY(cropRect));
    righttopp = NSMakePoint(NSMaxX(cropRect), NSMaxY(cropRect));
    
    leftp = [delegate setPointWithFixPoint:lefttopp andCrossPoint:leftp];
    rightp = [delegate setPointWithFixPoint:lefttopp andCrossPoint:rightp];
    righttopp = [delegate setPointWithFixPoint:lefttopp andCrossPoint:righttopp];
    
    //  计算右上点和右下点分别到左上点水平方向的距离，取小值作为新矩形的宽
    //  计算左下点和右下点分别到左上点垂直方向的距离，取小值minH
    //  根据宽按比例计算高，如果高>minH，将minH设置为新矩形的高，并根据比例计算宽
    //  根据左上点坐标和宽高值确定新矩形的原点
    newFrame.size.width = fminf(righttopp.x, rightp.x)-lefttopp.x;
    newFrame.size.height = lefttopp.y-fmaxf(leftp.y, rightp.y);
    if (newFrame.size.width/scale >= newFrame.size.height) {
        newFrame.size.width = newFrame.size.height*scale;
    }
    else {
        newFrame.size.height = newFrame.size.width/scale;
    }
    newFrame.origin.x = lefttopp.x;
    newFrame.origin.y = lefttopp.y-newFrame.size.height;
    
    return newFrame;
}

//  调整左上点，只考虑水平方向的变化，保持右下点不变，左下点的Y和右上点的X不变
- (NSRect)makeRectFromDragLeftTopWithX:(CGFloat)dx
                              andScale:(CGFloat)scale
{
    // 以水平方向的变化计算新矩形
    NSRect cropRect, newFrame;
    cropRect = downRect;
    
    cropRect.size.width -= dx;
    if (cropRect.size.width < MIN_WH) {
        cropRect.size.width = MIN_WH;
    }
    cropRect.size.height = cropRect.size.width/scale;
    if (cropRect.size.height < MIN_WH) {
        cropRect.size.height = MIN_WH;
        cropRect.size.width = cropRect.size.height*scale;
    }
    cropRect.origin.x = NSMaxX(downRect)-cropRect.size.width;
    cropRect.origin.y = NSMinY(downRect);
    
    //  条件：四个顶点都在imageView区域里
    NSPoint leftp, rightp, lefttopp, righttopp;
    leftp = NSMakePoint(NSMinX(cropRect), NSMinY(cropRect));
    rightp = NSMakePoint(NSMaxX(cropRect), NSMinY(cropRect));
    lefttopp = NSMakePoint(NSMinX(cropRect), NSMaxY(cropRect));
    righttopp = NSMakePoint(NSMaxX(cropRect), NSMaxY(cropRect));
    
    leftp = [delegate setPointWithFixPoint:rightp andCrossPoint:leftp];
    righttopp = [delegate setPointWithFixPoint:rightp andCrossPoint:righttopp];
    lefttopp = [delegate setPointWithFixPoint:rightp andCrossPoint:lefttopp];
    
    //  计算左下点和左上点分别到右下点水平方向的距离，取小值作为新矩形的宽
    //  计算左上点和右上点分别到右下点垂直方向的距离，取小值minH
    //  根据宽按比例计算高，如果高>minH，将minH设置为新矩形的高，并根据比例计算宽
    //  根据右下点坐标和宽高值确定新矩形的原点
    newFrame.size.width = rightp.x-fmaxf(leftp.x, lefttopp.x);
    newFrame.size.height = fminf(lefttopp.y, righttopp.y)-rightp.y;
    if (newFrame.size.width/scale >= newFrame.size.height) {
        newFrame.size.width = newFrame.size.height*scale;
    }
    else {
        newFrame.size.height = newFrame.size.width/scale;
    }
    newFrame.origin.x = rightp.x-newFrame.size.width;
    newFrame.origin.y = rightp.y;
    
    return newFrame;
}

// 比例模式下，调整裁剪区的大小
- (void)setFrameForScaleWithDownPoint:(NSPoint)dpoint
                      andCurrentPoint:(NSPoint)cpoint
{
    CGFloat dx;
    dx = cpoint.x-dpoint.x;
    NSRect newFrame;
    switch (nMousePointInAreaType) {
        case LEFTBOTTOM:
            newFrame = [self makeRectFromDragLeftBottomWithX:dx
                                                    andScale:scaleWH];
            if ((NSWidth(newFrame)>=MIN_WH) && (NSHeight(newFrame)>=MIN_WH)) {
                [delegate setArgumentsWithFrame:newFrame];
            }
            break;
        case RIGHTTOP:
            newFrame = [self makeRectFromDragRightTopWithX:dx
                                                  andScale:scaleWH];
            if ((NSWidth(newFrame)>=MIN_WH) && (NSHeight(newFrame)>=MIN_WH)) {
                [delegate setArgumentsWithFrame:newFrame];
            }
            break;
        case RIGHTBOTTOM:
            newFrame = [self makeRectFromDragRightBottomWithX:dx
                                                     andScale:scaleWH];
            if ((NSWidth(newFrame)>=MIN_WH) && (NSHeight(newFrame)>=MIN_WH)) {
                [delegate setArgumentsWithFrame:newFrame];
            }
            break;
        case LEFTTOP:
            newFrame = [self makeRectFromDragLeftTopWithX:dx
                                                 andScale:scaleWH];
            if ((NSWidth(newFrame)>=MIN_WH) && (NSHeight(newFrame)>=MIN_WH)) {
                [delegate setArgumentsWithFrame:newFrame];
            }
            break;
        case LEFTMID:
        case RIGHTMID:
        case BOTTOMMID:
        case TOPMID:
        case CENTERROTATION:
            [delegate setFrameWithDrag];
            break;
        default:
            break;
    }
}

@end
