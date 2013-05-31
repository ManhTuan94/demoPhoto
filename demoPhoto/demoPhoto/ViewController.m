//
//  ViewController.m
//  demoPhoto
//
//  Created by TechmasterVietNam on 5/31/13.
//  Copyright (c) 2013 TechmasterVietNam. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"
#import "GPUImagePixellatePositionFilter.h"
//#import "GPUImageRGBFilter.h"
#import <QuartzCore/QuartzCore.h>
#import "GPUImageFilter.h"



@interface ViewController () {
  GPUImageStillCamera *vc;
    UIImage *originalImage;
    BOOL cameraBool;

}
@property(strong,nonatomic) UIImageView* selectedImageView;
@property (readwrite, nonatomic) CGPoint localPoint;
@property(readwrite,nonatomic) GPUImagePixellatePositionFilter *ppf;
@end

@implementation ViewController
@synthesize ppf,localPoint;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    localPoint = [touch locationInView:self.view];
    NSLog(@"X location: %f", localPoint.x);
    NSLog(@"Y Location: %f", localPoint.y);
    ppf.center = CGPointMake(localPoint.y/self.view.frame.size.height, (1-localPoint.x/self.view.frame.size.width));

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *output = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain
                                                                     target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = output;
    
    UIBarButtonItem *input = [[UIBarButtonItem alloc] initWithTitle:@"Album" style:UIBarButtonItemStylePlain
                                                                     target:self action:@selector(input)];
    self.navigationItem.leftBarButtonItem = input;
    
    UIButton *camera = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
//    [[camera layer] setBorderWidth:2.0f];
//    [[camera layer] setBorderColor:[UIColor blackColor].CGColor];
    [[camera layer] setCornerRadius:7.0f];

    [camera setImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
    [camera addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = camera;
    
    ppf = [[GPUImagePixellatePositionFilter alloc] init];
    ppf.center = CGPointMake(0.5, 0.5);
    ppf.fractionalWidthOfAPixel = 0.03;
    ppf.radius = 0.1;
    
    vc = [[GPUImageStillCamera alloc] init];
//    [vc rotateCamera];
    vc.outputImageOrientation = UIInterfaceOrientationPortrait;
    [vc addTarget:ppf];
    GPUImageView *v = [[GPUImageView alloc] init];
    [ppf addTarget:v];
    self.view=v;
    cameraBool = YES;
    if (cameraBool==YES) {
        [vc startCameraCapture];
    }
    
    originalImage = [[UIImage alloc] init];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *alertTitle;
    NSString *alertMessage;
    if(!error)
    {
        alertTitle   = @"Image Saved";
        alertMessage = @"Image saved to photo album successfully.";
    }
    else
    {
        alertTitle   = @"Error";
        alertMessage = @"Unable to save to photo album.";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                    message:alertMessage
                                                   delegate:self
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
    [alert show];
}
-(void)takePhoto{
    cameraBool=YES;
    [vc startCameraCapture];
    [self.selectedImageView removeFromSuperview];
}
-(void)input{
    
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:photoPicker animated:YES completion:NULL];
}
- (void)imagePickerController:(UIImagePickerController *)photoPicker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//    self.saveButton.enabled = YES;
//    self.filterButton.enabled = YES;
    originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    UIImage *selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.selectedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-100)];
    self.selectedImageView.contentMode = UIViewContentModeCenter;
    self.selectedImageView.image = selectedImage;
    [self.view addSubview:self.selectedImageView];
    [vc stopCameraCapture];
    cameraBool=NO;
    [self dismissViewControllerAnimated:YES completion:^{}];
}
-(void)save{
    if (cameraBool==NO) {
        UIImageWriteToSavedPhotosAlbum(self.selectedImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        [vc startCameraCapture];
        [self.selectedImageView removeFromSuperview];
    }
    if (cameraBool==YES) {
//        UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
//        photoPicker.delegate = self;
//        photoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//        [self presentViewController:photoPicker animated:YES completion:NULL];

        GPUImageFilter *selectedFilter;
        UIImage *filteredImage = [selectedFilter imageByFilteringImage:originalImage];
        UIImageWriteToSavedPhotosAlbum(filteredImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }

    [vc startCameraCapture];
    NSLog(@"%c",cameraBool);
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:photoPicker animated:YES completion:NULL];
}
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    CGPoint location = [[touches anyObject] locationInView:self.view];
//    CGSize pixelS = CGSizeMake(location.x / self.view.bounds.size.width * 0.05, location.y / self.view.bounds.size.height * 0.05);
//    [ppf setPixelSize:pixelS];
//}
//
//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    CGPoint location = [[touches anyObject] locationInView:self.view];
//    CGSize pixelS = CGSizeMake(location.x / self.view.bounds.size.width * 0.5, location.y / self.view.bounds.size.height * 0.5);
//    [ppf setPixelSize:pixelS];
//}
@end