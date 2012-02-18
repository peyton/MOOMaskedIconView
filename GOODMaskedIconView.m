//
//  HATMaskedIcon.m
//  Hat
//
//  Created by Peyton Randolph on 2/6/12.
//  Copyright (c) 2012 pandolph. All rights reserved.
//

#import "GOODMaskedIconView.h"

static NSString * const GOODMaskedIconViewHighlightedKey = @"highlighted";
static NSString * const GOODMaskedIconViewMaskKey = @"mask";

@interface GOODMaskedIconView ()

@property (nonatomic, assign) CGImageRef mask;

+ (NSURL *)_resourceURL:(NSString *)resourceName;

@end

@implementation GOODMaskedIconView
@synthesize highlighted = _highlighted;

@synthesize color = _color;
@synthesize highlightedColor = _highlightedColor;

@synthesize drawingBlock = _drawingBlock;
@synthesize mask = _mask;

- (id)initWithImage:(UIImage *)image;
{
    if (!(self = [super initWithFrame:CGRectZero]))
        return nil;
    
    // Set view defaults
    self.backgroundColor = [UIColor clearColor];
    self.color = [UIColor darkGrayColor];
    
    // Configure with image
    [self configureWithImage:image];
    
    // Set up observing
    [self addObserver:self forKeyPath:GOODMaskedIconViewHighlightedKey options:0 context:NULL];
    [self addObserver:self forKeyPath:GOODMaskedIconViewMaskKey options:0 context:NULL];

    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    @throw([NSException exceptionWithName:NSInternalInconsistencyException reason:@"Called -initWithFrame: method on HATMaskedIcon. Use -initWithImage: instead." userInfo:nil]);
}

- (void)dealloc;
{
    [self removeObserver:self forKeyPath:GOODMaskedIconViewHighlightedKey];
    [self removeObserver:self forKeyPath:GOODMaskedIconViewMaskKey];

    self.color = nil;
    self.drawingBlock = NULL;
    self.highlightedColor = nil;
    self.mask = NULL;
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
    
    // Fill icon with color
    CGContextSaveGState(context);
    if (self.highlighted && self.highlightedColor)
        [self.highlightedColor set];
    else
        [self.color set];
    CGContextFillRect(context, rect);
    CGContextRestoreGState(context);
    
    // Perform additional drawing if specified
    if (self.drawingBlock != NULL)
    {
        CGContextSaveGState(context);
        self.drawingBlock(context);
        CGContextRestoreGState(context);
    }
}

- (CGSize)sizeThatFits:(CGSize)size;
{
    CGFloat scale = [UIScreen mainScreen].scale;
    return CGSizeMake(CGImageGetWidth(self.mask) / scale, CGImageGetHeight(self.mask) / scale);
}

#pragma mark - Getters and setters

- (void)setMask:(CGImageRef)mask;
{
    if (mask == self.mask)
        return;
    
    CGImageRelease(self.mask);
    _mask = CGImageRetain(mask);
}

#pragma mark - Configuration methods

- (void)configureWithImage:(UIImage *)image;
{
    [self configureWithImage:image size:CGSizeZero];
}

- (void)configureWithImage:(UIImage *)image size:(CGSize)size;
{
    if (image == nil)
    {
        self.mask = NULL;
        return;
    }
    
    CGImageRef imageRef = image.CGImage;
    CGSize imageSize = CGSizeZero;
    size_t bytesPerRow = 0;
    
    if (size.width > 0.0f && size.height > 0.0f) 
    {
        imageSize = size;
        bytesPerRow = CGImageGetWidth(imageRef) * CGColorSpaceGetNumberOfComponents(CGImageGetColorSpace(imageRef));
    }
    else 
    {
        imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
        bytesPerRow = CGImageGetBytesPerRow(imageRef);
    }
    
    CGImageRef maskRef = CGImageMaskCreate(imageSize.width, imageSize.height, CGImageGetBitsPerComponent(imageRef), CGImageGetBitsPerPixel(imageRef), bytesPerRow, CGImageGetDataProvider(imageRef), NULL, NO);
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
    UIImage *image = [UIImage imageWithContentsOfFile:[imageURL absoluteString]];
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
        return;
    
    // Calculate metrics
    CGRect mediaRect = CGPDFPageGetBoxRect(firstPage, kCGPDFCropBox);
    CGSize pdfSize = (size.width > 0.0f && size.height > 0.0f) ? size : mediaRect.size;
    
    // Set up context
    UIGraphicsBeginImageContextWithOptions(pdfSize, YES, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Draw background
    [[UIColor whiteColor] set];
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, pdfSize.width, pdfSize.height));
    
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

#pragma mark - KVO methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
    if ([keyPath isEqualToString:GOODMaskedIconViewHighlightedKey])
        [self setNeedsDisplay];
}

#pragma mark -

- (UIImage *)renderToImage;
{
    [self sizeToFit];
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0f);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - FOR PRIVATE EYES ONLY

+ (NSURL *)_resourceURL:(NSString *)resourceName
{
    return (resourceName) ? [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:resourceName ofType:nil]] : nil;
}

@end
