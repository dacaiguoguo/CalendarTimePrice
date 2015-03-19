//
//  FirstViewController.m
//  buttonbgTest
//
//  Created by dacaiguo on 15/3/17.
//  Copyright (c) 2015年 dacaiguo. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *redImage = [[UIImage imageNamed:@"redButton700.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
    UIButton *redButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [redButton setBackgroundImage:redImage forState:UIControlStateNormal];
    redButton.frame = CGRectMake(10, 100, 200, 100);
    [self.view addSubview:redButton];
    
    {
        
//        UIImage *redImage = [[UIImage imageNamed:@"greyButton700"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        UIImage *redImage = [[UIImage imageNamed:@"greyButton700.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:6];
        UIImageView* redimage = [[UIImageView alloc] initWithImage:redImage];
        redimage.frame = CGRectMake(10, 220, 200, 100);

//        UIButton *redButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [redButton setBackgroundImage:redImage forState:UIControlStateNormal];
//        redButton.frame = CGRectMake(10, 220, 200, 100);
        [self.view addSubview:redimage];
    }
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
