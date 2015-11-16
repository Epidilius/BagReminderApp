//
//  FirstViewController.h
//  BagReminderApp
//
//  Created by Joel Cright on 2015-11-04.
//  Copyright (c) 2015 Joel Cright. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMaps;

@interface FirstViewController : UIViewController

@property (strong, nonatomic) CLLocation* mOldLocation;
@property CLLocationDirection mOldHeading;

@property(strong, nonatomic) NSString* mLocation;
@property(strong, nonatomic) NSMutableArray* mArrayOfLocations;
@property CLLocationCoordinate2D mHomeCoordinates;
@property bool mDidGoToStore;
@property (strong, nonatomic) NSTimer* mTimer;

@property (strong, nonatomic) GMSPlacePicker* mPlacePicker;
@property (strong, nonatomic) GMSPlacePicker* mHomePicker;

@property (strong, nonatomic) NSString* HomeLocationSaveLocation;
@property (strong, nonatomic) NSString* StoreLocationsSaveLocation;

@property (weak, nonatomic) IBOutlet UIScrollView *UIScrollMainPage;
@property (weak, nonatomic) IBOutlet UITextField *HomeLocationTextBox;

@property (weak, nonatomic) IBOutlet UITableView *UITableMainPage;
@property (strong, nonatomic) CLLocationManager* mLocationManager;
@property (strong, nonatomic) GMSPlacesClient* mLocationClient;

@end

