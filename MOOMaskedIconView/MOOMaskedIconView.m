//
//  MOOMaskedIconView.m
//  MOOMaskedIconView
//
//  Created by Peyton Randolph on 2/6/12.
//

#import "MOOMaskedIconView.h"

#import <Accelerate/Accelerate.h>
#import <QuartzCore/QuartzCore.h>

#import "AHHelper.h"
#import "MOOCGImageWrapper.h"
#import "MOOResourceList.h"
#import "MOOStyleTrait.h"

// Keys for KVO
static NSString * const MOOHighlightedKeyPath = @"highlighted";
static NSString * const MOOMaskKeyPath = @"mask";
static NSString * const MOOOverlayKeyPath = @"overlay";

static NSString * const MOOGradientStartColorKeyPath = @"gradientStartColor";
static NSString * const MOOGradientEndColorKeyPath = @"gradientEndColor";
static NSString * const MOOGradientColorsKeyPath = @"gradientColors";
static NSString * const MOOGradientLocationsKeyPath = @"gradientLocations";
static NSString * const MOOGradientTypeKeyPath = @"gradientType";

static NSString * const MOOShadowColorKeyPath = @"shadowColor";
static NSString * const MOOShadowOffsetKeyPath = @"shadowOffset";

static NSString * const MOOOuterGlowRadiusKeyPath = @"outerGlowRadius";

// Helper functions
static NSURL *NSURLWithResourceNamed(NSString *resourceName, NSBundle *bundle);
static CGImageRef CGImageCreateInvertedMaskWithMask(CGImageRef sourceImage);

// Caches
NSCache *_defaultMaskCache;

@interface MOOMaskedIconView ()

@property (nonatomic, assign) CGImageRef mask;
@property (nonatomic, assign) CGGradientRef gradient;

- (id)_initWithMask:(CGImageRef)mask;


- (void)_addKVO;
- (void)_configureViewWithDefaults;
- (UIImage *)_renderImageHighlighted:(BOOL)shouldBeHighlighted;
- (void)_setNeedsGradient;
- (void)_updateGradientWithColors:(NSArray *)colors locations:(NSArray *)locations forType:(MOOGradientType)type;

@end

@implementation MOOMaskedIconView
@synthesize highlighted = _highlighted;
@dynamic trait;

@synthesize color = _color;
@synthesize highlightedColor = _highlightedColor;
@synthesize pattern = _pattern;
@synthesize patternBlendMode = _patternBlendMode;
@synthesize overlay = _overlay;
@synthesize overlayBlendMode = _overlayBlendMode;

@dynamic gradientStartColor;
@dynamic gradientEndColor;
@synthesize gradientColors = _gradientColors;
@synthesize gradientLocations = _gradientLocations;
@synthesize gradientType = _gradientType;

@synthesize shadowColor = _shadowColor;
@synthesize shadowOffset = _shadowOffset;
@synthesize clipsShadow = _clipsShadow;
@synthesize innerShadowColor = _innerShadowColor;
@synthesize innerShadowOffset = _innerShadowOffset;

@synthesize outerGlowColor = _outerGlowColor;
@synthesize outerGlowRadius = _outerGlowRadius;
@synthesize innerGlowColor = _innerGlowColor;
@synthesize innerGlowRadius = _innerGlowRadius;

@synthesize drawingBlock = _drawingBlock;
@synthesize mask = _mask;
@synthesize gradient = _gradient;

- (id)initWithFrame:(CGRect)frame;
{
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    // Configure view with defaults
    [self _configureViewWithDefaults];
    
    // Set up observing
    [self _addKVO];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    if (!(self = [super initWithCoder:aDecoder]))
        return nil;

    // Configure view with defaults
    [self _configureViewWithDefaults];
    
    // Set up observing
    [self _addKVO];

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

- (id)initWithPDFData:(NSData *)pdfData
{
    return [self initWithPDFData:pdfData size:CGSizeZero];
}

- (id)initWithPDFData:(NSData *)pdfData size:(CGSize)size
{
    if (!(self = [self initWithFrame:CGRectZero]))
        return nil;
    
    [self configureWithPDFData:pdfData size:size];
    
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

- (id)_initWithMask:(CGImageRef)mask;
{
    if (!(self = [self initWithFrame:CGRectZero]))
        return nil;
    
    self.mask = mask;
    
    return self;
}

- (void)dealloc;
{
    [self removeObserver:self forKeyPath:MOOHighlightedKeyPath];
    [self removeObserver:self forKeyPath:MOOMaskKeyPath];
    [self removeObserver:self forKeyPath:MOOOverlayKeyPath];
    [self removeObserver:self forKeyPath:MOOGradientStartColorKeyPath];
    [self removeObserver:self forKeyPath:MOOGradientEndColorKeyPath];
    [self removeObserver:self forKeyPath:MOOGradientColorsKeyPath];
    [self removeObserver:self forKeyPath:MOOGradientLocationsKeyPath];
    [self removeObserver:self forKeyPath:MOOGradientTypeKeyPath];
    [self removeObserver:self forKeyPath:MOOShadowColorKeyPath];
    [self removeObserver:self forKeyPath:MOOShadowOffsetKeyPath];
    [self removeObserver:self forKeyPath:MOOOuterGlowRadiusKeyPath];

    self.color = nil;
    self.highlightedColor = nil;
    self.pattern = nil;
    self.overlay = nil;
    self.drawingBlock = NULL;
    self.mask = NULL;
    self.gradient = NULL;
    self.gradientColors = nil;
    self.gradientLocations = nil;
    self.shadowColor = nil;
    self.innerShadowColor = nil;
    self.outerGlowColor = nil;
    self.innerGlowColor = nil;
    
    AH_SUPER_DEALLOC;
}

#pragma mark - Creation methods

+ (MOOMaskedIconView *)iconWithImage:(UIImage *)image;
{
    return AH_AUTORELEASE([[self alloc] initWithImage:image]);
}

+ (MOOMaskedIconView *)iconWithImage:(UIImage *)image size:(CGSize)size;
{
    return AH_AUTORELEASE([[self alloc] initWithImage:image size:size]);
}

+ (MOOMaskedIconView *)iconWithImageNamed:(NSString *)imageName;
{
    return AH_AUTORELEASE([[self alloc] initWithImageNamed:imageName]);
}

+ (MOOMaskedIconView *)iconWithImageNamed:(NSString *)imageName size:(CGSize)size;
{
    return AH_AUTORELEASE([[self alloc] initWithImageNamed:imageName size:size]);
}

+ (MOOMaskedIconView *)iconWithPDFNamed:(NSString *)pdfName;
{
    return AH_AUTORELEASE([[self alloc] initWithPDFNamed:pdfName]);
}

+ (MOOMaskedIconView *)iconWithPDFNamed:(NSString *)pdfName size:(CGSize)size;
{
    return AH_AUTORELEASE([[self alloc] initWithPDFNamed:pdfName size:size]);
}

+ (MOOMaskedIconView *)iconWithPDFData:(NSData *)pdfData
{
    return AH_AUTORELEASE([[self alloc] initWithPDFData:pdfData]);
}

+ (MOOMaskedIconView *)iconWithPDFData:(NSData *)pdfData size:(CGSize)size
{
    return AH_AUTORELEASE([[self alloc] initWithPDFData:pdfData size:size]);
}

+ (MOOMaskedIconView *)iconWithResourceNamed:(NSString *)resourceName;
{
    return AH_AUTORELEASE([[self alloc] initWithResourceNamed:resourceName]);
}

+ (MOOMaskedIconView *)iconWithResourceNamed:(NSString *)resourceName size:(CGSize)size;
{
    return AH_AUTORELEASE([[self alloc] initWithResourceNamed:resourceName size:size]);
}

#pragma mark - Drawing and layout methods

- (void)drawRect:(CGRect)rect
{
    // Generate gradient if needed
    if (_iconViewFlags.needsGradient)
    {
        [self _updateGradientWithColors:self.gradientColors locations:self.gradientLocations forType:self.gradientType];
        _iconViewFlags.needsGradient = NO;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGImageRef invertedMask = NULL;
    
    // Flip coordinates so images don't draw upside down
    CGContextTranslateCTM(context, 0.0f, CGRectGetHeight(rect));
    CGContextScaleCTM(context, 1.0f, -1.0f);

    CGRect imageRect = CGRectMake(0.0f, 0.0f, CGImageGetWidth(self.mask) / [UIScreen mainScreen].scale, CGImageGetHeight(self.mask) / [UIScreen mainScreen].scale);
    CGRect shadowRect = imageRect;
    shadowRect.origin = CGPointMake(self.shadowOffset.width, -self.shadowOffset.height);
        
    CGFloat dOuterGlow = (self.outerGlowRadius > 0.0f) ? -self.outerGlowRadius : 0.0f;
    
    CGRect unionRect = CGRectUnion(CGRectInset(imageRect, dOuterGlow, dOuterGlow), shadowRect);
    CGAffineTransform zeroOriginTransform = CGAffineTransformMakeTranslation(-CGRectGetMinX(unionRect), -CGRectGetMinY(unionRect));
    
    imageRect = CGRectApplyAffineTransform(imageRect, zeroOriginTransform);
    shadowRect = CGRectApplyAffineTransform(shadowRect, zeroOriginTransform);
    
    // Draw outer glow
    if (self.outerGlowRadius > 0.0f)
    {
        CGContextSaveGState(context);
        
        CGContextSetShadowWithColor(context, CGSizeZero, self.outerGlowRadius, (self.outerGlowColor) ? self.outerGlowColor.CGColor : [UIColor blackColor].CGColor);
        
        CGContextBeginTransparencyLayer(context, NULL);
        CGContextClipToMask(context, imageRect, self.mask);

        UIColor *fillColor = [UIColor blackColor];
        if (self.outerGlowColor)
        {
            CGColorRef outerGlowColorFullOpacity = CGColorCreateCopyWithAlpha(self.outerGlowColor.CGColor, 1.0f);
            fillColor = [UIColor colorWithCGColor:outerGlowColorFullOpacity];
            CGColorRelease(outerGlowColorFullOpacity);
        }
        
        [fillColor set];
        
        CGContextFillRect(context, imageRect);
        CGContextEndTransparencyLayer(context);
        
        CGContextRestoreGState(context);
    }
    
    // Draw shadow
    if (!CGSizeEqualToSize(self.shadowOffset, CGSizeZero))
    {
        CGContextSaveGState(context);
        [((self.shadowColor) ? self.shadowColor : [UIColor blackColor]) set];

        CGContextClipToMask(context, shadowRect, self.mask);
        
        // Clip to inverted mask to prevent icon from being filled
        if (self.clipsShadow)
        {
            if (!invertedMask)
                invertedMask = CGImageCreateInvertedMaskWithMask(self.mask);
            CGContextClipToMask(context, imageRect, invertedMask);
        }
        
        CGContextFillRect(context, shadowRect);
        CGContextRestoreGState(context);
    }
    
    CGContextSaveGState(context); // Push state before clipping to icon
    // Clip drawing to icon image
    CGContextClipToMask(context, imageRect, self.mask);
    
    // Fill icon
    CGContextSaveGState(context); // Save state before filling
    
    if (self.gradient && !(self.highlighted && self.highlightedColor))
    {
        // Draw gradient
        
        // Because the context is flipped, the start and end points must be swapped
        CGPoint startPoint = CGPointMake(CGRectGetMinX(imageRect), CGRectGetMinY(imageRect) + CGRectGetHeight(imageRect));
        CGPoint endPoint = CGPointMake(CGRectGetMinX(imageRect), CGRectGetMinY(imageRect));
        CGContextDrawLinearGradient(context, self.gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    } else {
        // Draw solid color
        if (self.highlighted && self.highlightedColor)
            [self.highlightedColor set];
        else
            [self.color set];
        
        CGContextFillRect(context, imageRect);
    }
    CGContextRestoreGState(context); // Restore state after filling
    
    if (self.pattern)
    {
        CGContextSaveGState(context);
        CGContextSetBlendMode(context, self.patternBlendMode);
        [self.pattern set];
        CGContextFillRect(context, imageRect);
        CGContextRestoreGState(context);
    }
    
    CGContextRestoreGState(context); // Pop state clipping to icon
    
    // Draw inner glow
    if (self.innerGlowRadius > 0.0f)
    {
        CGContextSaveGState(context);
        
        // Clip to inverted mask
        if (!invertedMask)
            invertedMask = CGImageCreateInvertedMaskWithMask(self.mask);
        
        CGContextClipToRect(context, imageRect);
        // Transparency layers create a drawing-context-within-a-drawing-context, allowing clearing without affecting what's been previously drawn.
        CGContextBeginTransparencyLayer(context, NULL);
        CGContextSetShadowWithColor(context, CGSizeZero, self.innerGlowRadius, (self.innerGlowColor) ? self.innerGlowColor.CGColor : [UIColor blackColor].CGColor);
        
        // Begin another transparency layer for the actual glow.
        CGContextBeginTransparencyLayer(context, NULL);
        CGContextClipToMask(context, imageRect, invertedMask);

        UIColor *fillColor = [UIColor blackColor];
        if (self.innerGlowColor)
        {
            CGColorRef outerGlowColorFullOpacity = CGColorCreateCopyWithAlpha(self.innerGlowColor.CGColor, 1.0f);
            fillColor = [UIColor colorWithCGColor:outerGlowColorFullOpacity];
            CGColorRelease(outerGlowColorFullOpacity);
        }
        
        [fillColor set];

        CGContextFillRect(context, self.bounds);
        CGContextEndTransparencyLayer(context); // End glow layer
        
        CGContextClipToMask(context, imageRect, invertedMask); // Reclip before clearing
        CGContextClearRect(context, imageRect); // Clear color drawn
        CGContextEndTransparencyLayer(context); // End makeshift context-within-a-context.
        
        CGContextRestoreGState(context);
    }

    CGContextClipToMask(context, imageRect, self.mask);
    // Draw inner shadow
    if (!CGSizeEqualToSize(self.innerShadowOffset, CGSizeZero))
    {
        CGContextSaveGState(context);
        
        // Clip to inverted mask to prevent main area from being filled
        if (!invertedMask)
            invertedMask = CGImageCreateInvertedMaskWithMask(self.mask);
        
        // Clip to inverted mask translated by innerShadowOffset
        CGAffineTransform innerShadowOffsetTransform = CGAffineTransformMakeTranslation(self.innerShadowOffset.width, -self.innerShadowOffset.height);
        CGContextClipToMask(context, CGRectApplyAffineTransform(imageRect, innerShadowOffsetTransform), invertedMask);            
        // Fill inner shadow color
        [self.innerShadowColor set];
        CGContextFillRect(context, imageRect);
        CGContextRestoreGState(context);
    }
    CGImageRelease(invertedMask); // Done with invertedMask
        
    // Draw overlay
    if (self.overlay)
    {
        CGContextSaveGState(context);
        CGContextSetBlendMode(context, self.overlayBlendMode);
        CGContextDrawImage(context, self.bounds, self.overlay.CGImage);
        CGContextRestoreGState(context);
    }
}

- (CGSize)sizeThatFits:(CGSize)size;
{
    const CGFloat scale = [UIScreen mainScreen].scale;
    CGSize newSize = CGSizeMake(CGImageGetWidth(self.mask) / scale + MAX(fabsf(self.shadowOffset.width), 2.0f * self.outerGlowRadius), CGImageGetHeight(self.mask) / scale + MAX(fabsf(self.shadowOffset.height), 2.0f * self.outerGlowRadius));
    return newSize;
}

#pragma mark - Configuration methods

- (void)configureWithImage:(UIImage *)image;
{
    [self configureWithImage:image size:CGSizeZero];
}

- (void)configureWithImage:(UIImage *)image size:(CGSize)size;
{
    CGImageRef mask = CGImageCreateMaskFromCGImage(image.CGImage, size);
    self.mask = mask;
    CGImageRelease(mask);
}

- (void)configureWithImageNamed:(NSString *)imageName;
{
    [self configureWithImageNamed:imageName size:CGSizeZero];
}

- (void)configureWithImageNamed:(NSString *)imageName size:(CGSize)size;
{
    // Fetch mask if it exists
    NSString *key = [imageName stringByAppendingString:NSStringFromCGSize(size)];
    CGImageRef mask = CGImageRetain(((MOOCGImageWrapper *)[[[self class] defaultMaskCache] objectForKey:key]).CGImage);
    if (!mask) {
        mask = CGImageCreateMaskFromImageNamed(imageName, size);
    }
    self.mask = mask;
    
    // Cache mask
    if ([[self class] shouldCacheMaskForKey:key]) {
        [[[self class] defaultMaskCache] setObject:[MOOCGImageWrapper wrapperWithCGImage:mask] forKey:key];
    }
    
    CGImageRelease(mask);
}

- (void)configureWithPDFNamed:(NSString *)pdfName;
{
    [self configureWithPDFNamed:pdfName size:CGSizeZero];
}

- (void)configureWithPDFNamed:(NSString *)pdfName size:(CGSize)size;
{
    // Fetch mask if it exists
    NSString *key = [pdfName stringByAppendingString:NSStringFromCGSize(size)];
    CGImageRef mask = CGImageRetain(((MOOCGImageWrapper *)[[[self class] defaultMaskCache] objectForKey:key]).CGImage);
    if (!mask)
        mask = CGImageCreateMaskFromPDFNamed(pdfName, size);
    
    self.mask = mask;
    
    // Cache mask
    if ([[self class] shouldCacheMaskForKey:key])
        [[[self class] defaultMaskCache] setObject:[MOOCGImageWrapper wrapperWithCGImage:mask] forKey:key];
    CGImageRelease(mask);
}

- (void)configureWithPDFData:(NSData *)pdfData
{
    [self configureWithPDFData:pdfData size:CGSizeZero];
}

- (void)configureWithPDFData:(NSData *)pdfData size:(CGSize)size
{
    CGImageRef mask = CGImageCreateMaskFromPDFData(pdfData, size);
    self.mask = mask;
    CGImageRelease(mask);
}

- (void)configureWithResourceNamed:(NSString *)resourceName;
{
    [self configureWithResourceNamed:resourceName size:CGSizeZero];
}

- (void)configureWithResourceNamed:(NSString *)resourceName size:(CGSize)size;
{
    NSString *key = [resourceName stringByAppendingString:NSStringFromCGSize(size)];
    CGImageRef mask = CGImageRetain(((MOOCGImageWrapper *)[[[self class] defaultMaskCache] objectForKey:key]).CGImage);
    if (!mask)
        mask = CGImageCreateMaskFromResourceNamed(resourceName, size);
    self.mask = mask;
    
    // Cache mask
    if ([[self class] shouldCacheMaskForKey:key])
        [[[self class] defaultMaskCache] setObject:[MOOCGImageWrapper wrapperWithCGImage:mask] forKey:key];
    CGImageRelease(mask);
}

#pragma mark - Trait methods

- (void)mixInTrait:(id<MOOStyleTrait>)trait;
{
    // Duplicated from MOOStyleTrait.m. TODO: share implementations
    if (![[self class] conformsToProtocol:trait.styleProtocol])
    {
        NSLog(@"Attempting to mix object %@ of incompatible protocol %@ into object %@ of protocol %@.", trait, NSStringFromProtocol(trait.styleProtocol), self, NSStringFromProtocol(self.styleProtocol));
        return;
    }
    
    id propertyValue;
    for (NSString *propertyName in propertyNamesForStyleProtocol(trait.styleProtocol))
        if ((propertyValue = [(NSObject *)trait valueForKey:propertyName]))
            [self setValue:propertyValue forKey:propertyName];
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

- (Protocol *)styleProtocol;
{
    return @protocol(MOOMaskedIconViewStyles);
}

- (id<MOOStyleTrait>)trait;
{
    MOOStyleTrait *trait = [MOOStyleTrait trait];
    
    for (NSString *propertyName in propertyNamesForStyleProtocol(self.styleProtocol))
        [trait setValue:[(NSObject *)self valueForKey:propertyName] forKey:propertyName];
        
    return trait;
}

- (void)setTrait:(id<MOOStyleTrait>)trait;
{
    if (![[self class] conformsToProtocol:trait.styleProtocol])
    {
        NSLog(@"Attempting to mix object %@ of incompatible protocol %@ into object %@ of protocol %@.", trait, NSStringFromProtocol(trait.styleProtocol), self, NSStringFromProtocol(self.styleProtocol));
        return;
    }
    
    for (NSString *propertyName in propertyNamesForStyleProtocol(self.styleProtocol))
        [self setValue:[(NSObject *)trait valueForKey:propertyName] forKey:propertyName];
}

#pragma mark - Caching methods

+ (NSCache *)defaultMaskCache;
{
    @synchronized(self)
    {
        if (!_defaultMaskCache)
        {
            _defaultMaskCache = [[NSCache alloc] init];
            _defaultMaskCache.totalCostLimit = 1024 * 1024 * 2; // Default mask cache size of 2mb;
        }
    
        return _defaultMaskCache;
    }
}

+ (BOOL)shouldCacheMaskForKey:(NSString *)key;
{
    return [[MOOResourceRegistry sharedRegistry] shouldCacheResourceWithKey:key];
}

#pragma mark - KVO methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
    if ([keyPath isEqualToString:MOOHighlightedKeyPath] ||
        [keyPath isEqualToString:MOOMaskKeyPath] ||
        [keyPath isEqualToString:MOOOverlayKeyPath])
    {
        [self setNeedsDisplay];
        return;
    }
    
    if ([keyPath isEqualToString:MOOShadowColorKeyPath] ||
        [keyPath isEqualToString:MOOShadowOffsetKeyPath] ||
        [keyPath isEqualToString:MOOOuterGlowRadiusKeyPath])
    {
        [self sizeToFit];
        [self setNeedsDisplay];
        return;
    }
    
    if ([keyPath isEqualToString:MOOGradientStartColorKeyPath] ||
        [keyPath isEqualToString:MOOGradientEndColorKeyPath] ||
        [keyPath isEqualToString:MOOGradientColorsKeyPath] ||
        [keyPath isEqualToString:MOOGradientLocationsKeyPath] ||
        [keyPath isEqualToString:MOOGradientTypeKeyPath])
    {
        [self _setNeedsGradient];
        [self setNeedsDisplay];
        return;
    }
}

#pragma mark - NSCopying methods

- (id)copyWithZone:(NSZone *)zone;
{
    // Todo: implement NSCopying
    return nil;
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

- (void)_addKVO;
{
    
    // Set up observing
    [self addObserver:self forKeyPath:MOOHighlightedKeyPath options:0 context:NULL];
    [self addObserver:self forKeyPath:MOOMaskKeyPath options:0 context:NULL];
    [self addObserver:self forKeyPath:MOOOverlayKeyPath options:0 context:NULL];
    [self addObserver:self forKeyPath:MOOGradientStartColorKeyPath options:0 context:NULL];
    [self addObserver:self forKeyPath:MOOGradientEndColorKeyPath options:0 context:NULL];
    [self addObserver:self forKeyPath:MOOGradientColorsKeyPath options:0 context:NULL];
    [self addObserver:self forKeyPath:MOOGradientLocationsKeyPath options:0 context:NULL];
    [self addObserver:self forKeyPath:MOOGradientTypeKeyPath options:0 context:NULL];
    [self addObserver:self forKeyPath:MOOShadowColorKeyPath options:0 context:NULL];
    [self addObserver:self forKeyPath:MOOShadowOffsetKeyPath options:0 context:NULL];
    [self addObserver:self forKeyPath:MOOOuterGlowRadiusKeyPath options:0 context:NULL];
}

- (void)_configureViewWithDefaults;
{
    self.backgroundColor = [UIColor clearColor];
}

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

- (void)_setNeedsGradient;
{
    _iconViewFlags.needsGradient = YES;
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
}

@end

// Helper functions

static NSURL *NSURLWithResourceNamed(NSString *resourceName, NSBundle *bundle)
{
    if (!resourceName)
        return nil;

    if (!bundle)
        bundle = [NSBundle mainBundle];
    
    NSString *path = [bundle pathForResource:resourceName ofType:nil];
    if (!path)
    {
        NSLog(@"File named %@ not found. Check spelling or capitalization?", resourceName);
        return nil;
    }

    return [NSURL fileURLWithPath:path];
}

CGImageRef CGImageCreateMaskFromCGImage(CGImageRef source, CGSize size)
{
    // If no image is passed, return nothing
    if (source == nil) {
        return NULL;
    }
    // Variables for image creation
    CGSize imageSize = CGSizeZero;
    size_t bytesPerRow = 0;
    const CGFloat scale = [UIScreen mainScreen].scale;
    
    CGImageRef maskSource; // The source to work create the mask from. Differs from `source` in that it may be resized

    if (size.width > 0.0f && size.height > 0.0f) 
    {
        // Custom size
        imageSize = size;
        imageSize.width *= scale;
        imageSize.height *= scale;
        CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceGray();
        bytesPerRow = imageSize.width * CGColorSpaceGetNumberOfComponents(colorspace);
        
        // Create bitmap context
        CGContextRef context = CGBitmapContextCreate(NULL, imageSize.width, imageSize.height, CGImageGetBitsPerComponent(source), bytesPerRow, colorspace, kCGBitmapAlphaInfoMask & kCGImageAlphaNone);
        CGColorSpaceRelease(colorspace);
        
        CGContextSetInterpolationQuality(context, kCGInterpolationLow);
        CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height), source);
        maskSource = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
    }
    else 
    {   
        // Default size
        imageSize = CGSizeMake(CGImageGetWidth(source), CGImageGetHeight(source));
        bytesPerRow = CGImageGetBytesPerRow(source);
        
        // Retain maskSource to match the created image's retain count above
        maskSource = CGImageRetain(source);
    }

    // Create mask
    CGImageRef maskRef = CGImageMaskCreate(imageSize.width, imageSize.height, CGImageGetBitsPerComponent(maskSource), CGImageGetBitsPerPixel(maskSource), bytesPerRow, CGImageGetDataProvider(maskSource), NULL, NO);
    
    // release the source as it has been retained locally
    CGImageRelease(maskSource);
    return maskRef;
}

CGImageRef CGImageCreateMaskFromImageNamed(NSString *imageName, CGSize size)
{
    NSURL *imageURL = NSURLWithResourceNamed(imageName, nil);
    UIImage *image = [UIImage imageWithContentsOfFile:[imageURL relativePath]];
    return CGImageCreateMaskFromCGImage(image.CGImage, size);
}

CGImageRef CGImageCreateMaskFromPDFNamed(NSString *pdfName, CGSize size)
{
    if (!pdfName)
        return NULL;
    
    // Grab pdf
    NSURL *pdfURL = NSURLWithResourceNamed(pdfName, nil);
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((__bridge CFURLRef)pdfURL);
    CGPDFPageRef firstPage = CGPDFDocumentGetPage(pdf, 1);
    
    if (firstPage == NULL)
    {
        CGPDFDocumentRelease(pdf);
        return NULL;
    }
    
    CGImageRef maskRef = CGImageCreateMaskFromPDFPage(firstPage, size);
    CGPDFDocumentRelease(pdf);
    
    return maskRef;
}

CGImageRef CGImageCreateMaskFromPDFData(NSData *pdfData, CGSize size)
{
    if (!pdfData)
        return NULL;
    
    // Grab pdf
    CGDataProviderRef pdfDataProvider = CGDataProviderCreateWithCFData((__bridge CFDataRef) pdfData);
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithProvider(pdfDataProvider);
    CGPDFPageRef firstPage = CGPDFDocumentGetPage(pdf, 1);
    CGDataProviderRelease(pdfDataProvider);
    
    if (firstPage == NULL)
    {
        CGPDFDocumentRelease(pdf);
        return NULL;
    }
    
    CGImageRef maskRef = CGImageCreateMaskFromPDFPage(firstPage, size);
    CGPDFDocumentRelease(pdf);
    
    return maskRef;
}

CGImageRef CGImageCreateMaskFromPDFPage(CGPDFPageRef page, CGSize size)
{
    // Calculate metrics
    const CGRect mediaRect = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
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
    CGContextDrawPDFPage(context, page);
    
    // Create image to mask
    CGImageRef imageToMask = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();
    
    // Create image mask
    CGImageRef maskRef = CGImageMaskCreate(CGImageGetWidth(imageToMask), CGImageGetHeight(imageToMask), CGImageGetBitsPerComponent(imageToMask), CGImageGetBitsPerPixel(imageToMask), CGImageGetBytesPerRow(imageToMask), CGImageGetDataProvider(imageToMask), NULL, NO);
    CGImageRelease(imageToMask);
    
    return maskRef;
}

CGImageRef CGImageCreateMaskFromResourceNamed(NSString *resourceName, CGSize size)
{
    NSString *extension = [resourceName pathExtension];
    if ([extension isEqualToString:@"pdf"])
        return CGImageCreateMaskFromPDFNamed(resourceName, size);

    return CGImageCreateMaskFromImageNamed(resourceName, size);
};

/*
 * CGImageCreateInvertedMaskWithMask.
 *
 * Adapted from Benjamin Godard's excellent NYXImagesKit: https://github.com/Nyx0uf/NYXImagesKit/blob/master/Categories/UIImage%2BFiltering.m
 */
/* Negative multiplier to invert a number */
static float __negativeMultiplier = -1.0f;
static CGImageRef CGImageCreateInvertedMaskWithMask(CGImageRef sourceMask)
{
    if (!sourceMask)
        return NULL;
    
    if (!CGImageIsMask(sourceMask))
    {
        NSLog(@"Attempting to invert non-mask: %@", sourceMask);
    }
    
    /// Create an ARGB bitmap context
	const size_t width = CGImageGetWidth(sourceMask);
	const size_t height = CGImageGetHeight(sourceMask);
    
	/// Grab the image raw data
    CFDataRef dataRef = CGDataProviderCopyData(CGImageGetDataProvider(sourceMask));
    if (!dataRef)
	{
		NSLog(@"Image to be inverted contains no data");
        return NULL;
	}
	UInt8* data = (UInt8*)CFDataGetBytePtr(dataRef);
    
	const size_t pixelsCount = width * height;
	float* dataAsFloat = (float*)malloc(sizeof(float) * pixelsCount);
    CGFloat min = 0.0f, max = 255.0f;
	UInt8* dataGray = data + 1;
    
	/// vDSP_vsmsa() = multiply then add
	/// slightly faster than the couple vDSP_vneg() & vDSP_vsadd()
	/// Probably because there are 3 function calls less
    
	/// Calculate gray components
	vDSP_vfltu8(dataGray, 2, dataAsFloat, 1, pixelsCount);
	vDSP_vsmsa(dataAsFloat, 1, &__negativeMultiplier, &max, dataAsFloat, 1, pixelsCount);
	vDSP_vclip(dataAsFloat, 1, &min, &max, dataAsFloat, 1, pixelsCount);
    // The following line generates memory access errors on iOS 6+ and doesn't appear to be necessary.
    // todo: figure out why float->uint conversion fails
//	vDSP_vfixu8(dataAsFloat, 1, dataGray, 2, pixelsCount);
    
    // Create new image in the gray color space, since RGB images aren't valid masks
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceGray();
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(dataRef);
	CGImageRef invertedImage = CGImageCreate(width, height, CGImageGetBitsPerComponent(sourceMask), CGImageGetBitsPerPixel(sourceMask), CGImageGetBytesPerRow(sourceMask), colorspace, CGImageGetBitmapInfo(sourceMask), dataProvider, NULL, NO, kCGRenderingIntentDefault);
    CGColorSpaceRelease(colorspace);
    CGDataProviderRelease(dataProvider);
    free(dataAsFloat);
    CFRelease(dataRef);
    
	return invertedImage;
}
