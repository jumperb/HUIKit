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

@interface HWebImageView ()
@property (nonatomic) NSString *lastURL;
@end

@implementation HWebImageView

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 200, 200)];
    if (self) {
        [self addSubview:self.imageView];
        _doMemoryWarn = YES;
        self.backgroundColor = [UIColor colorWithHex:0xe8e8e8];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(memoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)memoryWarning:(NSNotification *)notifation
{
    if (self.doMemoryWarn)
    {
        self.imageView.image = nil;
        _lastURL = nil;
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
        _doMemoryWarn = YES;
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
- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    self.lastURL = nil;
    self.placeHoderImage = nil;
    self.imageView.alpha = 1;
    self.didGetImage(self, image);
}
- (void)setImageUrl:(NSURL *)url
{
    return [self setImageUrl:url syncLoadCache:NO];
}

- (void)setImageUrl:(NSURL *)url syncLoadCache:(BOOL)syncLoadCache
{
    NSString *schema = url.scheme.lowercaseString;
    if (![schema hasPrefix:@"http"])
    {
        self.imageView.image = [UIImage imageNamed:url.absoluteString];
        self.imageView.alpha = 1;
        if (self.didGetImage) self.didGetImage(self, self.imageView.image);
        return;
    }
    if (self.imageView.image && [_lastURL isEqual:url.absoluteString])
    {
        self.imageView.alpha = 1;
        if (self.didGetImage) self.didGetImage(self, self.imageView.image);
        return;
    }
    if(!self.placeHoderImage) self.imageView.alpha = 0;
    __block UIImage *placeholder = self.placeHoderImage;
    
    @weakify(self);
    
    self.imageView.image = nil;
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
        
        
        if (!self.imageView.image)
        {
            [_imageView sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
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
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                                  object:nil];
}
@end
