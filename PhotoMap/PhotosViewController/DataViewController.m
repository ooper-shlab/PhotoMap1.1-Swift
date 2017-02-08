/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The view controller representing each page in PhotosViewController.
 */

#import "DataViewController.h"
#import "PhotoAnnotation.h"

@interface DataViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@end

@implementation DataViewController

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // we want for the title to only be the image name (obtained from the file system path)
    NSString *title = [self.dataObject.imagePath lastPathComponent];
    title = [title stringByDeletingPathExtension];
    self.title = title;
    
    self.imageView.image = self.dataObject.image;
}

@end
