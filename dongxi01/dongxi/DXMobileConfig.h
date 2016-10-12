//
//  DXMobileConfig.h
//  dongxi
//
//  Created by Xu Shiwen on 15/11/9.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#ifndef dongxi_DXMobileConfig_h
#define dongxi_DXMobileConfig_h

#define DXMobileHost                @"www.dongxi365.com"

#define DXMobilePageFeedURLFormat       @"http://" DXMobileHost "/wap.php?r=wap/feed/detail&id=%@"
#define DXMobilePageActivityURLFormat   @"http://" DXMobileHost "/wap.php?r=wap/activity/detail&id=%@"
#define DXMobilePageTopicRankHelpURL    @"http://" DXMobileHost "/html/help/topic_rank.html"

#if DEBUG
#define DXWebHost                   @"http://m.dongxi365.com:8088"
#else
#define DXWebHost                   @"http://m.dongxi365.com"
#endif

#endif
