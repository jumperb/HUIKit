//
//  HWebButtonView.m
//  PCommunityKitDemo
//
//  Created by zhangchutian on 15/8/6.
//  Copyright (c) 2015年 vstudio. All rights reserved.
//

#import "HWebButtonView.h"

@interface HWebImageView ()
- (void)setup;
@end

@implementation HWebButtonView

- (void)setup
{
    [self addSubview:self.button];
    [super setup];
}
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _button.frame = self.bounds;
}
- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    _button.frame = self.bounds;
}
- (UIButton *)button
{
    if (!_button)
    {
        _button = [[UIButton alloc] initWithFrame:self.bounds];
        _button.imageView.contentMode = UIViewContentModeScaleAspectFill;
        _button.layer.masksToBounds = YES;
        [_button hAddTarget:self action:@selector(buttonPressed)];
        _button.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return _button;
}

- (void)setRenderColor:(UIColor *)renderColor
{
    [super setRenderColor:renderColor];
    if (self.renderColor)
    {
        self.button.tintColor = self.renderColor;
        [self.button setImage:[[self.button imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    }
    else
    {
        [self.button setImage:[[self.button imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    }
}

- (void)buttonPressed
{
    if (_pressed) _pressed(self, nil);
}
@end

