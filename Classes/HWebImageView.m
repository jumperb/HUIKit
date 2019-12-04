//
//  HWebImageView.m
//  PCommunityKitDemo
//
//  Created by zhangchutian on 15/8/5.
//  Copyright (c) 2015年 vstudio. All rights reserved.
//

#import "HWebImageView.h"
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/NSData+ImageContentType.h>
#import <UIView+WebCache.h>
#import <Objc/runtime.h>
#import <FLAnimatedImage/FLAnimatedImageView.h>
#import <FLAnimatedImage/FLAnimatedImage.h>
#import <SDWebImageFLPlugin/FLAnimatedImageView+WebCache.h>
#import <UIKit/UIKit.h>

@interface HWebImageView ()
@property (nonatomic) FLAnimatedImageView *mImageView;
@property (nonatomic) NSString *lastURL;
@end

@implementation HWebImageView

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 200, 200)];
    if (self) {
        [self setup];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}
- (void)setup
{
    [self addSubview:self.mImageView];
    self.backgroundColor = [UIColor colorWithHex:0xe8e8e8];
}
- (FLAnimatedImageView *)mImageView {
    if (!_mImageView) {
        _mImageView = [[FLAnimatedImageView alloc] initWithFrame:self.bounds];
        _mImageView.contentMode = UIViewContentModeScaleAspectFill;
        _mImageView.layer.masksToBounds = YES;
        _mImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return _mImageView;
}
- (UIImageView *)imageView
{
    return self.mImageView;
}
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _mImageView.frame = self.bounds;
}
- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    _mImageView.frame = self.bounds;
}
- (void)_setImage:(UIImage *)image
{
    [self sd_cancelCurrentImageLoad];
    self.mImageView.animatedImage = nil;
    self.mImageView.image = image;
    self.mImageView.alpha = 1;
    [self applyRenderColor];
}
- (void)applyRenderColor {
    if (self.mImageView.animatedImage) return;
    if (!self.mImageView.image) return;
    
    if (self.renderColor)
    {
        if (self.mImageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate && self.mImageView.image != self.placeHoderImage) {
            self.mImageView.image = [self.mImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
    }
    else
    {
        if (self.mImageView.image.renderingMode == UIImageRenderingModeAlwaysTemplate) {
            self.mImageView.image = [self.mImageView.image imageWithRenderingMode:UIImageRenderingModeAutomatic];
        }
    }
}
- (void)setRenderColor:(UIColor *)renderColor
{
    _renderColor = renderColor;
    self.mImageView.tintColor = self.renderColor;
    if (self.mImageView.animatedImage) return;
    [self applyRenderColor];
}
- (void)setImage:(UIImage *)image
{
    [self _setImage:image];
    self.lastURL = nil;
    self.placeHoderImage = nil;
}
- (void)setImagePath:(NSString *)path {
    [self sd_cancelCurrentImageLoad];
    self.lastURL = nil;
    self.placeHoderImage = nil;
    self.mImageView.image = nil;
    self.mImageView.animatedImage = nil;
    self.mImageView.alpha = 0;
    asyncAtQueue(dispatch_get_global_queue(0, 0), ^{
        NSData *data = [NSData dataWithContentsOfFile:path];
        if (data) {
            if ([NSData sd_imageFormatForImageData:data] == SDImageFormatGIF) {
                FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
                asyncAtMain(^{
                    self.mImageView.animatedImage = animatedImage;
                    self.mImageView.alpha = 1;
                });
            }
            else {
                UIImage *image = [UIImage imageWithData:data];
                asyncAtMain(^{
                    [self _setImage:image];
                });
                
            }
        }
    });
}
- (void)setImageUrl:(NSURL *)url
{
    [self setImageUrl:url syncLoadCache:NO];
}

- (void)setImageUrl:(NSURL *)url syncLoadCache:(BOOL)syncLoadCache
{
    [self setImageUrlString:url.absoluteString syncLoadCache:syncLoadCache];
}

- (void)setImageUrlString:(NSString *)urlString
{
    [self setImageUrlString:urlString syncLoadCache:NO];
}

- (void)setImageUrlString:(NSString *)urlString syncLoadCache:(BOOL)syncLoadCache
{
    if (urlString.length == 0)
    {
        [self _setImage:self.placeHoderImage];
        self.lastURL = nil;
        if (self.didGetError) self.didGetError(self, herr(kDataFormatErrorCode, ([NSString stringWithFormat:@"url = %@", urlString])));
        return;
    }
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *schema = url.scheme.lowercaseString;
    if (![schema hasPrefix:@"http"])
    {
        [self _setImage:[UIImage imageNamed:urlString]];
        return;
    }
    if ([_lastURL isEqual:urlString] && (self.mImageView.animatedImage || self.mImageView.image))
    {
        self.mImageView.alpha = 1;
        return;
    }
    if(!self.placeHoderImage && !self.mImageView.animatedImage && !self.mImageView.image) self.mImageView.alpha = 0;
    __block UIImage *placeholder = self.placeHoderImage;
    
    [self _setImage:nil];
    self.lastURL = nil;
    
    if (syncLoadCache)
    {
        NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
        UIImage *image = [(SDImageCache *)[SDWebImageManager sharedManager].imageCache imageFromCacheForKey:key];
        if (image)
        {
            [self _setImage:image];
            self.lastURL = url.absoluteString;
        }
    }
    if (!self.mImageView.image)
    {
        @weakify(self);
        [self.mImageView sd_setImageWithURL:url placeholderImage:placeholder options:0 completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            @strongify(self);
            if (error)
            {
                if (self.didGetError) self.didGetError(self, error);
            }
            else if (image)
            {
                self.lastURL = url.absoluteString;
                if (SDImageCacheTypeNone == cacheType)
                {
                    [UIView animateWithDuration:0.5 animations:^{
                        self.mImageView.alpha = 1;
                    }];
                }
                else
                {
                    self.mImageView.alpha = 1;
                }
                if (image.class != SDFLAnimatedImage.class) {
                    [self applyRenderColor];
                }
                if (self.didGetImage) self.didGetImage(self, image);
            }
        }];
    }
}

@end
