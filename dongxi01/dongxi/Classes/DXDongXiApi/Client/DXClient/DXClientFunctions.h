//
//  DXClientFunctions.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/12.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef dongxi_DXClientFunctions_h
#define dongxi_DXClientFunctions_h

#define DXCLIENT_LOG_ON 0

#if DXCLIENT_LOG_ON == 1
#define DXClientLog(FORMAT, ...) NSLog(@"\n<DXClient Debug> %s [Line %d] " FORMAT, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DXClientLog(FORMAT, ...)
#endif


#endif