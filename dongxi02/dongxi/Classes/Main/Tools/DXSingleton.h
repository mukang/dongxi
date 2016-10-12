

// .h文件
#define DXSingletonInterface(className)           + (instancetype)shared##className;

// .m文件
// ARC
#if __has_feature(objc_arc)
#define DXSingletonImplementation(className) \
static id instance; \
+ (instancetype)allocWithZone:(struct _NSZone *)zone { \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
instance = [super allocWithZone:zone]; \
}); \
return instance; \
} \
+ (instancetype)shared##className { \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
instance = [[self alloc] init]; \
}); \
return instance; \
} \
- (id)copyWithZone:(NSZone *)zone { \
return instance; \
}
#else
// MRC
#define MKSingletonImplementation(className) \
static id instance; \
+ (instancetype)allocWithZone:(struct _NSZone *)zone { \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
instance = [super allocWithZone:zone]; \
}); \
return instance; \
} \
+ (instancetype)shared##className { \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
instance = [[self alloc] init]; \
}); \
return instance; \
} \
- (id)copyWithZone:(NSZone *)zone { \
return instance; \
} \
- (oneway void)release {} \
- (instancetype)retain {return instance;} \
- (instancetype)autorelease {return instance;} \
- (NSUInteger)retainCount {return ULONG_MAX;}

#endif


