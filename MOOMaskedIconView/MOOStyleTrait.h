//
//  MOOStyleTrait.h
//  MOOMaskedIconView
//
//  Created by Peyton Randolph on 2/26/12.
//

#import <UIKit/UIKit.h>

#import "MOOMaskedIconView.h"

/**
 MOOStyleTrait is a protocol defining the basic operations of a style trait.
 */
@protocol MOOStyleTrait <NSObject>

@property (nonatomic, strong, readonly) Protocol *styleProtocol;

/**
 * Creates and returns a new, autoreleased trait
 */
+ (id<MOOStyleTrait>)trait;

/**
 * Overwrites properties of the current trait with values from another trait as long as those values are set on the other trait.
 */
- (void)mixInTrait:(id<MOOStyleTrait>)otherTrait;

/**
 * Calls mixInTrait: on every element in an array of traits.
 * 
 * @see mixInTrait:
 */
- (void)mixInTraits:(NSArray *)traits;

/**
 * Creates a new trait composed of the current trait and a passed-in trait. Does not overwrite properties on the callee, unlike mixInTrait:.
 *
 * @see mixInTrait:
 */
- (id<MOOStyleTrait>)traitMixedWithTrait:(id<MOOStyleTrait>)otherTrait;

/**
 * Creates a trait composed of the current trait and an array of other traits. Does not overwrite properties on the callee, unlike mixInTraits:.
 *
 * @see traitMixedWithTrait:
 * @see mixInTrait:
 */
- (id<MOOStyleTrait>)traitMixedWithTraits:(NSArray *)otherTraits;

@end

/**
 MOOStyleTrait is an implementation of <MOOStyleTrait> that conforms to <MOOMaskedIconViewStyles>
 */
@interface MOOStyleTrait : NSObject <MOOMaskedIconViewStyles, MOOStyleTrait>

+ (MOOStyleTrait *)trait;

@end

/** @name Helper functions */

/**
 * Returns the set of all property names in a protocol excluding <NSObject> properties.
 */
NSSet *propertyNamesForStyleProtocol(Protocol *proto);

/**
 * Returns the set of all property names in a protocol.
 */
NSSet *propertyNamesForProtocol(Protocol *proto);
