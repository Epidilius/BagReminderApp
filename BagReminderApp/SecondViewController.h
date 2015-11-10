//
//  SecondViewController.h
//  BagReminderApp
//
//  Created by Joel Cright on 2015-11-04.
//  Copyright (c) 2015 Joel Cright. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMaps;

@interface SecondViewController : UIViewController

@property (strong, nonatomic) CLLocation* mLocationManager;
@property (strong, nonatomic) GMSPlacesClient* mLocationClient;
@property (strong, nonatomic) GMSPlacePicker* mPlacePicker;

@property (weak, nonatomic) IBOutlet UIView *MapView;
@property (weak, nonatomic) IBOutlet UIView *MapContainer;
@property (weak, nonatomic) IBOutlet UIButton *SearchButton;
@property (weak, nonatomic) IBOutlet UITextField *SearchText;
@property (strong, nonatomic) NSMutableArray* MarkerArray;

@end

