//
//  AppDelegate.h
//  buttonbgTest
//
//  Created by dacaiguo on 15/3/17.
//  Copyright (c) 2015年 dacaiguo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;//yyyy-MM-dd

@end

NSDateFormatter *dateFormatterFromAppDelegate();

