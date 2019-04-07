//
//  UIScrollView+Scalable.m
//  Fate
//
//  Created by szblsx2 on 2019/3/15.
//

#import <YYKit/YYKit.h>
#import <objc/runtime.h>
#import "UIScrollView+Scalable.h"

static const char kFDKVOInitializedContext = '0';
static const char kFDScalableImageURLContext = '0';
static const char kFDScalableImageViewContext = '0';
static const char kFDScalableImageHeightContext = '0';
static const char kFDScalableImageTransformContext = '0';

static void __objc_swizzleInstanceMethod(Class cls, SEL original, SEL replacement) {
    Method origMethod = class_getInstanceMethod(cls, original);
    Method swizzleMethod = class_getInstanceMethod(cls, replacement);
    BOOL isAdd = class_addMethod(cls, original, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod));
    if (!isAdd) {
        method_exchangeImplementations(origMethod, swizzleMethod);
    }else {
        class_replaceMethod(cls, replacement, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
}

@implementation UIScrollView (Scalable)

+ (void)load {
    dispatch_async(dispatch_get_main_queue(), ^{
        __objc_swizzleInstanceMethod(self, NSSelectorFromString(@"dealloc"), @selector(fd_dealloc));
    });
}

- (BOOL)fd_isInitialized {
    return [objc_getAssociatedObject(self, &kFDKVOInitializedContext) boolValue];
}

- (void)setFd_isInitialized:(BOOL)isInitialized {
    objc_setAssociatedObject(self, &kFDKVOInitializedContext, @(isInitialized), OBJC_ASSOCIATION_ASSIGN);
}

- (void)setScalableImageHeight:(CGFloat)scalableImageHeight {
    objc_setAssociatedObject(self, &kFDScalableImageHeightContext, @(scalableImageHeight), OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self setupHeaderImageViewFrame];
}

- (CGFloat)scalableImageHeight {
    CGFloat height = [objc_getAssociatedObject(self, &kFDScalableImageHeightContext) floatValue];
    return height == 0 ? 200 : height;
}

- (UIImage *)scalableImage {
    return self.fd_headerImageView.image;
}

- (void)setScalableImage:(UIImage *)scalableImage {
    self.fd_headerImageView.image = scalableImage;
    [self setupHeaderImageView];
}

- (void)setScalableImageURL:(NSURL *)scalableImageURL {
    objc_setAssociatedObject(self, &kFDScalableImageURLContext, scalableImageURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (scalableImageURL) {
        [[YYWebImageManager sharedManager] requestImageWithURL:scalableImageURL
                                                       options:0 progress:nil transform:nil
                                                    completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                                                        __block UIImage *theImage = image;
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            if ([self scalableImageTransform]) {
                                                                theImage = self.scalableImageTransform(theImage);
                                                            }
                                                            [self setScalableImage:theImage];
                                                        });
                                                    }];
    }
}

- (NSURL *)scalableImageURL {
    return objc_getAssociatedObject(self, &kFDScalableImageURLContext);
}

- (void)setScalableImageTransform:(UIImage *(^)(UIImage *))transform {
    objc_setAssociatedObject(self, &kFDScalableImageTransformContext, transform, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIImage *(^)(UIImage *))scalableImageTransform {
    return objc_getAssociatedObject(self, &kFDScalableImageTransformContext);
}

- (void)setupHeaderImageViewFrame {
    self.fd_headerImageView.frame = CGRectMake(0 , 0, self.bounds.size.width , self.scalableImageHeight);
}

- (void)setupHeaderImageView {
    [self setupHeaderImageViewFrame];
    if (![self fd_isInitialized]) {
        [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [self setFd_isInitialized:YES];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    CGFloat offsetY = self.contentOffset.y;
    if (offsetY < 0) {
        self.fd_headerImageView.frame = CGRectMake(offsetY, offsetY, self.bounds.size.width - offsetY * 2, self.scalableImageHeight - offsetY);
    } else {
        self.fd_headerImageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.scalableImageHeight);
    }
}

- (UIImageView *)fd_headerImageView {
    UIImageView *imageView = objc_getAssociatedObject(self, &kFDScalableImageViewContext);
    if (!imageView) {
        imageView = UIImageView.new;
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self insertSubview:imageView atIndex:0];
        objc_setAssociatedObject(self, &kFDScalableImageViewContext, imageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return imageView;
}

- (void)fd_dealloc {
    if ([self fd_isInitialized]) {
        [self removeObserver:self forKeyPath:@"contentOffset"];
    }
}

@end

@implementation UITableView (Scalable)

+ (void)load {
    dispatch_async(dispatch_get_main_queue(), ^{
        __objc_swizzleInstanceMethod(self, @selector(setTableHeaderView:), @selector(fd_setTableHeaderView:));
    });
}

- (void)fd_setTableHeaderView:(UIView *)tableHeaderView {
    if (![self isMemberOfClass:[UITableView class]]) return;
    [self fd_setTableHeaderView:tableHeaderView];
    UITableView *tableView = (UITableView *)self;
    self.scalableImageHeight = tableView.tableHeaderView.frame.size.height;
}

@end
