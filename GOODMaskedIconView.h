//
//  GOODMaskedIconView.h
//
//  Created by Peyton Randolph on 2/6/12.
//

#import <UIKit/UIKit.h>

typedef void (^DrawingBlock)(CGContextRef context);

@interface GOODMaskedIconView : UIView <NSCopying>
{
    BOOL _highlighted;
    
    UIColor *_color;
    UIColor *_highlightedColor;
    
    DrawingBlock _drawingBlock;
    CGImageRef _mask;
}

/* @name Properties */

/*
 * Whether the icon view is in its highlighted state.
 */
@property (nonatomic, assign, getter = isHighlighted) BOOL highlighted;

/*
 * The color painted when the icon view is unhighlighted.
 */
@property (nonatomic, strong) UIColor *color;

/*
 * The color painted when the icon view is highlighted.
 */
@property (nonatomic, strong) UIColor *highlightedColor;

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
