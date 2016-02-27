//
//  HWebButtonView.m
//  PCommunityKitDemo
//
//  Created by zhangchutian on 15/8/6.
//  Copyright (c) 2015年 vstudio. All rights reserved.
//

#import "HWebButtonView.h"
#import <SDWebImageManager.h>
#import <UIButton+WebCache.h>
#import <UIImageView+WebCache.h>

@interface HWebButtonView()
@property (nonatomic) NSString *lastURL;
@property (nonatomic) UIImageView *imageView;
@end

@implementation HWebButtonView
- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 200, 200)];
    if (self) {
        [self addSubview:self.button];
        [self addSubview:self.imageView];
        self.backgroundColor = [UIColor colorWithHex:0xe8e8e8];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.button];
        [self addSubview:self.imageView];
        self.backgroundColor = [UIColor colorWithHex:0xe8e8e8];
    }
    return self;
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
        ALWAYS_FULL(_button);
    }
    return _button;
}

- (UIImageView *)imageView
{
    if (!_imageView)
    {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds = YES;
        _imageView.userInteractionEnabled = NO;
        ALWAYS_FULL(_imageView);
    }
    return _imageView;
}

- (BOOL)setImageUrl:(NSURL *)url
{
    if (self.imageView.image && [_lastURL isEqual:url.absoluteString])
    {
        self.imageView.alpha = 1;
        if (self.didGetImage) self.didGetImage(self, self.imageView.image);
        return YES;
    }
    if(!self.placeHoderImage) self.imageView.alpha = 0;
    UIImage *placeholder = self.placeHoderImage;
    if ([[SDWebImageManager sharedManager] cachedImageExistsForURL:url])
    {
        self.imageView.alpha = 1;
        placeholder = nil;
    }
    self.imageView.image = nil;
    __weak typeof(self) weakSelf = self;
    [self.imageView sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error)
        {
            if (weakSelf.didGetError) weakSelf.didGetError(weakSelf, error);
        }
        else if (image)
        {
            weakSelf.lastURL = url.absoluteString;
            [UIView animateWithDuration:0.5 animations:^{
                weakSelf.imageView.alpha = 1;
            }];
            if (weakSelf.didGetImage) weakSelf.didGetImage(weakSelf, image);
        }
    }];
    return NO;
}
- (void)buttonPressed
{
    if (_pressed) _pressed(self, nil);
}
@end

