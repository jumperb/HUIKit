//
//  HWebButtonView.h
//  PCommunityKitDemo
//
//  Created by zhangchutian on 15/8/6.
//  Copyright (c) 2015年 vstudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HWebImageView.h"

@interface HWebButtonView : HWebImageView
@property (nonatomic) UIButton *button;
@property (nonatomic) callback pressed;
@end
