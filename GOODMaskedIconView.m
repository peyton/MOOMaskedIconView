//
//  HATMaskedIcon.m
//  Hat
//
//  Created by Peyton Randolph on 2/6/12.
//  Copyright (c) 2012 pandolph. All rights reserved.
//

#import "GOODMaskedIconView.h"

static NSString * const GOODMaskedIconViewHighlightedKey = @"highlighted";
@interface GOODMaskedIconView ()

@property (nonatomic, assign) CGImageRef mask;

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

    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    @throw([NSException exceptionWithName:NSInternalInconsistencyException reason:@"Called -initWithFrame: method on HATMaskedIcon. Use -initWithImage: instead." userInfo:nil]);
}

- (void)dealloc;
{
    self.mask = NULL;
    
    [self removeObserver:self forKeyPath:GOODMaskedIconViewHighlightedKey];
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

#pragma mark - Configuration methods

- (void)configureWithImage:(UIImage *)image;
{
    if (image == nil)
    {
        self.mask = NULL;
        return;
    }
    
    CGImageRef imageRef = image.CGImage;
    self.mask = CGImageMaskCreate(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef), CGImageGetBitsPerComponent(imageRef), CGImageGetBitsPerPixel(imageRef), CGImageGetBytesPerRow(imageRef), CGImageGetDataProvider(imageRef), NULL, NO);;
}

#pragma mark - KVO methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
    if ([keyPath isEqualToString:GOODMaskedIconViewHighlightedKey])
        [self setNeedsDisplay];
}


@end
