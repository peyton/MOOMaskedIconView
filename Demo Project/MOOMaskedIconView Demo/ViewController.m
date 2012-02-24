//
//  ViewController.m
//  MOOMaskedIconView Demo
//
//  Created by Peyton Randolph on 2/20/12.
//

#import "ViewController.h"

#import "MOOMaskedIconView.h"

@interface ViewController ()

- (void)toggleIcon4Highlighted:(id)sender;

@end

@implementation ViewController

#pragma mark - View lifecycle

- (void)loadView;
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    // Unstyled PNG
    MOOMaskedIconView *icon1 = [[MOOMaskedIconView alloc] initWithResourceNamed:@"Beer.png"];
    [self.view addSubview:icon1];
    
    // Yellow-red gradient squished PNG
    MOOMaskedIconView *icon2 = [[MOOMaskedIconView alloc] initWithResourceNamed:@"Beer.png" size:CGSizeMake(80.0f, 70.0f)];
    icon2.backgroundColor = self.view.backgroundColor;
    icon2.gradientStartColor = [UIColor yellowColor];
    icon2.gradientEndColor = [UIColor redColor];
    CGRect icon2Frame = icon2.frame;
    icon2Frame.origin.x = CGRectGetMaxX(icon1.frame);
    icon2.frame = icon2Frame;
    icon2.transform = CGAffineTransformMakeScale(-1.0f, 1.0f);
    [self.view addSubview:icon2];
    
    // Green squished PDF
    MOOMaskedIconView *icon3 = [[MOOMaskedIconView alloc] initWithResourceNamed:@"Beer.pdf" size:CGSizeMake(52.0f, 70.0f)];
    icon3.backgroundColor = [UIColor orangeColor];
    icon3.color = [UIColor greenColor];
    CGRect icon3Frame = icon3.frame;
    icon3Frame.origin.x = CGRectGetMaxX(icon2.frame);
    icon3.frame = icon3Frame;
    [self.view addSubview:icon3];
    
    // Squished highlighted blue PDF
    MOOMaskedIconView *icon4 = [[MOOMaskedIconView alloc] initWithResourceNamed:@"Beer.pdf" size:CGSizeMake(102.0f, 20.0f)];
    icon4.backgroundColor = [UIColor blackColor];
    icon4.color = [UIColor greenColor];
    icon4.highlightedColor = [UIColor blueColor];
    icon4.highlighted = YES;
    CGRect icon4Frame = icon4.frame;
    icon4Frame.origin.x = CGRectGetMaxX(icon3.frame);
    icon4.frame = icon4Frame;
    [self.view addSubview:icon4];
    
    // Toggle highlighting icon4 every 1s
    _icon4 = icon4;
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(toggleIcon4Highlighted:) userInfo:nil repeats:YES];
    
    // Large gray gradient mirrored PDF with overlay
    CGSize icon5Size = CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(icon1.frame));
    MOOMaskedIconView *icon5OverlayView = [[MOOMaskedIconView alloc] initWithResourceNamed:@"Overlay.pdf" size:icon5Size];
    icon5OverlayView.color = [UIColor whiteColor];
    icon5OverlayView.transform = CGAffineTransformMakeScale(-1.0f, 1.0f);
    UIImage *icon5Overlay = [icon5OverlayView renderImage];

    MOOMaskedIconView *icon5 = [[MOOMaskedIconView alloc] initWithResourceNamed:@"Beer.pdf" size:icon5Size];
    icon5.backgroundColor = self.view.backgroundColor;
    icon5.gradientColors = [NSArray arrayWithObjects:[UIColor colorWithWhite:1.0f alpha:1.0f], [UIColor colorWithWhite:0.6f alpha:1.0f], nil];
    icon5.gradientLocations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.9f], [NSNumber numberWithFloat:1.0], nil];
    icon5.overlay = icon5Overlay;
    icon5.transform = CGAffineTransformMakeScale(-1.0f, 1.0f);
    CGRect icon5Frame = icon5.frame;
    icon5Frame.origin.y = CGRectGetMaxY(icon1.frame);
    icon5.frame = icon5Frame;
    [self.view addSubview:icon5];
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
