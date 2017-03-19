//
//  CropViewController.m
//  PictureCuter
//
//  Created by Intelligent on 16/5/14.
//  Copyright © 2016年 com.Intelligent. All rights reserved.
//


#import "CropViewController.h"
#import "Utilities.h"

@interface CropViewController ()

@end

@implementation CropViewController

@synthesize originImage;
@synthesize cropView, cropImageView, cropRectView, cropArgumentView,cropViewBeautyView;
@synthesize delegate;
@synthesize saveCropRect, saveFrame;
@synthesize saveImage;
@synthesize saveRotateAngle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      //  NSLog(@"cropcrotle");
        cropView = [[CropView alloc] init];
        cropView.delegate = self;
        
        cropImageView = [[CropImageView alloc] init];
        cropImageView.delegate = self;
        [cropImageView setImageScaling:NSImageScaleAxesIndependently];
        [cropView addSubview:cropImageView];
        
        cropRectView = [[CropRectView alloc] init];
        cropRectView.delegate = self;
        [cropView addSubview:cropRectView];
        
        cropArgumentView = [[CropArgumentView alloc] init];
        cropArgumentView.delegate = self;
        
        
        cropViewBeautyView = [[CropViewBeautyView alloc] init];
        cropViewBeautyView.delegate = self;

        
    }
    return self;
}


// 在framSize内获取保持图片的比例的最大尺寸
- (NSSize)makeSizeFromFrameSize:(NSSize)frameSize withImageSize:(NSSize)imageSize
{
    NSSize newSize;
    
    CGFloat wratio, hratio, timageRatio;
    wratio = imageSize.width/frameSize.width;
    hratio = imageSize.height/frameSize.height;
    timageRatio = imageSize.width/imageSize.height;
    
    if (wratio>1.0 || hratio>1.0) {
        if (wratio>hratio) {
            newSize.width = frameSize.width;
            newSize.height = frameSize.width/timageRatio;
        }
        else {
            newSize.height = frameSize.height;
            newSize.width = frameSize.height*timageRatio;
        }
    }
    else {
        newSize = imageSize;
    }
    
    return newSize;
}

// 在自由模式下，将当前坐标系的点设置在imageView内
- (NSPoint)setPointFreeWithPoint:(NSPoint)point
{
    NSPoint tpoint;
    NSRect imageViewBounds;
    imageViewBounds = [cropImageView bounds];
    // 将点point从当前坐标系转到imageView的坐标系
    tpoint = [cropImageView convertPoint:point fromView:cropView];//
    //  若点超出imageViewe，根据imageView的边界分别设置X,Y
    if (tpoint.x<NSMinX(imageViewBounds)) {
        tpoint.x = NSMinX(imageViewBounds);
    }
    else if (tpoint.x>NSMaxX(imageViewBounds))
    {
        tpoint.x = NSMaxX(imageViewBounds);
    }
    if (tpoint.y<NSMinY(imageViewBounds)) {
        tpoint.y = NSMinY(imageViewBounds);
    }
    else if (tpoint.y>NSMaxY(imageViewBounds))
    {
        tpoint.y = NSMaxY(imageViewBounds);
    }
    // // 将点tpoint从imageView的坐标系转到当前坐标系
    tpoint = [cropView convertPoint:tpoint fromView:cropImageView];
    return tpoint;
}

// 将点point限制在cropImageView中，根据中心点cropMidPoint和point计算合适的最小比例
- (CGFloat)makeOriginPointFromPoint:(NSPoint)point
{
    NSPoint mpoint, epoint, tpoint;
    NSRect imageViewBounds;
    
    imageViewBounds = [cropImageView bounds];
    mpoint = cropImageView.cropMidPoint;
    epoint =[cropImageView convertPoint:point fromView:cropView];
    
    // 若点超出imageView，根据imageView的边界分别设置X,Y
    // 根据X,Y分别确定比例（生成点和传入点分别到中心点的距离比），选取较小的值计算新矩形的宽高和原点
    CGFloat scalex, scaley, scale;
    if (epoint.x<NSMinX(imageViewBounds)) {
        tpoint.x = NSMinX(imageViewBounds);
        
    }
    else if (epoint.x>NSMaxX(imageViewBounds))
    {
        tpoint.x = NSMaxX(imageViewBounds);
    }
    else
    {
        tpoint.x = epoint.x;
    }
    scalex = fabs(mpoint.x-tpoint.x)/fabs(mpoint.x-epoint.x);
    if (epoint.y<NSMinY(imageViewBounds)) {
        tpoint.y = NSMinY(imageViewBounds);
    }
    else if (epoint.y>NSMaxY(imageViewBounds))
    {
        tpoint.y = NSMaxY(imageViewBounds);
    }
    else{
        tpoint.y = epoint.y;
    }
    scaley = fabs(mpoint.y-tpoint.y)/fabs(mpoint.y-epoint.y);
    if (scalex > scaley) {
        scale = scaley;
    }
    else {
        scale = scalex;
    }
    return scale;
}

// 将rect限制在cropImageView中，保持中心点cropMidPoint和宽高比不变，生成最合适的矩形
- (NSRect)makeFitRectFromRect:(NSRect)rect
{
    NSPoint midp;
    midp = [cropView convertPoint:cropImageView.cropMidPoint fromView:cropImageView];
    
    NSRect frame;
    frame = rect;
    frame.origin.x += (midp.x-NSMidX(rect));
    frame.origin.y += (midp.y-NSMidY(rect));
    
    // 判断frame是否在imageView区域里面
    //  条件：四个顶点都在imageView区域里
    NSPoint leftp, rightp, lefttopp, righttopp;
    NSRect cropRect = frame;
    leftp = NSMakePoint(NSMinX(cropRect), NSMinY(cropRect));
    rightp = NSMakePoint(NSMaxX(cropRect), NSMinY(cropRect));
    lefttopp = NSMakePoint(NSMinX(cropRect), NSMaxY(cropRect));
    righttopp = NSMakePoint(NSMaxX(cropRect), NSMaxY(cropRect));
    
    // 根据四个顶点，返回四个原点，取原点最大值生成的矩形面积最小，将最小矩形作为新的位置
    CGFloat scale1, scale2, scale3, scale4, scale5;
    scale1 = [self makeOriginPointFromPoint:leftp];
    scale2 = [self makeOriginPointFromPoint:rightp];
    scale3 = [self makeOriginPointFromPoint:lefttopp];
    scale4 = [self makeOriginPointFromPoint:righttopp];
    scale5 = fmin(fmin(scale1, scale2), fmin(scale3, scale4));
    
    frame.origin.x = midp.x-scale5*NSWidth(rect)/2;
    frame.origin.y = midp.y-scale5*NSHeight(rect)/2;
    frame.size.width = scale5*NSWidth(rect);
    frame.size.height = scale5*NSHeight(rect);
    
    return frame;
}

// 根据View的四个顶点确定在新的坐标系下包含View的最小的矩形大小
- (NSRect)makeRectFromView:(NSView *)view withSuperView:(NSView *)sview
{
    NSPoint leftp, rightp, lefttopp, righttopp;
    NSRect tbounds, newRect;
    tbounds = [view bounds];
    leftp = NSMakePoint(NSMinX(tbounds), NSMinY(tbounds));
    rightp = NSMakePoint(NSMaxX(tbounds), NSMinY(tbounds));
    lefttopp = NSMakePoint(NSMinX(tbounds), NSMaxY(tbounds));
    righttopp = NSMakePoint(NSMaxX(tbounds), NSMaxY(tbounds));
    leftp = [sview convertPoint:leftp fromView:view];
    rightp = [sview convertPoint:rightp fromView:view];
    lefttopp = [sview convertPoint:lefttopp fromView:view];
    righttopp = [sview convertPoint:righttopp fromView:view];
    CGFloat minx, maxx, miny, maxy, width, height;
    minx = fminf(fminf(leftp.x, rightp.x), fminf(lefttopp.x, righttopp.x));
    maxx = fmaxf(fmaxf(leftp.x, rightp.x), fmaxf(lefttopp.x, righttopp.x));
    miny = fminf(fminf(leftp.y, rightp.y), fminf(lefttopp.y, righttopp.y));
    maxy = fmaxf(fmaxf(leftp.y, rightp.y), fmaxf(lefttopp.y, righttopp.y));
    width = maxx-minx;
    height = maxy-miny;
    newRect = NSMakeRect(0.0, 0.0, width, height);
    
    return newRect;
}


// 三点之间的夹角
- (CGFloat)getAngleWithLastPoint:(NSPoint)lPoint andCurentPoint:(NSPoint)curPoint andCirclePoint:(NSPoint)cirPoint
{
    CGFloat angle, langle, curangle;
    //  atan2 return -π to π
    langle = atan2(lPoint.y-cirPoint.y, lPoint.x-cirPoint.x)*180/M_PI;
    curangle = atan2(curPoint.y-cirPoint.y, curPoint.x-cirPoint.x)*180/M_PI;
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
    return angle;
}

// 裁剪指定区域图片
// 把图片重新画在一个context中，根据裁剪矩形按比例缩放后裁剪图片
- (NSImage *)getRotationCropImage
{
    saveRotateAngle = cropView.rotateAngle;
    //  包含图片的最小矩形
    NSRect rect = [self makeRectFromView:cropImageView withSuperView:cropView];
    NSRect tcivRect;
    tcivRect = [cropImageView frame];
    CGImageRef forCropImageRef = createCGImageRefFromNSImage(saveImage);
    CGFloat imageWidth = CGImageGetWidth(forCropImageRef);
    CGFloat imageViewWidth = tcivRect.size.width;
    CGFloat imageScale = imageWidth/imageViewWidth;
    rect.size.width *= imageScale;
    rect.size.height *= imageScale;
    
    //  计算裁剪矩形在创建图片中的位置
    //  通过计算裁剪区中心点与图片中心点的距离，按比例计算出新的裁剪区域的中心点坐标
    NSPoint imagep = NSMakePoint(NSWidth(tcivRect)/2, NSHeight(tcivRect)/2); // 中心点
    imagep = [cropView convertPoint:imagep fromView:cropImageView];
    NSRect tcrvRect = [cropRectView frame];
    NSPoint cropp = NSMakePoint(NSMidX(tcrvRect), NSMidY(tcrvRect));
    CGFloat dx, dy;
    dx = imagep.x-cropp.x;
    dy = imagep.y-cropp.y;
    dx *= imageScale;
    dy *= imageScale;
    NSPoint timagep, tcropp;
    timagep = NSMakePoint(NSMidX(rect), NSMidY(rect));
    tcropp = NSMakePoint(timagep.x-dx, timagep.y-dy);
    NSRect trect;
    trect.size.width = NSWidth(tcrvRect)*imageScale;
    trect.size.height = NSHeight(tcrvRect)*imageScale;
    trect.origin.x = tcropp.x-trect.size.width/2;
    // 原点在左上角
    trect.origin.y = NSHeight(rect)-(tcropp.y+trect.size.height/2);
    
    // 生成当前图片对应的原图
    CGContextRef context = MyCreateBitmapContext(rect.size.width, rect.size.height);
    CGFloat imagew, imageh;
    imagew = CGImageGetWidth(forCropImageRef);
    imageh = CGImageGetHeight(forCropImageRef);
    CGRect imageRect = CGRectMake((rect.size.width-imagew)/2,
                                  (rect.size.height-imageh)/2,
                                  imagew,
                                  imageh);
    
    // 将图片画在context中的过程
    //  将原点移到中心点，然后按旋转角度做旋转，再把中心点移到原点，在context中的指定矩形中画图
    CGContextTranslateCTM(context, NSWidth(rect)/2, NSHeight(rect)/2);
    CGContextRotateCTM(context, cropView.rotateAngle*M_PI/180);
    CGContextTranslateCTM(context, -NSWidth(rect)/2, -NSHeight(rect)/2);
    CGContextDrawImage(context, imageRect, forCropImageRef);
    
    CGImageRef doneCropImageRef = CGBitmapContextCreateImage(context);
    NSImage *tcropImage = createNSImageFromCGImageRef(doneCropImageRef);
    
    [[tcropImage TIFFRepresentation] writeToFile:@"/Users/mac/Downloads/one.jpg" atomically:YES];
    
    // 获取裁剪后的图片
    CGImageRef tdoneCropImageRef = CGImageCreateWithImageInRect(doneCropImageRef, trect);
    NSImage *timage = createNSImageFromCGImageRef(tdoneCropImageRef);
    
 //   [[timage TIFFRepresentation] writeToFile:@"/Users/mac/Downloads/tow.jpg" atomically:YES];
    
    return timage;
}

- (NSImage *)flipVerticalWithImage:(NSImage *)image
{
    CGImageRef imageRef = createCGImageRefFromNSImage(image);
    CGFloat imagew, imageh;
    NSRect rect;
    imagew = CGImageGetWidth(imageRef);
    imageh = CGImageGetHeight(imageRef);
    rect = NSMakeRect(0.0, 0.0, imagew, imageh);
    CGContextRef context = MyCreateBitmapContext(imagew, imageh);
    CGContextSaveGState(context);
    // 上下翻转
    CGContextTranslateCTM(context, 0.0f, rect.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextDrawImage(context, rect, imageRef);
    CGContextRestoreGState(context);
    CGImageRef flipImageRef = CGBitmapContextCreateImage(context);
    NSImage *flipImage = createNSImageFromCGImageRef(flipImageRef);
    CGImageRelease(flipImageRef);
    CGImageRelease(imageRef);
    
    return flipImage;
}

- (NSImage *)flipHorizontalWithImage:(NSImage *)image
{
    CGImageRef imageRef = createCGImageRefFromNSImage(image);
    CGFloat imagew, imageh;
    NSRect rect;
    imagew = CGImageGetWidth(imageRef);
    imageh = CGImageGetHeight(imageRef);
    rect = NSMakeRect(0.0, 0.0, imagew, imageh);
    CGContextRef context = MyCreateBitmapContext(imagew, imageh);
    CGContextSaveGState(context);
    // 左右翻转
    CGContextTranslateCTM(context, rect.size.width,0.0f);
    CGContextScaleCTM(context, -1.0f, 1.0f);
    CGContextDrawImage(context, rect, imageRef);
    CGContextRestoreGState(context);
    CGImageRef flipImageRef = CGBitmapContextCreateImage(context);
    NSImage *flipImage = createNSImageFromCGImageRef(flipImageRef);
    CGImageRelease(flipImageRef);
    CGImageRelease(imageRef);
    
    return flipImage;
}

#pragma mark - Interface
// 用于加载图片,设置参数saveImage,saveFrame
- (void)setViewFrame:(NSRect)rect andImage:(NSImage *)image
{
    if (![cropArgumentView superview]) {
        [[cropView superview] addSubview:cropArgumentView];
         [cropArgumentView setHidden:YES];
        
        [cropArgumentView initButtons];//初始化按钮
    }
    if (![cropViewBeautyView superview]) {
       // NSLog(@"pan duan");
        [[cropView superview] addSubview:cropViewBeautyView];
        [cropViewBeautyView setHidden:YES];
        
        [cropViewBeautyView initButton];//初始化按钮
    }
    [cropArgumentView setFrame:NSMakeRect(NSMaxX(rect), NSMinY(rect), 300, NSHeight(rect))];
    cropArgumentView.isFree = YES;
    cropRectView.isScale = NO;
   
    [cropViewBeautyView setFrame:NSMakeRect(NSMaxX(rect), NSMinY(rect), 300, NSHeight(rect))];
    
    NSSize oldFrameSize, newFrameSize, imageSize;
    NSRect newFrame;
    oldFrameSize.width = rect.size.width-100;
    oldFrameSize.height = rect.size.height-100;
    
    CGImageRef tshowImageRef = createCGImageRefFromNSImage(image);
    imageSize = NSMakeSize(CGImageGetWidth(tshowImageRef), CGImageGetHeight(tshowImageRef));
    NSRect flipRect;
    flipRect.origin = NSMakePoint(0, 0);
    flipRect.size = imageSize;
    
    cropArgumentView.originScale = (CGFloat)CGImageGetWidth(tshowImageRef)/(CGFloat)CGImageGetHeight(tshowImageRef);
    CGImageRelease(tshowImageRef);
    
    newFrameSize = [self makeSizeFromFrameSize:oldFrameSize
                                 withImageSize:imageSize];
    newFrame.size = newFrameSize;
    newFrame.origin.x = (rect.size.width-newFrameSize.width)/2;
    newFrame.origin.y = (rect.size.height-newFrameSize.height)/2;
    
    saveCropRect = NSMakeRect(NSMinX(newFrame)+100,
                              NSMinY(newFrame)+100,
                              NSWidth(newFrame)-200,
                              NSHeight(newFrame)-200);
    saveFrame = newFrame;
    saveImage = image;
    saveRotateAngle = 0.0;
    cropView.rotateAngle = 0.0;
    
    originImage = image;
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Straighten"];
}

- (void)readyCropView
{
      [cropArgumentView setHidden:NO];
  //  [cropViewBeautyView setHidden:NO];
    // 先把旋转角度设置为0，再设置Frame  增加灰色

    [cropImageView setFrameCenterRotation:0.0];
    [cropImageView setFrame:saveFrame];
    [cropImageView setFrameCenterRotation:saveRotateAngle];
    [cropImageView setImage:saveImage];
     //增加截图框
     [cropRectView setFrame:saveCropRect];
     cropRectView.downRect = saveCropRect;
     cropImageView.cropRect = saveCropRect;
     cropRectView.scaleWH = NSWidth(saveCropRect)/NSHeight(saveCropRect);
    
    NSPoint cmidPoint; //  cropRectView裁剪矩形的中心点
    cmidPoint = NSMakePoint(NSMidX(saveCropRect), NSMidY(saveCropRect));
    cmidPoint = [cropView convertPoint:cmidPoint toView:cropImageView];
    cropImageView.cropMidPoint = cmidPoint;
    
}

#pragma mark - CropViewDelegate
- (void)setFrameWithRotation:(CGFloat)angle
{
    [cropImageView setFrameCenterRotation:angle];
    NSRect frame;
    frame = [self makeFitRectFromRect:cropRectView.downRect];
    [cropRectView setFrame:frame];
    cropImageView.cropRect = frame;
}

- (void)setAngleSlide
{
    NSInteger angle, angleSlider;
    angle = cropView.rotateAngle;
    //  -45 to 45
    angleSlider = angle%90;
    if (angleSlider>45) {
        angle = 90-angleSlider;
    }
    else {
        angle = -angleSlider;
    }
    [cropArgumentView.slider setIntegerValue:angle];
    
}

#pragma mark - CropRectViewDelegate
// 根据imageView的边界确定cropRectView的位置，以imageView的坐标系为准
- (void)setFrameWithDrag
{
    NSPoint startPoint, endPoint;
    CGFloat dx, dy;
    startPoint = [cropImageView convertPoint:cropRectView.downPoint fromView:nil];
    endPoint = [cropImageView convertPoint:cropRectView.dragPoint fromView:nil];
    dx = endPoint.x-startPoint.x;
    dy = endPoint.y-startPoint.y;
    
    NSPoint leftp, rightp, lefttopp, righttopp, midp;
    NSRect cropRect = cropRectView.downRect;
    NSRect imageViewBounds = [cropImageView bounds];
    leftp = NSMakePoint(NSMinX(cropRect), NSMinY(cropRect));
    rightp = NSMakePoint(NSMaxX(cropRect), NSMinY(cropRect));
    lefttopp = NSMakePoint(NSMinX(cropRect), NSMaxY(cropRect));
    righttopp = NSMakePoint(NSMaxX(cropRect), NSMaxY(cropRect));
    midp = NSMakePoint(NSMidX(cropRect), NSMidY(cropRect));
    
    leftp = [cropImageView convertPoint:leftp fromView:cropView];
    rightp = [cropImageView convertPoint:rightp fromView:cropView];
    lefttopp = [cropImageView convertPoint:lefttopp fromView:cropView];
    righttopp = [cropImageView convertPoint:righttopp fromView:cropView];
    midp = [cropImageView convertPoint:midp fromView:cropView];
    
    CGFloat minx, miny, maxx, maxy;
    minx = fminf(fminf(leftp.x, rightp.x), fminf(lefttopp.x, righttopp.x));
    maxx = fmaxf(fmaxf(leftp.x, rightp.x), fmaxf(lefttopp.x, righttopp.x));
    miny = fminf(fminf(leftp.y, rightp.y), fminf(lefttopp.y, righttopp.y));
    maxy = fmaxf(fmaxf(leftp.y, rightp.y), fmaxf(lefttopp.y, righttopp.y));
    
    CGFloat tx, ty;
    // X轴越界
    if((minx+dx)<NSMinX(imageViewBounds))
    {
        tx = NSMinX(imageViewBounds)-minx;
    }
    else if((maxx+dx)>NSMaxX(imageViewBounds))
    {
        tx = NSMaxX(imageViewBounds)-maxx;
    }
    else {
        tx = dx;
    }
    leftp.x += tx;
    midp.x += tx;
    
    // Y轴越界
    if((miny+dy)<NSMinY(imageViewBounds))
    {
        ty = NSMinY(imageViewBounds)-miny;
    }
    else if((maxy+dy)>NSMaxY(imageViewBounds))
    {
        ty = NSMaxY(imageViewBounds)-maxy;
    }
    else {
        ty = dy;
    }
    leftp.y += ty;
    midp.y += ty;
    
    leftp = [cropView convertPoint:leftp fromView:cropImageView];
    NSRect trect;
    trect.origin = leftp;
    trect.size = [cropRectView frame].size;
    [cropRectView setFrame:trect];
    cropImageView.cropRect = trect;
    cropImageView.cropMidPoint = midp;
    [cropImageView display];
}

- (void)setArgumentsWithFrame:(NSRect)rect
{
    [cropRectView setFrame:rect];
    cropImageView.cropRect = rect;
    NSPoint midp = NSMakePoint(NSMidX(rect), NSMidY(rect));
    midp = [cropImageView convertPoint:midp fromView:cropView];
    cropImageView.cropMidPoint = midp;
    [cropImageView display]; //  每次drag都更新
}

// 将当前坐标系的点设置在imageView内
- (NSPoint)setPointWithPoint:(NSPoint)point
{
    NSPoint tpoint;
    NSRect imageViewBounds;
    imageViewBounds = [cropImageView bounds];
    // 将点point从当前坐标系转到imageView的坐标系
    tpoint = [cropImageView convertPoint:point fromView:cropView];
    //  若点超出imageViewe，根据imageView的边界分别设置X,Y
    if (tpoint.x<NSMinX(imageViewBounds)) {
        tpoint.x = NSMinX(imageViewBounds);
    }
    else if (tpoint.x>NSMaxX(imageViewBounds))
    {
        tpoint.x = NSMaxX(imageViewBounds);
    }
    if (tpoint.y<NSMinY(imageViewBounds)) {
        tpoint.y = NSMinY(imageViewBounds);
    }
    else if (tpoint.y>NSMaxY(imageViewBounds))
    {
        tpoint.y = NSMaxY(imageViewBounds);
    }
    // // 将点tpoint从imageView的坐标系转到当前坐标系
    tpoint = [cropView convertPoint:tpoint fromView:cropImageView];
    return tpoint;
}

- (NSPoint)setPointWithFixPoint:(NSPoint)fixPoint
                  andCrossPoint:(NSPoint)crossPoint
{
    NSPoint tpoint;
    NSRect imageViewBounds;
    imageViewBounds = [cropImageView bounds];
    // 将点point从当前坐标系转到imageView的坐标系
    crossPoint = [cropImageView convertPoint:crossPoint fromView:cropView];
    fixPoint = [cropImageView convertPoint:fixPoint fromView:cropView];
    //  若点超出imageViewe，根据imageView的边界分别设置X,Y
    tpoint = crossPoint;
    if (tpoint.x<NSMinX(imageViewBounds)) {
        tpoint.x = NSMinX(imageViewBounds);
        CGFloat dx;
        dx = fabsf(crossPoint.x-tpoint.x)/fabsf(fixPoint.x-tpoint.x);
        tpoint.y = fixPoint.y-(fixPoint.y-crossPoint.y)/(1+dx);
    }
    else if (tpoint.x>NSMaxX(imageViewBounds))
    {
        tpoint.x = NSMaxX(imageViewBounds);
        CGFloat dx;
        dx = fabsf(crossPoint.x-tpoint.x)/fabsf(fixPoint.x-tpoint.x);
        tpoint.y = fixPoint.y-(fixPoint.y-crossPoint.y)/(1+dx);
    }
    if (tpoint.y<NSMinY(imageViewBounds)) {
        tpoint.y = NSMinY(imageViewBounds);
        CGFloat dy;
        dy = fabsf(crossPoint.y-tpoint.y)/fabsf(fixPoint.y-tpoint.y);
        tpoint.x = fixPoint.x-(fixPoint.x-crossPoint.x)/(1+dy);
    }
    else if (tpoint.y>NSMaxY(imageViewBounds))
    {
        tpoint.y = NSMaxY(imageViewBounds);
        CGFloat dy;
        dy = fabsf(crossPoint.y-tpoint.y)/fabsf(fixPoint.y-tpoint.y);
        tpoint.x = fixPoint.x-(fixPoint.x-crossPoint.x)/(1+dy);
        
    }
    // // 将点tpoint从imageView的坐标系转到当前坐标系
    tpoint = [cropView convertPoint:tpoint fromView:cropImageView];
    return tpoint;
}

#pragma mark - CropArgumentView
// 切换比例时裁剪区域的面积保持不变，如果保持不变会越界就适当缩小
- (void)setScale:(CGFloat)scale isFree:(BOOL)isFree
{
    if (isFree) {
        cropRectView.isScale = NO;
    }
    else
    {
        cropRectView.isScale = YES;
        cropRectView.scaleWH = scale;
        CGFloat ow, oh, nw, nh;
        NSRect oframe, nframe;
        oframe = [cropRectView frame];
        ow = NSWidth(oframe);
        oh = NSHeight(oframe);
        nw = sqrtf(ow*oh*scale);
        nh = nw/scale;
        nframe.origin.x = NSMidX(oframe)-nw/2;
        nframe.origin.y = NSMidY(oframe)-nh/2;
        nframe.size.width = nw;
        nframe.size.height = nh;
        
        nframe = [self makeFitRectFromRect:nframe];//
        
        [cropRectView setFrame:nframe];
        cropImageView.cropRect = nframe;
            NSPoint midp = NSMakePoint(NSMidX(nframe), NSMidY(nframe));
            midp = [cropImageView convertPoint:midp fromView:self.view];
            cropImageView.cropMidPoint = midp;
            [cropImageView display]; //  每次drag都更新
        cropRectView.downRect = nframe;
    }
}

- (void)setRotationAngle:(NSInteger)angle
{
    NSInteger n, d , tangle;
    tangle = cropView.rotateAngle;
    n = tangle/90;
    d = tangle%90;
    if (d>45) {
        tangle = (n+1)*90-angle;
    }
    else if (d<45){
        tangle = n*90-angle;
    }
    else {
        if (angle>0) {
            tangle = (n+1)*90-angle;
        }
        else {
            tangle = n*90-angle;
        }
    }
    // 0---360
    if (tangle<0)
    {
        tangle += 360;
    }
    if(tangle >= 360)
    {
        tangle -= 360;
    }
    cropView.rotateAngle = tangle;
    [self setFrameWithRotation:tangle];
}

- (void)addRotateAngle:(CGFloat)angle
{
    CGFloat tangle;
    tangle = cropView.rotateAngle+angle;
    // 0---360
    if (tangle<0)
    {
        tangle += 360;
    }
    if(tangle >= 360)
    {
        tangle -= 360;
    }
    cropView.rotateAngle = tangle;
    [self setFrameWithRotation:tangle];
    [self setAngleSlide];
}

- (void)setHorizonRotateAngle
{
    CGFloat tangle;
    tangle = 0.0;
    cropView.rotateAngle = tangle;
    
    [self setFrameWithRotation:tangle];
    [self setAngleSlide];
}

- (void)flipImageVertical
{
    saveImage = [self flipVerticalWithImage:saveImage];
    [cropImageView setImage:saveImage];
}

- (void)flipImageHorizontal
{
    saveImage = [self flipHorizontalWithImage:saveImage];
    [cropImageView setImage:saveImage];
}
- (void)cancelCrop
{
    
    [cropArgumentView setHidden:NO];
    [cropView setHidden:YES];
    cropView.rotateAngle = saveRotateAngle;
    [delegate setShowViewWithCancel];
}

- (void)doneCrop
{
    [cropArgumentView setHidden:NO];
    [cropView setHidden:YES];
    saveCropRect = [cropRectView frame];
    saveRotateAngle = cropView.rotateAngle;
    [delegate setShowViewWithDone];
}
- (void)saveCrop
{
    [cropArgumentView setHidden:NO];
    [cropView setHidden:YES];
    saveCropRect = [cropRectView frame];
    saveRotateAngle = cropView.rotateAngle;
    [delegate setShowViewWithSave];
    //   NSSavePanel *panel = [NSSavePanel savePanel];
    //    showImage
    //    [panel setCanChooseDirectories:YES];
    //    [panel setCanChooseFiles:NO];
    //
    
    //   [panel setCanCreateDirectories:YES];
    //    if(NSFileHandlingPanelOKButton == [panel runModal])
    //    {
    //
    //    }
    //
}



#pragma mark -cropViewBeautyViewDelegate

-(void)setcomparedegree
{
   
}

-(void)settransparencydegree
{
    
}

-(void)setdecreasenoise
{
    
}

-(void)cancelButy
{
    [cropView setHidden:YES];
    //    saveCropRect = [cropRectView frame];
    
    
}
-(void)doneButy
{
    
}
-(void)savaButy
{
    
}

@end
