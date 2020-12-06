//
//  LToastView.m
//  MB
//
//  Created by 刘少华 on 2020/12/6.
//

#import "LToastView.h"

//#import "LinkBlock.h"
#import "UIColor+Additions.h"
#import "UIView+Positioning.h"
#import "UIImage+GIF.h"

static const CGFloat kWidthRatio = 0.7;             // 弹窗占全屏宽度的比例
static const CGFloat kMinViewWidth = 280;           // 弹窗最小宽度
static const CGFloat kHorizontalMargin = 20;        // 水平margin
static const CGFloat kVerticalMargin = 20;          // 垂直margin
static const CGFloat kVerticalPaddingTop = 15;      // 垂直上部分的padding
static const CGFloat kVerticalPaddingBottom = 25;   // 垂直下部分的padding
static const CGFloat kButtonHeight = 40;            // button的高度
static const CGFloat kLineSize = 0.5;               // 分隔线尺寸

static const CGFloat kTitleFontSize = 15;           // title字体
static const CGFloat kMessageFontSize = 13;         // 内容字体
static const CGFloat kCancelButtonFontSize = 15;    // 取消按钮字体
static const CGFloat kConfirmButtonFontSize = 15;   // 确认按钮字体

static LToastClickBlock _clickedBlock = nil;       // 点击事件回调
static MBProgressHUD *_alertHud = nil;              // 弹窗

@interface MBProgressHUD ()<LToastProtocol>

@end

@implementation LToastView
#pragma mark - API
+ (id<LToastProtocol>)alertWithTitle:(NSString *)title
                                  message:(NSString *)message
                      orAttributedMessage:(NSAttributedString *)attributedMessage
                         buttonTitleArray:(NSArray *)buttonTitleArray
                         buttonColorArray:(NSArray *)buttonColorArray
                             clickedBlock:(LToastClickBlock)clickedBlock
{
    return [self alertWithTitle:title message:message textAlignment:NSTextAlignmentCenter orAttributedMessage:attributedMessage buttonTitleArray:buttonTitleArray buttonColorArray:buttonColorArray clickedBlock:clickedBlock];
}

+ (id<LToastProtocol>)alertWithTitle:(NSString *)title
                                  message:(NSString *)message
                            textAlignment:(NSTextAlignment)alignment
                      orAttributedMessage:(NSAttributedString *)attributedMessage
                         buttonTitleArray:(NSArray *)buttonTitleArray
                         buttonColorArray:(NSArray *)buttonColorArray
                             clickedBlock:(LToastClickBlock)clickedBlock
{
    _clickedBlock = [clickedBlock copy];
    
    CGFloat viewHeight = kVerticalMargin;
    CGFloat viewWidth = [UIScreen mainScreen].bounds.size.width * kWidthRatio;
    viewWidth = viewWidth > kMinViewWidth ? viewWidth : kMinViewWidth;
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 0)];
    customView.layer.cornerRadius = 10;
    customView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
    
    if (title.length) {
        UIFont *titleFont = [UIFont systemFontOfSize:kTitleFontSize];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = titleFont;
        titleLabel.numberOfLines = 0;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = title;
        [customView addSubview:titleLabel];
        
        CGFloat titleWidth = viewWidth - 2*kHorizontalMargin;
        CGSize titleSize = CGSizeMake(titleWidth, 1000);
        CGFloat titleHeight = [title boundingRectWithSize:titleSize
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:titleFont}
                                                  context:nil].size.height;
        titleLabel.frame = CGRectMake(kHorizontalMargin,viewHeight, titleWidth, titleHeight);
        viewHeight += titleHeight + kVerticalPaddingTop;
    }
    
    if (message.length || attributedMessage.length) {
        UILabel *messageLabel = [[UILabel alloc] init];
        messageLabel.numberOfLines = 0;
        [customView addSubview:messageLabel];
        
        CGFloat messageWidth = viewWidth - 2*kHorizontalMargin;
        CGSize messageSize = CGSizeMake(messageWidth, 1000);
        
        NSMutableAttributedString *attributedText = nil;
        if (message.length) {
            attributedText = [[NSMutableAttributedString alloc] initWithString:message
                                                                    attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                                                                 NSFontAttributeName:[UIFont systemFontOfSize:kMessageFontSize]}];
            
        }else {
            attributedText = attributedMessage.mutableCopy;
        }
        
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.lineSpacing = 5;
        paraStyle.alignment = alignment;
        [attributedText addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, attributedText.length)];
        messageLabel.attributedText = attributedText;
        
        CGFloat messageHeight = [attributedText boundingRectWithSize:messageSize options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
        messageLabel.frame = CGRectMake(kHorizontalMargin, viewHeight, messageWidth, messageHeight);
        viewHeight += messageHeight + kVerticalPaddingBottom;
    }
    
    NSInteger buttonCount = buttonTitleArray.count;
    // 如果有button数据
    if (buttonCount) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeight - kLineSize, viewWidth, kLineSize)];
        view.backgroundColor = [UIColor grayColor];
        [customView addSubview:view];
        
        CGFloat buttonWidth = viewWidth/buttonCount;
        for (NSInteger i = 0; i < buttonCount; i++) {
            UIColor *buttonColor = buttonColorArray ? buttonColorArray[i] : [UIColor blueColor];
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0,viewHeight,buttonWidth, kButtonHeight)];
            [button setTitle:buttonTitleArray[i] forState:UIControlStateNormal];
            [button setTitleColor:buttonColor forState:UIControlStateNormal];
            button.titleLabel.font = i ? [UIFont boldSystemFontOfSize:kConfirmButtonFontSize] : [UIFont systemFontOfSize:kCancelButtonFontSize];
            [customView addSubview:button];
            
            button.centerX = i*viewWidth/buttonCount + 0.5*buttonWidth;
            button.tag = i;
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            
            // 分隔线
            if (i < buttonCount - 1) {
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kLineSize, kButtonHeight)];
                lineView.backgroundColor = [UIColor colorWithHexString:@"#666666"];
                [customView addSubview:lineView];
                lineView.center = CGPointMake((i+1)*buttonWidth, button.centerY);
            }
        }
        viewHeight += kButtonHeight;
    }
    
    customView.frame = CGRectMake(0, 0, viewWidth, viewHeight);
    
    [_alertHud hideAnimated:YES];
    _alertHud = (MBProgressHUD *)[self showHUDWithCustomView:customView inView:nil];
    
    return _alertHud;
}


+ (id<LToastProtocol>)alertWithCustomView:(UIView *)customView title:(NSString *)title
                              buttonTitleArray:(NSArray *)buttonTitleArray
                              buttonColorArray:(NSArray *)buttonColorArray
                                  clickedBlock:(LToastClickBlock)clickedBlock
{
    _clickedBlock = [clickedBlock copy];
    
    CGFloat viewHeight = kVerticalMargin;
    CGFloat viewWidth = [UIScreen mainScreen].bounds.size.width * kWidthRatio;
    viewWidth = viewWidth > kMinViewWidth ? viewWidth : kMinViewWidth;
    
    UIView *containerViewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 0)];
    containerViewView.layer.cornerRadius = 10;
    containerViewView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    
    CGFloat customY = 0;
    
    if (title.length) {
        UIFont *titleFont = [UIFont systemFontOfSize:kTitleFontSize];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = titleFont;
        titleLabel.numberOfLines = 0;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = title;
        [containerViewView addSubview:titleLabel];
        
        CGFloat titleWidth = viewWidth - 2*kHorizontalMargin;
        CGSize titleSize = CGSizeMake(titleWidth, 1000);
        CGFloat titleHeight = [title boundingRectWithSize:titleSize
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:titleFont}
                                                  context:nil].size.height;
        titleLabel.frame = CGRectMake(kHorizontalMargin,viewHeight, titleWidth, titleHeight);
        viewHeight += titleHeight + kVerticalPaddingTop;
        customY = titleLabel.bottom;
    }
    
    viewHeight += customView.height;
    
    customView.frame = CGRectMake(kHorizontalMargin, customY, viewWidth - 2 * kHorizontalMargin, customView.height);
    [containerViewView addSubview:customView];
    
    NSInteger buttonCount = buttonTitleArray.count;
    // 如果有button数据
    if (buttonCount) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeight - kLineSize, viewWidth, kLineSize)];
        view.backgroundColor = [UIColor grayColor];
        [containerViewView addSubview:view];
        
        CGFloat buttonWidth = viewWidth/buttonCount;
        for (NSInteger i = 0; i < buttonCount; i++) {
            UIColor *buttonColor = buttonColorArray ? buttonColorArray[i] : [UIColor blueColor];
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0,viewHeight,buttonWidth, kButtonHeight)];
            [button setTitle:buttonTitleArray[i] forState:UIControlStateNormal];
            [button setTitleColor:buttonColor forState:UIControlStateNormal];
            button.titleLabel.font = i ? [UIFont boldSystemFontOfSize:kConfirmButtonFontSize] : [UIFont systemFontOfSize:kCancelButtonFontSize];
            [containerViewView addSubview:button];
            
            button.centerX = i*viewWidth/buttonCount + 0.5*buttonWidth;
            button.tag = i;
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            
            // 分隔线
            if (i < buttonCount - 1) {
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kLineSize, kButtonHeight)];
                lineView.backgroundColor = [UIColor colorWithHexString:@"#666666"];
                [customView addSubview:lineView];
                lineView.center = CGPointMake((i+1)*buttonWidth, button.centerY);
            }
        }
        viewHeight += kButtonHeight;
    }
    
    containerViewView.frame = CGRectMake(0, 0, viewWidth, viewHeight);
    
    [_alertHud hideAnimated:YES];
    _alertHud = (MBProgressHUD *)[self showHUDWithCustomView:containerViewView inView:nil];
    
    return _alertHud;
}

+ (id<LToastProtocol>)showWithTitle:(NSString *)title {
    if (title == nil) return  nil;
    return [self showWithTitle:title inView:nil];
}

+ (id<LToastProtocol>)showWithTitle:(NSString *)title hideAllHudInView:(UIView *)view {
    UIView *theView = view ? view : [UIApplication sharedApplication].keyWindow;
    [self hideAll:YES inView:theView];
    
    return [self showWithTitle:title inView:theView];
}

+ (id<LToastProtocol>)showWithTitle:(NSString *)title inView:(UIView * __nullable)view {
    
    MBProgressHUD *alertHud = nil;
    
    UIView *superView = view ?view : [UIApplication sharedApplication].keyWindow;
    alertHud = [MBProgressHUD showHUDAddedTo:superView animated:YES];
    alertHud.mode = MBProgressHUDModeText;
    alertHud.detailsLabel.textColor = [UIColor whiteColor];
    alertHud.detailsLabel.text = title;
    alertHud.detailsLabel.font = [UIFont systemFontOfSize:16];
    
    ///小弹窗颜色
    alertHud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    alertHud.bezelView.color = [UIColor colorWithHexString:@"#000000" alpha:0.7];
       
    alertHud.minSize = CGSizeMake(112.f, 112.f);
    alertHud.removeFromSuperViewOnHide = YES;
    [alertHud hideAnimated:YES afterDelay:1.2];
    
    return alertHud;
}

/// 显示错误icon 的错误信息 不锁屏
+ (id<LToastProtocol>)showErrorWithTitle:(NSString *)title
{
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1){
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    
    UIView *superView = vc ?vc.view : [UIApplication sharedApplication].keyWindow;
    
    MBProgressHUD *alertHud = [MBProgressHUD showHUDAddedTo:superView animated:YES];
    alertHud.mode = MBProgressHUDModeCustomView;
    alertHud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sp_hud_error"]];
    alertHud.label.text = title;
    alertHud.label.textColor = [UIColor whiteColor];
   
    ///小弹窗颜色
    alertHud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    alertHud.bezelView.color = [UIColor colorWithHexString:@"#000000" alpha:0.7];
    
    alertHud.minSize = CGSizeMake(112.f, 112.f);
    alertHud.removeFromSuperViewOnHide = YES;
    // 1秒之后再消失
    [alertHud hideAnimated:YES afterDelay:1.2];
    
    return alertHud;
}

///显示成功icon 的正确信息。不锁屏
+ (id<LToastProtocol>)showSuccessWithTitle:(NSString *)title
{
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1){
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    UIView *superView = vc ?vc.view : [UIApplication sharedApplication].keyWindow;
    
    MBProgressHUD *alertHud = [MBProgressHUD showHUDAddedTo:superView animated:YES];
    alertHud.mode = MBProgressHUDModeCustomView;
    alertHud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sp_loading_success"]];
    alertHud.label.text = title;
    alertHud.label.textColor = [UIColor whiteColor];
   
    ///小弹窗颜色
    alertHud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    alertHud.bezelView.color = [UIColor colorWithHexString:@"#000000" alpha:0.7];
    
    alertHud.minSize = CGSizeMake(112.f, 112.f);
    alertHud.removeFromSuperViewOnHide = YES;
    // 1秒之后再消失
    [alertHud hideAnimated:YES afterDelay:1.2];
    
    return alertHud;
}

+ (id<LToastProtocol>)showLoadingWithTitle:(NSString *)title {
    return [self showLoadingWithTitle:title inView:nil];
}

+ (id<LToastProtocol>)showLoadingWithTitle:(NSString *)title inView:(UIView * __nullable)view {
    
    return [self showCustomLoadingWithTitle:title inView:view];
}

+ (id<LToastProtocol>)showProgressLoadingWithTitle:(NSString *)title {
    return [self showProgressLoadingWithTitle:title inView:nil];
}

+ (id<LToastProtocol>)showProgressLoadingWithTitle:(NSString *)title inView:(UIView *__nullable)view
{
    MBProgressHUD *alertHud = nil;
    UIView *superView = view ?: [UIApplication sharedApplication].keyWindow;
    
    alertHud = [MBProgressHUD showHUDAddedTo:superView animated:YES];
    alertHud.mode = MBProgressHUDModeDeterminate;
    alertHud.label.text = title;
    alertHud.progress = 0.00; // 给一个初始值，有更好的体验
    
    return alertHud;
}

+ (id<LToastProtocol>)showCustomLoadingInView:(UIView *)view
{
    return [self showCustomLoadingWithTitle:nil inView:view];
}

+ (id<LToastProtocol>)showCustomLoadingWithTitle:(NSString *)title inView:(UIView *)view
{
    MBProgressHUD *alertHud = nil;
    UIView *superView = view ? view : [UIApplication sharedApplication].keyWindow;
    [superView endEditing:YES];
    [self hideAll:YES inView:superView];
    
    alertHud = [MBProgressHUD showHUDAddedTo:superView animated:YES];
    alertHud.mode = MBProgressHUDModeCustomView;
    
    ///默认菊花 自定义先关闭
    //alertHud.mode = MBProgressHUDModeCustomView;
    //alertHud.color = [[UIColor whiteColor] colorWithAlphaComponent:1];
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sp_hud_loading"]];
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI*2.0];
    rotationAnimation.duration = 1.f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = MAXFLOAT;
    [imageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    alertHud.customView = imageView;
    
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];// initWithImage:[UIImage imageNamed:@"1"]];
//    NSMutableArray *images = [NSMutableArray array];
////    for (int i = 0; i < 25; i ++)
////    {
////        NSString *imageName = [NSString stringWithFormat:@"%zd",i + 1];
////        UIImage *image = [UIImage imageNamed:imageName];
////
////        [images addObject:image];
////    }
//
//    imageView.animationImages = images;
//    imageView.animationDuration = 1.25;
//    [imageView startAnimating];
    
    
    alertHud.label.text = title;
    alertHud.label.textColor = [UIColor whiteColor];
    alertHud.label.font = [UIFont systemFontOfSize:14];
   
    ///小弹窗颜色
    alertHud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    alertHud.bezelView.color = [UIColor colorWithHexString:@"#000000" alpha:0.7];
    
    alertHud.minSize = CGSizeMake(112.f, 112.f);
    alertHud.removeFromSuperViewOnHide = YES;
    
    alertHud.square = YES;
    return alertHud;
}

+ (id<LToastProtocol>)showGifInView:(UIView * __nullable)view
{
    return [self showGifWithTitle:nil InView:view];
}

+ (id<LToastProtocol>)showGifWithTitle:(NSString * __nullable)title InView:(UIView * __nullable)view
{
    MBProgressHUD *alertHud = nil;
    UIView *superView = view ? view : [UIApplication sharedApplication].keyWindow;
    [superView endEditing:YES];
    [self hideAll:YES inView:superView];
    
    alertHud = [MBProgressHUD showHUDAddedTo:superView animated:YES];
    alertHud.mode = MBProgressHUDModeCustomView;
    
    NSString *filePath = [[NSBundle bundleWithPath:[[NSBundle mainBundle] bundlePath]] pathForResource:@"sp_hud_loading_GIF" ofType:@"gif"];
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    UIImage *image = [UIImage sd_imageWithGIFData:imageData];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    alertHud.customView = imageView;

    if (title) {
        alertHud.label.text = title;
    }

    ///小弹窗颜色
    alertHud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    //alertHud.bezelView.color = [UIColor colorWithHexString:@"#000000" alpha:0.7];
    
    alertHud.minSize = CGSizeMake(112.f, 112.f);
    alertHud.removeFromSuperViewOnHide = YES;

    //bezelView显示尺寸相同
    alertHud.square = YES;
    return alertHud;
}

+ (void)hide:(BOOL)animated inView:(UIView *)view {
    for (MBProgressHUD *hud in view.subviews) {
        if ([hud isKindOfClass:[MBProgressHUD class]]) {
            [hud hideAnimated:animated];
            
            return;
        }
    }
}

+ (void)hideAll:(BOOL)animated inView:(UIView *)view {
    for (MBProgressHUD *hud in view.subviews) {
        if ([hud isKindOfClass:[MBProgressHUD class]]) {
            [hud hideAnimated:animated];
        }
    }
}

+ (void)hideInWindow:(BOOL)animated {
    [self hide:animated inView:[UIApplication sharedApplication].keyWindow];
}

+ (void)hideAllInWindow:(BOOL)animated {
    [self hideAll:animated inView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark - event response
/**
 *  点击点击事件
 *
 *  @param button 点击的按钮
 */
+ (void)buttonClick:(UIButton *)button {
    if (_clickedBlock) {
        _clickedBlock(button.tag, [button titleForState:UIControlStateNormal]);
    }
    
    _clickedBlock = nil;
    [_alertHud hideAnimated:YES];
    _alertHud = nil;
}

#pragma mark - private

/**
 *  显示自定义HUD
 *
 *  @param customView 传入自定义视图
 */
+ (id<LToastProtocol>)showHUDWithCustomView:(UIView *)customView inView:(UIView *)view {
    
    MBProgressHUD *alertHud = nil;
    UIView *theView = view ? view: [UIApplication sharedApplication].keyWindow;
    [theView endEditing:YES];
    alertHud = [MBProgressHUD showHUDAddedTo:theView animated:YES];
    alertHud.mode = MBProgressHUDModeCustomView;
    alertHud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    alertHud.backgroundView.color = [UIColor colorWithWhite:0.f alpha:.2f];
    alertHud.margin = 0;
    alertHud.customView = customView;
    
    return alertHud;
}


@end
