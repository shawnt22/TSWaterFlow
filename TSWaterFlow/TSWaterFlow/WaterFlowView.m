//
//  WaterFlowView.m
//  TSWaterFlow
//
//  Created by 松 滕 on 12-5-28.
//  Copyright (c) 2012年 shawnt22@gmail.com. All rights reserved.
//

#import "WaterFlowView.h"

#pragma mark - Header&Footer View
#pragma mark - HeaderView
@interface TSPullTableHeaderView()
@property (nonatomic, assign) UILabel *content;
@property (nonatomic, assign) UIActivityIndicatorView *indicator;
@end
@implementation TSPullTableHeaderView
@synthesize status = _status;
@synthesize content;
@synthesize indicator;
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *_content = [[UILabel alloc] initWithFrame:CGRectMake(ceilf((frame.size.width-100)/2)+20, frame.size.height-20-20, 100, 20)];
        _content.backgroundColor = [UIColor clearColor];
        _content.textAlignment = UITextAlignmentLeft;
        _content.font = [UIFont systemFontOfSize:14];
        _content.textColor = [UIColor colorWithRed:(134/255.0) green:(134/255.0) blue:(134/255.0) alpha:1];
        //_content.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:_content];
        [_content release];
        self.content = _content;
        
        UIActivityIndicatorView *_indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicator.hidesWhenStopped = YES;
        _indicator.center = CGPointMake(self.content.frame.origin.x - 40, self.content.center.y);
        [self addSubview:_indicator];
        [_indicator release];
        self.indicator = _indicator;
    }
    return self;
}
- (void)updateStatus:(PullTableFloatViewStatus)status {
    self.status = status;
    [self.indicator stopAnimating];
    switch (status) {
        case PullTableFloatViewLoading: {
            self.content.text = @"加载中...";
            [self.indicator startAnimating];
        }
            break;
        case PullTableFloatViewPullToLoad: {
            self.content.text = @"下拉刷新";
        }
            break;
        case PullTableFloatViewReleaseToLoad: {
            self.content.text = @"松开即可刷新";
        }
            break;
        default:
            break;
    }
}

@end


#pragma mark - FooterView
@interface TSPullTableFooterView()
@property (nonatomic, assign) UILabel *content;
@property (nonatomic, assign) UIActivityIndicatorView *indicator;
@end
@implementation TSPullTableFooterView
@synthesize status = _status;
@synthesize content;
@synthesize indicator;
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *_content = [[UILabel alloc] initWithFrame:CGRectMake(ceilf((frame.size.width-130)/2)+25, 20, 130, 20)];
        _content.backgroundColor = [UIColor clearColor];
        _content.textAlignment = UITextAlignmentLeft;
        _content.font = [UIFont systemFontOfSize:14];
        _content.textColor = [UIColor colorWithRed:(134/255.0) green:(134/255.0) blue:(134/255.0) alpha:1];
        //_content.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:_content];
        [_content release];
        self.content = _content;
        
        UIActivityIndicatorView *_indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicator.hidesWhenStopped = YES;
        _indicator.center = CGPointMake(self.content.frame.origin.x - 40, self.content.center.y);
        [self addSubview:_indicator];
        [_indicator release];
        self.indicator = _indicator;
    }
    return self;
}
- (void)updateStatus:(PullTableFloatViewStatus)status {
    self.status = status;
    [self.indicator stopAnimating];
    switch (status) {
        case PullTableFloatViewLoading: {
            self.content.text = @"加载中...";
            [self.indicator startAnimating];
        }
            break;
        case PullTableFloatViewPullToLoad: {
            self.content.text = @"上拉加载更多";
        }
            break;
        case PullTableFloatViewReleaseToLoad: {
            self.content.text = @"松开即可加载更多";
        }
            break;
        default:
            break;
    }
}

@end

#pragma mark - WaterFlow View Privated
@interface PWaterFlowView()
//  water flow
@property (nonatomic, retain) NSMutableArray *visiableItems;
@property (nonatomic, retain) NSMutableDictionary *reusableItems;
@property (nonatomic, assign) NSInteger numberOfColumn;
@property (nonatomic, assign) float widthOfColumn;
//  pull to refresh/loadmore
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingmore;

- (void)initSubobjects;
- (void)reloadData;
- (void)removeItem:(PWaterFlowItem *)item inArray:(NSMutableArray *)items;
- (void)addItem:(PWaterFlowItem *)item inArray:(NSMutableArray *)items;
- (void)clearItems;
- (void)check;
- (void)didFinishStartPullToRefreshAnimation;
- (void)didFinishStartPullToLoadmoreAnimation;
- (void)fillFreeFieldWithTopItem:(PWaterFlowItem *)topItem BottomItem:(PWaterFlowItem *)bottomItem visiableItems:(NSMutableArray *)items Column:(NSInteger)column visiableRect:(CGRect)visiableRect;
@end

#pragma mark - WaterFlow View Notify
@interface PWaterFlowView(Notify)
- (NSInteger)notifyNumberOfColumnInFlowView:(PWaterFlowView *)flowView;
- (NSInteger)notifyFlowView:(PWaterFlowView *)flowView numberOfRowInColumn:(NSInteger)column;
- (CGSize)notifyContentSizeOfFlowView:(PWaterFlowView *)flowView;
- (PWaterFlowItem *)notifyFlowView:(PWaterFlowView *)flowView itemAtIndexPath:(WFIndexPath)indexPath;
- (void)notifyFlowView:(PWaterFlowView *)flowView didSelectItemAtIndexPath:(WFIndexPath)indexPath;
- (void)notifyFlowViewPullToRefresh:(PWaterFlowView *)flowView;
- (void)notifyFlowViewPullToLoadmore:(PWaterFlowView *)flowView;
@end
@implementation PWaterFlowView(Notify)
- (NSInteger)notifyNumberOfColumnInFlowView:(PWaterFlowView *)flowView {
    if (self.wfDelegate && [self.wfDelegate respondsToSelector:@selector(numberOfColumnInFlowView:)]) {
        return [self.wfDelegate numberOfColumnInFlowView:flowView];
    }
    return 0;
}
- (NSInteger)notifyFlowView:(PWaterFlowView *)flowView numberOfRowInColumn:(NSInteger)column {
    if (self.wfDelegate && [self.wfDelegate respondsToSelector:@selector(flowView:numberOfRowInColumn:)]) {
        return [self.wfDelegate flowView:flowView numberOfRowInColumn:column];
    }
    return 0;
}
- (CGSize)notifyContentSizeOfFlowView:(PWaterFlowView *)flowView {
    if (self.wfDelegate && [self.wfDelegate respondsToSelector:@selector(contentSizeOfFlowView:)]) {
        return [self.wfDelegate contentSizeOfFlowView:flowView];
    }
    return CGSizeZero;
}
- (PWaterFlowItem *)notifyFlowView:(PWaterFlowView *)flowView itemAtIndexPath:(WFIndexPath)indexPath {
    if (self.wfDelegate && [self.wfDelegate respondsToSelector:@selector(flowView:itemAtIndexPath:)]) {
        return [self.wfDelegate flowView:flowView itemAtIndexPath:indexPath];
    }
    return nil;
}
- (void)notifyFlowView:(PWaterFlowView *)flowView didSelectItemAtIndexPath:(WFIndexPath)indexPath {
    if (self.wfDelegate && [self.wfDelegate respondsToSelector:@selector(flowView:didSelectItemAtIndexPath:)]) {
        [self.wfDelegate flowView:flowView didSelectItemAtIndexPath:indexPath];
    }
}
- (void)notifyFlowViewPullToRefresh:(PWaterFlowView *)flowView {
    if (self.wfDelegate && [self.wfDelegate respondsToSelector:@selector(flowViewPullToRefresh:)]) {
        [self.wfDelegate flowViewPullToRefresh:flowView];
    }
}
- (void)notifyFlowViewPullToLoadmore:(PWaterFlowView *)flowView {
    if (self.wfDelegate && [self.wfDelegate respondsToSelector:@selector(flowViewPullToLoadmore:)]) {
        [self.wfDelegate flowViewPullToLoadmore:flowView];
    }
}
@end

#pragma mark - WaterFlow SwipeGesture
@interface PWaterFlowView(SwipeGesture)
- (void)registerSwipeGesture;
@end
@implementation PWaterFlowView(SwipeGesture)
- (void)registerSwipeGesture {
    UISwipeGestureRecognizer *upSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
    upSwipe.direction = UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:upSwipe];
    [upSwipe release];
    
    UISwipeGestureRecognizer *downSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
    downSwipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self addGestureRecognizer:downSwipe];
    [downSwipe release];
}
- (void)swipeAction:(UISwipeGestureRecognizer *)swipe {
    switch (swipe.direction) {
        case UISwipeGestureRecognizerDirectionDown:{
            if (self.wfDelegate && [self.wfDelegate respondsToSelector:@selector(recognizeDownSwipeGesture:)]) {
                [self.wfDelegate recognizeDownSwipeGesture:self];
            }
        }
            break;
        case UISwipeGestureRecognizerDirectionUp:{
            if (self.wfDelegate && [self.wfDelegate respondsToSelector:@selector(recognizeUpSwipeGesture:)]) {
                [self.wfDelegate recognizeUpSwipeGesture:self];
            }
        }
            break;    
        default:
            break;
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
@end

#pragma mark - WaterFlow Pull 
@interface PWaterFlowView(Pull)
- (BOOL)checkPullToRefresh:(UIScrollView *)scrollView;
- (BOOL)checkPullToLoadmore:(UIScrollView *)scrollView;
@end
@implementation PWaterFlowView(Pull)
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGRect _f = self.pullFooterView.frame;
        _f.origin.y = self.frame.size.height > self.contentSize.height ? self.frame.size.height : self.contentSize.height;
        self.pullFooterView.frame = _f;
        
        _f = self.wfFooterView.frame;
        CGSize _size = [self notifyContentSizeOfFlowView:self];
        _f.origin.y = _size.height;
        self.wfFooterView.frame = _f;
    }
    if ([keyPath isEqualToString:@"status"]) {
        if (object == self.pullHeaderView) {
            self.isRefreshing = self.pullHeaderView.status == PullTableFloatViewLoading ? YES : NO;
            return;
        }
        if (object == self.pullFooterView) {
            self.isLoadingmore = self.pullFooterView.status == PullTableFloatViewLoading ? YES : NO;
            return;
        }
    }
}
- (BOOL)checkPullToRefresh:(UIScrollView *)scrollView {
    if (self.pullHeaderView.hidden) {
        return NO;
    }
    if (!(scrollView.contentOffset.y > -self.pullHeaderOffsetY)) {
        [self.pullHeaderView updateStatus:PullTableFloatViewLoading];
        
        [UIView beginAnimations:@"PullToRefresh" context:NULL];
        [UIView setAnimationDuration:0.2f];
        self.contentInset = UIEdgeInsetsMake(self.pullHeaderOffsetY, self.contentInset.left, self.contentInset.bottom, self.contentInset.right);
        [UIView commitAnimations]; 
        
        [self notifyFlowViewPullToRefresh:self];
        
        return YES;
    }
    return NO;
}
- (BOOL)checkPullToLoadmore:(UIScrollView *)scrollView {
    if (self.pullFooterView.hidden) {
        return NO;
    }
    float _delta = scrollView.bounds.size.height > scrollView.contentSize.height ? scrollView.contentOffset.y : scrollView.contentOffset.y+scrollView.bounds.size.height-scrollView.contentSize.height;
    if (_delta > 0) {
        if (_delta > self.pullFooterOffsetY) {
            [self.pullFooterView updateStatus:PullTableFloatViewLoading];
            
            _wfBottomSpace = self.bounds.size.height - scrollView.contentSize.height;
            _wfBottomSpace = _wfBottomSpace > 0 ? _wfBottomSpace : 0;
            
            [UIView beginAnimations:@"PullToLoadmore" context:NULL];
            [UIView setAnimationDuration:0.2f];
            self.contentInset = UIEdgeInsetsMake(self.contentInset.top, self.contentInset.left, self.pullFooterOffsetY+_wfBottomSpace, self.contentInset.right);
            [UIView commitAnimations];
            
            [self notifyFlowViewPullToLoadmore:self];
            
            return YES;
        }
    }
    return NO;
}

@end

#pragma mark - WaterFlow View
@implementation PWaterFlowView
@synthesize wfDelegate;
@synthesize visiableItems, reusableItems;
@synthesize numberOfColumn, widthOfColumn;
@synthesize pullHeaderView, pullFooterView, isRefreshing, isLoadingmore;
@synthesize pullFooterOffsetY, pullHeaderOffsetY, finishPullFooterOffsetY, finishPullHeaderOffsetY;
@synthesize wfFooterView;

#pragma mark init & dealloc
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubobjects];
        self.delegate = self;
        
        TSPullTableHeaderView *_header = [[TSPullTableHeaderView alloc] initWithFrame:CGRectMake(0, -self.pullHeaderOffsetY, self.bounds.size.width, self.pullHeaderOffsetY)];
        [self addSubview:_header];
        [_header release];
        self.pullHeaderView = _header;
        [self.pullHeaderView updateStatus:PullTableFloatViewPullToLoad];
        
        TSPullTableFooterView *_footer = [[TSPullTableFooterView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 50.0f)];
        [self addSubview:_footer];
        [_footer release];
        self.pullFooterView = _footer;
        [self.pullFooterView updateStatus:PullTableFloatViewPullToLoad];
        
        UILabel *_fullFooter = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 30)];
        _fullFooter.backgroundColor = [UIColor clearColor];
        _fullFooter.font = [UIFont systemFontOfSize:15];
        _fullFooter.textAlignment = UITextAlignmentCenter;
        _fullFooter.hidden = YES;
        _fullFooter.text = @"没有更多数据";
        self.wfFooterView = _fullFooter;
        [_fullFooter release];
        [self addSubview:self.wfFooterView];
        
        [self addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
        [self.pullHeaderView addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
        [self.pullFooterView addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
        
        [self registerSwipeGesture];
        [self setPullToLoadmoreEnable:NO];
    }
    return self;
}
- (void)initSubobjects {
    self.numberOfColumn = 0;
    self.visiableItems = [NSMutableArray array];                //  可见items
    self.reusableItems = [NSMutableDictionary dictionary];      //  可复用items
    
    self.isRefreshing = NO;
    self.isLoadingmore = NO;
    _wfBottomSpace = 0;
    
    self.pullFooterOffsetY = PullTableFooterOffsetY;
    self.pullHeaderOffsetY = PullTableHeaderOffsetY;
    self.finishPullFooterOffsetY = 0.0;
    self.finishPullHeaderOffsetY = 0.0;
    
    self.wfFooterView = nil;
}
- (void)dealloc {
    [self removeObserver:self forKeyPath:@"contentSize"];
    [self.pullHeaderView removeObserver:self forKeyPath:@"status"];
    [self.pullFooterView removeObserver:self forKeyPath:@"status"];
    
    self.visiableItems = nil;
    self.reusableItems = nil;
    
    self.wfFooterView = nil;
    [super dealloc];
}
- (void)initEmptyData {
    [self reloadData];
}
- (void)reloadData {
    [self clearItems];
    
    CGSize _size = [self notifyContentSizeOfFlowView:self];
    CGFloat _height = _size.height <= self.bounds.size.height ? self.bounds.size.height+1 : _size.height;
    self.contentSize = CGSizeMake(self.bounds.size.width, _height);
    
    self.numberOfColumn = [self notifyNumberOfColumnInFlowView:self];
    self.widthOfColumn = self.numberOfColumn > 0 ? self.bounds.size.width/self.numberOfColumn : 0.0;
    
    NSMutableArray *_vsItems = [NSMutableArray array];
    for (NSInteger i = 0; i < self.numberOfColumn; i++) {
        [_vsItems addObject:[NSMutableArray array]];
    }
    self.visiableItems = _vsItems;
    
    [self check];
}
- (void)reloadDataWithDataFull:(BOOL)full {
    [self reloadData];
    [self setWaterFlowDataFull:full];
}
- (void)setPullToRefreshEnable:(BOOL)enable {
    self.pullHeaderView.hidden = !enable;
}
- (void)setPullToLoadmoreEnable:(BOOL)enable {
    self.pullFooterView.hidden = !enable;
}
- (void)setWaterFlowDataFull:(BOOL)full {
    if (full) {
        [self setPullToLoadmoreEnable:NO];
        
        if (self.wfFooterView.hidden == YES) {
            self.wfFooterView.hidden = NO;
            self.contentInset = UIEdgeInsetsMake(self.contentInset.top, self.contentInset.left, self.contentInset.bottom+self.wfFooterView.bounds.size.height, self.contentInset.right);
        }
    } else {
        [self setPullToLoadmoreEnable:YES];
        
        if (self.wfFooterView.hidden == NO) {
            self.wfFooterView.hidden = YES;
            self.contentInset = UIEdgeInsetsMake(self.contentInset.top, self.contentInset.left, self.contentInset.bottom-self.wfFooterView.bounds.size.height, self.contentInset.right);
        }
    }
    self.contentInset = UIEdgeInsetsMake(self.contentInset.top, self.contentInset.left, self.pullFooterView.bounds.size.height, self.contentInset.right);
}

#pragma mark item manager
- (PWaterFlowItem *)dequeueReusableItemWithIdentifier:(NSString *)identifier {
    NSMutableArray *reuseItems = [self.reusableItems objectForKey:identifier];
    if (!reuseItems) {
        reuseItems = [NSMutableArray array];
        [self.reusableItems setObject:reuseItems forKey:identifier];
    }
    PWaterFlowItem *item = [reuseItems lastObject];
    return item;
}
- (void)clearItems {
    for (NSMutableArray *items in self.visiableItems) {
        for (PWaterFlowItem *aitem in items) {
            [aitem removeFromSuperview];
        }
    }
    self.reusableItems = [NSMutableDictionary dictionary];
    NSMutableArray *_vsItems = [NSMutableArray array];
    for (NSInteger i = 0; i < self.numberOfColumn; i++) {
        [_vsItems addObject:[NSMutableArray array]];
    }
    self.visiableItems = _vsItems;
}
- (void)removeItem:(PWaterFlowItem *)item inArray:(NSMutableArray *)items {
    NSMutableArray *reuseItems = [self.reusableItems objectForKey:item.reuseIdentifier];
    if (!reuseItems) {
        reuseItems = [NSMutableArray array];
        [self.reusableItems setObject:reuseItems forKey:item.reuseIdentifier];
    }
    [reuseItems addObject:item];
    
    [item removeFromSuperview];
    [items removeObject:item];
}
- (void)addItem:(PWaterFlowItem *)item inArray:(NSMutableArray *)items {
    [self addSubview:item];
    [self sendSubviewToBack:item];
    [items addObject:item];
    
    NSMutableArray *reuseItems = [self.reusableItems objectForKey:item.reuseIdentifier];
    [reuseItems removeObject:item];
}
- (void)check {
    if (self.contentOffset.y < -self.pullHeaderOffsetY || self.contentOffset.y+self.bounds.size.height+self.pullHeaderOffsetY > self.contentSize.height) {
        return;
    }
    for (NSInteger column = 0; column < self.numberOfColumn; column++) {
        NSMutableArray *items = [self.visiableItems objectAtIndex:column];
        //  可视区为两屏
        float offsetY = self.contentOffset.y - self.bounds.size.height/2;
        offsetY = offsetY < 0 ? 0 : offsetY;
        CGRect visiableRect = CGRectMake(self.contentOffset.x+self.widthOfColumn*column,
                                         offsetY, 
                                         self.widthOfColumn, 
                                         self.bounds.size.height*1.5);
        PWaterFlowItem *topItem = nil;
        PWaterFlowItem *bottomItem = nil;
        for (NSInteger index = 0; index < [items count]; index++) {
            PWaterFlowItem *aitem = [items objectAtIndex:index];
            CGRect intersection = CGRectIntersection(visiableRect, aitem.frame);
            //  移除不在当前屏内的item
            if (CGRectIsEmpty(intersection)) {
                [self removeItem:aitem inArray:items];
                index--;
                continue;
            }
            //  找到最上方的item
            if (topItem == nil) {
                topItem = aitem;
            } else {
                topItem = topItem.frame.origin.y > aitem.frame.origin.y ? aitem : topItem;
            }
            //  找到最下方的item
            if (bottomItem == nil) {
                bottomItem = aitem;
            } else {
                bottomItem = bottomItem.frame.origin.y+bottomItem.frame.size.height > aitem.frame.origin.y+aitem.frame.size.height ? bottomItem : aitem;
            }
        }
        [self fillFreeFieldWithTopItem:topItem BottomItem:bottomItem visiableItems:items Column:column visiableRect:visiableRect];
    }
}
//  每列递归填充空白区域
- (void)fillFreeFieldWithTopItem:(PWaterFlowItem *)topItem BottomItem:(PWaterFlowItem *)bottomItem visiableItems:(NSMutableArray *)items Column:(NSInteger)column visiableRect:(CGRect)visiableRect {
    BOOL needRecall = NO;
    //  区域尚无item，直接添加第一个
    if (!topItem && !bottomItem) {
        WFIndexPath indexPath = WFIndexPathMake(0, column);
        PWaterFlowItem *requiredItem = [self notifyFlowView:self itemAtIndexPath:indexPath];
        if (requiredItem) {
            [self addItem:requiredItem inArray:items];
            topItem = requiredItem;
            bottomItem = requiredItem;
            needRecall = YES;
        }
    }
    //  若上方未填满，则在上方添加一个item
    if (topItem && topItem.frame.origin.y > visiableRect.origin.y) {
        WFIndexPath indexPath = topItem.indexPath;
        indexPath.row = indexPath.row - 1;
        
        PWaterFlowItem *requiredItem = [self notifyFlowView:self itemAtIndexPath:indexPath];
        if (requiredItem) {
            [self addItem:requiredItem inArray:items];
            topItem = requiredItem;
            needRecall = YES;
        }
    }
    //  若下方未填满，则在下方添加一个item
    if (bottomItem && bottomItem.frame.origin.y+bottomItem.frame.size.height < visiableRect.origin.y+visiableRect.size.height) {
        WFIndexPath indexPath = bottomItem.indexPath;
        indexPath.row = indexPath.row + 1;
        if (indexPath.row < [self notifyFlowView:self numberOfRowInColumn:indexPath.column]) {
            PWaterFlowItem *requiredItem = [self notifyFlowView:self itemAtIndexPath:indexPath];
            if (requiredItem) {
                [self addItem:requiredItem inArray:items];
                bottomItem = requiredItem;
                needRecall = YES;
            }
        }
    }
    if (needRecall) {
        [self fillFreeFieldWithTopItem:topItem BottomItem:bottomItem visiableItems:items Column:column visiableRect:visiableRect];
    }
}

#pragma mark scroll delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self check];
    
    if (scrollView.dragging) {
        if (scrollView.contentOffset.y < 0) {
            if (self.pullHeaderView.hidden) {
                return;
            }
            if (scrollView.contentOffset.y > -self.pullHeaderOffsetY) {
                //  下拉刷新
                if (self.pullHeaderView.status == PullTableFloatViewLoading) {
                    //  正在刷新时，回推操作不更新status
                    return;
                }
                [self.pullHeaderView updateStatus:PullTableFloatViewPullToLoad];
            }else {
                //  松开刷新
                [self.pullHeaderView updateStatus:PullTableFloatViewReleaseToLoad];
            }
        }else {
            if (self.isRefreshing) {
                //  正在刷新时，不更新status
                return;
            }
            if (self.pullFooterView.hidden) {
                return;
            }
            float _delta = scrollView.bounds.size.height > scrollView.contentSize.height ? scrollView.contentOffset.y : scrollView.contentOffset.y+scrollView.bounds.size.height-scrollView.contentSize.height;
            if (_delta > 0) {
                if (_delta < self.pullFooterOffsetY) {
                    //  上拉加载更多
                    if (self.pullFooterView.status == PullTableFloatViewLoading) {
                        //  正在加载更多时，回推操作不更新status
                        return;
                    }
                    [self.pullFooterView updateStatus:PullTableFloatViewPullToLoad];
                }else {
                    //  松开加载更多
                    [self.pullFooterView updateStatus:PullTableFloatViewReleaseToLoad];
                }
            }
        }
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (![self checkPullToRefresh:scrollView]) {
        if (self.isRefreshing) {
            //  正在刷新时，不进行加载更多逻辑
            return;
        }
        [self checkPullToLoadmore:scrollView];
    }
}

#pragma mark pull
- (void)startPullToRefreshWithAnimated:(BOOL)animated {
    if (self.pullHeaderView.hidden) {
        return;
    }
    if (animated) {
        [UIView beginAnimations:@"PullToRefresh" context:NULL];
        [UIView setAnimationDuration:0.2f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(didFinishStartPullToRefreshAnimation)];
        self.contentOffset = CGPointMake(0, -self.pullHeaderOffsetY);
        [UIView commitAnimations];
    } else {
        self.contentOffset = CGPointMake(0, -self.pullHeaderOffsetY);
        [self didFinishStartPullToRefreshAnimation];
    }
}
- (void)didFinishStartPullToRefreshAnimation {
    [self checkPullToRefresh:self];
}
- (void)finishPullToRefreshWithAnimated:(BOOL)animated {
    [self.pullHeaderView updateStatus:PullTableFloatViewPullToLoad];
    if (animated) {
        [UIView beginAnimations:@"PullToRefresh" context:NULL];
        [UIView setAnimationDuration:0.2f];
        self.contentInset = UIEdgeInsetsMake(self.finishPullHeaderOffsetY, self.contentInset.left, self.contentInset.bottom, self.contentInset.right);
        [UIView commitAnimations];
    } else {
        self.contentInset = UIEdgeInsetsMake(self.finishPullHeaderOffsetY, self.contentInset.left, self.contentInset.bottom, self.contentInset.right);
    }
}
- (void)startPullToLoadmoreWithAnimated:(BOOL)animated {
    if (self.pullFooterView.hidden) {
        return;
    }
    if (animated) {
        [UIView beginAnimations:@"PullToLoadmore" context:NULL];
        [UIView setAnimationDuration:0.2f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(didFinishStartPullToLoadmoreAnimation)];
        self.contentOffset = CGPointMake(0, self.pullFooterOffsetY);
        [UIView commitAnimations];
    } else {
        self.contentOffset = CGPointMake(0, self.pullFooterOffsetY);
        [self didFinishStartPullToLoadmoreAnimation];
    }
}
- (void)didFinishStartPullToLoadmoreAnimation {
    [self checkPullToLoadmore:self];
}
- (void)finishPullToLoadmoreWithAnimated:(BOOL)animated {
    [self.pullFooterView updateStatus:PullTableFloatViewPullToLoad];
    if (animated) {
        [UIView beginAnimations:@"PullToLoadmore" context:NULL];
        [UIView setAnimationDuration:0.2f];
        self.contentInset = UIEdgeInsetsMake(self.contentInset.top, self.contentInset.left, self.pullFooterView.bounds.size.height, self.contentInset.right);
        [UIView commitAnimations]; 
    } else {
        self.contentInset = UIEdgeInsetsMake(self.contentInset.top, self.contentInset.left, self.pullFooterView.bounds.size.height, self.contentInset.right);
    }
}

#pragma mark actions
- (void)clickItemAction:(PWaterFlowItem *)item {
    [self notifyFlowView:self didSelectItemAtIndexPath:item.indexPath];
}

@end


#pragma mark - WaterFlow Item
@implementation PWaterFlowItem
@synthesize indexPath, reuseIdentifier;

- (id)initWithFrame:(CGRect)frame ReusedIdentifier:(NSString *)areuseIdentifier {
    self = [self initWithFrame:frame];
    if (self) {
        self.reuseIdentifier = areuseIdentifier;
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.indexPath = WFIndexPathInvalid;
        self.reuseIdentifier = kWFItemReuseIdentifierDefault;
    }
    return self;
}
- (id)init {
    self = [super init];
    if (self) {
        self.indexPath = WFIndexPathInvalid;
        self.reuseIdentifier = kWFItemReuseIdentifierDefault;
    }
    return self;
}
- (void)dealloc {
    self.reuseIdentifier = nil;
    [super dealloc];
}
- (void)refreshItem {}

@end


#pragma mark - Test

@interface PTestWaterFlowItem()
@property (nonatomic, assign) UIImageView *bg;
@end
@implementation PTestWaterFlowItem
@synthesize bg;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGRect bgRect = self.bounds;
        bgRect = CGRectInset(bgRect, 2, 2);
        UIImageView *_bg = [[UIImageView alloc] initWithFrame:bgRect];
        _bg.backgroundColor = [UIColor greenColor];
        _bg.image = [UIImage imageNamed:@"1600x1200.jpg"];
        [self addSubview:_bg];
        self.bg = _bg;
        [_bg release];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect f = self.bounds;
    self.bg.frame = CGRectInset(f, 2, 2);
}

@end


