//
//  HWebButtonView.h
//  PCommunityKitDemo
//
//  Created by zhangchutian on 15/8/6.
//  Copyright (c) 2015年 vstudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HCommon.h>

@interface HWebButtonView : UIView
@property (nonatomic) UIImage *placeHoderImage;
@property (nonatomic) UIButton *button;
@property (nonatomic) id userInfo;
@property (nonatomic, strong) callback pressed;
@property (nonatomic, strong) callback didGetImage;
@property (nonatomic, strong) callback didGetError;
/**
 *  设置图片链接
 *
 *  @param url 链接
 *
 *  @return 同步的(YES)还是异步的(NO)
 */
- (BOOL)setImageUrl:(NSURL *)url;
@end
