//
//  ProductCommentView.m
//  ZhuZhan
//
//  Created by 孙元侃 on 14-9-3.
//
//

#import "ProductCommentView.h"
#import "EGOImageView.h"

@interface ProductCommentView()
@property(nonatomic,strong)EGOImageView* userImageView;
@property(nonatomic,strong)UILabel* userNameLabel;
@property(nonatomic,strong)UILabel* userCommentContent;
@property(nonatomic,strong)UILabel* publishTime;

@end

@implementation ProductCommentView

-(instancetype)initWithCommentModel:(CommentModel*)commentModel{
    if ([super init]) {
        [self loadSelfWithCommentModel:commentModel];
    }
    return self;
}

-(void)loadSelfWithCommentModel:(CommentModel*)commentModel{
    //获取用户头像
    self.userImageView=[[EGOImageView alloc]initWithPlaceholderImage:[UIImage imageNamed:@"首页_16.png"]];
    //self.userImageView=[[EGOImageView alloc]init];
    self.userImageView.frame=CGRectMake(15, 20, 50, 50);
    self.userImageView.showActivityIndicator=YES;
    [self addSubview:self.userImageView];
    
    //用户名称label
    self.userNameLabel=[[UILabel alloc]initWithFrame:CGRectMake(80, 15, 150, 20)];
    self.userNameLabel.text=commentModel.name;
    self.userNameLabel.font=[UIFont systemFontOfSize:20];
    //self.userNameLabel.backgroundColor=[UIColor redColor];
    [self addSubview:self.userNameLabel];
    
    //用户评论内容label
    CGRect bounds=[commentModel.content boundingRectWithSize:CGSizeMake(213, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];
    self.userCommentContent=[[UILabel alloc]initWithFrame:CGRectMake(80, 40, 213, bounds.size.height)];
    self.userCommentContent.numberOfLines=0;
    self.userCommentContent.font=[UIFont systemFontOfSize:17];
    self.userCommentContent.text=commentModel.content;
    self.userCommentContent.textColor=RGBCOLOR(86, 86, 86);
    [self addSubview:self.userCommentContent];
    
    CGFloat height=0;
    if (self.userCommentContent.frame.size.height>=25) {
        height=bounds.size.height+40+20;
    }else{
        height=90;
    }
    
    //用户发表评论时间
    self.publishTime=[[UILabel alloc]initWithFrame:CGRectMake(192, 15, 100, 20)];
    self.publishTime.text=commentModel.time;
    self.publishTime.textColor=RGBCOLOR(170, 170, 170);
    self.publishTime.font=[UIFont systemFontOfSize:16];
    self.publishTime.textAlignment=NSTextAlignmentRight;
    [self addSubview:self.publishTime];
    
    //分割线
    self.separatorLine.center=CGPointMake(154, height-.5);
    [self addSubview:self.separatorLine];
    
    
    self.frame=CGRectMake(6, 0, 308, height);
    self.backgroundColor=[UIColor whiteColor];
}

-(UIView *)separatorLine{
    if (!_separatorLine) {
        _separatorLine=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 308, 1)];
        _separatorLine.backgroundColor=RGBCOLOR(229, 229, 229);
    }
    return _separatorLine;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
@end

