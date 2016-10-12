//
//  DXFeedPhoto.h
//  dongxi
//
//  Created by 穆康 on 16/3/1.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "DXFeedPhotoProtocol.h"

@interface DXFeedPhoto : NSObject <DXFeedPhoto>

@property (nonatomic) BOOL emptyImage;

+ (DXFeedPhoto *)photoWithImage:(UIImage *)image;
+ (DXFeedPhoto *)photoWithURL:(NSURL *)url;

- (id)init;
- (id)initWithImage:(UIImage *)image;
- (id)initWithURL:(NSURL *)url;

@end
