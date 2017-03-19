//
//  CropArgumentView.m
//  PictureCuter
//
//  Created by Intelligent on 16/5/14.
//  Copyright © 2016年 com.Intelligent. All rights reserved.
//

//
//  CropArgumentView.m
// 用于调整裁剪参数的界面




#import "CropArgumentView.h"

@implementation CropArgumentView

@synthesize delegate;
@synthesize slider;
@synthesize originScale, scale, straightAngle;
@synthesize isFree, isFlip;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      //  NSLog(@"init crop argumentview");
        originScale = 1.0;
        scale = 1.0;
        straightAngle = 0.0;
        isFree = NO;
        isFlip = NO;
    }
    return self;
}



- (void)initButtons
{
    NSLog(@"initbutteo");
    NSButton  *blbtn1, *blbtn2, *blbtn3, *blbtn4, *blbtn5, *blbtn6, *blbtn7, *blbtn8;
    NSButton *flipBtn;
    NSButton *straightBtn;
    NSButton *lbtn, *hbtn, *rbtn;
    NSButton *vflipBtn, *hflipBtn;
    NSButton *cancelBtn, *doneBtn,*saveBtn;
    blbtn1 = [[NSButton alloc] initWithFrame:NSMakeRect(30, 500, 100, 30)];
    [blbtn1 setTitle:@"Origin"];
    [blbtn1 setTarget:self];
    [blbtn1 setAction:@selector(setOriginScale)];
    blbtn2 = [[NSButton alloc] initWithFrame:NSMakeRect(150, 500, 100, 30)];
    [blbtn2 setTitle:@"Free"];
    [blbtn2 setTarget:self];
    [blbtn2 setAction:@selector(setFree)];
    blbtn3 = [[NSButton alloc] initWithFrame:NSMakeRect(30, 450, 100, 30)];
    [blbtn3 setTitle:@"2:1"];
    [blbtn3 setTarget:self];
    [blbtn3 setAction:@selector(setTwoWithOne)];
    blbtn4 = [[NSButton alloc] initWithFrame:NSMakeRect(150, 450, 100, 30)];
    [blbtn4 setTitle:@"16:9"];
    [blbtn4 setTarget:self];
    [blbtn4 setAction:@selector(setSixteenWithNine)];
    blbtn5 = [[NSButton alloc] initWithFrame:NSMakeRect(30, 400, 100, 30)];
    [blbtn5 setTitle:@"5:4"];
    [blbtn5 setTarget:self];
    [blbtn5 setAction:@selector(setFiveWithFour)];
    blbtn6 = [[NSButton alloc] initWithFrame:NSMakeRect(150, 400, 100, 30)];
    [blbtn6 setTitle:@"4:3"];
    [blbtn6 setTarget:self];
    [blbtn6 setAction:@selector(setFourWithThree)];
    blbtn7 = [[NSButton alloc] initWithFrame:NSMakeRect(30, 350, 100, 30)];
    [blbtn7 setTitle:@"3:2"];
    [blbtn7 setTarget:self];
    [blbtn7 setAction:@selector(setThreeWithTwo)];
    blbtn8 = [[NSButton alloc] initWithFrame:NSMakeRect(150, 350, 100, 30)];
    [blbtn8 setTitle:@"1:1"];
    [blbtn8 setTarget:self];
    [blbtn8 setAction:@selector(setOneWithOne)];
    flipBtn = [[NSButton alloc] initWithFrame:NSMakeRect(30, 300, 150, 30)];
    [flipBtn setTitle:@"Flip Ratio"];
    [flipBtn setTarget:self];
    [flipBtn setAction:@selector(setFlipScale)];
    [self addSubview:blbtn1];
    [self addSubview:blbtn2];
    [self addSubview:blbtn3];
    [self addSubview:blbtn4];
    [self addSubview:blbtn5];
    [self addSubview:blbtn6];
    [self addSubview:blbtn7];
    [self addSubview:blbtn8];
    [self addSubview:flipBtn];
    
    straightBtn = [[NSButton alloc] initWithFrame:NSMakeRect(30, 250, 150, 30)];
    [straightBtn setTitle:@"Straighten"];
    [straightBtn setTarget:self];
    [straightBtn setAction:@selector(setStraighten)];
    [self addSubview:straightBtn];
    
    slider = [[NSSlider alloc] initWithFrame:NSMakeRect(30, 200, 200, 30)];
    [slider setMinValue:-45.0];
    [slider setMaxValue:45.0];
    [slider setDoubleValue:0.0];
    [slider setTarget:self];
    [slider setAction:@selector(setStraAngle)];
    [self addSubview:slider];
    
    lbtn = [[NSButton alloc] initWithFrame:NSMakeRect(30, 150, 60, 30)];
    [lbtn setTitle:@"Left"];
    [lbtn setTarget:self];
    [lbtn setAction:@selector(leftRotate)];
    hbtn = [[NSButton alloc] initWithFrame:NSMakeRect(120, 150, 60, 30)];
    [hbtn setTitle:@"Horizon"];
    [hbtn setTarget:self];
    [hbtn setAction:@selector(setHorizon)];
    rbtn = [[NSButton alloc] initWithFrame:NSMakeRect(200, 150, 60, 30)];
    [rbtn setTitle:@"Right"];
    [rbtn setTarget:self];
    [rbtn setAction:@selector(rightRotate)];
    [self addSubview:lbtn];
    [self addSubview:hbtn];
    [self addSubview:rbtn];
    
    vflipBtn = [[NSButton alloc] initWithFrame:NSMakeRect(30, 100, 100, 30)];
    [vflipBtn setTitle:@"VFlip"];
    [vflipBtn setTarget:self];
    [vflipBtn setAction:@selector(vflipImage)];
    hflipBtn = [[NSButton alloc] initWithFrame:NSMakeRect(150, 100, 100, 30)];
    [hflipBtn setTitle:@"HFlip"];
    [hflipBtn setTarget:self];
    [hflipBtn setAction:@selector(hflipImage)];
    [self addSubview:vflipBtn];
    [self addSubview:hflipBtn];
    
    cancelBtn = [[NSButton alloc] initWithFrame:NSMakeRect(30, 50, 100, 30)];
    [cancelBtn setTitle:@"Cancel"];
    [cancelBtn setTarget:self];
    [cancelBtn setAction:@selector(cancel)];
    doneBtn = [[NSButton alloc] initWithFrame:NSMakeRect(150, 50, 100, 30)];
    [doneBtn setTitle:@"Done"];
    [doneBtn setTarget:self];
    [doneBtn setAction:@selector(done)];
    saveBtn = [[NSButton alloc] initWithFrame:NSMakeRect(30, 10, 100, 30)];
    [saveBtn setTitle:@"Save"];
    [saveBtn setTarget:self];
    [saveBtn setAction:@selector(save)];
    [self addSubview:cancelBtn];
    [self addSubview:doneBtn];
    [self addSubview:saveBtn];
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setOriginScale
{
    if (isFlip) {
        scale = 1/originScale;//原始比例
    }
    else {
        scale = originScale;
    }
    isFree = NO;
    [delegate setScale:scale isFree:isFree];
}

- (void)setTwoWithOne
{
    if (isFlip) {
        scale = 1.0/2.0;
    }
    else {
        scale = 2.0/1.0;
    }
    isFree = NO;
    [delegate setScale:scale isFree:isFree];
}

- (void)setSixteenWithNine
{
    if (isFlip) {
        scale = 9.0/16.0;
    }
    else {
        scale = 16.0/9.0;
    }
    isFree = NO;
    [delegate setScale:scale isFree:isFree];
}

- (void)setFiveWithFour
{
    if (isFlip) {
        scale = 4.0/5.0;
    }
    else {
        scale = 5.0/4.0;
    }
    isFree = NO;
    [delegate setScale:scale isFree:isFree];
}

- (void)setFourWithThree
{
    if (isFlip) {
        scale = 3.0/4.0;
    }
    else {
        scale = 4.0/3.0;
    }
    isFree = NO;
    [delegate setScale:scale isFree:isFree];
}

- (void)setThreeWithTwo
{
    if (isFlip) {
        scale = 2.0/3.0;
    }
    else {
        scale = 3.0/2.0;
    }
    isFree = NO;
    [delegate setScale:scale isFree:isFree];
}

- (void)setOneWithOne
{
    if (isFlip) {
        scale = 1.0/1.0;
    }
    else {
        scale = 1.0/1.0;
    }
    isFree = NO;
    [delegate setScale:scale isFree:isFree];
}

- (void)setFree
{
    isFree = YES;
    [delegate setScale:scale isFree:isFree];
}

- (void)setFlipScale
{
    if (isFlip) {
        isFlip = NO;
    }
    else {
        isFlip = YES;
    }
    scale = 1/scale;
    [delegate setScale:scale isFree:isFree];
}

- (void)setStraighten
{
    BOOL isStraight;
    isStraight = [[NSUserDefaults standardUserDefaults] boolForKey:@"Straighten"];
    if (isStraight) {
        isStraight = NO;
    }
    else {
        isStraight = YES;
    }
    [[NSUserDefaults standardUserDefaults] setBool:isStraight forKey:@"Straighten"];
}

- (void)setStraAngle//slider
{
    NSInteger angle = [slider integerValue];
    [delegate setRotationAngle:angle];
}

- (void)leftRotate
{
    [delegate addRotateAngle:90.0];
}

- (void)rightRotate
{
    [delegate addRotateAngle:-90.0];
}

- (void)setHorizon
{
    [delegate setHorizonRotateAngle];
}

- (void)vflipImage
{
    [delegate flipImageVertical];
}

- (void)hflipImage
{
    [delegate flipImageHorizontal];
}

- (void)cancel
{
    [delegate cancelCrop];
}

- (void)done
{
    [delegate doneCrop];
}
- (void)save
{
    [delegate saveCrop];
}

@end
