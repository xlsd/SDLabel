//
//  SDLabel.h
//  SDLabel
//
//  Created by xuelin on 2018/7/21.
//  Copyright © 2018年 upchina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDLabel : UIView
@property (nonatomic, assign) NSUInteger numberOfLines;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic) NSInteger lineSpace;
@property (nonatomic) NSTextAlignment textAlignment;

- (void)clear;
@end
