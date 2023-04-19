//  DHTimeAxis.m
//  DHTimeAxis
//
//  Create by daniel.hu on 2018/11/12.
//  Copyright © 2018年 daniel. All rights reserved.

#import "DHTimeAxis.h"
#import "DHTimeAxisData.h"
#import "DHTimeAxisRule.h"
#import "DHTimeAxisDigitalDivision.h"
#import "DHTimeAxisBaseLine.h"
#import "DHTimeAxis+Dynamic.h"
#import "DHTimeAxis+Appearance.h"
#import "DHTimeAxisView.h"

@interface DHTimeAxis ()
/// 真正的时间轴视图
@property (nonatomic, strong) DHTimeAxisView *axisView;

@property (nonatomic, assign) NSTimeInterval tempTimeInterval;
@property (nonatomic, assign) CGFloat tempScale;

@property (nonatomic, readwrite, assign) __block NSTimeInterval currentTimeInterval;
@property (nonatomic, readwrite, assign) CGFloat currentScale;
@property (nonatomic, readwrite, assign) DHAxisTimeScale currentRulerMark;
@property (nonatomic, readwrite, assign, getter=isPaning) __block BOOL paning;
@property (nonatomic, readwrite, assign, getter=isPinching) BOOL pinching;

/** 拖动手势 */
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
/** 缩放手势 */
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;

//刻度？
@property (nonatomic, strong) DHTimeAxisRule *rule;
@property (nonatomic, strong) DHTimeAxisDigitalDivision *digital;

/// 包装AxisView的UI数据
@property (nonatomic, strong) NSMutableArray *axisAppearanceArray;
@end
@implementation DHTimeAxis

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        [DHTimeAxisAppearance sharedAppearance];
        
        [self configCommon];
        
    }
    return self;
}
- (void)dealloc {
    [self removeObserver:self forKeyPath:@"currentTimeInterval"];
    [self removeObserver:self forKeyPath:@"currentScale"];
    [self removeObserver:self forKeyPath:@"paning"];
    [self removeObserver:self forKeyPath:@"pinching"];
    [self resignAppearanceNotification];
}

#pragma mark - config method
/// 共同设置
- (void)configCommon {
    self.backgroundColor = [UIColor clearColor];
    
    
    [self addSubview:self.axisView];
    
    [self updateAppearance];
    
    [self addGestureRecognizer:self.panGesture];
    [self addGestureRecognizer:self.pinchGesture];
    
    [self addObserver:self forKeyPath:@"currentTimeInterval" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"currentScale" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"currentRulerMark" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"paning" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"pinching" options:NSKeyValueObservingOptionNew context:nil];
    [self registeAppearanceNotification];
}

#pragma mark - public method
- (void)updateWithCurrentTimeInterval:(NSTimeInterval)currentTimeInterval {
    self.currentTimeInterval = currentTimeInterval;
}
- (void)updateWithDataArray:(NSArray<DHTimeAxisData *> *)dataArray {
    __weak typeof(self) weakself = self;
    CGSize viewSize = weakself.axisView.frame.size;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [weakself updateAppearanceWithDataArray:dataArray size:viewSize];
        [weakself.axisView setDataArray:dataArray];
    });
}
- (void)updateWithCurrentScale:(CGFloat)currentScale {
    self.currentScale = currentScale;
}
- (void)updateWithRulerMark:(DHAxisTimeScale)rulerMark {
    self.currentRulerMark = rulerMark;
}
- (void)manuallyStopRolling {
    // 刹车
    __weak typeof(self) weakself = self;
    [self manuallyStopRollingWithDeceleratingExtraUpdate:^{
        // 更新变量
        weakself.paning = NO;
        weakself.currentTimeInterval = weakself.rule.currentTimeInterval;
    }];
}
#pragma mark - private method
/// 判断在停止拖动的情况下，数据数组是否存在包含当前时间的数据项
- (void)judgeExistDataInTheInterval:(NSTimeInterval)targetTimeInterval fromDataArray:(NSArray <DHTimeAxisData *> *)dataArray withPanState:(BOOL)isPaning {
    if (isPaning == YES || !dataArray) return;
    
    if ([dataArray count] == 0) return ;
    
    // 异步处理数组com.vimtag.vimtagicom.vimtag.vimtagi
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        for (int i = 0; i < [dataArray count]; i++) {
            DHTimeAxisData *subData = [dataArray objectAtIndex:i];
            
            if (subData.startTimeInterval <= targetTimeInterval && subData.endTimeInterval >= targetTimeInterval) {
                if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(timeAxis:didEndedAtDataSection:)]) {
                    [weakself.delegate timeAxis:weakself didEndedAtDataSection:[subData copy]];
                    break;
                }
            }
        }
    });
}
/// 组装AxisView的InterfaceArray
- (void)updateAxisViewAppearanceArray {
    self.axisView.appearanceArray = [self.axisAppearanceArray copy];
}
/// 更新当前时间算法
- (void)updateCurrentTimeIntervalFrom:(NSTimeInterval)from offset:(CGPoint)offset viewSize:(CGSize)viewSize {
    CGFloat optimisticOffset = 0.0;
    CGFloat optimisticViewSize = 0.0;
    
    if (_delegate && [_delegate respondsToSelector:@selector(translationCurrentTimeIntervalFromOffset:viewSize:toOptimisticOffset:optimisticViewSize:)]) {
        [_delegate translationCurrentTimeIntervalFromOffset:offset viewSize:viewSize toOptimisticOffset:&optimisticOffset optimisticViewSize:&optimisticViewSize];
    } else {
        [self uponAppearanceForUpdateCurrentTimeIntervalFromOffset:offset viewSize:viewSize toOptimisticOffset:&optimisticOffset optimisticViewSize:&optimisticViewSize];
    }
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakself.currentTimeInterval = from - (optimisticOffset * 1.0 / [weakself.digital aSecondOfPixelWithViewWidth:optimisticViewSize]);
    });
}
/// 更新外观
- (void)updateAppearance {
    // 获取基本属性
    self.axisView.backgroundColor = [self updateAppearanceMainBackgroundColor];
    self.axisView.rendererClass = [self updateAppearanceRenderer];
    // 重新获取新的界面
    NSArray *temp = [self updateAppearanceArrayWithSize:self.axisView.frame.size];
    
    // 引用到特殊类
    for (id<DHTimeAxisComponent> axis in temp) {
        if ([axis isKindOfClass:[DHTimeAxisRule class]]) {
            _rule = axis;
        } else if ([axis isKindOfClass:[DHTimeAxisDigitalDivision class]]) {
            _digital = axis;
        }
    }
    // 更新数据
    self.currentTimeInterval = _rule.currentTimeInterval;
    self.currentScale = _digital.currentScale;
    
    self.axisAppearanceArray = [temp mutableCopy];
    // 更新view的外观数组
    [self updateAxisViewAppearanceArray];
}
#pragma mark - observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentTimeInterval"] || [keyPath isEqualToString:@"currentScale"] || [keyPath isEqualToString:@"currentRulerMark"]) {
        _rule.currentTimeInterval = _currentTimeInterval;
        _digital.currentRulerMark = _currentRulerMark;
        _digital.currentScale = _currentScale;
        // 这里通知当前时间改变
        [self updateAxisViewAppearanceArray];
    }
    
    if ([keyPath isEqualToString:@"currentTimeInterval"]) {
        if (_delegate && [_delegate respondsToSelector:@selector(timeAxis:didChangedTimeInterval:)]) {
            [_delegate timeAxis:self didChangedTimeInterval:_currentTimeInterval];
        }
        // 判断停止时是否存在数据
        [self judgeExistDataInTheInterval:_currentTimeInterval fromDataArray:self.axisView.dataArray withPanState:self.isPaning];
        
    } else if ([keyPath isEqualToString:@"currentScale"]) {
        if (_delegate && [_delegate respondsToSelector:@selector(timeAxis:didChangedScale:)]) {
            [_delegate timeAxis:self didChangedScale:_currentScale];
        }
    } else if ([keyPath isEqualToString:@"paning"]) {
        
        if (self.isPaning) {
            if (_delegate && [_delegate respondsToSelector:@selector(timeAxisDidBeginScrolling:)]) {
                [_delegate timeAxisDidBeginScrolling:self];
            }
        } else {
            if (_delegate && [_delegate respondsToSelector:@selector(timeAxisDidEndScrolling:)]) {
                [_delegate timeAxisDidEndScrolling:self];
            }
        }
    } else if ([keyPath isEqualToString:@"pinching"]) {
        
        if (self.isPinching) {
            if (_delegate && [_delegate respondsToSelector:@selector(timeAxisDidBeginPinching:)]) {
                [_delegate timeAxisDidBeginPinching:self];
            }
        } else {
            if (_delegate && [_delegate respondsToSelector:@selector(timeAxisDidEndPinching:)]) {
                [_delegate timeAxisDidEndPinching:self];
            }
        }
    }
}

#pragma mark - gesture recongnizer method
/// 单手拖动响应
- (void)panAction:(UIPanGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            self.paning = YES;
            _tempTimeInterval = _currentTimeInterval;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            
            /**
             
                获取当前时间戳所在的日期，比较当前时间是否大于或小于当天 0-24点的时间，如果不在范围内，提示用户
             时间戳转date，再转字符串，截取前10位年月日，拼接0点0分0秒，继续转时间戳，加上24*60*60，比较大小
             */
            
            
            
            
            CGPoint point = [sender translationInView:sender.view];
            [self updateCurrentTimeIntervalFrom:_tempTimeInterval offset:point viewSize:self.axisView.frame.size];
            
            //正在拖动代理方法
            if ([self.delegate respondsToSelector:@selector(timeAxisDidScrolling:)]) {
                [self.delegate timeAxisDidScrolling:self];
            }
            
            break;
        }
        case UIGestureRecognizerStateEnded: {
            // 松手后的速度——即理论上脱手后能达到的偏移距离，乘以0.5是怕你飘了~
            CGPoint velocity = [sender velocityInView:sender.view];
            velocity.x *= 0.05;
            velocity.y *= 0.5;
            CGSize viewSize = self.axisView.frame.size;
            // 更新temp的值 指向松手后的点
            _tempTimeInterval = _currentTimeInterval;
            
            // 模拟减速效果
            __weak typeof(self) weakself = self;
            [self deceleratingAnimateWithVelocityPoint:velocity action:^(CGPoint deceleratingSpeedPoint, BOOL stop) {
                
                if (stop) {
                    weakself.paning = NO;
                }
                
                // deceleratingSpeedPoint是衰减速度，与velocity的意思一样，它是由velocity值慢慢衰减到0的
                // 两个的差值即每隔一定时间的变化量 与 手势状态UIGestureRecognizerStateChanged反馈的效果一致
                [weakself updateCurrentTimeIntervalFrom:weakself.tempTimeInterval offset:CGPointMake(velocity.x - deceleratingSpeedPoint.x, velocity.y - deceleratingSpeedPoint.y) viewSize:viewSize];
            }];
            break;
        }
        default:
            self.paning = NO;
            break;
    }
    
}

/// 两手指捏合响应
- (void)pinchAction:(UIPinchGestureRecognizer *)sender {
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            _tempScale = _currentScale;
            self.pinching = YES;
            
//            NSLog(@"准备缩放 ========== 当前的缩放比例：%.2f",_currentScale);
            
            break;
        case UIGestureRecognizerStateChanged:
            
            self.currentScale = _tempScale + sender.scale - 1;
//            NSLog(@"正在缩放 ========== 缩放的范围：%.2f ========== 缩放结果 ：%.2f",sender.scale,self.currentScale);
            
            if ([self.delegate respondsToSelector:@selector(timeAxisDidPinching:)]) {
                [self.delegate timeAxisDidPinching:self];
            }
            break;
        default:
            self.pinching = NO;
            break;
    }
    
}

#pragma mark - getters
- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        _panGesture.maximumNumberOfTouches = 1;
    }
    return _panGesture;
}
- (UIPinchGestureRecognizer *)pinchGesture {
    if (!_pinchGesture) {
        _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    }
    return _pinchGesture;
}
- (DHTimeAxisView *)axisView {
    if (!_axisView) {
        _axisView = [[DHTimeAxisView alloc] initWithFrame:self.bounds];
    }
    return _axisView;
}
- (NSMutableArray *)axisAppearanceArray {
    if (!_axisAppearanceArray) {
        _axisAppearanceArray = [[NSMutableArray alloc] initWithCapacity:3];
    }
    return _axisAppearanceArray;
}
- (void)setCurrentScale:(CGFloat)currentScale {
    /// 优化比例值
    [_digital updateToOptimisticScale:&currentScale];
    _currentScale = currentScale;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.axisView.frame = self.bounds;
}

- (NSTimeInterval)getTimeIntervalFormOffset:(CGPoint)offset andViewSize:(CGSize)viewSize{
    CGFloat optimisticOffset = 0.0;
    CGFloat optimisticViewSize = 0.0;
    
    [self uponAppearanceForUpdateCurrentTimeIntervalFromOffset:offset viewSize:viewSize toOptimisticOffset:&optimisticOffset optimisticViewSize:&optimisticViewSize];
//    __block NSTimeInterval blocktime = _currentTimeInterval;
//    __weak typeof(self) weakself = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        return blocktime - (optimisticOffset * 1.0 / [weakself.digital aSecondOfPixelWithViewWidth:optimisticViewSize]);
//
//    });
    return _currentTimeInterval - (optimisticOffset * 1.0 / [self.digital aSecondOfPixelWithViewWidth:optimisticViewSize]);
}

@end
