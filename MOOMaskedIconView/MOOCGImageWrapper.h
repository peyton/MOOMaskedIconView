//
//  MOODiscardableCGImage.h
//  MOOMaskedIconView
//
//  Created by Peyton Randolph on 2/27/12.
//

#import <Foundation/Foundation.h>

@interface MOOCGImageWrapper : NSObject
{
    CGImageRef _CGImage;
    
    NSUInteger _refCount;
    
    BOOL _accessed;
}

@property (assign) CGImageRef CGImage;
@property (assign, readonly) NSUInteger cost;

- (id)initWithCGImage:(CGImageRef)image;
+ (MOOCGImageWrapper *)wrapperWithCGImage:(CGImageRef)image;

@end