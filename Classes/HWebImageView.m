//
//  HWebImageView.m
//  PCommunityKitDemo
//
//  Created by zhangchutian on 15/8/5.
//  Copyright (c) 2015年 vstudio. All rights reserved.
//

#import "HWebImageView.h"
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/NSData+ImageContentType.h>
#import <UIView+WebCache.h>
#import <FLAnimatedImage/FLAnimatedImageView.h>
#import <FLAnimatedImage/FLAnimatedImage.h>
#import <Objc/runtime.h>

@interface UIImage (hwimage)
@property (nonatomic, strong, nullable) FLAnimatedImage *h_FLAnimatedImage;
@end
@implementation UIImage (hwimage)

- (FLAnimatedImage *)h_FLAnimatedImage {
    return objc_getAssociatedObject(self, @selector(h_FLAnimatedImage));
}

- (void)setH_FLAnimatedImage:(FLAnimatedImage *)h_FLAnimatedImage {
    objc_setAssociatedObject(self, @selector(h_FLAnimatedImage), h_FLAnimatedImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

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
    if (image != nil)
    {
        if (self.renderColor)
        {
            if (self.mImageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                self.mImageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
        }
        else
        {
            self.mImageView.image = image;
        }
    }
    else
    {
        self.mImageView.image = nil;
    }
}
- (void)setRenderColor:(UIColor *)renderColor
{
    _renderColor = renderColor;
    self.mImageView.tintColor = self.renderColor;
    if (self.mImageView.animatedImage) return;
    if (self.renderColor)
    {
        if (self.mImageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
            self.mImageView.image = [self.mImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
    }
    else
    {
        if (self.mImageView.image.renderingMode != UIImageRenderingModeAlwaysOriginal) {
            self.mImageView.image = [self.mImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
    }
}
- (void)setImage:(UIImage *)image
{
    [self _setImage:image];
    self.lastURL = nil;
    self.placeHoderImage = nil;
    self.mImageView.alpha = 1;
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
        [self _setImage:nil];
        self.lastURL = nil;
        if (self.didGetError) self.didGetError(self, herr(kDataFormatErrorCode, ([NSString stringWithFormat:@"url = %@", urlString])));
        return;
    }
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *schema = url.scheme.lowercaseString;
    if (![schema hasPrefix:@"http"])
    {
        [self _setImage:[UIImage imageNamed:urlString]];
        self.mImageView.alpha = 1;
        if (self.didGetImage) self.didGetImage(self, self.mImageView.image);
        return;
    }
    if ([_lastURL isEqual:urlString] && (self.mImageView.animatedImage || self.mImageView.image))
    {
        self.mImageView.alpha = 1;
        if (self.didGetImage) self.didGetImage(self, self.mImageView.image);
        return;
    }
    if(!self.placeHoderImage && !self.mImageView.animatedImage && !self.mImageView.image) self.mImageView.alpha = 0;
    __block UIImage *placeholder = self.placeHoderImage;
    
    [self _setImage:nil];
    self.lastURL = nil;
    
    if (syncLoadCache)
    {
        NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
        UIImage *image = [[SDWebImageManager sharedManager].imageCache imageFromCacheForKey:key];
        if (image)
        {
            [self _setImage:image];
            self.mImageView.alpha = 1;
            self.lastURL = url.absoluteString;
            if (self.didGetImage) self.didGetImage(self, image);
        }
    }
    if (!self.mImageView.image)
    {
        @weakify(self);
        dispatch_group_t group = dispatch_group_create();
        [self sd_internalSetImageWithURL:url
                        placeholderImage:placeholder
                                 options:SDWebImageRetryFailed
                            operationKey:nil
                           setImageBlock:^(UIImage *image, NSData *imageData) {
                               @strongify(self);
                               //见https://github.com/SDWebImage/SDWebImage/blob/master/SDWebImage/FLAnimatedImage/FLAnimatedImageView%2BWebCache.m
                               FLAnimatedImage *associatedAnimatedImage = image.h_FLAnimatedImage;
                               if (associatedAnimatedImage) {
                                   // Asscociated animated image exist
                                   self.mImageView.animatedImage = associatedAnimatedImage;
                                   self.mImageView.image = nil;
                                   if (group) {
                                       dispatch_group_leave(group);
                                   }
                               } else if ([NSData sd_imageFormatForImageData:imageData] == SDImageFormatGIF) {
                                   // Firstly set the static poster image to avoid flashing
                                   UIImage *posterImage = image.images ? image.images.firstObject : image;
                                   self.mImageView.image = posterImage;
                                   self.mImageView.animatedImage = nil;
                                   // Secondly create FLAnimatedImage in global queue because it's time consuming, then set it back
                                   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                                       FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:imageData];
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           image.h_FLAnimatedImage = animatedImage;
                                           self.mImageView.animatedImage = animatedImage;
                                           self.mImageView.image = nil;
                                           if (group) {
                                               dispatch_group_leave(group);
                                           }
                                       });
                                   });
                               } else {
                                   [self _setImage:image];
                                   if (group) {
                                       dispatch_group_leave(group);
                                   }
                               }
                           } progress:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
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
                                   if (self.didGetImage) self.didGetImage(self, image);
                               }
                           } context:group ? @{SDWebImageInternalSetImageGroupKey : group} : nil];
        
    }
}

@end
