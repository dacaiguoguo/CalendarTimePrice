//
//  LCCollectionViewController.m
//  buttonbgTest
//
//  Created by dacaiguo on 15/3/18.
//  Copyright (c) 2015年 dacaiguo. All rights reserved.
//

#import "LCCollectionViewController.h"
#import "UIView+AutoLayout.h"
#import "NSDate+convenience.h"

#ifdef DEBUG
#define LVLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define LVLog(format, ...) //NSLog(format, ## __VA_ARGS__)
#endif
NSString * const MSCollectionElementKindDayColumnHeader = @"MSCollectionElementKindDayHeader";
NSString * const MSDayColumnHeaderReuseIdentifier = @"MSDayColumnHeaderReuseIdentifier";
NSString * const MSDayColumnFooterReuseIdentifier = @"MSDayColumnFooterReuseIdentifier";
//字体颜色
NSString *const cTextBlack_Color = @"00000064"; //一号字体黑色 0,0,0
NSString *const cTextDarkGray_Color = @"66666664"; //二号字体黑灰色 102,102,102
NSString *const cTextLightGray_Color = @"aaaaaa64"; //三号字体灰色 170,170,170
NSString *const cTextWhite_Color = @"ffffff64"; //四号字体白色 255,255,255
NSString *const cTextRed_Color = @"d3077564"; //价格字体红色 211,7,117

@implementation TimePrice
+ (TimePrice *)parseTimePriceJson:(NSDictionary *)jsonDictionary {
    TimePrice *timePrice = [[TimePrice alloc] init];
    timePrice.sellPrice = [[jsonDictionary objectForKey:@"sellPrice"] floatValue];
    timePrice.specDate = jsonDictionary[@"specDate"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    timePrice.specDateTrue = [TimePrice dateFromString:timePrice.specDate formatter:formatter];
    timePrice.aperiodicDesc = jsonDictionary[@"aperiodicDesc"];
    timePrice.childSellPrice = [[jsonDictionary objectForKey:@"childSellPrice"] floatValue];
    timePrice.childOnSaleFlag = [[jsonDictionary objectForKey:@"childOnSaleFlag"] boolValue];
    return timePrice;
}

+ (NSDate *)dateFromString:(NSString *)string  formatter:(NSDateFormatter*)formatter
{
    if ([string length] == 0) {
        return [NSDate date];
    }
    NSDate *date = [formatter dateFromString:string];
    return date;
}
@end

@implementation MSEventCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
//        self.layer.borderWidth = 1;
        self.title = [UILabel new];
        self.title.numberOfLines = 0;
        self.title.backgroundColor = [UIColor clearColor];
        self.title.textAlignment = NSTextAlignmentCenter;
        self.location.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:self.title];
        
        self.location = [UILabel new];
        self.location.numberOfLines = 0;
        self.location.backgroundColor = [UIColor clearColor];
        self.location.font = [UIFont systemFontOfSize:12];
        self.location.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.location];
        [self.title autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero ];
        [self.location autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [self.location autoSetDimension:ALDimensionHeight toSize:20];

    }
    return self;
}

@end

@implementation MSDayColumnHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}


@end
@interface LCCollectionViewController ()
@property (nonatomic, retain) NSDate *currentMonth;
@property (nonatomic, retain, getter = selectedDate) NSDate *selectedDate;
@property (nonatomic, retain, getter = nearDate) NSDate *nearDate;
@property (nonatomic, retain) NSSet *markedDatesSet;
@property (nonatomic, retain) NSArray *markedDates;
@property (nonatomic, retain) NSArray *markedLabels;

@end

@implementation LCCollectionViewController
{
    NSMutableArray *mutArray;
    NSInteger  todayBlock;
    NSInteger  firstWeekDay;
    float minPrice;
    NSArray *weekdays;
    NSIndexPath *selectedPath;

}
static NSString * const reuseIdentifier = @"CellReuseIdentifier";

+ (UIColor *)hexColor:(NSString *)hexColor {
    if ([hexColor hasPrefix:@"#"]) {
        hexColor = [hexColor substringFromIndex:1];
    }
    if ([hexColor length] == 6) {
        hexColor = [hexColor stringByAppendingString:@"64"];
    }
    unsigned int red, green, blue, alpha;
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    range.location = 6;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&alpha];
    
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green/255.0f) blue:(float)(blue/255.0f) alpha:(float)(alpha/100.0f)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    weekdays = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
    self.collectionView.contentInset = UIEdgeInsetsMake(20, 0, 50, 0);
    [self.collectionView setShowsVerticalScrollIndicator:NO];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    NSData *startJsonData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"json"]];
    NSDictionary *startJson = [NSJSONSerialization JSONObjectWithData:startJsonData options:NSJSONReadingAllowFragments error:nil];
    NSArray *datas = startJson[@"data"];
    mutArray = [NSMutableArray new];
    NSMutableArray *mutDateArray = [NSMutableArray new];
    NSMutableArray * mutPriceArray = [NSMutableArray new];
    minPrice = 0;
    float toCompare = 0;

    for (int i=0;i<datas.count;i++) {
        NSDictionary *dic = datas[i];
       TimePrice * tem =  [TimePrice parseTimePriceJson:dic];
        if (i==0) {
            minPrice = tem.sellPrice;
        }
        toCompare = tem.sellPrice;
        if (toCompare < minPrice) {
            minPrice = toCompare;
        }
        [mutArray addObject:tem];
        [mutDateArray addObject:tem.specDateTrue];
        [mutPriceArray addObject:[NSString stringWithFormat:@"￥%.0f",tem.sellPrice]];
    }
    [self markDates:mutDateArray labels:mutPriceArray];
    [self reset];
    // Register cell classes
    [self.collectionView registerClass:[MSEventCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerClass:MSDayColumnHeader.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:MSDayColumnHeaderReuseIdentifier];
    [self.collectionView registerClass:MSDayColumnHeader.class forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:MSDayColumnFooterReuseIdentifier];


    // Do any additional setup after loading the view.
}

-(void)markDates:(NSArray *)dates labels:(NSArray *)labels {
    self.markedDates = dates;
    self.markedLabels = labels;
    self.markedDatesSet = [NSSet setWithArray:self.markedDates];

}
-(void)reset {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components =
    [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit |
                           NSDayCalendarUnit) fromDate: _markedDates[0]];
    self.currentMonth = [gregorian dateFromComponents:components]; //clean month
    firstWeekDay = [self.currentMonth firstWeekDayInMonth];
    todayBlock = [[NSDate date] day] + firstWeekDay - 1;
}

-(int)numRows {
    LVLog(@"dacaiguoguo:\n%s\n%ld",__func__,(long)[self.currentMonth numDaysInMonth]);
    LVLog(@"dacaiguoguo:\n%s\n%ld",__func__,(long)[self.currentMonth firstWeekDayInMonth]-1);

    float lastBlock = [self.currentMonth numDaysInMonth]+(firstWeekDay-1);
    return ceilf(lastBlock/7);
}

- (NSString *)formatIndexPath:(NSIndexPath *)indexPath {
    return [NSString stringWithFormat:@"{%ld,%ld}", (long)indexPath.row, (long)indexPath.section];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numRows]*7+8;
}

- (BOOL)isContain:(NSDate*)dateTemp
{
    LVLog(@"%@ ==== %d",dateTemp ,[self.markedDatesSet containsObject:dateTemp] );
    return [self.markedDatesSet containsObject:dateTemp];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MSEventCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    if (indexPath.row < 8) {
        cell.backgroundColor = [UIColor whiteColor];
        if (indexPath.row == 0) {
            cell.title.text = [NSString stringWithFormat:@"%d年%d月",(int)[self.currentMonth year],(int)[self.currentMonth month]];
            cell.location.text = nil;
            cell.title.textColor = [LCCollectionViewController hexColor:cTextBlack_Color];
        } else {
            cell.title.text = weekdays[indexPath.row-1];
            cell.location.text = nil;
            if (indexPath.row ==1||indexPath.row ==7) {
                cell.title.textColor =[LCCollectionViewController hexColor:cTextRed_Color];
            } else {
                cell.title.textColor = [LCCollectionViewController hexColor:cTextBlack_Color];
            }
        }
        return cell;

    }
    float lastBlock = [self.currentMonth numDaysInMonth]+([self.currentMonth firstWeekDayInMonth]-1);
    NSInteger targetDate = indexPath.row-8+1;

    if (targetDate <= lastBlock) {
        cell.title.text = [NSString stringWithFormat:@"%zd",targetDate];
        
        BOOL isSelectedPath = selectedPath && [selectedPath compare:indexPath] == NSOrderedSame;
        

        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:self.currentMonth];
        [comps setDay:targetDate];
        NSDate *dateTemp = [gregorian dateFromComponents:comps];
        LVLog(@"%ld----%@",(long)targetDate,dateTemp);
        if ([self isContain:dateTemp]) {
            int index = (int)[self.markedDates indexOfObject:dateTemp];
            TimePrice * tem  = [mutArray objectAtIndex:index];
            cell.backgroundColor = [UIColor whiteColor];
            if (targetDate %7 ==1||targetDate %7 ==0) {
                cell.title.textColor =[LCCollectionViewController hexColor:cTextRed_Color];
            } else {
                if (todayBlock == targetDate) {
                    cell.title.textColor =[LCCollectionViewController hexColor:cTextRed_Color];
                    cell.title.text = @"今天";
                } else if (todayBlock+1 == targetDate) {
                    cell.title.textColor = [LCCollectionViewController hexColor:cTextRed_Color];
                    cell.title.text = @"明天";
                } else if (todayBlock+2 == targetDate) {
                    cell.title.textColor =[LCCollectionViewController hexColor:cTextRed_Color];
                    cell.title.text = @"后天";
                } else {
                    cell.title.textColor =[LCCollectionViewController hexColor:cTextBlack_Color];
                }
            }
            if (tem.sellPrice == minPrice) {
                cell.location.textColor =[LCCollectionViewController hexColor:cTextRed_Color];
            } else {
                cell.location.textColor = [LCCollectionViewController hexColor:cTextBlack_Color];
            }
            if (isSelectedPath) {
                cell.backgroundColor =[LCCollectionViewController hexColor:cTextRed_Color];
                cell.location.textColor = [UIColor whiteColor];
                cell.title.textColor = [UIColor whiteColor];
            }
            cell.location.text =  [self.markedLabels objectAtIndex:index];
        } else {
            //        LVLog(@"dacaiguoguo:\n%s\n%@",__func__,[self formatIndexPath:indexPath]);
            cell.backgroundColor = [UIColor whiteColor];
            cell.title.textColor = [LCCollectionViewController hexColor:cTextLightGray_Color];
            cell.location.text = nil;
        }
    } else {
        cell.backgroundColor = [UIColor whiteColor];
        cell.title.text = nil;
        cell.location.text = nil;
    }

    return cell;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    MSDayColumnHeader *view;
    if (kind == UICollectionElementKindSectionHeader) {
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:MSDayColumnHeaderReuseIdentifier forIndexPath:indexPath];
    } else if(kind == UICollectionElementKindSectionFooter){
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:MSDayColumnFooterReuseIdentifier forIndexPath:indexPath];
        view.backgroundColor = [LCCollectionViewController hexColor:cTextLightGray_Color];
    }
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row ==0) {
        return CGSizeMake([[UIScreen mainScreen] bounds].size.width, 20);
    }
    CGSize cellSize = CGSizeZero;
    cellSize.width = [[UIScreen mainScreen] bounds].size.width/7;
    cellSize.height = cellSize.width;
    return cellSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    MSEventCell *cell =  (MSEventCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.location.text.length < 1) {
        return;
    }
    selectedPath = indexPath;
    [collectionView reloadData];
}
@end
