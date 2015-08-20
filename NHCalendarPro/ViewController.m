//
//  ViewController.m
//  NHCalendarPro
//
//  Created by hu jiaju on 15/8/19.
//  Copyright (c) 2015年 hu jiaju. All rights reserved.
//

#import "ViewController.h"
#import "NHConstants.h"
#import "NSDate+Common.h"
#import "NHCalendar/NHCalender.h"

@interface ViewController ()<CalendarDelegate,CalendarDataSource>

@property (nonatomic, strong) UIButton *monthBtn;
@property (nonatomic, strong) NHCalender *calendar;
@property (nonatomic, strong) NSCalendar *gregorian;
@property (nonatomic, assign) NSInteger curYear,curMonth,curDay;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"账单日历";
    
    _gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *componets = [_gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:[NSDate date]];
    NSInteger month = [componets month];
    
    CGFloat btnwidth = screenWD/3;
    CGFloat btnHeight = 70;
    CGFloat curY = self.navigationController.navigationBar.bounds.size.height+20;
    CGRect infoRect = CGRectMake(0, curY, btnwidth, btnHeight);
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = infoRect;
    [btn setTitle:[NSString stringWithFormat:@"%zd月",month] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    _monthBtn = btn;
    
    infoRect.origin.x += btnwidth;
    UILabel *label = [[UILabel alloc] initWithFrame:infoRect];
    //label.font = [UIFont systemFontOfSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"总投资8,000";
    [self.view addSubview:label];
    
    infoRect.origin.x += btnwidth;
    label = [[UILabel alloc] initWithFrame:infoRect];
    //label.font = [UIFont systemFontOfSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"总收益200.1";
    [self.view addSubview:label];
    
    curY += btnHeight;
    //calendar
    infoRect = CGRectMake(0, curY, screenWD, screenWD);
    _calendar = [[NHCalender alloc] initWithFrame:infoRect];
    _calendar.delegate = self;
    _calendar.dataSource = self;
    _calendar.calendarDate = [NSDate date];
    _calendar.currentMonth = [NSDate date];
    _calendar.borderSelectColor = [UIColor blackColor];
    [self.view addSubview:_calendar];
    
    curY += screenWD+20;
    
    infoRect = CGRectMake(30, curY, 100, 50);
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = infoRect;
    [btn setTitle:@"pre Month" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(preMonth) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    infoRect.origin.x += 110;
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = infoRect;
    [btn setTitle:@"Next Month" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(nextMonth) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    infoRect.origin.x += 110;
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = infoRect;
    [btn setTitle:@"show Month" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showMonth) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)nextMonth{
    [_calendar nextMonth];
}

- (void)preMonth{
    [_calendar previousMonth];
}

- (void)showMonth {
    NSDate *monthDate = [NSDate dateWithYear:2015 Month:5 Day:3 Hour:2 Minute:2 Second:2];
    [_calendar showMonth:monthDate];
}

- (NSDateFormatter *) dateFormatter {
    static NSDateFormatter *_dateFormmater;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormmater = [[NSDateFormatter alloc] init];
    });
    return _dateFormmater;
}

#pragma mark - Calendar Delegate

- (BOOL)canChangeToDate:(NSDate *)date {
    return true;
}

- (UIColor *)titleColorForDate:(NSDate *)date{
    UIColor *color;
    if (![date sameMonthWithDate:_calendar.currentMonth]) {
        color = [UIColor lightGrayColor];
    }else{
        if ([date sameDayWithDate:_calendar.calendarDate]) {
            color = RGBCOLOR(237, 0, 0);
        } else {
            color = RGBCOLOR(0, 0, 0);
        }
    }
    
    return color;
}
- (UIColor *)borderColorForDate:(NSDate *)date{
    UIColor *color = [UIColor whiteColor];
    if ([date sameMonthWithDate:_calendar.currentMonth]) {
        if ([date sameDayWithDate:_calendar.calendarDate]) {
            color = RGBCOLOR(237, 0, 0);
        }
    }
    
    return color;
}
- (UIColor *)backgroundColorForDate:(NSDate *)date{
    UIColor *color = [UIColor whiteColor];
    //如果当下有事件则可根据日期自定义颜色
    if ([self hasEvent:date]) {
        color = [UIColor greenColor];
    }
    return color;
}

- (void)calendarChangedMonth{
    NSInteger month = [_calendar.currentMonth month];
    [_calendar.currentMonth year];
    [_monthBtn setTitle:[NSString stringWithFormat:@"%zd月",month] forState:UIControlStateNormal];
}

- (void)calendarDidSelectedDate:(NSDate *)selectedDate{
    NSDateFormatter *format = [NSDate defaultDateFormatterWithFormatYYYYMMdd];
    NSString *info= [format stringFromDate:selectedDate];
    NSLog(@"did select date:%@",info);
}

- (BOOL)hasEvent:(NSDate *)date {
    return false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
