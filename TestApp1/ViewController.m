//
//  ViewController.m
//  TestApp1
//
//  Created by Ian Ellison-Taylor on 6/5/15.
//  Copyright (c) 2015 Ian Ellison-Taylor. All rights reserved.
//

// TODO
// Add menu items for geo and scan
// Try using characteristic data to share id
// Add BTLE Central role

#import "ViewController.h"

@interface ViewController ()

@end


@implementation ViewController {
    CLLocationManager *mLocationManager;
    CBPeripheralManager *mPeripheralManager;
    NSMutableString *mText;
    CBCentralManager *mCentralManager;
    CBUUID *kServiceUUID;
}

enum {
    kGeoScanTag = 1,
    kBTLEAdvertiseTag,
    kBTLEScanTag
};

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
    kServiceUUID = [CBUUID UUIDWithString:@"CE5C0BF3-B9B0-4A22-847B-74834A70BB93"];
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

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheralManager {
    [self updateStatusText:@"peripheralManagerDidUpdateState"];
    
    CBUUID *extraUUID1 = [CBUUID UUIDWithString:@"01234567"]; // TODO - Random number
    //CBUUID *extraUUID2 = [CBUUID UUIDWithString:@"89ABCDEF"]; // TODO - Random number
    //CBUUID *characteristicUUID = [CBUUID UUIDWithString:@"EF72F7D6-D68C-4F5C-8D89-50BEBC66681A"];
    //UInt32 id  = 0xA0B0C0D0;
    
    // FYI - Setting the service isn't necessary if you're just advertising
    CBMutableService *service = [[CBMutableService alloc] initWithType:kServiceUUID primary:YES];
// FYI - Skip using a characteristic value, it's kinda slow to read. Just stick with random service UUID
//    CBMutableCharacteristic *characteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID
//        properties:CBCharacteristicPropertyRead value:[NSData dataWithBytes:&id length:sizeof(id)]
//        permissions:CBAttributePermissionsReadable];
//    service.characteristics = @[characteristic];
    
    [mPeripheralManager addService:service];
    
    
    if (peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        [self updateStatusText:@"peripheralManagerDidUpdateState: State On"];
        if (peripheralManager.isAdvertising) {
            [self updateStatusText:@"peripheralManagerDidUpdateState: Already Avertising"];
        } else {
            [self updateStatusText:@"peripheralManagerDidUpdateState: startAdvertising"];
            [peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey : @[kServiceUUID, extraUUID1], CBAdvertisementDataLocalNameKey:@"CARD: Testing"}];
        }
    } else {
        [self updateStatusText:@"peripheralManagerDidUpdateState: State off"];
    }
    
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    [self updateStatusText:@"didAddService"];

    if (error) {
        NSLog(@"Error publishing service: %@", [error localizedDescription]);
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    if (error) {
        NSLog(@"Error advertising: %@", [error localizedDescription]);
        [self updateStatusText:@"peripheralManagerDidStartAdvertising: Error"];
    } else {
        [self updateStatusText:@"peripheralManagerDidStartAdvertising"];
    }
}

- (IBAction)doToolbarAction:(UIButton*)sender {
    [self updateStatusText:[NSString stringWithFormat:@"Action: %ld", (long)sender.tag]];
    
    if (sender.tag == kGeoScanTag) {
        // Location
        if (mLocationManager == nil) mLocationManager = [[CLLocationManager alloc] init];
        
        mLocationManager.delegate = self;
        mLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
        mLocationManager.distanceFilter = 10;
        
        if ([mLocationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [mLocationManager requestWhenInUseAuthorization];
        }
        
        [mLocationManager startUpdatingLocation];
        // TODO - stop after 30s
    }
    
    if (sender.tag == kBTLEAdvertiseTag) {
        if (mPeripheralManager == nil) {
        mPeripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:@{CBPeripheralManagerOptionShowPowerAlertKey:@YES}];
        }
    }
    
    if (sender.tag == kBTLEScanTag) {
        if (mCentralManager == nil) {
            // NB - This is untested, need a device that can act as a beacon
            mCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey:@YES}];
            //[mCentralManager scanForPeripheralsWithServices:@[kServiceUUID] options:nil];
        }
    }
    
}

- (void)respondToRequest:(CBATTRequest *)request withResult:(CBATTError)result {
    [self updateStatusText:@"respondToRequest"];
    
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    [self updateStatusText:@"didReceiveReadRequest"];
  
//    request.value = [request.characteristic.value
//                     subdataWithRange:NSMakeRange(request.offset, request.characteristic.value.length - request.offset)];
//    [mPeripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    [self updateStatusText:@"didDiscoverPeripheral"];
    [self updateStatusText:[NSString stringWithFormat:@"Name: %@", peripheral.name]];
    [self updateStatusText:[NSString stringWithFormat:@"RSSI: %@", RSSI]];
    [self updateStatusText:[NSString stringWithFormat:@"Manufacturer Data: %@", advertisementData[CBAdvertisementDataManufacturerDataKey]]];
    [self updateStatusText:[NSString stringWithFormat:@"Service Data: %@", advertisementData[CBAdvertisementDataServiceDataKey]]];
    [self updateStatusText:[NSString stringWithFormat:@"UUIDs: %@", advertisementData[CBAdvertisementDataServiceUUIDsKey    ]]];
    
//    for (CBService *service in peripheral.services) {
//        [self updateStatusText:[NSString stringWithFormat:@"Service: %@", service]];
//    }
    //TODO Stop scanning after a certain timeout
    //[mCentralManager stopScan];

}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    [self updateStatusText:[NSString stringWithFormat:@"centralManagerDidUpdateState: %ld", (long)central.state]];
    
    if (central.state == CBCentralManagerStatePoweredOn) {
        [self updateStatusText:@"centralManager: Powered On"];
        [self updateStatusText:@"Starting scanning..."];
        [mCentralManager scanForPeripheralsWithServices:nil options:nil];
    }

}

@end
