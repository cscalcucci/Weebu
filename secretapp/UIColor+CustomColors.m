//
//  UIColor+CustomColors.m
//  TheWalls
//
//  Created by John McClelland on 6/13/15.
//  Copyright (c) 2015 machine^n. All rights reserved.
//

#import "UIColor+CustomColors.h"

@implementation UIColor (CustomColors)

+ (UIColor *)redEmotionColor {
    return [UIColor colorWithRed:208/255.0 green:2/255.0 blue:27/255.0 alpha:100];
}

+ (UIColor *)yellowEmotionColor {
    return [UIColor colorWithRed:248/255.0 green:231/255.0 blue:28/255.0 alpha:100];
}

+ (UIColor *)greenEmotionColor {
    return [UIColor colorWithRed:113/255.0 green:227/255.0 blue:80/255.0 alpha:100];
}

+ (UIColor *)blueEmotionColor {
    return [UIColor colorWithRed:74/255.0 green:144/255.0 blue:226/255.0 alpha:100];
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}



@end
