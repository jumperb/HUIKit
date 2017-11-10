//
//  HWebButtonView.h
//  PCommunityKitDemo
//
//  Created by zhangchutian on 15/8/6.
//  Copyright (c) 2015年 vstudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Hodor/HCommon.h>

@interface HWebButtonView : UIView
@property (nonatomic) UIImageView *imageView;
//@property (nonatomic) UIColor *tintColor; //注意这个虽然注释掉是因为父类有了，但是这里是可用的
@property (nonatomic) UIImage *placeHoderImage;
@property (nonatomic) UIButton *button;
@property (nonatomic) id userInfo;

@property (nonatomic) callback pressed;
@property (nonatomic) callback didGetImage;
@property (nonatomic) callback didGetError;
/**
 *  设置图片链接
 *
 *  @param url 链接
 *
 */
- (void)setImageUrl:(NSURL *)url;

/**
 *  设置图片链接,如果有缓存同步读取缓存
 *
 *  @param url           链接
 *  @param syncLoadCache 是否同步读缓存
 *
 */
- (void)setImageUrl:(NSURL *)url syncLoadCache:(BOOL)syncLoadCache;

/**
 *  设置图片链接
 *
 *  @param urlString 链接字符串
 *
 */
- (void)setImageUrlString:(NSString *)urlString;

/**
 *  设置图片链接,如果有缓存同步读取缓存
 *
 *  @param urlString           链接字符串
 *  @param syncLoadCache 是否同步读缓存
 *
 */
- (void)setImageUrlString:(NSString *)urlString syncLoadCache:(BOOL)syncLoadCache;


/**
 *  直接设置图片
 *
 *  @param image 图片
 */
- (void)setImage:(UIImage *)image;

@end
