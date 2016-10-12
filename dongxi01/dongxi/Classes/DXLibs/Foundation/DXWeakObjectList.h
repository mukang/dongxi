//
//  DXWeakObjectList.h
//  dongxi
//
//  Created by Xu Shiwen on 15/12/9.
//  Copyright © 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DXWeakObjectList : NSObject <NSFastEnumeration>

@property (nonatomic, readonly) NSUInteger count;

- (void)addObject:(id __weak)object;

- (void)removeObjectAtIndex:(NSUInteger)index;

- (void)removeReleasedObjects;

@end
