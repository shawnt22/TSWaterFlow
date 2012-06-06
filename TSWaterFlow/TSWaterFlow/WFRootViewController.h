//
//  WFRootViewController.h
//  TSWaterFlow
//
//  Created by 松 滕 on 12-5-28.
//  Copyright (c) 2012年 shawnt22@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WaterFlowView.h"

@interface WFRootViewController : UIViewController <PWaterFlowViewDelegate, TSViewGestureDelegate>

@property (nonatomic, retain) NSMutableArray *wfSources;

@end

#pragma mark - WFImage for test
@interface PTestPin : NSObject {
@private
    
}
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) float imgWidth;
@property (nonatomic, assign) float imgHeight;

- (void)updateImageWithName:(NSString *)imgName wfitemWidth:(float)width;
@end

#pragma mark - WFModel
@interface PWFPin : NSObject {
@private
    
}
@property (nonatomic, retain) id pin;
@property (nonatomic, assign) CGRect rect;

@end

@interface PPinWaterFlowItem : PWaterFlowItem {
@private
}
@property (nonatomic, retain) id pin;

@end