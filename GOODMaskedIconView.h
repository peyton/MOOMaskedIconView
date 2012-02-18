//
//  HATMaskedIcon.h
//  Hat
//
//  Created by Peyton Randolph on 2/6/12.
//  Copyright (c) 2012 pandolph. All rights reserved.
//

typedef void (^DrawingBlock)(CGContextRef context);

@interface GOODMaskedIconView : UIView {
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

- (void)configureWithImage:(UIImage *)image;
- (void)configureWithImage:(UIImage *)image size:(CGSize)size;
- (void)configureWithImageNamed:(NSString *)imageName;
- (void)configureWithImageNamed:(NSString *)imageName size:(CGSize)size;
- (void)configureWithPDFNamed:(NSString *)pdfName;
- (void)configureWithPDFNamed:(NSString *)pdfName size:(CGSize)size;

- (UIImage *)renderToImage;

@end
