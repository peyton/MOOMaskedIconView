//
//  MOOMaskedIconView.h
//  MOOMaskedIconView
//
//  Created by Peyton Randolph on 2/6/12.
//

#import <UIKit/UIKit.h>

//
//  ARC Helper
//
//  Version 1.2.1
//
//  Created by Nick Lockwood on 05/01/2012.
//  Copyright 2012 Charcoal Design
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://gist.github.com/1563325
//

#ifndef AH_RETAIN
#if __has_feature(objc_arc)
#define AH_RETAIN(x) (x)
#define AH_RELEASE(x)
#define AH_AUTORELEASE(x) (x)
#define AH_SUPER_DEALLOC
#else
#warning "Compiling MOOMaskedIconView without ARC is beta and may not work. Use at your own risk"
#define __AH_WEAK
#define AH_WEAK assign
#define AH_RETAIN(x) [(x) retain]
#define AH_RELEASE(x) [(x) release]
#define AH_AUTORELEASE(x) [(x) autorelease]
#define AH_SUPER_DEALLOC [super dealloc]
#endif
#endif

//  Weak reference support

#ifndef AH_WEAK
#if defined __IPHONE_OS_VERSION_MIN_REQUIRED
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
#define __AH_WEAK __weak
#define AH_WEAK weak
#else
#define __AH_WEAK __unsafe_unretained
#define AH_WEAK unsafe_unretained
#endif
#elif defined __MAC_OS_X_VERSION_MIN_REQUIRED
#if __MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_7
#define __AH_WEAK __weak
#define AH_WEAK weak
#else
#define __AH_WEAK __unsafe_unretained
#define AH_WEAK unsafe_unretained
#endif
#endif
#endif

//  ARC Helper ends

typedef void (^DrawingBlock)(CGContextRef context);

typedef enum {
    MOOGradientTypeLinear = 0,
} MOOGradientType;

@protocol MOOMaskedIconViewStyles <NSObject>


/* @name Style Properties */

/*
 * Fill color painted when the icon view is unhighlighted.
 *
 * When gradientStartColor and gradientEndColor are both non-nil,
 * the view ignores fill color and draws a gradient.
 *
 * @see highlightedColor
 */
@property (nonatomic, strong) UIColor *color;

/*
 * Fill color painted when the icon view is highlighted.
 *
 * When gradientStartColor and gradientEndColor are both non-nil,
 * the view ignores fill color and draws a gradient.
 *
 * @see color
 */
@property (nonatomic, strong) UIColor *highlightedColor;

/*
 * A pattern composited over the icon. Created with UIColor's colorWithPatternImage:.
 */
@property (nonatomic, strong) UIColor *pattern;

/*
 * The blend mode under which the pattern is drawn. Defaults to kCGBlendModeNormal. For a list of options see "CGBlendMode".
 */
@property (nonatomic, assign) CGBlendMode patternBlendMode;

/*
 * An image composited over the icon after drawing's done.
 *
 * @see overlayBlendMode
 */
@property (nonatomic, strong) UIImage *overlay;

/*
 * The blend mode under which the overlay is drawn. Defaults to kCGBlendModeNormal. For a list of options see "CGBlendMode".
 *
 * @see overlay
 */
@property (nonatomic, assign) CGBlendMode overlayBlendMode;

/*
 * A block called with the current context at the end of every drawing. Has signature `void (^DrawingBlock)(CGContextRef context)`.
 *
 * Useful for custom drawing.
 */
@property (nonatomic, strong) DrawingBlock drawingBlock;


/* @name Gradient Properties */

/*
 * The color filled at the gradient's start location. Cleared by gradientColors if that's set.
 *
 * @deprecated Use gradientColors instead
 *
 * @see gradientEndColor
 * @see gradientColors
 */
@property (nonatomic, strong) UIColor *gradientStartColor;

/*
 * The color filled at the gradient's end location. Cleared by gradientColors if that's set.
 *
 * @deprecated Use gradientColors instead
 *
 * @see gradientStartColor
 * @see gradientColors
 */
@property (nonatomic, strong) UIColor *gradientEndColor;

/*
 * An optional array of UIColors defining the color of the gradient at each stop. Setting gradientColors clears gradientStartColor and gradientEndColor.
 *
 * @see gradientLocations
 */
@property (nonatomic, strong) NSArray *gradientColors;

/*
 * An optional array of NSNumber objects defining the location of each gradient stop. 
 *
 * Must have the same number of components as gradientColors. The gradient stops are specified as values between 0 and 1. The values must be monotonically increasing. If nil, the stops are spread uniformly across the range. Defaults to nil.
 *
 * @see gradientColors
 */
@property (nonatomic, strong) NSArray *gradientLocations;

/*
 * Style of gradient drawn. MOOGradientTypeLinear is the sole option right now.
 */
@property (nonatomic, assign) MOOGradientType gradientType;


/* @name Shadow Properties */

/*
 * Specifies shadow color.
 * 
 * @see shadowOffet
 */
@property (nonatomic, strong) UIColor *shadowColor;

/*
 * Specifies shadow offset.
 *
 * @see shadowColor
 */
@property (nonatomic, assign) CGSize shadowOffset;

/*
 * Set to YES if your icon is translucent and you don't want the shadow showing through.
 * 
 * @see shadowColor
 * @see shadowOffset
 */
@property (nonatomic, assign) BOOL clipsShadow;

/*
 * Specifies inner shadow color.
 * 
 * @see innerShadowOffset
 */
@property (nonatomic, strong) UIColor *innerShadowColor;

/*
 * Specifies inner shadow offset.
 *
 * @see innerShadowColor
 */
@property (nonatomic, assign) CGSize innerShadowOffset;

/* @name Glow Properties */

/*
 * Specifies outer glow color.
 *
 * Note: Generally requires a higher opacity or greater radius than its Photoshop counterpart to achieve the same effect.
 * 
 * @see outerGlowRadius.
 */
@property (nonatomic, strong) UIColor *outerGlowColor;

/*
 * Specifies the total displacement of the outer glow in points.
 * 
 * @see outerGlowColor
 */
@property (nonatomic, assign) CGFloat outerGlowRadius;

/*
 * Specifies inner glow color.
 * 
 * @see innerGlowRadius
 */
@property (nonatomic, strong) UIColor *innerGlowColor;

/*
 * Specifies the total displacement of the inner glow in points.
 * 
 * @see innerGlowColor
 */
@property (nonatomic, assign) CGFloat innerGlowRadius;

@end

@protocol MOOStyleTrait;
@class MOOStyleTrait;

@interface MOOMaskedIconView : UIView <MOOMaskedIconViewStyles>
{
    BOOL _highlighted;

    UIColor *_color;
    UIColor *_highlightedColor;
    UIColor *_pattern;
    CGBlendMode _patternBlendMode;
    UIImage *_overlay;
    CGBlendMode _overlayBlendMode;
    
    NSArray *_gradientColors;
    NSArray *_gradientLocations;
    MOOGradientType _gradientType;
    
    UIColor *_shadowColor;
    CGSize _shadowOffset;
    BOOL _clipsShadow;
    UIColor *_innerShadowColor;
    CGSize _innerShadowOffset;
    
    UIColor *_outerGlowColor;
    CGFloat _outerGlowRadius;
    UIColor *_innerGlowColor;
    CGFloat _innerGlowRadius;

    DrawingBlock _drawingBlock;
    CGImageRef _mask;
    CGGradientRef _gradient;
    
    struct {
        BOOL hasGradientStartColor: 1;
        BOOL hasGradientEndColor: 1;
        BOOL needsGradient: 1;
    } _iconViewFlags;
}

/* @name State Properties */

/*
 * Whether the icon view is in its highlighted state.
 */
@property (nonatomic, assign, getter = isHighlighted) BOOL highlighted;

/*
 * The current CGImage mask held by the view. Read-only.
 *
 * @see Configuration methods
 */
@property (nonatomic, assign, readonly) CGImageRef mask;


/* @name Other Properties */

@property (nonatomic, strong, readonly) Protocol *styleProtocol;

/* @name Initialization methods */
- (id)initWithImage:(UIImage *)image;
- (id)initWithImage:(UIImage *)image size:(CGSize)size;
- (id)initWithImageNamed:(NSString *)imageName;
- (id)initWithImageNamed:(NSString *)imageName size:(CGSize)size;
- (id)initWithPDFNamed:(NSString *)pdfName;
- (id)initWithPDFNamed:(NSString *)pdfName size:(CGSize)size;
- (id)initWithResourceNamed:(NSString *)resourceName;
- (id)initWithResourceNamed:(NSString *)resourceName size:(CGSize)size;

/* @name Creation methods */
+ (MOOMaskedIconView *)iconWithImage:(UIImage *)image;
+ (MOOMaskedIconView *)iconWithImage:(UIImage *)image size:(CGSize)size;
+ (MOOMaskedIconView *)iconWithImageNamed:(NSString *)imageName;
+ (MOOMaskedIconView *)iconWithImageNamed:(NSString *)imageName size:(CGSize)size;
+ (MOOMaskedIconView *)iconWithPDFNamed:(NSString *)pdfName;
+ (MOOMaskedIconView *)iconWithPDFNamed:(NSString *)pdfName size:(CGSize)size;
+ (MOOMaskedIconView *)iconWithResourceNamed:(NSString *)resourceName;
+ (MOOMaskedIconView *)iconWithResourceNamed:(NSString *)resourceName size:(CGSize)size;

/* @name Configuration methods */
- (void)configureWithImage:(UIImage *)image;
- (void)configureWithImage:(UIImage *)image size:(CGSize)size;
- (void)configureWithImageNamed:(NSString *)imageName;
- (void)configureWithImageNamed:(NSString *)imageName size:(CGSize)size;
- (void)configureWithPDFNamed:(NSString *)pdfName;
- (void)configureWithPDFNamed:(NSString *)pdfName size:(CGSize)size;
- (void)configureWithResourceNamed:(NSString *)resourceName;
- (void)configureWithResourceNamed:(NSString *)resourceName size:(CGSize)size;


/* @name Traits */

- (void)mixInTrait:(id<MOOStyleTrait>)trait;


/* @name Rendering */

/*
 * Render the icon unhighlighted to a UIImage.
 *
 * Useful for passing the icon to other views, e.g. UIButton.
 *
 * @see renderHighlightedImage
 */
- (UIImage *)renderImage;

/*
 * Render the icon highlighted to a UIImage.
 *
 * Useful for passing the icon to other views, e.g. UIButton.
 *
 * @see renderImage
 */
- (UIImage *)renderHighlightedImage;

/* @name Caching */

+ (NSCache *)defaultMaskCache;

+ (BOOL)shouldCacheMaskForKey:(NSString *)key;

@end

/* @name Helper functions */

/*
 * Create a mask CGImage from a given image for a given size.
 */
CGImageRef CGImageCreateMaskFromCGImage(CGImageRef source, CGSize size);

/*
 * Create a mask CGImage from a given image name for a given size.
 */
CGImageRef CGImageCreateMaskFromImageNamed(NSString *imageName, CGSize size);

/*
 * Create a mask CGImage from a given pdf name for a given size.
 */
CGImageRef CGImageCreateMaskFromPDFNamed(NSString *pdfName, CGSize size);

/*
 * Create a mask CGImage from a given resource name for a given size
 */
CGImageRef CGImageCreateMaskFromResourceNamed(NSString *resourceName, CGSize size);
