//
//  ViewController.m
//  GOODMaskedIconView Demo
//
//  Created by Peyton Randolph on 2/20/12.
//  Copyright (c) 2012 pandolph. All rights reserved.
//

#import "ViewController.h"

#import "GOODMaskedIconView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)loadView;
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    GOODMaskedIconView *icon1 = [[GOODMaskedIconView alloc] initWithResourceNamed:@"Beer.png"];
    [self.view addSubview:icon1];
    
    GOODMaskedIconView *icon2 = [[GOODMaskedIconView alloc] initWithResourceNamed:@"Beer.png" size:CGSizeMake(52.0f, 70.0f)];
    icon2.color = [UIColor yellowColor];
    CGRect icon2Frame = icon2.frame;
    icon2Frame.origin.x = CGRectGetMaxX(icon1.frame);
    icon2.frame = icon2Frame;
    [self.view addSubview:icon2];
    
    GOODMaskedIconView *icon3 = [[GOODMaskedIconView alloc] initWithResourceNamed:@"Beer.pdf" size:CGSizeMake(52.0f, 70.0f)];
    icon3.backgroundColor = [UIColor orangeColor];
    icon3.color = [UIColor greenColor];
    CGRect icon3Frame = icon3.frame;
    icon3Frame.origin.x = CGRectGetMaxX(icon2.frame);
    icon3.frame = icon3Frame;
    [self.view addSubview:icon3];
    
    GOODMaskedIconView *icon4 = [[GOODMaskedIconView alloc] initWithResourceNamed:@"Beer.pdf" size:CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(icon1.frame))];
    icon4.color = [UIColor whiteColor];
    CGRect icon4Frame = icon4.frame;
    icon4Frame.origin.y = CGRectGetMaxY(icon1.frame);
    icon4.frame = icon4Frame;
    icon4.transform = CGAffineTransformMakeScale(-1.0f, 1.0f);
    [self.view addSubview:icon4];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

@end
