//
//  SFImageManager.h
//  Conference
//
//  Created by Raja Rao DV on 3/19/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFImageManager : NSObject
//used to download asynchronously images
@property(strong, nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@property(strong, nonatomic) NSMutableDictionary *imageCache;

- (void)setImageView:(UIImageView *)imageView forImageUrl:(NSString *)imageUrl WithRadius:(float) radius;
-(void) makeImageViewRounded:(UIImageView *)imageView withRadius:(float) radius;
- (void)setBackgroundImageForView:(UIView *)view withImageUrl:(NSString *)imageUrl;

+ (id) sharedInstance;
@end
