//
//  ViewController.m
//  HUIKitDemo
//
//  Created by camera360 on 15/11/20.
//  Copyright © 2015年 pp_panda. All rights reserved.
//

#import "ViewController.h"
#import "HWebImageView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    HWebImageView *imageView = [[HWebImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [imageView setImageUrlString:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
