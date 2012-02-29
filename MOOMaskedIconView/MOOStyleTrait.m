//
//  MOOStyleTrait.m
//  MOOMaskedIconView
//
//  Created by Peyton Randolph on 2/26/12.
//

#import "MOOStyleTrait.h"

#import "AHHelper.h"
#import <objc/runtime.h>

@implementation MOOStyleTrait
@dynamic styleProtocol;

@synthesize color;
@synthesize highlightedColor;
@synthesize pattern;
@synthesize patternBlendMode;
@synthesize overlay;
@synthesize overlayBlendMode;
@synthesize drawingBlock;
@synthesize gradientStartColor;
@synthesize gradientEndColor;
@synthesize gradientColors;
@synthesize gradientLocations;
@synthesize gradientType;
@synthesize shadowColor;
@synthesize shadowOffset;
@synthesize clipsShadow;
@synthesize innerShadowColor;
@synthesize innerShadowOffset;
@synthesize outerGlowColor;
@synthesize outerGlowRadius;
@synthesize innerGlowColor;
@synthesize innerGlowRadius;

+ (MOOStyleTrait *)trait;
{
    return AH_AUTORELEASE([[MOOStyleTrait alloc] init]);
}

- (void)dealloc;
{
    self.color = nil;
    self.highlightedColor = nil;
    self.pattern = nil;
    self.overlay = nil;
    self.drawingBlock = NULL;
    self.gradientStartColor = nil;
    self.gradientEndColor = nil;
    self.gradientColors = nil;
    self.gradientLocations = nil;
    self.shadowColor = nil;
    self.innerShadowColor = nil;
    self.outerGlowColor = nil;
    self.innerGlowColor = nil;
    
    AH_SUPER_DEALLOC;
}

#pragma mark - MOOStyleTrait methods

- (Protocol *)styleProtocol;
{
    return @protocol(MOOMaskedIconViewStyles);
}

- (void)mixInTrait:(id<MOOStyleTrait>)otherTrait;
{
    if (![[self class] conformsToProtocol:otherTrait.styleProtocol])
    {
        NSLog(@"Attempting to mix object %@ of incompatible protocol %@ into object %@ of protocol %@.", otherTrait, NSStringFromProtocol(otherTrait.styleProtocol), self, NSStringFromProtocol(self.styleProtocol));
        return;
    }
    
    id propertyValue;
    for (NSString *propertyName in propertyNamesForStyleProtocol(otherTrait.styleProtocol))
        if ((propertyValue = [(NSObject *)otherTrait valueForKey:propertyName]))
            [self setValue:propertyValue forKey:propertyName];
}

- (void)mixInTraits:(NSArray *)traits;
{
    if ([traits count] == 0)
        return;
    
    [self mixInTrait:[traits objectAtIndex:0]];
    [self mixInTraits:[traits subarrayWithRange:NSMakeRange(1, [traits count] - 1)]];
}

- (MOOStyleTrait *)traitMixedWithTrait:(MOOStyleTrait *)otherTrait;
{
    MOOStyleTrait *newTrait = AH_AUTORELEASE([[MOOStyleTrait alloc] init]);
    [newTrait mixInTraits:[NSArray arrayWithObjects:self, otherTrait, nil]];
    
    return newTrait;
}

- (MOOStyleTrait *)traitMixedWithTraits:(NSArray *)otherTraits;
{
    MOOStyleTrait *newTrait = AH_AUTORELEASE([[MOOStyleTrait alloc] init]);
    NSMutableArray *otherTraitsMutable = [NSMutableArray arrayWithArray:otherTraits];
    [otherTraitsMutable insertObject:self atIndex:0];
    [newTrait mixInTraits:otherTraitsMutable];
    
    return newTrait;
}

@end

#pragma mark - Helper functions

// Returns the set of all property names in a protocol excluding <NSObject> properties.
NSSet *propertyNamesForStyleProtocol(Protocol *proto)
{
    NSSet *propertyList = propertyNamesForProtocol(proto);
    
    // Strip <NSObject> properties. They're irrelevent.
    if (protocol_conformsToProtocol(proto, @protocol(NSObject)))
    {
        static NSSet *nsObjectProperties;
        if (!nsObjectProperties)
            nsObjectProperties = propertyNamesForProtocol(@protocol(NSObject));
        
        propertyList = [propertyList objectsPassingTest:^BOOL(id obj, BOOL *stop) {
            return ![nsObjectProperties containsObject:obj];
        }];
    }
    
    return propertyList;
}

// Returns the set of all property names in a protocol.
NSSet *propertyNamesForProtocol(Protocol *proto)
{
    unsigned int propertyListCount;
    objc_property_t *propertyList = protocol_copyPropertyList(proto, &propertyListCount);
    objc_property_t *incPropertyList = propertyList;
    NSMutableSet *propertyNames = [NSMutableSet setWithCapacity:propertyListCount];
    
    while (propertyListCount)
    {
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(*incPropertyList)];
        [propertyNames addObject:propertyName];
        
        ++incPropertyList;
        --propertyListCount;
    }
    
    free(propertyList);
    return propertyNames;
}
