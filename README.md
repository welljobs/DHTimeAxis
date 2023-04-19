# DHTimeAxis
### 是在DHTimeAxis基础上修改的IoT时间轴，支持时间刻度选择，目前只支持横屏
### 主要修改的类：DHTimeAxisRuleRenderer

#主要修改代码
```objectivec
/// 绘制时间轴每段
- (void)visitTimeAxisDigitalDivision:(DHTimeAxisDigitalDivision *)aTimeAxisDigitalDivision {

    [super visitTimeAxisDigitalDivision:aTimeAxisDigitalDivision];

    // 计算每秒代表的像素宽度
    CGFloat aSecondWidth = self.aSecondOfPixel;
    CGFloat aHourWidth = aSecondWidth * 3600.0;
    CGFloat ruleOffset = self.ruleFixedOffset;
    CGFloat baseLineOffset = self.baseLineFixedOffset;
    NSDate *currentHourDate = self.currentHourDate;
    NSInteger currentHour = self.currentHour;
    CGFloat maxWidth = self.axisDirection == DHTimeAxisDirectionHorizontal ? self.viewWidth : self.viewHeight;

    // 计算当前时间的所在的整点小时时间的差值，当前时间距离正点的差值
    NSTimeInterval diffTime = [[NSDate dateWithTimeIntervalSince1970:self.currentTimeInterval] timeIntervalSinceDate:currentHourDate];

    CGFloat tempX = ruleOffset - diffTime * aSecondWidth;

    // 计算最左边的小时数，一般要画到视图外多一个小时
    NSInteger count = 1;
    while ((tempX -= aHourWidth) > 0) {
        count++;
    }
    NSInteger minHour = currentHour - count;
    CGFloat minHourPosition = ruleOffset - (diffTime+60*60*count) * aSecondWidth;

    // 计算最右边的小时数，一般要画到视图外多一个小时
    count = 1;
    while ((tempX += aHourWidth) < maxWidth) {
        count++;
    }
    CGFloat maxHourPosition = ruleOffset + (diffTime+60*60*count) * aSecondWidth;

    CGFloat tempWidth = aHourWidth;
    // 开始画刻度
    CGFloat tempHourPosition = minHourPosition;
    NSInteger tempHour = minHour;
    NSInteger piece = 12;


    if (aTimeAxisDigitalDivision.currentScale >= 6) {
        piece = 60; //  1分钟60个刻度，当前缩放比例是8，最大缩放比例是10.5
    } else if (aTimeAxisDigitalDivision.currentScale >= 2 && aTimeAxisDigitalDivision.currentScale < 6) {
        piece = 12; //  5分钟12个刻度，当前缩放比例是2，最大缩放比例是10.5
    } else if (aTimeAxisDigitalDivision.currentScale >= 1 && aTimeAxisDigitalDivision.currentScale < 2) {
        piece = 6;  //  10分钟6个刻度，当前缩放比例是1，最大缩放比例是10.5，此时也是最小缩放比例
    }
    while (tempHourPosition <= maxHourPosition) {
        if (self.axisDirection == DHTimeAxisDirectionHorizontal) {
            CGPoint point = CGPointMake(tempHourPosition, baseLineOffset);
            // 整点小时文字显示
            [self drawTimeAxisText:point second:tempHour * 3600 division:aTimeAxisDigitalDivision];
            // 大刻度线(小时) - 上方的刻度线，高度30
            [self drawTimeAxisRule:point start:0 lenth:30];
            // 大刻度线(小时) - 下方的刻度线，高度30
            [self drawTimeAxisRule:point start:self.viewHeight lenth:self.viewHeight-30];
            // 半小时刻度(30分钟)
            for (int i = 1; i < 2; i++) {
                CGPoint point = CGPointMake(tempWidth/2*i+tempHourPosition, baseLineOffset);
                if (aTimeAxisDigitalDivision.currentScale != 1) {   //  10分钟刻度不显示半小时文字
                    // 半小时小时文字显示
                    [self drawTimeAxisText:point second:tempHour * 3600 + 30 * 60 division:aTimeAxisDigitalDivision];
                }
                //  半小时上方刻度线，高度20
                [self drawTimeAxisRule:point start:0 lenth:20];
                //  半小时下方刻度线，高度20
                [self drawTimeAxisRule:point start:self.viewHeight lenth:self.viewHeight-20];
            }
            if (aTimeAxisDigitalDivision.currentScale >= 6) {   //  选择1分钟刻度才画10分钟刻度线
                // 小刻度线(10分钟)
                for (int i = 1; i < 6; i++) {
                    CGPoint point = CGPointMake(tempWidth/6*i+tempHourPosition, baseLineOffset);
                    [self drawTimeAxisText:point second:tempHour * 3600 + 10*i * 60 division:aTimeAxisDigitalDivision];
                    //  10分钟上方刻度线，高度15
                    [self drawTimeAxisRule:point start:0 lenth:15];
                    //  10分钟上方刻度线，高度15
                    [self drawTimeAxisRule:point start:self.viewHeight lenth:self.viewHeight-15];
                }
            }
            //  最小刻度(选择1分钟，此时1格表示1分钟，5分钟，1格表示5分钟，10分钟1格表示10分钟),高度10
            for (int i = 1; i < piece; i++) {
                CGPoint point = CGPointMake(tempWidth/piece*i+tempHourPosition, baseLineOffset);
                // 最小刻度上方刻度，高度10
                [self drawTimeAxisRule:point start:0 lenth:10];
                // 最小刻度下方刻度，高度10
                [self drawTimeAxisRule:point start:self.viewHeight lenth:self.viewHeight-10];
            }

        } else {
            CGPoint point = CGPointMake(baseLineOffset, tempHourPosition);
            // 文字显示
            [self drawTimeAxisText:point second:tempHour * 3600 division:aTimeAxisDigitalDivision];

            // 大刻度线(小时)
            CGContextMoveToPoint(self.context, point.x, point.y);
            CGContextAddLineToPoint(self.context, point.x+20.0, point.y);
            CGContextStrokePath(self.context);

            // 半小时刻度
            for (int i = 1; i < 2; i++) {
                CGPoint point = CGPointMake(tempWidth/2*i+tempHourPosition, baseLineOffset);
                if (aTimeAxisDigitalDivision.currentRulerMark != DHAxisTimeScaleTenMinute) {
                    [self drawTimeAxisText:point second:tempHour * 3600 + 30 * 60 division:aTimeAxisDigitalDivision];
                }

                CGContextMoveToPoint(self.context, point.x-.5, 0);
                CGContextAddLineToPoint(self.context, point.x-.5, 20.0);
                CGContextStrokePath(self.context);

                CGContextMoveToPoint(self.context, point.x-.5, self.viewHeight);
                CGContextAddLineToPoint(self.context, point.x-.5, self.viewHeight-20.0);
                CGContextStrokePath(self.context);
            }
            CGFloat ruleHeight = 10;
            if (aTimeAxisDigitalDivision.currentRulerMark == DHAxisTimeScaleOneMinute) {
                // 小刻度线(10分钟)
                ruleHeight = 5.0;
                for (int i = 1; i < 6; i++) {
                    CGPoint point = CGPointMake(tempWidth/6*i+tempHourPosition, baseLineOffset);

                    [self drawTimeAxisText:point second:tempHour * 3600 + 10*i * 60 division:aTimeAxisDigitalDivision];

                    CGContextMoveToPoint(self.context, point.x-.5, 0);
                    CGContextAddLineToPoint(self.context, point.x-.5, 10.0);
                    CGContextStrokePath(self.context);

                    CGContextMoveToPoint(self.context, point.x-.5, self.viewHeight);
                    CGContextAddLineToPoint(self.context, point.x-.5, self.viewHeight-10.0);
                    CGContextStrokePath(self.context);
                }
            }

            for (int i = 1; i < piece; i++) {
                CGPoint point = CGPointMake(tempWidth/piece*i+tempHourPosition, baseLineOffset);
                CGContextMoveToPoint(self.context, point.x-.5, 0);
                CGContextAddLineToPoint(self.context, point.x-.5, ruleHeight);
                CGContextStrokePath(self.context);

                CGContextMoveToPoint(self.context, point.x-.5, self.viewHeight);
                CGContextAddLineToPoint(self.context, point.x-.5, self.viewHeight-ruleHeight);
                CGContextStrokePath(self.context);
            }
        }

        tempHourPosition += tempWidth;
        tempHour++;
    }
}
/// 绘制刻度线
- (void)drawTimeAxisRule:(CGPoint)point start:(CGFloat)start lenth:(CGFloat)lenght {
    CGContextMoveToPoint(self.context, point.x-.5, start);
    CGContextAddLineToPoint(self.context, point.x-.5, lenght);
    CGContextStrokePath(self.context);
}
/// 绘制刻度尺文字
- (void)drawTimeAxisText:(CGPoint)point second:(NSInteger)second division:(DHTimeAxisDigitalDivision *)division {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"HH:mm";
    format.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSString *text = [format stringFromDate:date];
    NSAttributedString *timeText = [[NSAttributedString alloc] initWithString:text attributes:division.digitalAttribute];
    CGSize textSize = timeText.size;
    CGFloat startY = (self.viewHeight - textSize.height) / 2;
    CGRect rect = CGRectMake(point.x-13, startY, textSize.width, textSize.height);
    [text drawInRect:rect withAttributes:division.digitalAttribute];
}
```
# 效果展示
