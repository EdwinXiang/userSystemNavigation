//
//  ViewController.m
//  调用系统导航
//
//  Created by Edwin on 16/3/23.
//  Copyright © 2016年 EdwinXiang. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
@interface ViewController ()<CLLocationManagerDelegate>
@property (nonatomic,strong)CLGeocoder *geocoder;
@property (nonatomic,strong)CLLocationManager *manager;
@property (nonatomic,copy)NSString *userLocation;
@end
@implementation ViewController

-(CLLocationManager *)manager{
    if (_manager == nil) {
        _manager = [[CLLocationManager alloc]init];
    }
    return _manager;
}

-(CLGeocoder *)geocoder{
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc]init];
    }
    return _geocoder;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.manager.delegate = self;
    self.manager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.manager requestAlwaysAuthorization];
    [self.manager startUpdatingLocation];
    
   
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    MKPointAnnotation *ann = [[MKPointAnnotation alloc]init];
    CLLocation *loc = [locations firstObject];
    CLGeocoder *gecoder = [[CLGeocoder alloc]init];
    [gecoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks.count == 0 ||error) {
            NSLog(@"解析失败");
        }else if (placemarks.count>0){
            CLPlacemark *pm = [placemarks firstObject];
            if (pm.locality) {
                ann.title = pm.locality ;
                NSLog(@"local = %@,subtitle = %@,name = %@",pm.locality,pm.subLocality,pm.name);
                self.userLocation = pm.name;
                //导航
                [self userSystemNavigationMap];
                ann.subtitle = pm.name;
                
            }else{
                ann.title = pm.administrativeArea;
                ann.subtitle = pm.name;
            }
        }
    }];
    
}

-(void)userSystemNavigationMap{
    [self.geocoder geocodeAddressString:self.userLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        MKPlacemark *startPlacemark = [[MKPlacemark alloc]initWithPlacemark:[placemarks firstObject]];
#warning 终点坐标需要自己手动输入  @"高升桥"
        [self.geocoder geocodeAddressString:@"成都市武侯区高升桥七道堰街" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            MKPlacemark *endPlacemark = [[MKPlacemark alloc]initWithPlacemark:[placemarks firstObject]];
            
            /**
             将MKPlaceMark转换成MKMapItem，这样可以放入到item这个数组中
             
             */
            MKMapItem *startItem = [[MKMapItem alloc ] initWithPlacemark:startPlacemark];
            MKMapItem *endItem = [[MKMapItem alloc ] initWithPlacemark:endPlacemark];
            
            NSArray *item = @[startItem ,endItem];
            
            //建立字典存储导航的相关参数
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[MKLaunchOptionsDirectionsModeKey] = MKLaunchOptionsDirectionsModeDriving;
            dict[MKLaunchOptionsMapTypeKey] = [NSNumber numberWithInteger:MKMapTypeStandard];
            
            /**
             *调用app自带导航，需要传入一个数组和一个字典，数组中放入MKMapItem，
             字典中放入对应键值
             MKLaunchOptionsDirectionsModeKey   开启导航模式
             MKLaunchOptionsMapTypeKey  地图模式
             MKMapTypeStandard = 0,
             MKMapTypeSatellite,
             MKMapTypeHybrid
             
             // 导航模式
             MKLaunchOptionsDirectionsModeDriving 开车;
             MKLaunchOptionsDirectionsModeWalking 步行;
             */
#warning 其实所有的代码都是为了下面一句话，打开系统自带的高德地图然后执行某些动作，launchOptions里面的参数指定做哪些动作
            [MKMapItem openMapsWithItems:item launchOptions:dict];
        }];
        
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
