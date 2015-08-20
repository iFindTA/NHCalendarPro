//
//  NHCalender.h
//  NHCalendarPro
//
//  Created by hu jiaju on 15/8/19.
//  Copyright (c) 2015年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CalendarDelegate;
@protocol CalendarDataSource;
@interface NHCalender : UIView

@property (nonatomic, assign) id<CalendarDelegate> delegate;
@property (nonatomic, assign) id<CalendarDataSource> dataSource;

// Font
@property (nonatomic, strong) UIFont *defaultFont;
@property (nonatomic, strong) UIFont *titleFont;

//real calendar date
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSDate *calendarDate;
@property (nonatomic, strong) NSDate *currentMonth;

// Allows or disallows the user to change month when tapping a day button from another month
@property (nonatomic, assign) BOOL allowsChangeMonthByDayTap;

// Border
@property (nonatomic, strong) UIColor *borderSelectColor;
@property (nonatomic, assign) NSInteger borderWidth;

// "Change month" animations
@property (nonatomic, assign) UIViewAnimationOptions nextMonthAnimation;
@property (nonatomic, assign) UIViewAnimationOptions prevMonthAnimation;

- (void)nextMonth;
- (void)previousMonth;
- (void)showMonth:(NSDate *)date;

@end


@protocol CalendarDataSource <NSObject>
@optional
- (BOOL)canChangeToDate:(NSDate *)date;
@required
- (UIColor *)titleColorForDate:(NSDate *)date;
- (UIColor *)borderColorForDate:(NSDate *)date;
- (UIColor *)backgroundColorForDate:(NSDate *)date;

@end

@protocol CalendarDelegate <NSObject>

- (void)calendarChangedMonth;
- (void)calendarDidSelectedDate:(NSDate *)selectedDate;

@end