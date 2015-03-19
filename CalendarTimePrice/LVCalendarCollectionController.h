//
//  LCCollectionViewController.h
//  buttonbgTest
//
//  Created by dacaiguo on 15/3/18.
//  Copyright (c) 2015年 dacaiguo. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface TimePrice : NSObject

@property (nonatomic, strong) NSString *specDate;
@property (nonatomic, strong) NSDate *specDateTrue;
@property (nonatomic, assign) float sellPrice;
@property (nonatomic, strong) NSString *aperiodicDesc; //期票描述
@property (nonatomic, assign) float childSellPrice;
@property (nonatomic, assign) BOOL childOnSaleFlag;//是否儿童禁售

@end
@interface LVCalendarViewCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *dayLabel;
@property (nonatomic, strong) UILabel *priceLabel;

@end
@interface LVCalendarSectionHeader : UICollectionReusableView
@end
@interface LVCalendarCollectionController : UICollectionViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@end
