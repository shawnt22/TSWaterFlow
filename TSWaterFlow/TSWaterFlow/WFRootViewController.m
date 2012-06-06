//
//  WFRootViewController.m
//  TSWaterFlow
//
//  Created by 松 滕 on 12-5-28.
//  Copyright (c) 2012年 shawnt22@gmail.com. All rights reserved.
//

#import "WFRootViewController.h"

@interface WFRootViewController()
@property (nonatomic, assign) PWaterFlowView *wfView;
- (void)createWaterFlowView;
- (void)initWFSources;
- (void)sortWFSourcesWithPins:(NSArray *)pins;
@end

@implementation WFRootViewController
@synthesize wfSources, wfView;

#define kNavigationBarHeight 44.0
#define kTabBarHeight 0.0

#define kWFColumnMarginLeft 10.0
#define kWFColumnWidth 100.0
#define kWFColumnCount 3

#pragma mark init & dealloc
- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (void)dealloc {
    self.wfView = nil;
    self.wfSources = nil;
    
    [super dealloc];
}
- (void)initWFSources {
    NSMutableArray *_sources = [NSMutableArray array];
    for (NSInteger i = 0; i < kWFColumnCount; i++) {
        [_sources addObject:[NSMutableArray array]];
    }
    self.wfSources = _sources;
}

#pragma mark viewcontroller delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"WaterFlow";
    self.view.backgroundColor = [UIColor colorWithRed:(53/255.0) green:(53/255.0) blue:(53/255.0) alpha:1.0];
    
    [self createWaterFlowView];
    [self.wfView initEmptyData];
}

#pragma mark waterFlow manaager
- (void)createWaterFlowView {
    PWaterFlowView *_wfview = [[PWaterFlowView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-kNavigationBarHeight-kTabBarHeight)];
    _wfview.wfDelegate = self;
    [self.view addSubview:_wfview];
    self.wfView = _wfview;
    [_wfview release];
}
- (void)sortWFSourcesWithPins:(NSArray *)pins {
    for (PTestPin *pin in pins) {
        NSMutableArray *lowPins = [self.wfSources objectAtIndex:0];
        PWFPin *lowPin = [lowPins lastObject];
        NSInteger lowIndex = 0;
        for (NSInteger i = 0; i < [self.wfSources count]; i++) {
            NSMutableArray *_lowPins = [self.wfSources objectAtIndex:i];
            PWFPin *_lastPin = [_lowPins lastObject];
            if (!_lastPin) {
                lowPins = _lowPins;
                lowIndex = i;
                lowPin = _lastPin;
                break;
            }
            //  bijiao
            if (lowPin.rect.origin.y+lowPin.rect.size.height > _lastPin.rect.origin.y+_lastPin.rect.size.height) {
                lowPin = _lastPin;
                lowPins = _lowPins;
                lowIndex = i;
            }
        }
        CGRect _f = CGRectMake(kWFColumnWidth*lowIndex + kWFColumnMarginLeft, 0, pin.imgWidth, pin.imgHeight);
        _f.origin.y = lowPin ? lowPin.rect.origin.y+lowPin.rect.size.height : _f.origin.y;
        
        PWFPin *wfpin = [[PWFPin alloc] init];
        wfpin.pin = pin;
        wfpin.rect = _f;
        [lowPins addObject:wfpin];
        [wfpin release];
    }
}
- (NSInteger)numberOfColumnInFlowView:(PWaterFlowView *)flowView {
    return kWFColumnCount;
}
- (NSInteger)flowView:(PWaterFlowView *)flowView numberOfRowInColumn:(NSInteger)column {
    if (column < [self.wfSources count]) {
        return [[self.wfSources objectAtIndex:column] count];
    }
    return 0;
}
- (CGSize)contentSizeOfFlowView:(PWaterFlowView *)flowView {
    PWFPin *longWFPin = [[self.wfSources objectAtIndex:0] lastObject];
    if (longWFPin) {
        for (NSMutableArray *asources in self.wfSources) {
            PWFPin *lastWFPin = [asources lastObject];
            if (lastWFPin) {
                if (longWFPin.rect.origin.y+longWFPin.rect.size.height < lastWFPin.rect.origin.y+lastWFPin.rect.size.height) {
                    longWFPin = lastWFPin;
                }
            }
        }
        return CGSizeMake(flowView.bounds.size.width, longWFPin.rect.size.height+longWFPin.rect.origin.y);
    }
    return CGSizeMake(flowView.bounds.size.width, flowView.bounds.size.height+1);
}
- (PWaterFlowItem *)flowView:(PWaterFlowView *)flowView itemAtIndexPath:(WFIndexPath)indexPath {
    if (!(indexPath.column < [self.wfSources count] && indexPath.row < [[self.wfSources objectAtIndex:indexPath.column] count])) {
        return nil;
    }
    
    PWFPin *wfpin = [[self.wfSources objectAtIndex:indexPath.column] objectAtIndex:indexPath.row];
    
    NSString *identifier = @"pwfitem";
    PPinWaterFlowItem *wfitem = (PPinWaterFlowItem *)[flowView dequeueReusableItemWithIdentifier:identifier];
    if (!wfitem) {
        wfitem = [[[PPinWaterFlowItem alloc] initWithFrame:wfpin.rect ReusedIdentifier:identifier] autorelease];
        [wfitem addTarget:flowView action:kWFItemClickSelector forControlEvents:UIControlEventTouchUpInside];
    }
    wfitem.indexPath = indexPath;
    wfitem.pin = wfpin.pin;
    wfitem.frame = wfpin.rect;
    [wfitem refreshItem];
    return wfitem;
}
- (void)flowView:(PWaterFlowView *)flowView didSelectItemAtIndexPath:(WFIndexPath)indexPath {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"选中了(%d, %d)", indexPath.row, indexPath.column] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
    [alert release];
}
- (void)flowViewPullToRefresh:(PWaterFlowView *)flowView {
    [self performSelector:@selector(delayFinishPullToRefresh:) withObject:flowView afterDelay:2];
}
- (void)flowViewPullToLoadmore:(PWaterFlowView *)flowView {
    [self performSelector:@selector(delayFinishPullToLoadmore:) withObject:flowView afterDelay:2];
}
- (void)delayFinishPullToRefresh:(PWaterFlowView *)flowView {
    NSMutableArray *imgs = [NSMutableArray array];
    for (NSInteger i = 0; i < 30; i++) {
        PTestPin *tstPin = [[PTestPin alloc] init];
        [tstPin updateImageWithName:[NSString stringWithFormat:@"%d", i] wfitemWidth:kWFColumnWidth]; 
        [imgs addObject:tstPin];
        [tstPin release];
    }
    [self initWFSources];
    [self sortWFSourcesWithPins:imgs];
    [self.wfView reloadDataWithDataFull:NO];
    
    [flowView finishPullToRefreshWithAnimated:YES];
}
- (void)delayFinishPullToLoadmore:(PWaterFlowView *)flowView {
    NSMutableArray *imgs = [NSMutableArray array];
    for (NSInteger i = 0; i < 30; i++) {
        PTestPin *tstPin = [[PTestPin alloc] init];
        [tstPin updateImageWithName:[NSString stringWithFormat:@"%d", i] wfitemWidth:kWFColumnWidth]; 
        [imgs addObject:tstPin];
        [tstPin release];
    }
    [self sortWFSourcesWithPins:imgs];
    [self.wfView reloadDataWithDataFull:NO];
    
    [flowView finishPullToLoadmoreWithAnimated:YES];
}

@end

#pragma mark - WFImage for test
@implementation PTestPin
@synthesize image, imgHeight, imgWidth;

- (void)dealloc {
    self.image = nil;
    [super dealloc];
}
- (void)updateImageWithName:(NSString *)imgName wfitemWidth:(float)width {
    UIImage *_img = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imgName ofType:@"jpg"]];;
    CGImageRef _imgRef = _img.CGImage;
    float _width = CGImageGetWidth(_imgRef);
    float _height = CGImageGetHeight(_imgRef);
    float height = _height * width / _width;
    height = height > 2000 ? 2000.0 : height;
    self.imgWidth = width;
    self.imgHeight = height;
    self.image = _img;
}

@end

#pragma mark - WFModel
@interface PWFPin()
@end
@implementation PWFPin
@synthesize pin, rect;

#pragma mark init & dealloc
- (id)init {
    self = [super init];
    if (self) {
        self.pin = nil;
        self.rect = CGRectZero;
    }
    return self;
}
- (void)dealloc {
    self.pin = nil;
    [super dealloc];
}

@end

@interface PPinWaterFlowItem()
@property (nonatomic, assign) UIImageView *imgView;
@end
@implementation PPinWaterFlowItem
@synthesize pin, imgView;

#pragma mark init & dealloc
- (id)initWithFrame:(CGRect)frame ReusedIdentifier:(NSString *)areuseIdentifier {
    self = [super initWithFrame:frame ReusedIdentifier:areuseIdentifier];
    if (self) {
        self.pin = nil;
        
        UIImageView *_imgv = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_imgv];
        self.imgView = _imgv;
        [_imgv release];
    }
    return self;
}
- (void)dealloc {
    self.pin = nil;
    [super dealloc];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect f = self.bounds;
    self.imgView.frame = CGRectInset(f, 2, 2);
}
- (void)refreshItem {
    [super refreshItem];
    PTestPin *_tstpin = (PTestPin *)self.pin;
    self.imgView.image = _tstpin.image;
}

@end