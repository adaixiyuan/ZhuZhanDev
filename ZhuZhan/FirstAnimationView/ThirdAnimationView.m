//
//  ThirdAnimationView.m
//  AnimationDemo
//
//  Created by 孙元侃 on 14/12/8.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "ThirdAnimationView.h"
#import "GetImagePath.h"
@interface ThirdAnimationView ()
@property(nonatomic,strong)UIImageView *image;
@property(nonatomic)BOOL animationEnd;
@end

@implementation ThirdAnimationView

static int j;
-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        self.image = [[UIImageView alloc] initWithFrame:self.frame];
        [self addSubview:self.image];
        j=1;
        self.image.image = [GetImagePath getImagePath:@"030001"];
    }
    return self;
}
-(void)startAnimation{
    if (!self.animationEnd) {
        [self.delegate startAnimation];

        self.animationEnd=YES;
        j=1;
        [self addImage:j];
    }
}
-(void)addImage:(int)index{
    UIScrollView* scrollView=(UIScrollView*)self.superview;
    [scrollView setContentOffset:CGPointMake(640, 0)];
    scrollView.contentSize=CGSizeMake(320*4, 568);
    if(index <=27){
        if(index<10){
            self.image.image = [GetImagePath getImagePath:[NSString stringWithFormat:@"03000%d",index]];
        }else{
            self.image.image = [GetImagePath getImagePath:[NSString stringWithFormat:@"0300%d",index]];
        }
        j++;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self addImage:j];
        });
    }else{
        [self.delegate endAnimation];
    }
}
@end
