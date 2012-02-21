//
//  GOODMaskedIconView.h
//
//  Created by Peyton Randolph on 2/6/12.
//

#import <UIKit/UIKit.h>

#if !__has_feature(objc_arc)
# GOODMaskedIconView is supported only under ARC.
#endif

typedef void (^DrawingBlock)(CGContextRef context);

@interface GOODMaskedIconView : UIView <NSCopying>
{
    BOOL _highlighted;
    
    UIColor *_color;
    UIColor *_highlightedColor;
    UIColor *_gradientStartColor;
    UIColor *_gradientEndColor;
    UIImage *_overlay;
    CGBlendMode _overlayBlendMode;
    
    DrawingBlock _drawingBlock;
    CGImageRef _mask;
    CGGradientRef _gradient;
}

/* @name Properties */

/*
 * Whether the icon view is in its highlighted state.
 */
@property (nonatomic, assign, getter = isHighlighted) BOOL highlighted;

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
 * The color filled at the gradient's start location
 *
 * When gradientStartColor and gradientEndColor are both non-nil,
 * the view ignores fill color and draws a gradient.
 * 
 * @see gradientEndColor
 */
@property (nonatomic, strong) UIColor *gradientStartColor;

/*
 * The color filled at the gradient's end location
 *
 * When gradientStartColor and gradientEndColor are both non-nil,
 * the view ignores fill color and draws a gradient.
 * 
 * @see gradientStartColor
 */
@property (nonatomic, strong) UIColor *gradientEndColor;

/*
 * An image composited over the icon after drawing's done.
 * 
 * @see overlayBlendMode
 */
@property (nonatomic, strong) UIImage *overlay;

/*
 * The blend mode under which the overlay is drawn. Defaults to kCGBlendModeNormal. For a list of options see "CGBlendMode"
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

/*
 * The current CGImage mask held by the view. Read-only.
 *
 * @see Configuration methods
 */
@property (nonatomic, assign, readonly) CGImageRef mask;

/* @name Initialization methods */
- (id)initWithImage:(UIImage *)image;
- (id)initWithImage:(UIImage *)image size:(CGSize)size;
- (id)initWithImageNamed:(NSString *)imageName;
- (id)initWithImageNamed:(NSString *)imageName size:(CGSize)size;
- (id)initWithPDFNamed:(NSString *)pdfName;
- (id)initWithPDFNamed:(NSString *)pdfName size:(CGSize)size;
- (id)initWithResourceNamed:(NSString *)resourceName;
- (id)initWithResourceNamed:(NSString *)resourceName size:(CGSize)size;

/* @name Configuration methods */
- (void)configureWithImage:(UIImage *)image;
- (void)configureWithImage:(UIImage *)image size:(CGSize)size;
- (void)configureWithImageNamed:(NSString *)imageName;
- (void)configureWithImageNamed:(NSString *)imageName size:(CGSize)size;
- (void)configureWithPDFNamed:(NSString *)pdfName;
- (void)configureWithPDFNamed:(NSString *)pdfName size:(CGSize)size;
- (void)configureWithResourceNamed:(NSString *)resourceName;
- (void)configureWithResourceNamed:(NSString *)resourceName size:(CGSize)size;

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

@end
