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
    
    GOODMaskedIconView *icon1 = [[GOODMaskedIconView alloc] initWithResourceNamed:@"beer.png"];
    [self.view addSubview:icon1];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

@end
