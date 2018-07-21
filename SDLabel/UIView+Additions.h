//
//  UIView+Additions.h
//  SDLabel
//
//  Created by xuelin on 2018/7/21.
//  Copyright © 2018年 upchina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Additions)
- (float)x;
- (float)y;
- (float)width;
- (float)height;

- (void)setX:(float)x;
- (void)setY:(float)y;
- (void)setWidth:(float)w;
- (void)setHeight:(float)h;

- (float)boundsWidth;
- (float)boundsHeight;
- (void)setBoundsWidth:(float)w;
- (void)setBoundsHeight:(float)h;
@end
