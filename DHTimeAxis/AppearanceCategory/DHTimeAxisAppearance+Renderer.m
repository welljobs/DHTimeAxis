//  DHTimeAxisAppearance+Renderer.m
//  DHTimeAxis
//
//  Create by daniel.hu on 2018/11/12.
//  Copyright © 2018年 daniel. All rights reserved.

#import "DHTimeAxisAppearance+Renderer.h"
#import "DHTimeAxisRuleRenderer.h"
#import "DHTimeAxisGearRenderer.h"

@implementation DHTimeAxisAppearance (Renderer)

+ (void)renderRuleAppearanceWithDirection:(DHAxisDirection)direction {
    DHTimeAxisAppearance *appearance = [DHTimeAxisAppearance sharedAppearance];
    
    //时间轴背景色
    appearance.mainBackgroundColor = [UIColor whiteColor];
    appearance.rendererClass = [DHTimeAxisRuleRenderer class];
    appearance.direction = direction;
    
    appearance.dataStrokeColor = [UIColor colorWithRed:1 green:0.2 blue:0.2 alpha:0.8];
    appearance.dataStrokeSizeType = DHStrokeSizeTypeFull;
    
    appearance.ruleColor = [UIColor redColor];
    appearance.ruleStrokeSize = 1.0;
    appearance.ruleOffsetLocationType = DHStrokeLocationTypeMiddle;
    
    appearance.divisionColor = [UIColor whiteColor];
    appearance.divisionStrokeSize = 1.0;
    
    //刻度尺 & 刻度值颜色
    appearance.digitalAttribute = @{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor grayColor]};
    
    appearance.baseLineColor = [UIColor whiteColor];
    appearance.baseLineStrokeSize = 1.0;
    appearance.baseLineFixedOffset = 80.0;
    appearance.baseLineOffsetLocationType = DHStrokeLocationTypeFlexible;
    
    appearance.minimumScale = 1.0;
    appearance.maximumScale = 10.5;
    appearance.oneToOneScaleMatchMaxHoursInVisible = 4;
}


+ (void)fullAxis_renderRuleAppearanceWithDirection:(DHAxisDirection)direction {
    DHTimeAxisAppearance *appearance = [DHTimeAxisAppearance sharedAppearance];
    
    //时间轴背景色    white后面的参数表示灰度，从0-1之间表示从黑到白的变化，alpha：透明度
    appearance.mainBackgroundColor = [UIColor colorWithWhite:0.f alpha:0.5];
    appearance.rendererClass = [DHTimeAxisRuleRenderer class];
    appearance.direction = direction;
    
    appearance.dataStrokeColor = [UIColor colorWithRed:1 green:0.2 blue:0.2 alpha:0.8];
    appearance.dataStrokeSizeType = DHStrokeSizeTypeFull;
    
    appearance.ruleColor = [UIColor whiteColor];
    appearance.ruleStrokeSize = 1.0;
    appearance.ruleOffsetLocationType = DHStrokeLocationTypeMiddle;
    
    appearance.divisionColor = [UIColor whiteColor];
    appearance.divisionStrokeSize = 1.0;
    
    //刻度尺 & 刻度值颜色
    appearance.digitalAttribute = @{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    appearance.baseLineColor = [UIColor clearColor];
    appearance.baseLineStrokeSize = 1.0;
    appearance.baseLineFixedOffset = 80.0;
    appearance.baseLineOffsetLocationType = DHStrokeLocationTypeFlexible;
    
    appearance.minimumScale = 1.0;
    appearance.maximumScale = 10.5;
    appearance.oneToOneScaleMatchMaxHoursInVisible = 4;
}



+ (void)renderGearAppearanceWithDirection:(DHAxisDirection)direction {
    DHTimeAxisAppearance *appearance = [DHTimeAxisAppearance sharedAppearance];
    appearance.mainBackgroundColor = [UIColor blackColor];
    appearance.rendererClass = [DHTimeAxisGearRenderer class];
    appearance.direction = direction;
    
    appearance.ruleColor = [UIColor whiteColor];
    appearance.ruleStrokeSize = 1.0;
    appearance.ruleOffsetLocationType = DHStrokeLocationTypeMiddle;
    
    appearance.divisionColor = [UIColor whiteColor];
    appearance.divisionStrokeSize = 1.0;
    
    appearance.digitalAttribute = @{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    appearance.baseLineColor = [UIColor whiteColor];
    appearance.baseLineStrokeSize = 1.0;
    appearance.baseLineFixedOffset = 0.0;
    appearance.baseLineOffsetLocationType = DHStrokeLocationTypeFlexible;
    
    appearance.minimumScale = 0.5;
    appearance.maximumScale = 4.0;
    appearance.oneToOneScaleMatchMaxHoursInVisible = 4;
    
    appearance.dataStrokeColor = [[UIColor clearColor] colorWithAlphaComponent:.5];
    appearance.dataStrokeSizeType = DHStrokeSizeTypeFull;
}

@end
