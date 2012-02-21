//
//  GOODMaskedIconView.m
//
//  Created by Peyton Randolph on 2/6/12.
//

#import "GOODMaskedIconView.h"

#import <QuartzCore/QuartzCore.h>

static NSString * const GOODMaskedIconViewGradientStartColorKey = @"gradientStartColor";
static NSString * const GOODMaskedIconViewGradientEndColorKey = @"gradientEndColor";
static NSString * const GOODMaskedIconViewHighlightedKey = @"highlighted";
static NSString * const GOODMaskedIconViewMaskKey = @"mask";
static NSString * const GOODMaskedIconViewOverlayKey = @"overlay";

@interface GOODMaskedIconView ()

@property (nonatomic, assign) CGImageRef mask;
@property (nonatomic, assign) CGGradientRef gradient;

- (UIImage *)_renderImageHighlighted:(BOOL)shouldBeHighlighted;
+ (NSURL *)_resourceURL:(NSString *)resourceName;
- (void)_updateGradientWithStartColor:(UIColor *)startColor endColor:(UIColor *)endColor;

@end

@implementation GOODMaskedIconView
@synthesize highlighted = _highlighted;

@synthesize color = _color;
@synthesize highlightedColor = _highlightedColor;
@synthesize gradientStartColor = _gradientStartColor;
@synthesize gradientEndColor = _gradientEndColor;
@synthesize overlay = _overlay;
@synthesize overlayBlendMode = _overlayBlendMode;

@synthesize drawingBlock = _drawingBlock;
@synthesize mask = _mask;
@synthesize gradient = _gradient;

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    // Set view defaults
    self.backgroundColor = [UIColor clearColor];
    self.color = [UIColor blackColor];
    self.overlayBlendMode = kCGBlendModeNormal;
    
    // Set up observing
    [self addObserver:self forKeyPath:GOODMaskedIconViewGradientStartColorKey options:0 context:NULL];
    [self addObserver:self forKeyPath:GOODMaskedIconViewGradientEndColorKey options:0 context:NULL];
    [self addObserver:self forKeyPath:GOODMaskedIconViewHighlightedKey options:0 context:NULL];
    [self addObserver:self forKeyPath:GOODMaskedIconViewMaskKey options:0 context:NULL];
    [self addObserver:self forKeyPath:GOODMaskedIconViewOverlayKey options:0 context:NULL];
    
    return self;
}

- (id)initWithImage:(UIImage *)image;
{
    return [self initWithImage:image size:CGSizeZero];
}

- (id)initWithImage:(UIImage *)image size:(CGSize)size;
{
    if (!(self = [self initWithFrame:CGRectZero]))
        return nil;
    
    // Configure with image
    [self configureWithImage:image size:size];

    return self;
}

- (id)initWithImageNamed:(NSString *)imageName;
{
    return [self initWithImageNamed:imageName size:CGSizeZero];
}

- (id)initWithImageNamed:(NSString *)imageName size:(CGSize)size;
{
    if (!(self = [self initWithFrame:CGRectZero]))
        return nil;
    
    [self configureWithImageNamed:imageName size:size];
    
    return self;
}

- (id)initWithPDFNamed:(NSString *)pdfName;
{
    return [self initWithPDFNamed:pdfName size:CGSizeZero];
}

- (id)initWithPDFNamed:(NSString *)pdfName size:(CGSize)size;
{
    if (!(self = [self initWithFrame:CGRectZero]))
        return nil;
    
    [self configureWithPDFNamed:pdfName size:size];
    
    return self;
}

- (id)initWithResourceNamed:(NSString *)resourceName;
{
    return [self initWithResourceNamed:resourceName size:CGSizeZero];
}

- (id)initWithResourceNamed:(NSString *)resourceName size:(CGSize)size;
{
    if (!(self = [self initWithFrame:CGRectZero]))
        return nil;
    
    [self configureWithResourceNamed:resourceName size:size];
    
    return self;
}

- (void)dealloc;
{
    [self removeObserver:self forKeyPath:GOODMaskedIconViewGradientStartColorKey];
    [self removeObserver:self forKeyPath:GOODMaskedIconViewGradientEndColorKey];
    [self removeObserver:self forKeyPath:GOODMaskedIconViewHighlightedKey];
    [self removeObserver:self forKeyPath:GOODMaskedIconViewMaskKey];
    [self removeObserver:self forKeyPath:GOODMaskedIconViewOverlayKey];

    self.color = nil;
    self.drawingBlock = NULL;
    self.highlightedColor = nil;
    self.mask = NULL;
    self.gradient = NULL;
}

#pragma mark - Drawing and layout methods

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Flip coordinates so images don't draw upside down
    CGContextTranslateCTM(context, 0.0f, CGRectGetHeight(rect));
    CGContextScaleCTM(context, 1.0f, -1.0f);
    
    // Clip drawing to icon image
    CGContextClipToMask(context, rect, self.mask);
    
    // Fill icon
    CGContextSaveGState(context);
        
    if (self.gradient)
    {
        // Draw gradient
        
        // Because the context is flipped, the start and end points must be swapped
        CGPoint startPoint = CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds) + CGRectGetHeight(self.bounds));
        CGPoint endPoint = CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds));
        CGContextDrawLinearGradient(context, self.gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    } else {
        // Draw solid color
        if (self.highlighted && self.highlightedColor)
            [self.highlightedColor set];
        else
            [self.color set];
        
        CGContextFillRect(context, rect);
    }

    CGContextRestoreGState(context);
    
    // Perform additional drawing if specified
    if (self.drawingBlock != NULL)
    {
        CGContextSaveGState(context);
        self.drawingBlock(context);
        CGContextRestoreGState(context);
    }
    
    // Draw overlay
    if (self.overlay)
    {
        CGContextSaveGState(context);
        CGContextSetInterpolationQuality(context, kCGInterpolationNone);
        NSLog(@"%f", self.overlay.scale);
        NSLog(@"%@", NSStringFromCGSize(self.overlay.size));
        CGContextSetBlendMode(context, self.overlayBlendMode);
        CGContextDrawImage(context, self.bounds, self.overlay.CGImage);
        CGContextRestoreGState(context);
    }
}

- (CGSize)sizeThatFits:(CGSize)size;
{
    const CGFloat scale = [UIScreen mainScreen].scale;
    return CGSizeMake(CGImageGetWidth(self.mask) / scale, CGImageGetHeight(self.mask) / scale);
}

#pragma mark - Configuration methods

- (void)configureWithImage:(UIImage *)image;
{
    [self configureWithImage:image size:CGSizeZero];
}

- (void)configureWithImage:(UIImage *)image size:(CGSize)size;
{
    // If no image is passed, clear mask
    if (image == nil)
    {
        self.mask = NULL;
        return;
    }
    
    // Variables for image creation
    CGImageRef imageRef = CGImageRetain(image.CGImage);
    CGSize imageSize = CGSizeZero;
    size_t bytesPerRow = 0;
    const CGFloat scale = [UIScreen mainScreen].scale;
    
    if (size.width > 0.0f && size.height > 0.0f) 
    {
        // Custom size
        imageSize = size;
        imageSize.width *= scale;
        imageSize.height *= scale;
        CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceGray();
        bytesPerRow = imageSize.width * CGColorSpaceGetNumberOfComponents(colorspace);
        
        // Create bitmap context
        CGContextRef context = CGBitmapContextCreate(NULL, imageSize.width, imageSize.height, CGImageGetBitsPerComponent(imageRef), bytesPerRow, colorspace, kCGImageAlphaNone);
        CGColorSpaceRelease(colorspace);

        CGContextSetInterpolationQuality(context, kCGInterpolationLow);
        CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height), imageRef);
        CGImageRelease(imageRef);
        imageRef = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
    }
    else 
    {
        // Default size
        imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
        bytesPerRow = CGImageGetBytesPerRow(imageRef);
    }
    
    // Create mask
    CGImageRef maskRef = CGImageMaskCreate(imageSize.width, imageSize.height, CGImageGetBitsPerComponent(imageRef), CGImageGetBitsPerPixel(imageRef), bytesPerRow, CGImageGetDataProvider(imageRef), NULL, NO);
    CGImageRelease(imageRef);
    self.mask = maskRef;
    CGImageRelease(maskRef);
}

- (void)configureWithImageNamed:(NSString *)imageName;
{
    return [self configureWithImageNamed:imageName size:CGSizeZero];
}

- (void)configureWithImageNamed:(NSString *)imageName size:(CGSize)size;
{
    NSURL *imageURL = [GOODMaskedIconView _resourceURL:imageName];
    UIImage *image = [UIImage imageWithContentsOfFile:[imageURL relativePath]];

    [self configureWithImage:image size:size];
}

- (void)configureWithPDFNamed:(NSString *)pdfName;
{
    [self configureWithPDFNamed:pdfName size:CGSizeZero];
}

- (void)configureWithPDFNamed:(NSString *)pdfName size:(CGSize)size;
{
    if (!pdfName)
        return;
    
    // Grab pdf
    NSURL *pdfURL = [GOODMaskedIconView _resourceURL:pdfName];
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((__bridge CFURLRef)pdfURL);
    CGPDFPageRef firstPage = CGPDFDocumentGetPage(pdf, 1);
    
    if (firstPage == NULL)
    {
        CGPDFDocumentRelease(pdf);
        return;
    }
    
    // Calculate metrics
    const CGRect mediaRect = CGPDFPageGetBoxRect(firstPage, kCGPDFCropBox);
    const CGSize pdfSize = (size.width > 0.0f && size.height > 0.0f) ? size : mediaRect.size;
    
    // Set up context
    UIGraphicsBeginImageContextWithOptions(pdfSize, YES, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Draw background
    [[UIColor whiteColor] set];
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, pdfSize.width, pdfSize.height));
    
    // Scale and flip context right-side-up
    CGContextScaleCTM(context, pdfSize.width / mediaRect.size.width, -pdfSize.height / mediaRect.size.height);
    CGContextTranslateCTM(context, 0.0f, -mediaRect.size.height);
    
    // Draw pdf
    CGContextDrawPDFPage(context, firstPage);
    CGPDFDocumentRelease(pdf);

    // Create image to mask
    CGImageRef imageToMask = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();
    
    // Create image mask
    CGImageRef maskRef = CGImageMaskCreate(CGImageGetWidth(imageToMask), CGImageGetHeight(imageToMask), CGImageGetBitsPerComponent(imageToMask), CGImageGetBitsPerPixel(imageToMask), CGImageGetBytesPerRow(imageToMask), CGImageGetDataProvider(imageToMask), NULL, NO);
    CGImageRelease(imageToMask);
    self.mask = maskRef;
    CGImageRelease(maskRef);
}

- (void)configureWithResourceNamed:(NSString *)resourceName;
{
    [self configureWithResourceNamed:resourceName size:CGSizeZero];
}

- (void)configureWithResourceNamed:(NSString *)resourceName size:(CGSize)size;
{
    NSString *extension = [resourceName pathExtension];
    if ([extension isEqualToString:@"pdf"])
        [self configureWithPDFNamed:resourceName size:size];
    else 
        [self configureWithImageNamed:resourceName size:size];
}

#pragma mark - Getters and setters

- (void)setMask:(CGImageRef)mask;
{
    if (mask == self.mask)
        return;
    
    CGImageRelease(_mask);
    _mask = CGImageRetain(mask);
    
    // Resize view when mask changes
    [self sizeToFit];
    [self setNeedsDisplay];
}

- (void)setGradient:(CGGradientRef)gradient;
{
    if (gradient == self.gradient)
        return;
    
    CGGradientRelease(_gradient);
    _gradient = CGGradientRetain(gradient);
    
    [self setNeedsDisplay];
}

#pragma mark - KVO methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
    if ([keyPath isEqualToString:GOODMaskedIconViewHighlightedKey] || [keyPath isEqualToString:GOODMaskedIconViewMaskKey] || [keyPath isEqualToString:GOODMaskedIconViewOverlayKey])
    {
        [self setNeedsDisplay];
        return;
    }
    
    if ([keyPath isEqualToString:GOODMaskedIconViewGradientStartColorKey] || [keyPath isEqualToString:GOODMaskedIconViewGradientEndColorKey])
    {
        [self _updateGradientWithStartColor:self.gradientStartColor endColor:self.gradientEndColor];
        return;
    }
}

#pragma mark - NSCopying methods

- (id)copyWithZone:(NSZone *)zone;
{
    GOODMaskedIconView *iconView = [[GOODMaskedIconView alloc] initWithFrame:self.frame];
    
    iconView.color = self.color;
    iconView.drawingBlock = self.drawingBlock;
    iconView.highlightedColor = self.highlightedColor;
    iconView.mask = self.mask;
    
    return iconView;
}

#pragma mark - Image rendering

- (UIImage *)renderImage;
{
    return [self _renderImageHighlighted:NO];
}

- (UIImage *)renderHighlightedImage;
{
    return [self _renderImageHighlighted:YES];
}

#pragma mark - FOR PRIVATE EYES ONLY

- (UIImage *)_renderImageHighlighted:(BOOL)shouldBeHighlighted;
{
    // Save state
    BOOL wasHighlighted = self.isHighlighted;
    
    // Render image
    self.highlighted = shouldBeHighlighted;
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Restore state
    self.highlighted = wasHighlighted;
    
    return image;
}

+ (NSURL *)_resourceURL:(NSString *)resourceName
{
    if (!resourceName)
        return nil;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:resourceName ofType:nil];
    if (!path)
    {
        NSLog(@"File named %@ not found by %@. Check capitalization?", resourceName, self);
        return nil;
    }
    
    return [NSURL fileURLWithPath:path];
}

- (void)_updateGradientWithStartColor:(UIColor *)startColor endColor:(UIColor *)endColor;
{
    if (!(startColor && endColor))
    {
        self.gradient = NULL;
        return;
    }
    
    // Create colors and colorspace
    const CGColorRef cColors[] = {startColor.CGColor, endColor.CGColor};
    CFArrayRef colors = CFArrayCreate(NULL, (const void **)&cColors, 2, &kCFTypeArrayCallBacks);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    // Create and set gradient
    CGGradientRef gradient = CGGradientCreateWithColors(colorspace, colors, NULL);
    CGColorSpaceRelease(colorspace);
    self.gradient = gradient;
    CGGradientRelease(gradient);
    
    // Refresh view
    [self setNeedsDisplay];
}

@end
