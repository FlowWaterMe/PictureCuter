//
//  CropView.m
//  PictureCuter
//
//  Created by Intelligent on 16/5/14.
//  Copyright © 2016年 com.Intelligent. All rights reserved.
//


#import "CropView.h"

@implementation CropView

@synthesize rotateAngle, tempAngle;
@synthesize downPoint, currentPoint, midPoint;
@synthesize delegate;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"init cropview");
        rotateAngle = 0.0;
        tempAngle = 0.0;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

// 三点之间的夹角
- (CGFloat)getAngleWithLastPoint:(NSPoint)lPoint andCurentPoint:(NSPoint)curPoint andCirclePoint:(NSPoint)cirPoint
{
    CGFloat angle, langle, curangle;
    //  atan2 return -π to π
    langle = atan2(lPoint.y-cirPoint.y, lPoint.x-cirPoint.x)*180/M_PI;
    curangle = atan2(curPoint.y-cirPoint.y, curPoint.x-cirPoint.x)*180/M_PI;
    NSLog(@"langle is %lf\n",langle);
    NSLog(@"curangle is %lf\n",curangle);

    angle = curangle-langle;
    // 0---360
    if (angle<0)
    {
        angle += 360;
    }
    if(angle >= 360)
    {
        angle -= 360;
    }
    NSLog(@"angle is %lf",angle);
    return angle;
    //return 0.0;
}

#pragma mark - Mouse Event
- (void)mouseDown:(NSEvent *)theEvent
{
    downPoint = [theEvent locationInWindow];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
        BOOL isStraight;
        isStraight = [[NSUserDefaults standardUserDefaults] boolForKey:@"Straighten"];
    NSLog(@"%d",isStraight);
        if (!isStraight) {
            currentPoint = [theEvent locationInWindow];
            tempAngle = [self getAngleWithLastPoint:downPoint
                                     andCurentPoint:currentPoint
                                     andCirclePoint:midPoint];
            CGFloat angle;
            angle = tempAngle+rotateAngle;
    
            [delegate setFrameWithRotation:angle];
        }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    BOOL isStraight;
    isStraight = [[NSUserDefaults standardUserDefaults] boolForKey:@"Straighten"];
    if (isStraight) {
        currentPoint = [theEvent locationInWindow];
        //  atan2 return -π to π
        CGFloat tangle;
        tangle = atan2(currentPoint.y-downPoint.y, currentPoint.x-downPoint.x)*180/M_PI;
        // 0---360
        if (tangle<0)
        {
            tangle += 360;
        }
        if(tangle >= 360)
        {
            tangle -= 360;
        }
        NSInteger d;
        d = (NSInteger)tangle%90;
        if (d<45) {
            rotateAngle -= d;
        }
        else {
            rotateAngle += (90-d);
        }
        // 0---360
        if (rotateAngle<0)
        {
            rotateAngle += 360;
        }
        if(rotateAngle >= 360)
        {
            rotateAngle -= 360;
        }
        [delegate setFrameWithRotation:rotateAngle];
        [delegate setAngleSlide];
        isStraight = NO;
        [[NSUserDefaults standardUserDefaults] setBool:isStraight forKey:@"Straighten"];
    }
    else {
        rotateAngle += tempAngle;
        // 0---360
        if (rotateAngle<0)
        {
            rotateAngle += 360;
        }
        if(rotateAngle >= 360)
        {
            rotateAngle -= 360;
        }
        [delegate setAngleSlide];
    }
}

@end
