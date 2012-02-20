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

@property (nonatomic, assign, getter = isHighlighted) BOOL highlighted;

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *highlightedColor;

@property (nonatomic, strong) DrawingBlock drawingBlock;
@property (nonatomic, assign, readonly) CGImageRef mask;

- (id)initWithImage:(UIImage *)image;
- (id)initWithImage:(UIImage *)image size:(CGSize)size;
- (id)initWithImageNamed:(NSString *)imageName;
- (id)initWithImageNamed:(NSString *)imageName size:(CGSize)size;
- (id)initWithPDFNamed:(NSString *)pdfName;
- (id)initWithPDFNamed:(NSString *)pdfName size:(CGSize)size;
- (id)initWithResourceNamed:(NSString *)resourceName;
- (id)initWithResourceNamed:(NSString *)resourceName size:(CGSize)size;

- (void)configureWithImage:(UIImage *)image;
- (void)configureWithImage:(UIImage *)image size:(CGSize)size;
- (void)configureWithImageNamed:(NSString *)imageName;
- (void)configureWithImageNamed:(NSString *)imageName size:(CGSize)size;
- (void)configureWithPDFNamed:(NSString *)pdfName;
- (void)configureWithPDFNamed:(NSString *)pdfName size:(CGSize)size;
- (void)configureWithResourceNamed:(NSString *)resourceName;
- (void)configureWithResourceNamed:(NSString *)resourceName size:(CGSize)size;

- (UIImage *)renderImage;
- (UIImage *)renderHighlightedImage;

@end
