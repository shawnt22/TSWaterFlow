//
//  WaterFlowView.h
//  TSWaterFlow
//
//  Created by 松 滕 on 12-5-28.
//  Copyright (c) 2012年 shawnt22@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    NSInteger row;
    NSInteger column;
}WFIndexPath;
NS_INLINE WFIndexPath WFIndexPathMake(NSInteger r, NSInteger c) {
    WFIndexPath indexPath;
    indexPath.row = r;
    indexPath.column = c;
    return indexPath;
}
#define WFIndexPathInvalid WFIndexPathMake(-1, -1)
NS_INLINE BOOL WFIndexPathEqualToIndexPath(WFIndexPath indexPath1, WFIndexPath indexPath2) {
    BOOL result = NO;
    if (indexPath1.row == indexPath2.row && indexPath1.column == indexPath2.column) {
        result = YES;
    }
    return result;
}
NS_INLINE BOOL isInvalidWFIndexPath(WFIndexPath indexPath) {
    BOOL result = NO;
    WFIndexPath invalid = WFIndexPathInvalid;
    if (indexPath.row == invalid.row && indexPath.column == invalid.column) {
        result = YES;
    }
    return result;
}

#pragma mark - Protocols
@protocol TSPullTableViewProtocol <NSObject>
@optional
- (void)startPullToRefreshWithAnimated:(BOOL)animated;
- (void)finishPullToRefreshWithAnimated:(BOOL)animated;
- (void)startPullToLoadmoreWithAnimated:(BOOL)animated;
- (void)finishPullToLoadmoreWithAnimated:(BOOL)animated;
@end

@protocol TSViewGestureDelegate <NSObject>
@optional
- (void)recognizeUpSwipeGesture:(UIView *)view;
- (void)recognizeDownSwipeGesture:(UIView *)view;
@end

#pragma mark - Header&Footer View
#define PullTableHeaderOffsetY  70.0f
#define PullTableFooterOffsetY  70.0f
typedef enum {
    PullTableFloatViewPullToLoad,
    PullTableFloatViewReleaseToLoad,
    PullTableFloatViewLoading,
}PullTableFloatViewStatus;

@protocol TSPullTableFloatViewProtocol <NSObject>
@property (nonatomic, assign) PullTableFloatViewStatus status;
- (void)updateStatus:(PullTableFloatViewStatus)status;
@end

@interface TSPullTableHeaderView : UIView<TSPullTableFloatViewProtocol> {
@private
    PullTableFloatViewStatus _status;
}
@end

@interface TSPullTableFooterView : UIView<TSPullTableFloatViewProtocol> {
@private
    PullTableFloatViewStatus _status;
}
@end

#pragma mark - WaterFlow Delegate

@class PWaterFlowView;
@class PWaterFlowItem;

@protocol PWaterFlowViewDelegate <NSObject>
@required
- (NSInteger)numberOfColumnInFlowView:(PWaterFlowView *)flowView;
- (NSInteger)flowView:(PWaterFlowView *)flowView numberOfRowInColumn:(NSInteger)column;
- (CGSize)contentSizeOfFlowView:(PWaterFlowView *)flowView;
- (PWaterFlowItem *)flowView:(PWaterFlowView *)flowView itemAtIndexPath:(WFIndexPath)indexPath;
@optional
- (void)flowView:(PWaterFlowView *)flowView didSelectItemAtIndexPath:(WFIndexPath)indexPath;
- (void)flowViewPullToRefresh:(PWaterFlowView *)flowView;
- (void)flowViewPullToLoadmore:(PWaterFlowView *)flowView;
@end

#pragma mark - WaterFlow View
@interface PWaterFlowView : UIScrollView<UIScrollViewDelegate, TSPullTableViewProtocol> {
@private
    float _wfBottomSpace;
}
@property (nonatomic, assign) id<PWaterFlowViewDelegate, TSViewGestureDelegate> wfDelegate;
@property (nonatomic, assign) TSPullTableHeaderView *pullHeaderView;
@property (nonatomic, assign) TSPullTableFooterView *pullFooterView;
@property (nonatomic, assign) float pullHeaderOffsetY;
@property (nonatomic, assign) float pullFooterOffsetY;
@property (nonatomic, assign) float finishPullHeaderOffsetY;
@property (nonatomic, assign) float finishPullFooterOffsetY;

@property (nonatomic, retain) UIView *wfFooterView;

- (PWaterFlowItem *)dequeueReusableItemWithIdentifier:(NSString *)identifier;
- (void)initEmptyData;
- (void)reloadDataWithDataFull:(BOOL)full;

- (void)setPullToRefreshEnable:(BOOL)enable;
- (void)setPullToLoadmoreEnable:(BOOL)enable;

- (void)setWaterFlowDataFull:(BOOL)full;

@end

#pragma mark - WaterFlow Item
#define kWFItemReuseIdentifierDefault @"wfitem"
#define kWFItemClickSelector @selector(clickItemAction:)
@interface PWaterFlowItem : UIControl {
@private
}
@property (nonatomic, assign) WFIndexPath indexPath;
@property (nonatomic, retain) NSString *reuseIdentifier;
- (id)initWithFrame:(CGRect)frame ReusedIdentifier:(NSString *)areuseIdentifier;
- (void)refreshItem;
@end


#pragma mark - Test
@interface PTestWaterFlowItem : PWaterFlowItem {
@private
    
}
@end
