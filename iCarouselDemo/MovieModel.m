//
//  HotReleased.m
//  地图项目
//
//  Created by 09 on 15/11/9.
//  Copyright © 2015年 yifan. All rights reserved.
//

#import "MovieModel.h"

@implementation MovieModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        self.ID = value;
    }
}

+ (MovieModel *)shareJsonWithDictionary:(NSDictionary *)dictionary {
    MovieModel *model = [[MovieModel alloc] init];
    [model setValuesForKeysWithDictionary:dictionary];

    return model;
}

@end
