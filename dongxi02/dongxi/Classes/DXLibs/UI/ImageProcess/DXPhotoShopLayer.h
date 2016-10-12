//
//  DXPhotoShopLayer.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/25.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CIFilter;
@class CIImage;


@protocol DXPhotoShopLayer <NSObject>

@required
- (CIFilter *)filter;

@end



@interface DXPhotoShopLayer : NSObject <DXPhotoShopLayer>

@property (nonatomic, assign) BOOL disabled;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, strong) NSString * filterName;

@property (nonatomic, strong) CIImage * inputImage;
@property (nonatomic, readonly) CIImage * outputImage;

@property (nonatomic, strong) NSDictionary * attributes;

@end
