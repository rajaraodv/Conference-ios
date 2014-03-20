//
//  SFImageManager.m
//  Conference
//
//  Created by Raja Rao DV on 3/19/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "SFImageManager.h"
#import "IconDownloader.h"



@implementation SFImageManager

+ (SFImageManager *)sharedInstance {
    static SFImageManager *sharedInstance;
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[SFImageManager alloc] init];
            [sharedInstance initStuff];
        }
    }
    return sharedInstance;
}

-(void) initStuff {
    //init
    self.imageDownloadsInProgress =  [NSMutableDictionary dictionary];
    self.imageCache =  [NSMutableDictionary dictionary];
}



- (void)setImageView:(UIImageView *)imageView forImageUrl:(NSString *)imageUrl WithRadius:(float) radius {
    
    UIImage *image = [self.imageCache objectForKey:imageUrl];
    if (image != nil) {
        imageView.image = image;
        if(radius > 0) {
            [self makeImageViewRounded:imageView withRadius:radius];
        }
        return;
    }
    
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:imageUrl];
    if (iconDownloader == nil) {
        iconDownloader = [[IconDownloader alloc] init];
        [iconDownloader setCompletionHandler:^(UIImage *image) {
            
            
            // Display the newly loaded image
            [self.imageCache setObject:image forKey:imageUrl];
            
            //set loaded image
            imageView.image = image;
            if(radius > 0) {
                [self makeImageViewRounded:imageView withRadius:radius];
            }

            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:imageUrl];
            
        }];
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:imageUrl];
        
        [iconDownloader startDownloadWithURL:imageUrl AndToken:nil];
    }
}

- (void)setBackgroundImageForView:(UIView *)view withImageUrl:(NSString *)imageUrl {
    
    UIImage *image = [self.imageCache objectForKey:imageUrl];
    if (image != nil) {
        view.backgroundColor = [UIColor colorWithPatternImage:image];
        
        return;
    }
    
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:imageUrl];
    if (iconDownloader == nil) {
        iconDownloader = [[IconDownloader alloc] init];
        [iconDownloader setCompletionHandler:^(UIImage *image) {
            
            
            // Display the newly loaded image
            [self.imageCache setObject:image forKey:imageUrl];
            view.backgroundColor = [UIColor colorWithPatternImage:image];
            
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:imageUrl];
            
        }];
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:imageUrl];
        
        [iconDownloader startDownloadWithURL:imageUrl AndToken:nil];
    }
}

-(void) makeImageViewRounded:(UIImageView *)imageView withRadius:(float) radius {
    
    
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, [UIScreen mainScreen].scale);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:imageView.bounds
                                cornerRadius:radius] addClip];
    // Draw your image
    [imageView.image drawInRect:imageView.bounds];
    
    // Get the image, here setting the UIImageView image
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
}
@end
