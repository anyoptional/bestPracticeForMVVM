//
//  UIScrollView+Scalable.h
//  Fate
//
//  Created by szblsx2 on 2019/3/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (Scalable)
/**
 需要下拉放大的图片地址
 */
@property (nonatomic, nullable, strong) NSURL *scalableImageURL;
/**
 需要下拉放大的图片
 */
@property (nonatomic, nullable, strong) UIImage *scalableImage;
/**
 需要下拉放大的图片高度
 */
@property (nonatomic, assign) CGFloat scalableImageHeight;
/**
 需要对图片做什么变换
 */
@property (nonatomic, nullable, copy) UIImage * _Nullable (^scalableImageTransform)(UIImage *original);
@end

NS_ASSUME_NONNULL_END
