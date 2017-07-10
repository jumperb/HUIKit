//
//  HWebImageView.h
//  PCommunityKitDemo
//
//  Created by zhangchutian on 15/8/5.
//  Copyright (c) 2015年 vstudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Hodor/HCommon.h>

@interface HWebImageView : UIView
@property (nonatomic) UIImage *placeHoderImage;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) id userInfo;
@property (nonatomic) BOOL doMemoryWarn;
@property (nonatomic) callback didGetImage;
@property (nonatomic) callback didGetError;
/**
 *  设置图片链接
 *
 *  @param url 链接
 */
- (void)setImageUrl:(NSURL *)url;

/**
 *  设置图片链接,如果有缓存同步读取缓存
 *
 *  @param url           链接
 *  @param syncLoadCache 是否同步读缓存
 */
- (void)setImageUrl:(NSURL *)url syncLoadCache:(BOOL)syncLoadCache;

/**
 *  直接设置图片
 *
 *  @param image 图片
 */
- (void)setImage:(UIImage *)image;
@end
