//
//  NSObject+DXModel.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/12.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "NSObject+DXModel.h"
#import <objc/runtime.h>

@interface NSArray (DXModel)

- (NSArray *)dx_parseArray;

@end


@interface NSDictionary (DXModel)

- (NSDictionary *)dx_parseDictionary;

@end



@implementation NSObject (DXModel)

- (NSArray *)allPropertyNames {
    NSMutableArray * names = [NSMutableArray array];
    unsigned int propertyCount;
    objc_property_t *propertyList = class_copyPropertyList([self class], &propertyCount);
    
    for (int i = 0; i < propertyCount; i++) {
        objc_property_t property = propertyList[i];
        const char *c_propertyName = property_getName(property);
        NSString *propertyName = [NSString stringWithCString:c_propertyName encoding:[NSString defaultCStringEncoding]];
        [names addObject:propertyName];
    }
    
    free(propertyList);
    return [names copy];
}

- (instancetype)initWithObjectDictionary:(NSDictionary *)dic {
    if (dic == nil) {
        return nil;
    }

    self = [self init];
    if (self) {
        unsigned int propertyCount;
        objc_property_t *propertyList = class_copyPropertyList([self class], &propertyCount);
        
        NSDictionary * objectClassInArrayMap = nil;
        if (propertyCount > 0 && [[self class] respondsToSelector:@selector(objectClassInArray)]) {
            objectClassInArrayMap = [[self class] performSelector:@selector(objectClassInArray)];
        }
        
        NSDictionary * objectClassInDictionaryMap = nil;
        if (propertyCount > 0 && [[self class] respondsToSelector:@selector(objectClassInDictionary)]) {
            objectClassInDictionaryMap = [[self class] performSelector:@selector(objectClassInDictionary)];
        }
        
        for (int i = 0; i < propertyCount; i++) {
            objc_property_t property = propertyList[i];
            const char *c_propertyName = property_getName(property);
            NSString *propertyName = [NSString stringWithCString:c_propertyName encoding:[NSString defaultCStringEncoding]];
            
            id value = nil;
            NSDictionary * systemVariablesMap = DXMODEL_SYSTEM_VARIABLES_MAP;
            if ([systemVariablesMap objectForKey:propertyName]) {
                value = [dic objectForKey:[systemVariablesMap objectForKey:propertyName]];
            } else {
                value = [dic objectForKey:propertyName];
            }
            
            if (value && value != [NSNull null]) {
                if ([value isKindOfClass:[NSArray class]]) {
                    Class objectClass = [objectClassInArrayMap objectForKey:propertyName];
                    if (objectClass) {
                        value = [objectClass objectArrayFromObjectDictionaryArray:value];
                    }
                }
                
                if ([value isKindOfClass:[NSDictionary class]]) {
                    Class objectClass = [objectClassInDictionaryMap objectForKey:propertyName];
                    if (objectClass) {
                        value = [[objectClass alloc] initWithObjectDictionary:value];
                    }
                }
                [self setValue:value forKey:propertyName];
            }
        }
        free(propertyList);
    }
    return self;
}

+ (NSArray *)objectArrayFromObjectDictionaryArray:(NSArray *)array {
    NSMutableArray * objectArray = [NSMutableArray array];
    for (id object in array) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            [objectArray addObject:[[[self class] alloc] initWithObjectDictionary:object]];
        }
    }
    return objectArray;
}


- (NSDictionary *)toObjectDictionary {
    return [self toObjectDictionary:NO];
}

- (NSDictionary *)toObjectDictionary:(BOOL)recursive {
    NSArray * baseClasses = @[
                              [NSNumber class],
                              [NSDate class],
                              [NSString class],
                              [NSArray class],
                              [NSDictionary class]
                              ];
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    unsigned int propertyCount;
    objc_property_t *propertyList = class_copyPropertyList([self class], &propertyCount);
    for (int i = 0; i < propertyCount; i++) {
        objc_property_t property = propertyList[i];
        const char *c_propertyName = property_getName(property);
        NSString *propertyName = [NSString stringWithCString:c_propertyName encoding:[NSString defaultCStringEncoding]];
        id value = [self valueForKey:propertyName];
        if (value != nil) {
            BOOL isBaseClass = false;
            for (Class baseClass in baseClasses) {
                if ([value isKindOfClass:baseClass]) {
                    isBaseClass = true;
                    break;
                }
            }
            if (!isBaseClass) {
                value = [value toObjectDictionary];
            }
            
            if (recursive) {
                if ([value isKindOfClass:[NSArray class]]) {
                    value = [(NSArray *)value dx_parseArray];
                }
                
                if ([value isKindOfClass:[NSDictionary class]]) {
                    value = [(NSDictionary *)value dx_parseDictionary];
                }
            }
            
            NSDictionary * systemVariablesMap = DXMODEL_SYSTEM_VARIABLES_MAP;
            if ([systemVariablesMap objectForKey:propertyName])  {
                [dic setObject:value forKey:[systemVariablesMap objectForKey:propertyName]];
            } else {
                [dic setObject:value forKey:propertyName];
            }
        }
    }
    free(propertyList);
    return [dic copy];
}



+ (NSDictionary *)objectClassInArray {
    return nil;
}

+ (NSDictionary *)objectClassInDictionary {
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSDictionary * modelDict = [self toObjectDictionary];
    for (NSString * key in modelDict) {
        id value = [modelDict objectForKey:key];
        if ([value conformsToProtocol:@protocol(NSCoding)]) {
            [aCoder encodeObject:value forKey:key];
        }
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [self init]) {
        NSArray * propertyNames = [self allPropertyNames];
        for (NSString * name in propertyNames) {
            NSDictionary * systemVariablesMap = DXMODEL_SYSTEM_VARIABLES_MAP;
            NSString * realKey = [systemVariablesMap objectForKey:name];
            if (realKey == nil) {
                realKey = name;
            }
            if ([aDecoder containsValueForKey:realKey]) {
                id value = [aDecoder decodeObjectForKey:realKey];
                [self setValue:value forKey:name];
            }
        }
    }
    return self;
}

@end


@implementation NSArray (DXModel)

- (NSArray *)dx_parseArray {
    NSArray * baseClasses = @[
                              [NSNumber class],
                              [NSDate class],
                              [NSString class],
                              ];
    
    NSMutableArray * copied = [NSMutableArray array];
    for (id item in self) {
        BOOL isBase = false;
        for (Class baseClass in baseClasses) {
            if ([item isKindOfClass:baseClass]) {
                [copied addObject:item];
                isBase = true;
                break;
            }
        }
        if (isBase) continue;
        
        if ([item isKindOfClass:[NSArray class]]) {
            [copied addObject:[item dx_parseArray]];
        } else if ([item isKindOfClass:[NSDictionary class]]) {
            [copied addObject:[item dx_parseDictionary]];
        } else {
            [copied addObject:[item toObjectDictionary]];
        }
    }
    return [copied copy];
}

@end



@implementation NSDictionary (DXModel)

- (NSDictionary *)dx_parseDictionary {
    NSArray * baseClasses = @[
                              [NSNumber class],
                              [NSDate class],
                              [NSString class],
                              ];
    
    NSMutableDictionary * copied = [NSMutableDictionary dictionary];
    for (NSString * key in self) {
        BOOL isBase = false;
        id item = [self objectForKey:key];
        for (Class baseClass in baseClasses) {
            if ([item isKindOfClass:baseClass]) {
                [copied setObject:item forKey:key];
                isBase = true;
                break;
            }
        }
        if (isBase) continue;
        
        if ([item isKindOfClass:[NSArray class]]) {
            [copied setObject:[item dx_parseArray] forKey:key];
        } else if ([item isKindOfClass:[NSDictionary class]]) {
            [copied setObject:[item dx_parseDictionary] forKey:key];
        } else {
            [copied setObject:[item toObjectDictionary] forKey:key];
        }
    }
    return [copied copy];
}

@end
