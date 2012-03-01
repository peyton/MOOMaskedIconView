//
//  MOOResourceList.h
//  MOOMaskedIconView
//
//  Created by Peyton Randolph on 2/27/12.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 MOOResourceList lists resources which should be cached and provides background rendering of itself.
 
 Resource lists should be placed inside the shared resource registry.
 
 @see MOOResourceRegistry
 */
@interface MOOResourceList : NSObject
{
    NSArray *_names;
}

@property (strong, readonly) NSArray *names;
@property (strong, readonly) NSArray *keys;

/**
 Initializes a resource list with an array of resource names, e.g. {"Icon1.pdf", "Icon2.pdf", "Icon3.pdf"}
 
 @param resourceNames   An array of resource names. *Note*: Names are not paths.
 
 @see initWithPlistNamed:
 @see listWithResourceNames:
 */
- (id)initWithResourceNames:(NSArray *)resourceNames;

/**
 Initializes a resource list with an array taken from a given property list
 
 @param plistName   The name of the plist of resource names to load
 
 @see initWithResourceNames:
 @see listWithPlistNamed:
 */
- (id)initWithPlistNamed:(NSString *)plistName;

/**
 Creates a resource list with an array of resource names, e.g. {"Icon1.pdf", "Icon2.pdf", "Icon3.pdf"}
 
 @param resourceNames   An array of resource names. *Note*: Names are not paths.
 
 @see initWithResourceNames:
 */
+ (MOOResourceList *)listWithResourceNames:(NSArray *)resourceNames;

/**
 Creates a resource list with an array taken from a given property list
 
 @param plistName   The name of the plist of resource names to load
 
 @see initWithPlistNamed:
 */
+ (MOOResourceList *)listWithPlistNamed:(NSString *)plistName;

/** 
 Renders and caches masks of every resource in the list in a background queue.
 */
- (void)renderMasksInBackground;

/**
 The default background render queue.
 
 defaultRenderQueue is a serial GCD queue with background priority on iOS 5.0+ and low priority on iOS 4.
 */
+ (dispatch_queue_t)defaultRenderQueue;

@end

/**
 MOOResourceRegistry registers resource lists that should be cached. After a MOOMaskedIconView renders its mask, it checks with the sharedRegistry to see whether the newly-created mask should go in the cache.
 */
@interface MOOResourceRegistry : NSObject
{
    NSArray *_resourceLists;
}

/**
 The array of resourceLists tracked by the registry
 */
@property (nonatomic, strong, readonly) NSArray *resourceLists;

/**
 Registers a resource list for querying by MOOMaskedIconView instances
 
 @param resourceList    The resource list to register
 
 @see deregisterList:
 */
- (void)registerList:(MOOResourceList *)resourceList;

/**
 Deregisters a resource list from querying by MOOMaskedIconView instances
 
 @param resourceList    The resource list to deregister
 
 @see registerList:
 */
- (void)deregisterList:(MOOResourceList *)resourceList;

/**
 Iterates through the resource list and returns whether the resource with key `key` should be cached.
 
 @param key The cache key of the queried resource
 
 @return Whether the resource with key `key` should go into the cache
 */
- (BOOL)shouldCacheResourceWithKey:(NSString *)key;

/**
 @return A shared registry.
 */
+ (MOOResourceRegistry *)sharedRegistry;

@end