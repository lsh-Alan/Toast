//
//  LToastView.h
//  MB
//
//  Created by 刘少华 on 2020/12/6.
//

// hud 显示时，不能阻挡俯视图手势的响应，如果要拦截可以让hud添加相应的手势

#import <UIKit/UIKit.h>

#import <MBProgressHUD/MBProgressHUD.h>

static NSString * _Nullable const kLoading = @"正在加载";
static NSString * _Nullable const kLoadSuccess = @"加载完成";
static NSString * _Nullable const kLoadFailed = @"加载出错";
static NSString * _Nullable const kPullUpLoadMore = @"上拉加载更多";
static NSString * _Nullable const kAllLoaded = @"已全部加载完";

@protocol LToastProtocol <NSObject>

@property (assign) NSInteger tag;
@property (assign) CGFloat progress;

- (void)hideAnimated:(BOOL)animated;

- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay;

@end

/**
 *  alertView的回调
 */
typedef void(^LToastClickBlock)(NSInteger buttonIndex, NSString * _Nullable buttonTitle);

NS_ASSUME_NONNULL_BEGIN

@interface LToastView : UIView

/**
 *  弹出alertView
 *
 *  @param title             标题
 *  @param message           内容 NSString类型 与 attributedMessage 参数只能传其中一个
 *  @param attributedMessage 内容 NSAttributedString 类型 与message 参数只能传其中一个
 *  @param buttonTitleArray  数组的titleArray
 *  @param buttonColorArray  数组的title颜色array，传的color数量需要和title数量相等，传nil则使用默认的一个主题颜色
 *  @param clickedBlock      点击按钮的回调
 */
+ (id<LToastProtocol>)alertWithTitle:(NSString *)title
                                  message:(NSString *)message
                      orAttributedMessage:(NSAttributedString *)attributedMessage
                         buttonTitleArray:(NSArray *)buttonTitleArray
                         buttonColorArray:(NSArray *)buttonColorArray
                             clickedBlock:(LToastClickBlock)clickedBlock;


+ (id<LToastProtocol>)alertWithTitle:(NSString *)title
                                  message:(NSString *)message
                            textAlignment:(NSTextAlignment)alignment
                      orAttributedMessage:(NSAttributedString *)attributedMessage
                         buttonTitleArray:(NSArray *)buttonTitleArray
                         buttonColorArray:(NSArray *)buttonColorArray
                             clickedBlock:(LToastClickBlock)clickedBlock;


/// 弹出中间部分的自定义视图，标题和按钮还是内部封装好的，自定义视图的frame设置仅高度有效，高度是中间部分视图的高度
+ (id<LToastProtocol>)alertWithCustomView:(UIView *)customView title:(NSString *)title
                              buttonTitleArray:(NSArray *)buttonTitleArray
                              buttonColorArray:(NSArray *)buttonColorArray
                                  clickedBlock:(LToastClickBlock)clickedBlock;

/**
 *  显示一个文字提醒，在1秒后自动消失-  锁屏
 *  @param title 提醒信息
 */
+ (id<LToastProtocol>)showWithTitle:(NSString *)title;


/// 显示一个文字提醒，在1秒后自动消失-  锁屏 并隐藏view上原有的所有hud
+ (id<LToastProtocol>)showWithTitle:(NSString *)title hideAllHudInView:(UIView *)view;


/**
 *  显示一个文字提醒，在1秒后自动消失-  不锁屏
 *  @param title 信息
 *  @param view  父视图
 *  @return 返回hud
 */
+ (id<LToastProtocol>)showWithTitle:(NSString *)title inView:(UIView * __nullable)view;

/// 显示错误icon 的错误信息 不锁屏
+ (id<LToastProtocol>)showErrorWithTitle:(NSString *)title;

///显示成功icon 的正确信息。不锁屏
+ (id<LToastProtocol>)showSuccessWithTitle:(NSString *)title;

/**
 *  显示循环转圈的loadingHUD ----  锁屏
 *  @param title 对应文字信息
 */
+ (id<LToastProtocol>)showLoadingWithTitle:(NSString *)title;

/**
 *  显示循环转圈loadingHud ---- 不锁屏
 *  @param title 信息
 *  @param view  父视图
 *  @return 对应hud
 */
+ (id<LToastProtocol>)showLoadingWithTitle:(NSString *)title inView:(UIView * __nullable)view;

/**
 *  显示加载进度的loadingHUD ---- 锁屏
 *  @param title 对应文字信息
 */
+ (id<LToastProtocol>)showProgressLoadingWithTitle:(NSString *)title;

/**
 *  显示加载进度的loadingHud- ---  不锁屏
 *  @param title 文字信息
 *  @param view  父视图
 *  @return 返回hud
 */
+ (id<LToastProtocol>)showProgressLoadingWithTitle:(NSString *)title inView:(UIView *__nullable)view;

/**
 *  显示无文字的loadingHud
 *  @param view 父视图
 *  @return 返回hud
 */
+ (id<LToastProtocol>)showCustomLoadingInView:(UIView *)view;

/// 返回gif loading
+ (id<LToastProtocol>)showGifInView:(UIView * __nullable)view;

/// 返回gif loading
+ (id<LToastProtocol>)showGifWithTitle:(NSString * __nullable)title InView:(UIView * __nullable)view;

/**
 *  隐藏HUD
 *  @param animated 是否需要动画
 */
+ (void)hideInWindow:(BOOL)animated;

/**
 *  隐藏window下的所有hud
 *  @param animated 是否需要动画
 */
+ (void)hideAllInWindow:(BOOL)animated;

/**
 *  隐藏视图下的所有hud
 *  @param animated 是否需要动画
 *  @param view     父视图
 */
+ (void)hideAll:(BOOL)animated inView:(UIView *)view;


@end

NS_ASSUME_NONNULL_END
