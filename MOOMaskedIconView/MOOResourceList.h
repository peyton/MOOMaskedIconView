//
//  MOOResourceList.h
//  MOOMaskedIconView
//
//  Created by Peyton Randolph on 2/27/12.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MOOResourceList : NSObject
{
    NSArray *_names;
}

@property (strong, readonly) NSArray *names;
@property (strong, readonly) NSArray *keys;

- (id)initWithResourceNames:(NSArray *)resourceNames;
- (id)initWithPlistNamed:(NSString *)propertyListName;

+ (MOOResourceList *)resourceListWithResourceNames:(NSArray *)resourceNames;
+ (MOOResourceList *)resourceListWithPlistNamed:(NSString *)propertyListName;

- (void)renderMasksInBackground;

+ (dispatch_queue_t)defaultRenderQueue;

@end

@interface MOOResourceRegistry : NSObject
{
    NSArray *_resourceLists;
}

@property (nonatomic, strong, readonly) NSArray *resourceLists;

- (void)registerList:(MOOResourceList *)resourceList;
- (void)deregisterList:(MOOResourceList *)resourceList;

- (BOOL)shouldCacheResourceWithKey:(NSString *)key;

+ (MOOResourceRegistry *)sharedRegistry;

@end