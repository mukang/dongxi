//
//  DXPSLinearTiltShiftLayer.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/25.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPhotoShopLayer.h"


@interface DXPSLinearTiltShiftLayer : DXPhotoShopLayer

/** 模糊的范围，0 到 1.0 */
@property (nonatomic, assign) CGFloat range;
/** 模糊的中心，范围从{0,0}到{0,1}，默认{0,0.5} */
@property (nonatomic, assign) CGPoint blurCenter;

@property (nonatomic, assign) CGFloat rangeScaleOfHeight;

- (void)resetBlurInputs;

@end
