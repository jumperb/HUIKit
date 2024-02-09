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
    [imageView setImageUrlString:@"https://d.musicapp.migu.cn/prod/vrbt-template-service/template/20230323/0c918f6f-a073-46e4-bfac-4cdb1ddbfc1c.gif"];
    [self.view addSubview:imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
