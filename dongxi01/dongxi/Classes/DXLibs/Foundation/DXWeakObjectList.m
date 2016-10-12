//
//  DXWeakObjectList.m
//  dongxi
//
//  Created by Xu Shiwen on 15/12/9.
//  Copyright © 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXWeakObjectList.h"



@interface DXWeakObjectNode : NSObject

@property (nonatomic, weak) id object;
@property (nonatomic, strong) DXWeakObjectNode * previous;
@property (nonatomic, strong) DXWeakObjectNode * next;

@end

@implementation DXWeakObjectNode

@end




@implementation DXWeakObjectList {
    DXWeakObjectNode * _first;
    DXWeakObjectNode * _last;
    
    NSUInteger _count;
    unsigned long _mutations;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (void)addObject:(id __weak)object {
    if (object == nil) {
        return;
    }
    
    typeof(object) __weak weakObject = object;
    
    DXWeakObjectNode * node = [[DXWeakObjectNode alloc] init];
    node.object = weakObject;
    if (_first == nil) {
        _first = node;
        _last = node;
    } else {
        _last.next = node;
        node.previous = _last;
        _last = node;
    }
    
    _count++;
}


- (void)removeObjectAtIndex:(NSUInteger)index {
    NSUInteger currentIndex = 0;
    for (DXWeakObjectNode * current = _first; current != nil; current = current.next) {
        if (currentIndex == index) {
            if (current.previous) {
                current.previous.next = current.next;
            } else {
                _first = current.next;
                _first.previous = nil;
            }
            
            if (current.next == nil) {
                _last = current.previous;
            }
            
            _count--;
            break;
        } else {
            currentIndex++;
        }
    }
}

- (void)removeReleasedObjects {
    for (DXWeakObjectNode * current = _first; current != nil; current = current.next) {
        if (current.object == nil) {
            if (current.previous) {
                current.previous.next = current.next;
            } else {
                _first = current.next;
                _first.previous = nil;
            }
            
            if (current.next == nil) {
                _last = current.previous;
            }
            _count--;
        }
    }
}


#pragma mark - <NSFastEnumeration>

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id  _Nonnull *)buffer count:(NSUInteger)len {
    
    assert(sizeof(DXWeakObjectNode *) <= sizeof(unsigned long));
    
    if (state->state == 0) {
        state->state = 1;
        state->mutationsPtr = (__bridge void *)self;
        state->extra[0] = (unsigned long)_first;
    }
    
    DXWeakObjectNode * currentNode = (__bridge DXWeakObjectNode *)((void *)state->extra[0]);
    
    NSUInteger i;
    for (i = 0; i < len && currentNode != nil; i++) {
        buffer[i] = currentNode.object;
        currentNode = currentNode.next;
    }
    state->extra[0] = (unsigned long)currentNode;
    state->itemsPtr = buffer;
    
    return i;
}

@end
