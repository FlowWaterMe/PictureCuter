//
//  CropViewBeautyView.m
//  PictureCuter
//
//  Created by Intelligent on 16/5/15.
//  Copyright © 2016年 com.Intelligent. All rights reserved.
//

#import "CropViewBeautyView.h"

@implementation CropViewBeautyView
@synthesize delegate;
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
-(id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
//       [self initButton];
      //  NSLog(@"init betiful");
    }
    return self;
}

-(void)initButton
{
    NSButton *bt1,*bt2,*bt3,*bt4,*bt5,*bt6,*bt7,*bt8,*bt9,*bt10;
    NSButton *cancelBtn,*doneBtn,*saveBtn;
     NSLog(@"betifullly");
    bt1 = [[NSButton alloc] initWithFrame:NSMakeRect(30, 500, 100, 30)];
    [bt1 setTarget:self];
    [bt1 setTitle:@"White"];
    [bt1 setAction:@selector(setDuiBiDu)];
    
    bt2 = [[NSButton alloc] initWithFrame:NSMakeRect(150,500,100,30)];
    [bt2 setTarget:self];
    [bt2 setTitle:@"Blue"];
    [bt2 setAction:@selector(setTouMingDu)];
    
    bt3 = [[NSButton alloc] initWithFrame:NSMakeRect(30, 450, 100, 30)];
    [bt3 setTarget:self];
    [bt3 setTitle:@"Blue1"];
    [bt3 setAction:@selector(setJiangZao)];
    
    bt4 = [[NSButton alloc] initWithFrame:NSMakeRect(150, 450, 100, 30)];
    [bt4 setTarget:self];
    [bt4 setTitle:@"White1"];
    
    bt5 = [[NSButton alloc] initWithFrame:NSMakeRect(30, 400, 100, 30)];
    [bt5 setTarget:self];
    [bt5 setTitle:@"White2"];
    
    bt6= [[NSButton alloc] initWithFrame:NSMakeRect(150, 400, 100, 30)];
    [bt6 setTarget:self];
    [bt6 setTitle:@"White3"];
    
    bt7 = [[NSButton alloc] initWithFrame:NSMakeRect(30, 350, 100, 30)];
    [bt7 setTarget:self];
    [bt7 setTitle:@"White4"];
    
    bt8 = [[NSButton alloc] initWithFrame:NSMakeRect(150, 350, 100, 30)];
    [bt8 setTarget:self];
    [bt8 setTitle:@"White5"];
    
    bt9 = [[NSButton alloc] initWithFrame:NSMakeRect(30, 300, 100, 30)];
    [bt9 setTarget:self];
    [bt9 setTitle:@"White6"];
    
    bt10 = [[NSButton alloc] initWithFrame:NSMakeRect(150, 300, 100, 30)];
    [bt10 setTarget:self];
    [bt10 setTitle:@"White"];

    
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
    [self addSubview:bt1];
    [self addSubview:bt2];
    [self addSubview:bt3];
    [self addSubview:bt4];
    [self addSubview:bt5];
    [self addSubview:bt6];
    [self addSubview:bt7];
    [self addSubview:bt8];
    [self addSubview:bt9];
    [self addSubview:bt10];
    
}

-(void)setCompareDegree
{
    //[delegate setcomparedegree];
}

-(void)setTransparencyDegree
{
    //[delegate settransparencydegree];
}

-(void)setDecreaseNoise
{
    //[delegate setdegreasenoise];
}
- (void)cancel
{
    [delegate cancelButy];
    
}

- (void)done
{
    [delegate doneButy];
}
- (void)save
{
    [delegate saveButy];
}



@end



























