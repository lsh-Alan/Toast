//
//  UIColor+Additions.h
//  MB
//
//  Created by 刘少华 on 2020/12/6.
//
#import <UIKit/UIKit.h>

#define rgb(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0]

@interface UIColor (Additions)

+ (UIColor *)add_colorWithRGBHexString:(NSString*)rgbHexString;

+ (UIColor *)colorWithHexString:(NSString *)hexString;

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert alpha:(CGFloat)alpha;

+ (UIImage *)createImageWithColor:(UIColor *)color;

@end
