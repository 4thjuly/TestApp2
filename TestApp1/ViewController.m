//
//  ViewController.m
//  TestApp1
//
//  Created by Ian Ellison-Taylor on 6/5/15.
//  Copyright (c) 2015 Ian Ellison-Taylor. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    CLLocationManager *mLocationManager;
    CBPeripheralManager *mPeripheralManager;
    NSMutableString *mText;
}

- (void)updateStatusText:(NSString*)text {
    [mText appendString:[NSString stringWithFormat:@"%@\r\n", text]];
    [self.textView setText:mText];
    [self.textView scrollRangeToVisible: NSMakeRange(mText.length, 0)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    mText = [NSMutableString stringWithCapacity:100];
    [self updateStatusText:@"Starting..."];
    
    // Location
    if (mLocationManager == nil) mLocationManager = [[CLLocationManager alloc] init];
    
    mLocationManager.delegate = self;
    mLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
    mLocationManager.distanceFilter = 10;
    
    if ([mLocationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [mLocationManager requestWhenInUseAuthorization];
    }
    
    // TODO - Add a 30s timer
    [mLocationManager startUpdatingLocation];
    
    // Bluetooth LE
    mPeripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self updateStatusText:@"didUpdateLocations..."];

    CLLocation *location = [locations lastObject];
    [self updateStatusText:location.description];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self updateStatusText:@"didFailWithError"];
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error {
    [self updateStatusText:@"didFinishDeferredUpdatesWithError"];
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    [self updateStatusText:@"locationManagerDidPauseLocationUpdates"];
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    [self updateStatusText:@"locationManagerDidResumeLocationUpdates"];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self updateStatusText:@"didChangeAuthorizationStatus"];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    [self updateStatusText:@"peripheralManagerDidUpdateState"];
    
    // TODO - Is this necessary?
    CBUUID *serviceUUID = [CBUUID UUIDWithString:@"CE5C0BF3-B9B0-4A22-847B-74834A70BB93"];
    CBMutableService *service = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
    [mPeripheralManager addService:service];
    
    [mPeripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey : @[serviceUUID], CBAdvertisementDataLocalNameKey:@"CARD"}];
    
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    [self updateStatusText:@"didAddService"];

    if (error) {
        NSLog(@"Error publishing service: %@", [error localizedDescription]);
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    [self updateStatusText:@"peripheralManagerDidStartAdvertising"];

    if (error) {
        NSLog(@"Error advertising: %@", [error localizedDescription]);
    }
}

@end
