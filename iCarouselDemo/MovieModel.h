//
//  HotReleased.h
//  地图项目
//
//  Created by 09 on 15/11/9.
//  Copyright © 2015年 yifan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MovieModel : NSObject

@property (nonatomic, strong) NSDictionary *rating;
@property (nonatomic, strong) NSNumber *collect_count;
@property (nonatomic, strong) NSString *mainland_pubdate;
@property (nonatomic, strong) NSString *original_title;
@property (nonatomic, strong) NSArray *genres;
@property (nonatomic, strong) NSDictionary *images;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *casts;
@property (nonatomic, strong) NSArray *durations;
@property (nonatomic, strong) NSArray *directors;
@property (nonatomic, strong) NSArray *pubdates;
@property (nonatomic, strong) NSString *ID;

+ (MovieModel *)shareJsonWithDictionary:(NSDictionary *)dictionary;

@end
