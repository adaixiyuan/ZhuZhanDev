//
//  PersonalCenterModel.m
//  ZhuZhan
//
//  Created by 汪洋 on 14-9-28.
//
//

#import "PersonalCenterModel.h"
#import "ProjectStage.h"
@implementation PersonalCenterModel

- (void)setDict:(NSDictionary *)dict{
    _dict = dict;
    
    self.a_id = [ProjectStage ProjectStrStage:dict[@"id"]];
    self.a_entityId = [ProjectStage ProjectStrStage:dict[@"entityId"]];
    self.a_entityUrl = [ProjectStage ProjectStrStage:dict[@"entityUrl"]];
    self.a_entityName = [ProjectStage ProjectStrStage:dict[@"entityName"]];
    self.a_projectStage = [ProjectStage ProjectStrStage:dict[@"projectStage"]];
    self.a_time = [ProjectStage ProjectDateStage:dict[@"createdTime"]];
    self.a_content = [ProjectStage ProjectStrStage:dict[@"content"]];
    self.a_imageUrl = [ProjectStage ProjectStrStage:dict[@"imageLocation"]];
    self.a_category = [ProjectStage ProjectStrStage:dict[@"category"]];
    self.a_imageWidth = [ProjectStage ProjectStrStage:[NSString stringWithFormat:@"%@",dict[@"imageWidth"]]];
    self.a_imageHeight = [ProjectStage ProjectStrStage:[NSString stringWithFormat:@"%@",dict[@"imageHeight"]]];
    self.a_avatarUrl = [ProjectStage ProjectStrStage:dict[@"avatarUrl"]];
    self.a_userName = [ProjectStage ProjectStrStage:dict[@"userName"]];
}
@end
