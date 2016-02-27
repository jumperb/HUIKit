//
//  HWebImageView.m
//  PCommunityKitDemo
//
//  Created by zhangchutian on 15/8/5.
//  Copyright (c) 2015年 vstudio. All rights reserved.
//

#import "HWebImageView.h"
#import <SDWebImageManager.h>
#import <UIImageView+WebCache.h>

@interface HWebImageView ()
@property (nonatomic) NSString *lastURL;
@end

@implementation HWebImageView

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 200, 200)];
    if (self) {
        [self addSubview:self.imageView];
        self.backgroundColor = [UIColor colorWithHex:0xe8e8e8];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(memoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)memoryWarning:(NSNotification *)notifation
{
    self.imageView.image = nil;
    _lastURL = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
        self.backgroundColor = [UIColor colorWithHex:0xe8e8e8];
    }
    return self;
}

- (UIImageView *)imageView
{
    if (!_imageView)
    {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds = YES;
    }
    return _imageView;

}
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _imageView.frame = self.bounds;
}
- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    _imageView.frame = self.bounds;
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
    [_imageView sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                                  object:nil];
}
@end
