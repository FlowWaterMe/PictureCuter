//
//  BaseToolController.m
//  PictureCuter
//
//  Created by Intelligent on 16/5/14.
//  Copyright © 2016年 com.Intelligent. All rights reserved.
//

#import "BaseToolController.h"
#import "Utilities.h"

@implementation BaseToolController

@synthesize baseView, showImageView;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        cropViewController = [[CropViewController alloc] init];
     }
   // NSLog(@"init");
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
   // NSLog(@"load");
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

// 在framSize内获取保持图片的比例的最大尺寸
- (NSSize)makeSizeFromFrameSize:(NSSize)frameSize withImageSize:(NSSize)imageSize
{
    NSSize newSize;
    CGFloat wratio, hratio, imageRatio;
    wratio = imageSize.width/frameSize.width;
    hratio = imageSize.height/frameSize.height;
    imageRatio = imageSize.width/imageSize.height;
    
    if (wratio>1.0 || hratio>1.0) {
        if (wratio>hratio) {
            newSize.width = frameSize.width;
            newSize.height = frameSize.width/imageRatio;
        }
        else {
            newSize.height = frameSize.height;
            newSize.width = frameSize.height*imageRatio;
        }
    }
    else {
        newSize = imageSize;
    }
    
    return newSize;
}

- (IBAction)loadImage:(id)sender
{
    if(showImage)
    {
       // [showImageView setHidden:YES];
        [cropViewController.cropView setHidden:YES];
        [cropViewController.cropArgumentView setHidden:YES];
        [cropViewController.cropViewBeautyView setHidden:YES];
    }
    else{
        
    
    [showImageView setHidden:NO];
    [cropViewController.cropView setHidden:NO];
    [cropViewController.cropArgumentView setHidden:NO];
    [cropViewController.cropViewBeautyView setHidden:NO];
    
    //[showImage dealloc];
    }
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    NSArray *nstype = [NSArray arrayWithObjects: @"jpg", @"jpeg", @"png", @"tiff", @"tif", @"bmp", @"gif", nil];
    //	NSInteger result = [panel runModalForDirectory:[@"~/Documents" stringByExpandingTildeInPath] file:nil types:nstype]; //NS_DEPRECATED_MAC(10_0, 10_6)
    [panel setDirectoryURL:[NSURL URLWithString:@"~/Documents"]];//设置打开路径在文档中
    [panel setAllowedFileTypes:nstype];
    NSInteger result = [panel runModal];
    
    if (NSFileHandlingPanelOKButton == result) {
        NSInteger i = 0;
        
        //        NSString *imagePath = [[[panel filenames] objectAtIndex:i] copy]; //NS_DEPRECATED_MAC(10_0, 10_6)
        NSString *imagePath = [[[[panel URLs] objectAtIndex:i] relativePath] copy];
//        NSLog(@"%@",imagePath);
        showImage = [[NSImage alloc] initWithContentsOfFile:imagePath];
        
        // set imageView Frame and Image
        NSSize oldFrameSize, newFrameSize, imageSize;
        NSRect newFrame;
        oldFrameSize = NSMakeSize(self.baseView.frame.size.width-100-300, self.baseView.frame.size.height-100);
        
        CGImageRef tshowImageRef = createCGImageRefFromNSImage(showImage);
        imageSize = NSMakeSize(CGImageGetWidth(tshowImageRef), CGImageGetHeight(tshowImageRef));
        
        CGImageRelease(tshowImageRef);
        
        newFrameSize = [self makeSizeFromFrameSize:oldFrameSize
                                     withImageSize:imageSize];
        newFrame.size = newFrameSize;
        newFrame.origin.x = (oldFrameSize.width-newFrameSize.width)/2+50;
        newFrame.origin.y = (oldFrameSize.height-newFrameSize.height)/2+80;
        [showImageView setFrame:newFrame];
        [showImageView setImage:showImage];
        
        // 初始化裁剪区
        NSRect viewFrame = NSMakeRect(50,
                                      80,
                                      self.baseView.frame.size.width-100-300,
                                      self.baseView.frame.size.height-100);
        if (![cropViewController.cropView isDescendantOf:baseView]) {
            [cropViewController.cropView setFrame:viewFrame];
            [baseView addSubview:cropViewController.cropView];
            cropViewController.delegate = self;
            cropViewController.cropView.midPoint = NSMakePoint(NSMidX(viewFrame), NSMidY(viewFrame));
        }
        [cropViewController setViewFrame:viewFrame andImage:showImage];
       
        //
        // 初始化裁剪区
    }
}

- (IBAction)cropImage:(id)sender {
    if (!showImage) {
        return ;
    }
    [cropViewController readyCropView];
    [cropViewController.cropArgumentView setHidden:NO];
    [showImageView setHidden:YES];
    [cropViewController.cropView setHidden:NO];//  界面都会消失
    
}

- (IBAction)beautyImage:(id)sender
{
    if (!showImage) {
        return ;
    }
    NSLog(@"beauty");
    [cropViewController.cropView setHidden:YES];
 // [cropViewController.cropRectView setHidden:YES];
 [cropViewController.cropArgumentView setHidden:YES];
 [showImageView setHidden:NO];
 [cropViewController.cropViewBeautyView setHidden:NO];

}
#pragma mark - CropViewControllerDelegate
- (void)setShowViewWithCancel
{
    [showImageView setHidden:NO];
}

- (void)setShowViewWithDone
{
    showImage = [cropViewController getRotationCropImage];
    [showImageView setImage:showImage];
    [showImageView setHidden:NO];
}
- (void)setShowViewWithSave
{
    showImage = [cropViewController getRotationCropImage];
    [showImageView setImage:showImage];
    [showImageView setHidden:NO];
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setCanCreateDirectories:YES];
//    [panel setCanChooseFiles:NO];
//    NSFileManager * fm = [NSFileManager defaultManager];
    if(NSFileHandlingPanelOKButton == [panel runModal])
    {
        NSString * filepath = [[panel URL]path];
     [[showImage TIFFRepresentation] writeToFile:filepath atomically:YES];
    }
}


@end
