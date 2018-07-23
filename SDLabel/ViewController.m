//
//  ViewController.m
//  SDLabel
//
//  Created by xuelin on 2018/7/21.
//  Copyright © 2018年 upchina. All rights reserved.
//

#import "ViewController.h"
#import "SDLabel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SDLabel *label = [[SDLabel alloc] initWithFrame:CGRectMake(15, 100, [UIScreen mainScreen].bounds.size.width - 15 * 2, 300)];
    
    label.font = [UIFont systemFontOfSize:18];
    label.lineSpace = 5;
    label.numberOfLines = 3;
    label.text = @"在当代中国音乐文学史上，人们不能忘记这样一位作家和诗人，自1948年以来的半个世纪中，他创作的《让我们荡起双桨》、《思念》、《难忘今霄》、《我的祖国》等众多词作不仅广为传唱，而且长久不衰，成为时代的见证。然而，谁能想象出这些优美朴实的歌词，竟出自一位满脸花皱纹，一副金丝眼镜后面的一双小眼睛经常闪着智慧灵光的小老头之手笔呢？在当代中国音乐文学史上，人们不能忘记这样一位作家和诗人，自1948年以来的半个世纪中，他创作的《让我们荡起双桨》、《思念》、《难忘今霄》、《我的祖国》等众多词作不仅广为传唱，而且长久不衰，成为时代的见证。然而，谁能想象出这些优美朴实的歌词，竟出自一位满脸花皱纹，一副金丝眼镜后面的一双小眼睛经常闪着智慧灵光的小老头之手笔呢？";
    label.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:label];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
