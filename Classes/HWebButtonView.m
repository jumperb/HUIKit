//
//  HWebButtonView.m
//  PCommunityKitDemo
//
//  Created by zhangchutian on 15/8/6.
//  Copyright (c) 2015年 vstudio. All rights reserved.
//

#import "HWebButtonView.h"
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIButton+WebCache.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface HWebButtonView()
@property (nonatomic) NSString *lastURL;

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

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    self.lastURL = nil;
    self.placeHoderImage = nil;
}


- (void)setImageUrl:(NSURL *)url
{
    return [self setImageUrl:url syncLoadCache:NO];
}

- (void)setImageUrl:(NSURL *)url syncLoadCache:(BOOL)syncLoadCache
{
    if (self.imageView.image && [_lastURL isEqual:url.absoluteString])
    {
        self.imageView.alpha = 1;
        if (self.didGetImage) self.didGetImage(self, self.imageView.image);
        return;
    }
    
    if(!self.placeHoderImage) self.imageView.alpha = 0;
    
    __block UIImage *placeholder = self.placeHoderImage;

    @weakify(self);
    [[SDWebImageManager sharedManager] cachedImageExistsForURL:url completion:^(BOOL isInCache) {
        @strongify(self);

        if (self.cacheStatusCallback) self.cacheStatusCallback(self, isInCache?@(YES):nil);

        if (isInCache)
        {
            self.imageView.alpha = 1;
            placeholder = nil;
            if (syncLoadCache)
            {
                NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
                UIImage *image = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:key];
                self.imageView.image = image;
                
                self.lastURL = url.absoluteString;
                if (self.didGetImage) self.didGetImage(self, image);
            }
        }
    }];
    
    self.imageView.image = nil;

    [self.imageView sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        @strongify(self);
        if (error)
        {
            if (self.didGetError) self.didGetError(self, error);
        }
        else if (image)
        {
            self.lastURL = url.absoluteString;
            [UIView animateWithDuration:0.5 animations:^{
                self.imageView.alpha = 1;
            }];
            if (self.didGetImage) self.didGetImage(self, image);
        }
    }];
}

- (void)buttonPressed
{
    if (_pressed) _pressed(self, nil);
}
@end

