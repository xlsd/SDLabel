//
//  ViewController.m
//  SDLabel
//
//  Created by xuelin on 2018/7/21.
//  Copyright © 2018年 upchina. All rights reserved.
//

#import "ViewController.h"
#import "SDLabel.h"
#import "NSString+YTJAddtions.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *tex = @"在当代中国音乐文学史上，在当代中国音乐文学史上，在当代中在当代中国音乐文学史上，在当代中在当代中国音乐文学史上，在当代中在当代中国音乐文学史上，在当代中在当代中国音乐文学史上，在当代中";
    
    CGFloat height = [tex sizeWithConstrainedToWidth:[UIScreen mainScreen].bounds.size.width - 15 * 2 fromFont:[UIFont systemFontOfSize:18] lineSpace:5].height;
    
    NSInteger num = [tex numberOfLinesWithConstrainedToWidth:[UIScreen mainScreen].bounds.size.width - 15 * 2 fromFont:[UIFont systemFontOfSize:18] lineSpace:5];
    
    CGFloat labelheight = height / num;
    
    NSInteger row = num >= 2 ? 2 : num;
    
    SDLabel *label = [[SDLabel alloc] initWithFrame:CGRectMake(15, 100, [UIScreen mainScreen].bounds.size.width - 15 * 2, labelheight * row)];
    
    label.font = [UIFont systemFontOfSize:18];
    label.lineSpace = 5;
    label.numberOfLines = 2;
    label.text = tex;
    label.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:label];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
