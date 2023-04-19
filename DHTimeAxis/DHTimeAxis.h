//  DHTimeAxis.h
//  DHTimeAxis
//
//  Create by daniel.hu on 2018/11/12.
//  Copyright © 2018年 daniel. All rights reserved.

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "DHTimeAxisData.h"
#import "DHTimeAxisAppearance+Renderer.h"
#import "DHTimeAxisAppearance.h"

@class DHTimeAxis;
@protocol DHTimeAxisDelegate <NSObject>
@optional
/// 更新当前时间
- (void)timeAxis:(DHTimeAxis *_Nullable)timeAxis didChangedTimeInterval:(NSTimeInterval)currentTimeInterval;
/// 更新放缩比例
- (void)timeAxis:(DHTimeAxis *_Nullable)timeAxis didChangedScale:(CGFloat)currentScale;
/// 停止的位置存在数据
- (void)timeAxis:(DHTimeAxis *_Nullable)timeAxis didEndedAtDataSection:(DHTimeAxisData *_Nullable)aAxisData;
/// 开始滚动
- (void)timeAxisDidBeginScrolling:(DHTimeAxis *_Nullable)timeAxis;

/** 正在拖动 */
- (void)timeAxisDidScrolling:(DHTimeAxis *_Nullable)timeAxis;

/// 结束滚动
- (void)timeAxisDidEndScrolling:(DHTimeAxis *_Nullable)timeAxis;
/// 开始捏合手势
- (void)timeAxisDidBeginPinching:(DHTimeAxis *_Nullable)timeAxis;
/// 结束捏合手势
- (void)timeAxisDidEndPinching:(DHTimeAxis *_Nullable)timeAxis;

/** 正在捏合 */
- (void)timeAxisDidPinching:(DHTimeAxis *_Nullable)timeAxis;



/**
 外部提供偏移当前时间参数 的计算方法
 @param offset 手势造成的偏移
 @param viewSize 视图长宽
 @param opOffset 计算后的偏移值
 @param opViewSize 计算后的尺寸
 */
- (void)translationCurrentTimeIntervalFromOffset:(CGPoint)offset viewSize:(CGSize)viewSize toOptimisticOffset:(CGFloat *_Nullable)opOffset optimisticViewSize:(CGFloat *_Nullable)opViewSize;
@end


NS_ASSUME_NONNULL_BEGIN

@interface DHTimeAxis : UIControl

@property (nonatomic, weak) id<DHTimeAxisDelegate> delegate;
//当前滑动的游标卡尺的位置，也可是播放进度
@property (nonatomic, readonly, assign) NSTimeInterval currentTimeInterval;

@property (nonatomic, readonly, assign) CGFloat currentScale;

@property (nonatomic, readonly, assign, getter=isPaning) __block BOOL paning;
@property (nonatomic, readonly, assign, getter=isPinching) BOOL pinching;

/**
 外部驱动时间轴更新
 
 @param currentTimeInterval 当前时间刻度
 */
- (void)updateWithCurrentTimeInterval:(NSTimeInterval)currentTimeInterval;

/**
 更新时间段数据
 
 @param dataArray 段数据
 */
- (void)updateWithDataArray:(NSArray <DHTimeAxisData *>*)dataArray;
/**
 设置时间轴的缩放比例

 @param currentScale 当前的缩放比例
 */
- (void)updateWithCurrentScale:(CGFloat)currentScale;

/**
 设置时间轴的刻度大小标记

 @param rulerMark 当前的刻度大小标记
 */
- (void)updateWithRulerMark:(DHAxisTimeScale)rulerMark;

/**
 手动停止滚动
 */
- (void)manuallyStopRolling;

//根据偏移量算出时间 传入时间轴中点到指定point偏移量即可。
- (NSTimeInterval)getTimeIntervalFormOffset:(CGPoint)offset andViewSize:(CGSize)viewSize;
@end

NS_ASSUME_NONNULL_END
