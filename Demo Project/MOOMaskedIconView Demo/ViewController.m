//
//  ViewController.m
//  MOOMaskedIconView Demo
//
//  Created by Peyton Randolph on 2/20/12.
//

#import "ViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "MOOMaskedIconView.h"
#import "MOOStyleTrait.h"

#define kBarHeight 64.0f

@interface ViewController ()

- (void)toggleIcon4Highlighted:(id)sender;

@end

@implementation ViewController

#pragma mark - View lifecycle

- (void)loadView;
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    /*
     * Create toolbar
     */
    
    UIView *grayBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.view.frame) - kBarHeight, CGRectGetWidth(self.view.bounds), kBarHeight)];
    grayBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Gray-Bar.png"]];
    [self.view addSubview:grayBar];
    
    // Appearance trait for small, gray icons
    MOOStyleTrait *grayIconTrait = [MOOStyleTrait trait];
    
    grayIconTrait.gradientColors = [NSArray arrayWithObjects:
                           [UIColor colorWithHue:0.0f saturation:0.05f brightness:0.34f alpha:1.0f],
                           [UIColor colorWithHue:0.0f saturation:0.05f brightness:0.57f alpha:1.0f], nil];
    grayIconTrait.shadowColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
    grayIconTrait.shadowOffset = CGSizeMake(0.0f, -1.0f);
    
    grayIconTrait.innerShadowColor = [UIColor colorWithWhite:1.0f alpha:0.6f];
    grayIconTrait.innerShadowOffset = CGSizeMake(0.0f, -1.0f);
    
    // Appearance trait for small, blue icons
    MOOStyleTrait *blueIconTrait = [MOOStyleTrait trait];
    blueIconTrait.shadowColor = [UIColor colorWithHue:234.f/360.f saturation:0.91f brightness:1.0f alpha:0.70f];
    blueIconTrait.shadowOffset = CGSizeMake(0.0f, -1.0f);
    blueIconTrait.innerShadowColor = [UIColor colorWithHue:212.f/360.f saturation:0.87f brightness:1.0f alpha:0.93];
    blueIconTrait.innerShadowOffset = CGSizeMake(0.0f, -1.0f);
    
    blueIconTrait.gradientColors = [NSArray arrayWithObjects:
                               [UIColor colorWithHue:237.0f/360.0f saturation:.83f brightness:.74f alpha:1.0f],
                               [UIColor colorWithHue:205.0f/360.0f saturation:.71f brightness:.96f alpha:1.0f], nil];
    blueIconTrait.outerGlowColor = [UIColor colorWithHue:210.0f/360.0f saturation:.95f brightness:.43f alpha:0.9f];
    blueIconTrait.outerGlowRadius = 15.0f;
    blueIconTrait.innerGlowColor = [UIColor colorWithRed:0.8f green:0.9f blue:1.0f alpha:0.8f];
    blueIconTrait.innerGlowRadius = 1.0f;
    
    // Quick closure to position icons
    void (^positionIconAtIndex)(MOOMaskedIconView *icon, NSUInteger index) = ^(MOOMaskedIconView *icon, NSUInteger index) {
        CGFloat stepSize = CGRectGetWidth(self.view.bounds) / 5.0f;
        
        icon.layer.position = CGPointMake(stepSize * (index + 0.5f), CGRectGetHeight(grayBar.bounds) / 2.0f);
        icon.frame = CGRectIntegral(icon.frame);
    };
    
    MOOMaskedIconView *eye = [[MOOMaskedIconView alloc] initWithResourceNamed:@"Eye.pdf"];
    [eye mixInTrait:grayIconTrait];
    positionIconAtIndex(eye, 0);
    [grayBar addSubview:eye];
    
    MOOMaskedIconView *chatBubble = [[MOOMaskedIconView alloc] initWithResourceNamed:@"Chat Bubble.pdf"];
    [chatBubble mixInTrait:grayIconTrait];
    positionIconAtIndex(chatBubble, 1);
    [grayBar addSubview:chatBubble];
    
    MOOMaskedIconView *roundedRect = [[MOOMaskedIconView alloc] initWithResourceNamed:@"Rounded Rect.pdf"];
    [roundedRect mixInTrait:grayIconTrait];
    positionIconAtIndex(roundedRect, 2);
    [grayBar addSubview:roundedRect];
    
    MOOMaskedIconView *location = [[MOOMaskedIconView alloc] initWithResourceNamed:@"Location.pdf"];
    [location mixInTrait:blueIconTrait];
    positionIconAtIndex(location, 2);
    
    MOOMaskedIconView *locationOverlay = [[MOOMaskedIconView alloc] initWithResourceNamed:@"Overlay.pdf" size:location.frame.size];
    locationOverlay.color = [UIColor colorWithWhite:1.0f alpha:0.7f];
    location.overlay = [locationOverlay renderImage];
    
    [grayBar addSubview:location];
    
    MOOMaskedIconView *search = [[MOOMaskedIconView alloc] initWithResourceNamed:@"Search.pdf"];
    [search mixInTrait:grayIconTrait];
    positionIconAtIndex(search, 3);
    [grayBar addSubview:search];
    
    MOOMaskedIconView *arrow = [[MOOMaskedIconView alloc] initWithResourceNamed:@"Arrow.pdf"];
    [arrow mixInTrait:grayIconTrait];
    positionIconAtIndex(arrow, 4);
    [grayBar addSubview:arrow];
    
    // Large gray gradient mirrored PDF with overlay
    CGSize beer5Size = CGSizeMake(CGRectGetWidth(self.view.bounds) - 20.0f, CGRectGetHeight(self.view.bounds) - kBarHeight - 20.0f);
    MOOMaskedIconView *icon5OverlayView = [[MOOMaskedIconView alloc] initWithResourceNamed:@"Overlay.pdf" size:beer5Size];
    icon5OverlayView.color = [UIColor whiteColor];
    icon5OverlayView.transform = CGAffineTransformMakeScale(-1.0f, 1.0f);
    UIImage *icon5Overlay = [icon5OverlayView renderImage];
    
    MOOMaskedIconView *beer = [[MOOMaskedIconView alloc] initWithResourceNamed:@"Beer.pdf" size:beer5Size];
    beer.backgroundColor = self.view.backgroundColor;
    beer.gradientColors = [NSArray arrayWithObjects:
                            [UIColor colorWithWhite:0.8f alpha:1.0f],
                            [UIColor colorWithWhite:0.9f alpha:1.0f], 
                            [UIColor colorWithWhite:0.9f alpha:1.0f], 
                            [UIColor colorWithWhite:0.5f alpha:1.0f], nil];
    beer.gradientLocations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0f],
                               [NSNumber numberWithFloat:0.1f], 
                               [NSNumber numberWithFloat:0.9f], 
                               [NSNumber numberWithFloat:1.0f], nil];
    beer.overlay = icon5Overlay;
    
    CGRect beerFrame = beer.frame;
    beerFrame.origin = CGPointMake(10.0f, 10.0f);
    beer.frame = beerFrame;
    [self.view addSubview:beer];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark -

- (void)toggleIcon4Highlighted:(id)sender;
{
    _icon4.highlighted = !_icon4.isHighlighted;
}

@end
