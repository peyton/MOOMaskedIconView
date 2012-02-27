//
//  MOOResourceList.m
//  MOOMaskedIconView
//
//  Created by Peyton Randolph on 2/27/12.
//

#import "MOOResourceList.h"

#import "MOOCGImageWrapper.h"
#import "MOOMaskedIconView.h"

static dispatch_queue_t _defaultRenderQueue;

@interface MOOResourceList ()

@property (strong) NSArray *names;

@end;

@implementation MOOResourceList
@synthesize names = _names;

- (id)initWithResourceNames:(NSArray *)resourceNames;
{
    if (!(self = [super init]))
        return nil;
    
    self.names = resourceNames;
    
    return self;
}

- (id)initWithPlistNamed:(NSString *)propertyListName;
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:propertyListName ofType:nil];
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

+ (MOOResourceList *)resourceListWithResourceNames:(NSArray *)resourceNames;
{
    return AH_AUTORELEASE([[self alloc] initWithResourceNames:resourceNames]);
}

+ (MOOResourceList *)resourceListWithPlistNamed:(NSString *)propertyListName;
{
    return AH_AUTORELEASE([[self alloc] initWithPlistNamed:propertyListName]);
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

#pragma mark - 

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
