//
//  ViewController.m
//  TestApp1
//
//  Created by Ian Ellison-Taylor on 6/5/15.
//  Copyright (c) 2015 Ian Ellison-Taylor. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property NSMutableString *text;

@end

@implementation ViewController {
    CLLocationManager *mLocationManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.text = [NSMutableString stringWithCapacity:100];
    [self.text appendString:@"Starting...\r\n"];
    [self.text appendString:@"Still starting...\r\n"];
    [self.textView setText:self.text];
    
    if (mLocationManager == nil) mLocationManager = [[CLLocationManager alloc] init];
    
    mLocationManager.delegate = self;
    mLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
    mLocationManager.distanceFilter = 10;
    
    if ([mLocationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [mLocationManager requestWhenInUseAuthorization];
    }
    
    [mLocationManager startUpdatingLocation];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self.text appendString:@"didUpdateLocations\r\n"];
    [self.textView setText:self.text];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.text appendString:@"didFailWithError\r\n"];
    [self.textView setText:self.text];
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error {
    [self.text appendString:@"didFinishDeferredUpdatesWithError"];
    [self.textView setText:self.text];
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    [self.text appendString:@"locationManagerDidPauseLocationUpdates"];
    [self.textView setText:self.text];
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    [self.text appendString:@"locationManagerDidResumeLocationUpdates"];
    [self.textView setText:self.text];
}

@end
