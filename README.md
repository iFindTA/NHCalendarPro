# NHCalendarPro
高度自定义日历控件（For iOS）
![image](https://github.com/iFindTA/NHCalendarPro/blob/master/screenshots/screen1.png)


使用方法：
    CGRect infoRect = CGRectMake(0, curY, screenWD, screenWD);
    _calendar = [[NHCalender alloc] initWithFrame:infoRect];
    _calendar.delegate = self;
    _calendar.dataSource = self;
    _calendar.calendarDate = [NSDate date];
    _calendar.currentMonth = [NSDate date];
    _calendar.borderSelectColor = [UIColor blackColor];
    [self.view addSubview:_calendar];

如果某一天有事件需要标注，则在委托方法：
- (UIColor *)titleColorForDate:(NSDate *)date；
- (UIColor *)borderColorForDate:(NSDate *)date；
- (UIColor *)titleColorForDate:(NSDate *)date；
中自定义。
