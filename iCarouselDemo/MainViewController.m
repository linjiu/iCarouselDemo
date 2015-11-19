//
//  MainViewController.m
//  iCarouselDemo
//
//  Created by 09 on 15/11/19.
//  Copyright © 2015年 yifan. All rights reserved.
//

#define kHotUrl @"http://api.douban.com/v2/movie/in_theaters?count=100&udid=b6dcdfae53dd3e58ba9610bdf8e2e3cc40e3134b&start=0&client=s%3Amobile%7Cy%3AAndroid+4.4.2%7Co%3AKHHCNBF5.0%7Cf%3A70%7Cv%3A2.7.4%7Cm%3AWanDouJia_Parter%7Cd%3A865983026114430%7Ce%3AXiaomi+HM2014501&apikey=0b2bdeda43b5688921839c8ecb20399b&city=%E4%B8%8A%E6%B5%B7"

/**
 *  布局用
 */
#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define kBounds [UIScreen mainScreen].bounds

#define kFitWidth kWidth/375.0
#define kFitHeight kHeight/667.0

#import "MainViewController.h"
#import "MovieModel.h"
#import "BlurImageView.h"

#import "LORequestManger.h"
#import "UIImageView+WebCache.h"
#import "UIView+AdjustFrame.h"

#import "iCarousel.h"


@interface MainViewController ()<iCarouselDataSource, iCarouselDelegate, UIAccelerometerDelegate>

@property (nonatomic, strong) iCarousel *iCarouselV;

@property (nonatomic, strong) BlurImageView *backV;

@property (nonatomic, strong) NSMutableArray *Arr;//图片

// 保留x,y轴上面的速度
@property(nonatomic,assign)CGPoint velocity;


@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self handle];
    
    /**
     *  加速计
     */
    // 1.获取单例对象
    UIAccelerometer *acclerometer = [UIAccelerometer sharedAccelerometer];
    
    // 2.设置代理
    acclerometer.delegate = self;
    
    // 3.设置采样间隔
    acclerometer.updateInterval = 1 / 30.0;

}
- (void)handle {
    /**
     *  加载中
     */
    [LORequestManger GET:kHotUrl success:^(id response) {
        NSDictionary *dic = (NSDictionary *)response;
        for (NSDictionary *pic in dic[@"subjects"]) {
            MovieModel *model = [MovieModel shareJsonWithDictionary:pic];
            [self.Arr addObject:model.images];
        }
        [self setUp];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        /**
         *  alert 提醒可重新加载
         */
        [self warning];
    }];
    
}
//转动图片
- (void)setUp {
    /**
     *  设置背景图片
     */
    NSDictionary *dicImages = self.Arr[0];
    self.backV = [[BlurImageView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
    [self.backV sd_setImageWithURL:[NSURL URLWithString:dicImages[@"large"]]];
    [self.view addSubview:self.backV];

    /**
     iCarousel初始设置
     */
    self.iCarouselV = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, kWidth, 400 * kFitHeight)];
    self.iCarouselV.type = 1;
    self.iCarouselV.delegate = self;
    self.iCarouselV.dataSource = self;
    self.iCarouselV.pagingEnabled = YES;
    self.iCarouselV.scrollOffset = 0;
    [self.view addSubview:self.iCarouselV];

    
}
#pragma mark - iCarousel代理方法
- (NSInteger)numberOfItemsInCarousel:(iCarousel * __nonnull)carousel {
    return self.Arr.count;
}
- (UIView *)carousel:(iCarousel * __nonnull)carousel viewForItemAtIndex:(NSInteger)index reusingView:(nullable UIView *)view {
    
    NSDictionary *dicImages = self.Arr[index];
    
    if (view == nil) {
        view =[[UIImageView alloc] initWithFrame:CGRectMake(0, 50 * kFitHeight, 220 * kFitWidth,  300 * kFitHeight)];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50 * kFitHeight, 220 * kFitWidth, 300 * kFitHeight)];
    [imageView sd_setImageWithURL:[NSURL URLWithString:dicImages[@"large"]]];
    [view addSubview:imageView];
    return view;
}

//转动触发方法
- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    
    if (self.iCarouselV.scrollOffset == self.Arr.count) {
        self.iCarouselV.scrollOffset = self.Arr.count - 1;
    }
    NSDictionary *dic = self.Arr[(NSInteger)self.iCarouselV.scrollOffset];
    
    [self.backV sd_setImageWithURL:[NSURL URLWithString:dic[@"large"]]];
    
}

//提醒方法
- (void)warning
{
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:@"网络错误" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *freshAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"重新加载" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self handle];
    }];
    [alertC addAction:freshAction];
    [alertC addAction:cancelAction];
    [self presentViewController:alertC animated:YES completion:nil];
}
//懒加载
- (NSMutableArray *)Arr {
    if (!_Arr) {
        _Arr = [NSMutableArray array];
    }
    return _Arr;
}

/**
 *  获取到加速计信息的时候会调用该方法
 *
 *  @param acceleration  里面有x,y,z抽上面的加速度
 */
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    // NSLog(@"x:%f y:%f z:%f", acceleration.x, acceleration.y, acceleration.z);
    // 1.计算小球速度(对象的结构内部的属性是不能直接赋值)
    _velocity.x += acceleration.x;
    _velocity.y += acceleration.y;
    
    if (_velocity.x > 0) {
        self.iCarouselV.scrollOffset -= fabs(acceleration.x);
    }else {
        self.iCarouselV.scrollOffset += fabs(acceleration.x);
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
