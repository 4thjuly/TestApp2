//
//  ViewController.h
//  TestApp1
//
//  Created by Ian Ellison-Taylor on 6/5/15.
//  Copyright (c) 2015 Ian Ellison-Taylor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end
