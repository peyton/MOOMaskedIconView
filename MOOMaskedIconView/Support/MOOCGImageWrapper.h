//
//  MOOCGImageWrapper.h
//  MOOMaskedIconView
//
//  Created by Peyton Randolph on 2/27/12.
//


@interface MOOCGImageWrapper : NSObject
{
    CGImageRef _CGImage;
}

@property (assign) CGImageRef CGImage;
@property (assign, readonly) NSUInteger cost;

- (id)initWithCGImage:(CGImageRef)image;
+ (MOOCGImageWrapper *)wrapperWithCGImage:(CGImageRef)image;

@end
