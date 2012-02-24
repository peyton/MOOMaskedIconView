//
//  MOOMaskedIconView.m
//  MOOMaskedIconView
//
//  Created by Peyton Randolph on 2/6/12.
//

#import "MOOMaskedIconView.h"

#import <QuartzCore/QuartzCore.h>

// Keys for KVO
static NSString * const MOOMaskedIconViewHighlightedKey = @"highlighted";
static NSString * const MOOMaskedIconViewMaskKey = @"mask";
static NSString * const MOOMaskedIconViewOverlayKey = @"overlay";

static NSString * const MOOMaskedIconViewGradientStartColorKey = @"gradientStartColor";
static NSString * const MOOMaskedIconViewGradientEndColorKey = @"gradientEndColor";
static NSString * const MOOMaskedIconViewGradientColorsKey = @"gradientColors";
static NSString * const MOOMaskedIconViewGradientLocationsKey = @"gradientLocations";
static NSString * const MOOMaskedIconViewGradientTypeKey = @"gradientType";

static NSString * const MOOMaskedIconViewShadowColor = @"shadowColor";
static NSString * const MOOMaskedIconViewShadowOffset = @"shadowOffset";

@interface MOOMaskedIconView ()

@property (nonatomic, assign) CGImageRef mask;
@property (nonatomic, assign) CGGradientRef gradient;

- (UIImage *)_renderImageHighlighted:(BOOL)shouldBeHighlighted;
+ (NSURL *)_resourceURL:(NSString *)resourceName;
- (void)_updateGradientWithColors:(NSArray *)colors locations:(NSArray *)locations forType:(MOOGradientType)type;

@end

@implementation MOOMaskedIconView
@synthesize highlighted = _highlighted;

@synthesize color = _color;
@synthesize highlightedColor = _highlightedColor;
@synthesize overlay = _overlay;
@synthesize overlayBlendMode = _overlayBlendMode;

@dynamic gradientStartColor;
@dynamic gradientEndColor;
@synthesize gradientColors = _gradientColors;
@synthesize gradientLocations = _gradientLocations;
@synthesize gradientType = _gradientType;

@synthesize shadowColor = _shadowColor;
@synthesize shadowOffset = _shadowOffset;

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
    [self addObserver:self forKeyPath:MOOMaskedIconViewHighlightedKey options:0 context:NULL];
    [self addObserver:self forKeyPath:MOOMaskedIconViewMaskKey options:0 context:NULL];
    [self addObserver:self forKeyPath:MOOMaskedIconViewOverlayKey options:0 context:NULL];
    [self addObserver:self forKeyPath:MOOMaskedIconViewGradientStartColorKey options:0 context:NULL];
    [self addObserver:self forKeyPath:MOOMaskedIconViewGradientEndColorKey options:0 context:NULL];
    [self addObserver:self forKeyPath:MOOMaskedIconViewGradientColorsKey options:0 context:NULL];
    [self addObserver:self forKeyPath:MOOMaskedIconViewGradientLocationsKey options:0 context:NULL];
    [self addObserver:self forKeyPath:MOOMaskedIconViewGradientTypeKey options:0 context:NULL];
    [self addObserver:self forKeyPath:MOOMaskedIconViewShadowColor options:0 context:NULL];
    [self addObserver:self forKeyPath:MOOMaskedIconViewShadowOffset options:0 context:NULL];
    
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
    [self removeObserver:self forKeyPath:MOOMaskedIconViewHighlightedKey];
    [self removeObserver:self forKeyPath:MOOMaskedIconViewMaskKey];
    [self removeObserver:self forKeyPath:MOOMaskedIconViewOverlayKey];
    [self removeObserver:self forKeyPath:MOOMaskedIconViewGradientStartColorKey];
    [self removeObserver:self forKeyPath:MOOMaskedIconViewGradientEndColorKey];
    [self removeObserver:self forKeyPath:MOOMaskedIconViewGradientColorsKey];
    [self removeObserver:self forKeyPath:MOOMaskedIconViewGradientLocationsKey];
    [self removeObserver:self forKeyPath:MOOMaskedIconViewGradientTypeKey];
    [self removeObserver:self forKeyPath:MOOMaskedIconViewShadowColor];
    [self removeObserver:self forKeyPath:MOOMaskedIconViewShadowOffset];

    self.color = nil;
    self.highlightedColor = nil;
    self.shadowColor = nil;
    self.gradientColors = nil;
    self.gradientLocations = nil;
    self.overlay = nil;
    self.drawingBlock = NULL;
    self.mask = NULL;
    self.gradient = NULL;
    
    AH_SUPER_DEALLOC;
}

#pragma mark - Drawing and layout methods

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Flip coordinates so images don't draw upside down
    CGContextTranslateCTM(context, 0.0f, CGRectGetHeight(rect));
    CGContextScaleCTM(context, 1.0f, -1.0f);
    
    CGRect imageRect = CGRectMake((self.shadowOffset.width > 0.0f) ? self.shadowOffset.width : 0.0f, (self.shadowOffset.height > 0.0f) ? self.shadowOffset.height : 0.0f, CGImageGetWidth(self.mask) / [UIScreen mainScreen].scale, CGImageGetHeight(self.mask) / [UIScreen mainScreen].scale);
    
    if (!CGSizeEqualToSize(self.shadowOffset, CGSizeZero))
    {
        CGContextSaveGState(context);
        [((self.shadowColor) ? self.shadowColor : [UIColor blackColor]) set];
        CGRect shadowRect = imageRect;
        shadowRect.origin = CGPointMake((self.shadowOffset.width < 0.0f) ? -self.shadowOffset.width : 0.0f, (self.shadowOffset.height < 0.0f) ? -self.shadowOffset.height : 0.0f);
        CGContextClipToMask(context, shadowRect, self.mask);
        CGContextFillRect(context, shadowRect);
        CGContextRestoreGState(context);
    }
    
    // Clip drawing to icon image
    CGContextClipToMask(context, imageRect, self.mask);
    
    // Fill icon
    CGContextSaveGState(context);
    
    if (self.gradient && !(self.highlighted && self.highlightedColor))
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
        
        CGContextFillRect(context, imageRect);
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
        CGContextSetBlendMode(context, self.overlayBlendMode);
        CGContextDrawImage(context, self.bounds, self.overlay.CGImage);
        CGContextRestoreGState(context);
    }
}

- (CGSize)sizeThatFits:(CGSize)size;
{
    const CGFloat scale = [UIScreen mainScreen].scale;
    return CGSizeMake(CGImageGetWidth(self.mask) / scale + fabsf(self.shadowOffset.width), CGImageGetHeight(self.mask) / scale + fabsf(self.shadowOffset.height));
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
    NSURL *imageURL = [MOOMaskedIconView _resourceURL:imageName];
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
    NSURL *pdfURL = [MOOMaskedIconView _resourceURL:pdfName];
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

- (void)setGradient:(CGGradientRef)gradient;
{
    if (gradient == self.gradient)
        return;
    
    CGGradientRelease(_gradient);
    _gradient = CGGradientRetain(gradient);
    
    [self setNeedsDisplay];
}

- (void)setGradientColors:(NSArray *)gradientColors;
{
    if ([gradientColors isEqualToArray:self.gradientColors])
        return;
    
    _gradientColors = gradientColors;
    
    // Clear gradient start color and gradient end color
    _iconViewFlags.hasGradientStartColor = NO;
    _iconViewFlags.hasGradientEndColor = NO;
}

- (UIColor *)gradientStartColor;
{
    // Deprecated. Use gradientColors instead
    if (!_iconViewFlags.hasGradientStartColor)
        return nil;
    
    return [self.gradientColors objectAtIndex:0];
}

- (void)setGradientStartColor:(UIColor *)gradientStartColor;
{
    // Deprecated. Setting gradientStartColor is overly complicated. Use gradientColors instead
    if (gradientStartColor == self.gradientStartColor)
        return;
    
    if (gradientStartColor == nil)
    {
        [self willChangeValueForKey:@"gradientColors"];
        _gradientColors = (_iconViewFlags.hasGradientEndColor) ? [NSArray arrayWithObject:self.gradientEndColor] : nil;
        [self didChangeValueForKey:@"gradientColors"];
        _iconViewFlags.hasGradientStartColor = NO;
        return;
    }
    
    
    [self willChangeValueForKey:@"gradientColors"];
    _gradientColors = (_iconViewFlags.hasGradientEndColor) ? [NSArray arrayWithObjects:gradientStartColor, self.gradientEndColor, nil] : [NSArray arrayWithObject:gradientStartColor];
    [self didChangeValueForKey:@"gradientColors"];
    
    _iconViewFlags.hasGradientStartColor = YES;
}

- (UIColor *)gradientEndColor;
{
    // Deprecated. Use gradientColors instead
    if (!_iconViewFlags.hasGradientEndColor)
        return nil;
    
    return [self.gradientColors lastObject];
}

- (void)setGradientEndColor:(UIColor *)gradientEndColor;
{
    // Deprecated. Setting gradientEndColor is overly complicated. Use gradientColors instead
    if (gradientEndColor == self.gradientEndColor)
        return;
    
    if (gradientEndColor == nil)
    {
        [self willChangeValueForKey:@"gradientColors"];
        _gradientColors = (_iconViewFlags.hasGradientStartColor) ? [NSArray arrayWithObject:self.gradientStartColor] : nil;
        [self didChangeValueForKey:@"gradientColors"];
        _iconViewFlags.hasGradientEndColor = NO;
        return;
    }
    
    
    [self willChangeValueForKey:@"gradientColors"];
    _gradientColors = (_iconViewFlags.hasGradientStartColor) ? [NSArray arrayWithObjects:self.gradientStartColor, gradientEndColor, nil] : [NSArray arrayWithObject:gradientEndColor];
    [self didChangeValueForKey:@"gradientColors"];
    
    _iconViewFlags.hasGradientEndColor = YES;
}

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

#pragma mark - KVO methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
    if ([keyPath isEqualToString:MOOMaskedIconViewHighlightedKey] ||
        [keyPath isEqualToString:MOOMaskedIconViewMaskKey] ||
        [keyPath isEqualToString:MOOMaskedIconViewOverlayKey])
    {
        [self setNeedsDisplay];
        return;
    }
    
    if ([keyPath isEqualToString:MOOMaskedIconViewShadowColor] ||
        [keyPath isEqualToString:MOOMaskedIconViewShadowOffset])
    {
        [self sizeToFit];
        [self setNeedsDisplay];
        return;
    }
    
    if ([keyPath isEqualToString:MOOMaskedIconViewGradientStartColorKey] ||
        [keyPath isEqualToString:MOOMaskedIconViewGradientEndColorKey] ||
        [keyPath isEqualToString:MOOMaskedIconViewGradientColorsKey] ||
        [keyPath isEqualToString:MOOMaskedIconViewGradientLocationsKey] ||
        [keyPath isEqualToString:MOOMaskedIconViewGradientTypeKey])
    {
        [self _updateGradientWithColors:self.gradientColors locations:self.gradientLocations forType:self.gradientType];
        return;
    }
}

#pragma mark - NSCopying methods

- (id)copyWithZone:(NSZone *)zone;
{
    MOOMaskedIconView *iconView = [[MOOMaskedIconView alloc] initWithFrame:self.frame];
    
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

- (void)_updateGradientWithColors:(NSArray *)colors locations:(NSArray *)locations forType:(MOOGradientType)type;
{
    if (!colors)
    {
        self.gradient = NULL;
        return;
    }
    
    if (!locations || [locations count] != [colors count])
    {
        NSMutableArray *defaultLocations = [NSMutableArray arrayWithCapacity:[colors count]];
        CGFloat step = 1.0f / ([colors count] - 1);
        CGFloat location = 0.0f;
        for (NSUInteger i = 0; i < [colors count]; i++)
        {
            [defaultLocations addObject:[NSNumber numberWithFloat:location]];
            location += step;
        }
            
        locations = defaultLocations;
    }
    
    // Create colors and colorspace
    CGColorRef colorCArray[[colors count]];
    
    // Get gradient locations    
    CGFloat locationsCArray[[locations count]];
    for (NSUInteger i = 0; i < [colors count]; i++)
    {
        colorCArray[i] = ((UIColor *)[colors objectAtIndex:i]).CGColor;
        locationsCArray[i] = [[locations objectAtIndex:i] floatValue];
    }
    
    CFArrayRef colorsCFArray = CFArrayCreate(NULL, (const void **)&colorCArray, [colors count], &kCFTypeArrayCallBacks);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
        
    // Create and set gradient
    CGGradientRef gradient = CGGradientCreateWithColors(colorspace, colorsCFArray, locationsCArray);
    CGColorSpaceRelease(colorspace);
    CFRelease(colorsCFArray);
    self.gradient = gradient;
    CGGradientRelease(gradient);
    
    // Refresh view
    [self setNeedsDisplay];
}

@end
