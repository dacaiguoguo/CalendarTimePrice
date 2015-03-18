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
        self.layer.borderColor = [[UIColor redColor] CGColor];
        self.layer.borderWidth = 1.;
        self.title = [UILabel new];
        self.title.numberOfLines = 0;
        self.title.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.title];
        
        self.location = [UILabel new];
        self.location.numberOfLines = 0;
        self.location.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.location];
        [self.title autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero ];
        [self.location autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [self.location autoSetDimension:ALDimensionHeight toSize:20];

    }
    return self;
}

@end

@implementation MSDayColumnHeader



@end
@interface LCCollectionViewController ()
@property (nonatomic, retain) NSDate *currentMonth;
@property (nonatomic, retain, getter = selectedDate) NSDate *selectedDate;
@property (nonatomic, retain, getter = nearDate) NSDate *nearDate;

@end

@implementation LCCollectionViewController
{
    NSMutableArray *mutArray;
}
static NSString * const reuseIdentifier = @"CellReuseIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    NSData *startJsonData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"json"]];
    NSDictionary *startJson = [NSJSONSerialization JSONObjectWithData:startJsonData options:NSJSONReadingAllowFragments error:nil];
    NSArray *datas = startJson[@"data"];
    mutArray = [NSMutableArray new];
    for (NSDictionary *dic  in datas) {
       TimePrice * tem =  [TimePrice parseTimePriceJson:dic];
        [mutArray addObject:tem];
    }
    [self reset];
    // Register cell classes
    [self.collectionView registerClass:[MSEventCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerClass:MSDayColumnHeader.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:MSDayColumnHeaderReuseIdentifier];
    [self.collectionView registerClass:MSDayColumnHeader.class forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:MSDayColumnFooterReuseIdentifier];


    // Do any additional setup after loading the view.
}
-(void)reset {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    TimePrice * tem = mutArray[0];
    NSDateComponents *components =
    [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit |
                           NSDayCalendarUnit) fromDate: tem.specDateTrue];
    self.currentMonth = [gregorian dateFromComponents:components]; //clean month
}

-(int)numRows {
    LVLog(@"dacaiguoguo:\n%s\n%ld",__func__,(long)[self.currentMonth numDaysInMonth]);
    LVLog(@"dacaiguoguo:\n%s\n%ld",__func__,(long)[self.currentMonth firstWeekDayInMonth]-1);


    float lastBlock = [self.currentMonth numDaysInMonth]+([self.currentMonth firstWeekDayInMonth]-1);
    return ceilf(lastBlock/7);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numRows]*7;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MSEventCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.title.text = @"222";
    // Configure the cell
    
    return cell;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view;
    if (kind == UICollectionElementKindSectionHeader) {
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:MSDayColumnHeaderReuseIdentifier forIndexPath:indexPath];
        view.layer.borderWidth = 1;
        view.layer.borderColor = [[UIColor greenColor] CGColor];
    } else if(kind == UICollectionElementKindSectionFooter){
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:MSDayColumnFooterReuseIdentifier forIndexPath:indexPath];
        view.layer.borderWidth = 1;
        view.layer.borderColor = [[UIColor blackColor] CGColor];
    }
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize cellSize = CGSizeZero;
    cellSize.width = [[UIScreen mainScreen] bounds].size.width/7;
    cellSize.height = cellSize.width;
    return cellSize;
}
@end
