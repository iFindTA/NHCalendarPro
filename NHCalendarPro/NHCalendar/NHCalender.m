//
//  NHCalender.m
//  NHCalendarPro
//
//  Created by hu jiaju on 15/8/19.
//  Copyright (c) 2015年 hu jiaju. All rights reserved.
//

#import "NHCalender.h"
#import "NHConstants.h"
#import "NSDate+Common.h"

#pragma mark -- Calendar Unit --

@interface NHCalenderUnit : UIView

@end

@implementation NHCalenderUnit

@end

#pragma mark -- Calendar --

@interface NHCalender ()

// Gregorian calendar
@property (nonatomic, strong) NSCalendar *gregorian;

// Width in point of a day button
@property (nonatomic, assign) NSInteger dayWidth;
// origin of the calendar Array
@property (nonatomic, assign) NSInteger originX;
@property (nonatomic, assign) NSInteger originY;

// NSCalendarUnit for day, month, year and era.
@property (nonatomic, assign) NSCalendarUnit dayInfoUnits;

// Array of label of weekdays
@property (nonatomic, strong) NSArray *weekDayNames;

@end

@implementation NHCalender

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        NSUInteger divideCounts = 8;
        _dayWidth                   = frame.size.width/divideCounts;
        _originX                    = _dayWidth*0.5;
        _originY                    = _dayWidth;
        _gregorian                  = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        CGFloat textFontSize        = 17;
        _defaultFont                = [UIFont fontWithName:@"HelveticaNeue" size:textFontSize];
        _titleFont                  = [UIFont fontWithName:@"Helvetica-Bold" size:textFontSize];
        _calendarDate               = [NSDate date];
        _currentMonth               = [_calendarDate copy];
        _selectedDate               = [_calendarDate copy];
        _dayInfoUnits               = NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        
        _allowsChangeMonthByDayTap = true;
        
        _borderWidth                = 2.f;
        _borderSelectColor                = [UIColor blackColor];
        
        
        _nextMonthAnimation         = UIViewAnimationOptionTransitionCrossDissolve;
        _prevMonthAnimation         = UIViewAnimationOptionTransitionCrossDissolve;
    }
    return self;
}

- (void)setCalendarDate:(NSDate *)calendarDate{
    _calendarDate = calendarDate;
    [self setNeedsDisplay];
}

- (void)setBorderSelectColor:(UIColor *)borderSelectColor{
    _borderSelectColor = borderSelectColor;
    [self setNeedsDisplay];
}

#pragma mark - Various methods

- (NSInteger)buttonTagForDate:(NSDate *)date {
    NSDateComponents * componentsDate       = [_gregorian components:_dayInfoUnits fromDate:date];
    NSDateComponents * componentsDateCal    = [_gregorian components:_dayInfoUnits fromDate:_currentMonth];
    
    if (componentsDate.month == componentsDateCal.month && componentsDate.year == componentsDateCal.year) {
        // Both dates are within the same month : buttonTag = day
        return componentsDate.day;
    }else{
        //  buttonTag = deltaMonth * 40 + day
        NSInteger offsetMonth =  (componentsDate.year - componentsDateCal.year)*12 + (componentsDate.month - componentsDateCal.month);
        return componentsDate.day + offsetMonth*40;
    }
}

- (BOOL)canChangeToDate:(NSDate *)date {
    if (_dataSource == nil)
        return YES;
    return [_dataSource canChangeToDate:date];
}

- (void)performViewAnimation:(UIViewAnimationOptions)animation {
    NSDateComponents * components = [_gregorian components:_dayInfoUnits fromDate:_selectedDate];
    
    NSDate *clickedDate = [_gregorian dateFromComponents:components];
    if (_delegate && [_delegate respondsToSelector:@selector(calendarDidSelectedDate:)]) {
        [_delegate calendarDidSelectedDate:clickedDate];
    }
    
    [UIView transitionWithView:self
                      duration:0.5f
                       options:animation
                    animations:^ { [self setNeedsDisplay]; }
                    completion:nil];
}

#pragma mark - Button creation and configuration

- (UIButton *)dayButtonWithFrame:(CGRect)frame {
    UIButton *button                = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font          = _defaultFont;
    button.layer.cornerRadius       = frame.size.width*0.5;
    button.layer.masksToBounds      = true;
    button.frame                    = frame;
    button.layer.borderWidth        = _borderWidth;
    [button     addTarget:self action:@selector(tappedDate:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)configureDayButton:(UIButton *)button withDate:(NSDate*)date {
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:date];
    [button setTitle:[NSString stringWithFormat:@"%ld",(long)components.day] forState:UIControlStateNormal];
    button.tag = [self buttonTagForDate:date];
    
    NSAssert(_dataSource != nil, @"Calendar's dataSource cannot be nil vale !");
    UIColor *titleColor = [_dataSource titleColorForDate:date];
    UIColor *borderColor = [_dataSource borderColorForDate:date];
    UIColor *bgColor = [_dataSource backgroundColorForDate:date];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button setBackgroundColor:bgColor];
    
    if ([date sameDayWithDate:_selectedDate]) {
        if (![date sameDayWithDate:_calendarDate]) {
            borderColor = _borderSelectColor;
        }
    }
    button.layer.borderColor = [borderColor CGColor];
    
}

- (void)previousMonth {
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:_currentMonth];
    components.day = 1;
    components.month --;
    NSDate *prevMonthDate = [_gregorian dateFromComponents:components];
    
    // The day tapped is in another month than the one currently displayed
    BOOL canPreMonth = [self canChangeToDate:prevMonthDate];
    if (!canPreMonth)
        return;
    
    _currentMonth = prevMonthDate;
    if (_delegate && [_delegate respondsToSelector:@selector(calendarChangedMonth)]) {
        [_delegate calendarChangedMonth];
    }
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (_selectedDate != nil) {
        components = [_gregorian components:_dayInfoUnits fromDate:_selectedDate];
        components.month --;
        _selectedDate = [_gregorian dateFromComponents:components];
    }
    
    [self performViewAnimation:_prevMonthAnimation];
}

- (void)nextMonth {
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:_currentMonth];
    components.day = 1;
    components.month ++;
    NSDate *nextMonthDate =[_gregorian dateFromComponents:components];
    
    // The day tapped is in another month than the one currently displayed
    BOOL canNextMonth = [self canChangeToDate:nextMonthDate];
    if (!canNextMonth)
        return;
    
    _currentMonth = nextMonthDate;
    if (_delegate && [_delegate respondsToSelector:@selector(calendarChangedMonth)]) {
        [_delegate calendarChangedMonth];
    }
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (_selectedDate != nil) {
        components = [_gregorian components:_dayInfoUnits fromDate:_selectedDate];
        components.month ++;
        _selectedDate = [_gregorian dateFromComponents:components];
    }
    
    [self performViewAnimation:_nextMonthAnimation];
}

- (void)showMonth:(NSDate *)date {
    if (date == nil) {
        return;
    }
    NSUInteger month = [date month];
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:date];
    components.day = 1;
    components.month = month;
    NSDate *nextMonthDate =[_gregorian dateFromComponents:components];
    
    // The day tapped is in another month than the one currently displayed
    BOOL canNextMonth = [self canChangeToDate:nextMonthDate];
    if (!canNextMonth)
        return;
    
    _currentMonth = nextMonthDate;
    if (_delegate && [_delegate respondsToSelector:@selector(calendarChangedMonth)]) {
        [_delegate calendarChangedMonth];
    }
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (_selectedDate != nil) {
        components = [_gregorian components:_dayInfoUnits fromDate:_selectedDate];
        components.month = month;
        _selectedDate = [_gregorian dateFromComponents:components];
    }
    
    [self performViewAnimation:_nextMonthAnimation];
}

- (void)tappedDate:(UIButton *)sender {
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:_currentMonth];
    
    if (sender.tag < 0 || sender.tag >= 40) {
        
        
        NSInteger offsetMonth   = (sender.tag < 0)?-1:1;
        NSInteger offsetTag     = (sender.tag < 0)?40:-40;
        
        // otherMonthDate set to beginning of the next/previous month
        components.day = 1;
        components.month += offsetMonth;
        NSDate * otherMonthDate =[_gregorian dateFromComponents:components];
        NSLog(@"month:&&&%zd",[otherMonthDate month]);
        
        // The day tapped is in another month than the one currently displayed
        BOOL canNextMonth = [self canChangeToDate:otherMonthDate];
        if (!_allowsChangeMonthByDayTap || !canNextMonth)
            return;
        
        _currentMonth = otherMonthDate;
        //_calendarDate = otherMonthDate;
        if (_delegate && [_delegate respondsToSelector:@selector(calendarChangedMonth)]) {
            [_delegate calendarChangedMonth];
        }
        
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        // New selected date set to the day tapped
        components.day = sender.tag + offsetTag;
        _selectedDate = [_gregorian dateFromComponents:components];
        
        UIViewAnimationOptions animation = (offsetMonth >0)?_nextMonthAnimation:_prevMonthAnimation;
        
        // Animate the transition
        [self performViewAnimation:animation];
        
        return;
    }
    
    // Day taped within the the displayed month
    NSDateComponents * componentsDateSel = [_gregorian components:_dayInfoUnits fromDate:_selectedDate];
    if(componentsDateSel.day != sender.tag || componentsDateSel.month != components.month || componentsDateSel.year != components.year) {
        // Let's keep a backup of the old selectedDay
        NSDate * oldSelectedDate = [_selectedDate copy];
        
        // We redifine the selected day
        componentsDateSel.day       = sender.tag;
        componentsDateSel.month     = components.month;
        componentsDateSel.year      = components.year;
        _selectedDate               = [_gregorian dateFromComponents:componentsDateSel];
        
        // Configure  the new selected day button
        [self configureDayButton:sender             withDate:_selectedDate];
        
        // Configure the previously selected button, if it's visible
        UIButton *previousSelected =(UIButton *) [self viewWithTag:[self buttonTagForDate:oldSelectedDate]];
        if (previousSelected)
            [self configureDayButton:previousSelected   withDate:oldSelectedDate];
        
        // Finally, notify the delegate
        if (_delegate && [_delegate respondsToSelector:@selector(calendarDidSelectedDate:)]) {
            [_delegate calendarDidSelectedDate:_selectedDate];
        }
    }
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //background color
    [[UIColor whiteColor] setFill];
    CGContextFillRect(ctx, rect);
    
    //head
    UIColor *headColor = [UIColor colorWithRed:236/255.f green:236/255.f blue:236/255.f alpha:1];
    CGRect headFrame = CGRectMake(0, 0, rect.size.width, _dayWidth);
    [headColor setFill];
    CGContextFillRect(ctx, headFrame);
    
    //line
    CGFloat lineWidth = 1;
    UIColor *lineColor = [UIColor lightGrayColor];
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath setLineWidth:lineWidth];
    [linePath moveToPoint:CGPointZero];
    [linePath addLineToPoint:CGPointMake(rect.size.width, 0)];
    [linePath moveToPoint:CGPointMake(0, _dayWidth-lineWidth)];
    [linePath addLineToPoint:CGPointMake(rect.size.width, _dayWidth-lineWidth)];
    [lineColor setStroke];
    [linePath stroke];
    
    // week day names
    NSMutableArray *weeks = [NSMutableArray arrayWithArray:[[NSCalendar currentCalendar] shortWeekdaySymbols]];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                _titleFont,NSFontAttributeName,
                                [UIColor grayColor],NSForegroundColorAttributeName,
                                style,NSParagraphStyleAttributeName,nil];
    [weeks enumerateObjectsUsingBlock:^(NSString *weekname, NSUInteger idx, BOOL *stop) {
        if ([weekname isEqualToString:@"Sun"]) {
            weekname = @"日";
        }else if ([weekname isEqualToString:@"Mon"]){
            weekname = @"一";
        }else if ([weekname isEqualToString:@"Tue"]){
            weekname = @"二";
        }else if ([weekname isEqualToString:@"Wed"]){
            weekname = @"三";
        }else if ([weekname isEqualToString:@"Thu"]){
            weekname = @"四";
        }else if ([weekname isEqualToString:@"Fri"]){
            weekname = @"五";
        }else if ([weekname isEqualToString:@"Sat"]){
            weekname = @"六";
        }
        CGSize textSize = [weekname sizeWithAttributes:attributes];
        CGRect textRect = CGRectMake(_originX + _dayWidth*idx, (_dayWidth-textSize.height)*0.5, _dayWidth, textSize.height);
        [weekname drawInRect:textRect withAttributes:attributes];
    }];
    
    ///calendar content
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:_currentMonth];
    
    components.day = 1;
    NSDate *firstDayOfMonth         = [_gregorian dateFromComponents:components];
    NSDateComponents *comps         = [_gregorian components:NSWeekdayCalendarUnit fromDate:firstDayOfMonth];
    
    NSInteger weekdayBeginning      = [comps weekday];  // Starts at 1 on Sunday
    weekdayBeginning -= 1;
    if(weekdayBeginning < 0)
        weekdayBeginning += 7;                          // Starts now at 0 on Monday
    
    NSRange days = [_gregorian rangeOfUnit:NSDayCalendarUnit
                                    inUnit:NSMonthCalendarUnit
                                   forDate:_currentMonth];
    
    NSInteger monthLength = days.length;
    NSInteger remainingDays = (monthLength + weekdayBeginning) % 7;
    
    
//    // Frame drawing
//    NSInteger minY = _originY + _dayWidth;
//    NSInteger maxY = _originY + _dayWidth * (NSInteger)(1+(monthLength+weekdayBeginning)/7) + ((remainingDays !=0)? _dayWidth:0);
//    NSLog(@"miny:%zd---maxy:%zd",minY,maxY);
    
    // Current month
    for (NSInteger i= 0; i<monthLength; i++){
        components.day      = i+1;
        NSInteger offsetX   = (_dayWidth*((i+weekdayBeginning)%7));
        NSInteger offsetY   = (_dayWidth *((i+weekdayBeginning)/7));
        UIButton *button    = [self dayButtonWithFrame:CGRectMake(_originX+offsetX, _originY+offsetY, _dayWidth, _dayWidth)];
        NSDate *day = [_gregorian dateFromComponents:components];
        [self configureDayButton:button withDate:day];
        [self addSubview:button];
    }
    
    // Previous month
    NSDateComponents *previousMonthComponents = [_gregorian components:_dayInfoUnits fromDate:_currentMonth];
    previousMonthComponents.month --;
    NSDate *previousMonthDate = [_gregorian dateFromComponents:previousMonthComponents];
    NSRange previousMonthDays = [_gregorian rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:previousMonthDate];
    NSInteger maxDate = previousMonthDays.length - weekdayBeginning;
    for (int i=0; i<weekdayBeginning; i++){
        previousMonthComponents.day     = maxDate+i+1;
        NSInteger offsetX               = (_dayWidth*(i%7));
        NSInteger offsetY               = (_dayWidth *(i/7));
        UIButton *button                = [self dayButtonWithFrame:CGRectMake(_originX+offsetX, _originY + offsetY, _dayWidth, _dayWidth)];
        
        [self configureDayButton:button withDate:[_gregorian dateFromComponents:previousMonthComponents]];
        [self addSubview:button];
    }
    
    // Next month
    if(remainingDays == 0)
        return ;
    
    NSDateComponents *nextMonthComponents = [_gregorian components:_dayInfoUnits fromDate:_currentMonth];
    nextMonthComponents.month ++;
    
    for (NSInteger i=remainingDays; i<7; i++){
        nextMonthComponents.day         = (i+1)-remainingDays;
        NSInteger offsetX               = (_dayWidth*((i) %7));
        NSInteger offsetY               = (_dayWidth *((monthLength+weekdayBeginning)/7));
        UIButton *button                = [self dayButtonWithFrame:CGRectMake(_originX+offsetX, _originY + offsetY, _dayWidth, _dayWidth)];
        
        [self configureDayButton:button withDate:[_gregorian dateFromComponents:nextMonthComponents]];
        [self addSubview:button];
    }
}

- (NSDateFormatter *) dateFormatter {
    static NSDateFormatter *_dateFormmater;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormmater = [[NSDateFormatter alloc] init];
        [_dateFormmater setDateFormat:@"yyyy-MM-dd"];
    });
    return _dateFormmater;
}

@end
