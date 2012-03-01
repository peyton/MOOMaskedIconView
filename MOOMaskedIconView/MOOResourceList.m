//
//  MOOResourceList.m
//  MOOMaskedIconView
//
//  Created by Peyton Randolph on 2/27/12.
//

#import "MOOResourceList.h"

#import "AHHelper.h"
#import "MOOCGImageWrapper.h"
#import "MOOMaskedIconView.h"

// Queues
static dispatch_queue_t _defaultRenderQueue;

// Shared instances
static MOOResourceRegistry *_sharedRegistry;

@interface MOOResourceList ()

@property (strong) NSArray *names;

@end;

@implementation MOOResourceList
@synthesize names = _names;
@dynamic keys;

- (id)initWithResourceNames:(NSArray *)resourceNames;
{
    if (!(self = [super init]))
        return nil;
    
    self.names = resourceNames;
    
    return self;
}

- (id)initWithPlistNamed:(NSString *)plistName;
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:plistName ofType:nil];
    // Try loading as array
    NSArray *resourceNames = [NSArray arrayWithContentsOfFile:plistPath];
    
    // Try loading as dictionary
    if (!resourceNames)
        resourceNames = [[NSDictionary dictionaryWithContentsOfFile:plistPath] objectForKey:@"Icons"];

    if (!resourceNames)
        return nil;
    
    if (!(self = [self initWithResourceNames:resourceNames]))
        return nil;
    
    return self;
}

+ (MOOResourceList *)listWithResourceNames:(NSArray *)resourceNames;
{
    return AH_AUTORELEASE([[self alloc] initWithResourceNames:resourceNames]);
}

+ (MOOResourceList *)listWithPlistNamed:(NSString *)plistName;
{
    return AH_AUTORELEASE([[self alloc] initWithPlistNamed:plistName]);
}

- (void)dealloc;
{
    self.names = nil;
    
    AH_SUPER_DEALLOC;
}

#pragma mark - Rendering methods

- (void)renderMasksInBackground;
{
    // Punt to the next cycle of the runLoop
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSString *resourceName in self.names)
            dispatch_async([MOOResourceList defaultRenderQueue], ^{
                NSCache *maskCache = [MOOMaskedIconView defaultMaskCache];
                NSString *key = [resourceName stringByAppendingString:NSStringFromCGSize(CGSizeZero)];
                if (![maskCache objectForKey:key])
                {
                    CGImageRef mask = CGImageCreateMaskFromResourceNamed(resourceName, CGSizeZero);
                    MOOCGImageWrapper *imageWrapper = [MOOCGImageWrapper wrapperWithCGImage:mask];
                    CGImageRelease(mask);
                    
                    if (![maskCache objectForKey:key])
                        [maskCache setObject:imageWrapper forKey:key cost:imageWrapper.cost];
                }
            });
    });

}

#pragma mark - Getters and setters

- (NSArray *)keys;
{
    NSMutableArray *keys = [NSMutableArray arrayWithCapacity:[self.names count]];
    
    for (NSString *name in self.names)
        [keys addObject:[name stringByAppendingString:NSStringFromCGSize(CGSizeZero)]];
        
    return keys;
}

#pragma mark - Queues

+ (dispatch_queue_t)defaultRenderQueue;
{
    @synchronized (self)
    {
        if (!_defaultRenderQueue)
        {
            _defaultRenderQueue = dispatch_queue_create([NSStringFromSelector(_cmd) UTF8String], DISPATCH_QUEUE_SERIAL);
            
            // Background queue priority requires iOS 5.0+
            NSString *reqSysVer = @"5.0";
            NSString *currSysVer = [UIDevice currentDevice].systemVersion;
            dispatch_set_target_queue(_defaultRenderQueue, dispatch_get_global_queue(([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) ? DISPATCH_QUEUE_PRIORITY_BACKGROUND : DISPATCH_QUEUE_PRIORITY_LOW, 0));
        }
        return _defaultRenderQueue;
    }
}

@end

@interface MOOResourceRegistry ()

@property (nonatomic, strong) NSArray *resourceLists;

@end

@implementation MOOResourceRegistry
@synthesize resourceLists = _resourceLists;

- (id)init;
{
    if (!(self = [super init]))
        return nil;

    // Initialize resource lists
    self.resourceLists = [NSArray array];

    return self;
}

- (void)dealloc;
{
    self.resourceLists = nil;

    AH_SUPER_DEALLOC;
}

#pragma mark - List marshalling

- (void)registerList:(MOOResourceList *)resourceList;
{
    if (![self.resourceLists containsObject:resourceList])
        self.resourceLists = [self.resourceLists arrayByAddingObject:resourceList];
}

- (void)deregisterList:(MOOResourceList *)resourceList;
{
    self.resourceLists = [self.resourceLists filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return evaluatedObject != resourceList;
    }]];
}

#pragma mark - Resource querying

- (BOOL)shouldCacheResourceWithKey:(NSString *)key;
{
    for (MOOResourceList *list in self.resourceLists)
        for (NSString *keyToCache in list.keys)
            if ([keyToCache isEqualToString:key])
                return YES;
    return NO;
}

#pragma mark - Shared instances

+ (MOOResourceRegistry *)sharedRegistry;
{
    if (!_sharedRegistry)
        _sharedRegistry = [[MOOResourceRegistry alloc] init];
    
    return _sharedRegistry;
}

@end
