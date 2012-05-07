//
//  MOOCGImageWrapper.h
//  MOOMaskedIconView
//
//  Created by Peyton Randolph on 2/27/12.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <CoreGraphics/CoreGraphics.h>
#else
#import <ApplicationServices/ApplicationServices.h>
#endif

@interface MOOCGImageWrapper : NSObject
{
    CGImageRef _CGImage;
}

@property (assign) CGImageRef CGImage;
@property (assign, readonly) NSUInteger cost;

- (id)initWithCGImage:(CGImageRef)image;
+ (MOOCGImageWrapper *)wrapperWithCGImage:(CGImageRef)image;

@end
