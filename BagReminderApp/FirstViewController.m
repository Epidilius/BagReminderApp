//
//  FirstViewController.m
//  BagReminderApp
//
//  Created by Joel Cright on 2015-11-04.
//  Copyright (c) 2015 Joel Cright. All rights reserved.
//

#import "FirstViewController.h"
#import "LocationStruct.h"
@import GoogleMaps;

//TODO: Swipe to delete
//TODO: Location based logic
    //Make a background service
    //Have it monitor user location and compare to the active locations in the list
    //When close, send notification and switch a bool titled "mHasBeenToStore"
        //Users can go to multiple stores this way, and be notified every time
    //When the user gets home, if the bool is YES send a notifciation and start a 5 minute timer to send a second one
        //Cancel the timer if they click the notification


//dataUsingEncoding:NSUTF8StringEncoding

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mArrayOfLocations = [[NSMutableArray alloc] init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    
    self.HomeLocationSaveLocation = [documentsPath stringByAppendingString:@"\\HomeLocation"];
    self.StoreLocationsSaveLocation = [documentsPath stringByAppendingString:@"\\StoreLocations"];
    
    [self CreateDirectory:self.HomeLocationSaveLocation];
    [self CreateDirectory:self.StoreLocationsSaveLocation];
    
    self.HomeLocationSaveLocation = [self.HomeLocationSaveLocation stringByAppendingString:@".txt"];
    self.StoreLocationsSaveLocation = [self.StoreLocationsSaveLocation stringByAppendingString:@".txt"];
    
    self.mOldHeading = nil;
    self.mOldLocation = nil;
    
    self.mLocation = @"";
    self.mLocationClient = [[GMSPlacesClient alloc] init];
    self.mLocationManager = [[CLLocationManager alloc] init];
    
    [self.mLocationManager setDelegate:self];
    [self.mLocationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [self.mLocationManager setDistanceFilter:1.0f];
    [self.mLocationManager setHeadingFilter:40.0f];
    [self.mLocationManager setPausesLocationUpdatesAutomatically:YES];
    [self.mLocationManager setActivityType:CLActivityTypeOther];
    
    [self.mLocationManager requestAlwaysAuthorization];
    
    [self.mLocationManager startUpdatingLocation];
    [self.mLocationManager startUpdatingHeading];
    //self.mLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //self.mLocationManager.distanceFilter = 1.0f;
    //self.mLocationManager.headingFilter = 5;
    
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(LoadButtonsAndHome)
                                   userInfo:nil
                                    repeats:NO];
    
    [self SetLocationCallback];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        self.mLocationManager = [[CLLocationManager alloc]init];
        [self.mLocationManager setDelegate:self];
        [self.mLocationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        [self.mLocationManager setDistanceFilter:1.0f];
        [self.mLocationManager setHeadingFilter:40.0f];
        [self.mLocationManager setPausesLocationUpdatesAutomatically:YES];
        [self.mLocationManager setActivityType:CLActivityTypeOther];
    }    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.mLocationManager startMonitoringSignificantLocationChanges];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if(self.mLocationManager)
        [self.mLocationManager stopMonitoringSignificantLocationChanges];
    
    self.mLocationManager = [[CLLocationManager alloc]init];
    [self.mLocationManager setDelegate:self];
    [self.mLocationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [self.mLocationManager setDistanceFilter:1.0f];
    [self.mLocationManager setHeadingFilter:40.0f];
    [self.mLocationManager setPausesLocationUpdatesAutomatically:YES];
    [self.mLocationManager setActivityType:CLActivityTypeOther];
    
    [self.mLocationManager startMonitoringSignificantLocationChanges];
}

- (void)LoadButtonsAndHome {
    [self LoadFile:self.HomeLocationSaveLocation HomeOrNot:YES];
    [self LoadFile:self.StoreLocationsSaveLocation HomeOrNot:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)SetHomeButton:(id)sender {
    
    self.HomeLocationTextBox.text = self.mLocation;
    [self SaveFileWithData:self.mLocation Directory:self.HomeLocationSaveLocation];
}

- (IBAction)AddNewLocation:(id)sender {
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(51.5108396, -0.0922251);
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001);
    CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001);
    GMSCoordinateBounds *viewport = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast
                                                                         coordinate:southWest];
    GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:viewport];
    self.mPlacePicker = [[GMSPlacePicker alloc] initWithConfig:config];
    
    [self.mPlacePicker pickPlaceWithCallback:^(GMSPlace *place, NSError *error) {
        if (error != nil) {
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            return;
        }
        
        if (place != nil) {
            NSLog(@"Place name %@", place.name);
            NSLog(@"Place address %@", place.formattedAddress);
            NSLog(@"Place attributions %@", place.attributions.string);
            
            [self AddLocationWithID:self.mArrayOfLocations.count PlaceID:place.placeID PlaceName: place.name OnOff:YES Latitude:place.coordinate.latitude Longitude:place.coordinate.longitude Address:place.formattedAddress FromLoadFunction:NO];
        } else {
            NSLog(@"No place selected");
        }
    }];
}

-(void)AddLocationWithID:(int)aObjID PlaceID:(NSString*)aPlaceID PlaceName: (NSString*) aName OnOff:(bool)aOnOff Latitude:(float)aLat Longitude:(float)aLng Address:(NSString*)aAddress FromLoadFunction:(bool)aFromLoad {
    LocationStruct *locStruct = [[LocationStruct alloc] init];
    
    if(aAddress == nil)
        aAddress = @"No Address";
    
    UISwitch* toggle = [self AddLocationToContainer:aName WithState:aOnOff];
    
    [locStruct setObjID:aObjID];
    [locStruct setPlaceID:aPlaceID];
    [locStruct setPlaceName:aName];
    [locStruct setOnOff:toggle];
    [locStruct setLat:aLat];
    [locStruct setLng:aLng];
    [locStruct setAddress:aAddress];
    
    [self.mArrayOfLocations addObject:locStruct];
    
    if(!aFromLoad)
        [self AppendToFileWithData:[locStruct ToString] Directory:self.StoreLocationsSaveLocation];
}

-(void)SetLocationCallback {
    [self.mLocationClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *likelihoodList, NSError *error) {
        if (error != nil) {
            NSLog(@"Current Place error %@", [error localizedDescription]);
            return;
        }
        
        if (likelihoodList != nil) {
            GMSPlace *place = [[[likelihoodList likelihoods] firstObject] place];
            if (place != nil) {
                NSLog(@"Place Name: ", place.name);
                self.mLocation = [[place.formattedAddress componentsSeparatedByString:@", "]
                                          componentsJoinedByString:@"\n"];
            }
        }
        
    }];

}

-(bool)CheckIfFileExists:(NSString*)aDir {
    if ([[NSFileManager defaultManager] fileExistsAtPath:aDir])
    {
        return true;
    }
    else
    {
        return false;
    }
}

-(bool)SaveFileWithData:(NSString*)aFileData Directory:(NSString*)aDir {
    NSData* theData = [aFileData dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:aDir])		//Does file exist?
    {
        if (![[NSFileManager defaultManager] removeItemAtPath:aDir error:&error])	//Delete it
        {
            NSLog(@"Delete file error: %@", error);
        }
    }
    
    bool didFileSave = [[NSFileManager defaultManager] createFileAtPath:aDir
                                                  contents:theData
                                                attributes:nil];
    
    return didFileSave;
}

-(void)LoadFile:(NSString*)aDir HomeOrNot:(bool)aHome {
    if ([[NSFileManager defaultManager] fileExistsAtPath:aDir])
    {
        //File exists
        NSData *file = [[NSData alloc] initWithContentsOfFile:aDir];
        if (file)
        {
            if(aHome)
            {
                NSString* homeStr = [[NSString alloc] initWithData:file encoding:NSUTF8StringEncoding];
                
                self.HomeLocationTextBox.text = homeStr;
                self.mLocation = homeStr;
            }
            else
            {
                NSString* locStr = [[NSString alloc] initWithData:file encoding:NSUTF8StringEncoding];
                NSArray* locStringArray = [locStr componentsSeparatedByString:@"EOL"];
                for(int i = 0; i < locStringArray.count; i++)
                {
                    NSArray* locSingle = [[locStringArray objectAtIndex:i] componentsSeparatedByString:@"|"];
                    //0 = ID
                    //1 = Place ID
                    //2 = On/Off
                    //3 = Latitude
                    //4 = Longitude
                    //5 = Address
                    if(![[locSingle objectAtIndex:0] isEqual: @""])
                    {
                        int idInt = [locSingle[0] intValue];
                        NSString* placeID = locSingle[1];
                        NSString* placeName = locSingle[2];
                        bool isOnOrOff = YES;
                        if([locSingle[3]  isEqual: @"NO"])
                            isOnOrOff = NO;
                        float lat = [locSingle[4] floatValue];
                        float lng = [locSingle[5] floatValue];
                        NSString* address = locSingle[6];
                    
                        [self AddLocationWithID:idInt PlaceID:placeID PlaceName:placeName OnOff:isOnOrOff Latitude:lat Longitude:lng Address:address FromLoadFunction:YES];
                    }
                }
            }
        }
    }
    else
    {
        NSLog(@"File does not exist");
    }
}

-(void)AppendToFileWithData:(NSString*)aFileData Directory:(NSString*)aDir {
    if ([[NSFileManager defaultManager] fileExistsAtPath:aDir])
    {
        //File exists
        NSData *file = [[NSData alloc] initWithContentsOfFile:aDir];
        if (file)
        {
            NSString* fileString = [[NSString alloc] initWithData:file encoding:NSUTF8StringEncoding];
            
            fileString = [fileString stringByAppendingString:aFileData];
            
            [self SaveFileWithData:fileString Directory:aDir];
        }
    }
    else
    {
        NSLog(@"File does not exist");
        [self SaveFileWithData:aFileData Directory:aDir];
    }

}

-(void)SwapData:(NSString*)aFileData AtID:(int)aID Directory:(NSString*)aDir {
    if ([[NSFileManager defaultManager] fileExistsAtPath:aDir])
    {
        //File exists
        NSData *file = [[NSData alloc] initWithContentsOfFile:aDir];
        if (file)
        {
            NSString* fileString = [[NSString alloc] initWithData:file encoding:NSUTF8StringEncoding];
            
            NSMutableArray* locStringArray = [fileString componentsSeparatedByString:@"EOL"];
            [locStringArray replaceObjectAtIndex:aID withObject:aFileData];
            
            fileString = @"";
            
            for(int i = 0; i < locStringArray.count; i++)
            {
                NSString* toAppend = [locStringArray objectAtIndex:i];
                fileString = [fileString stringByAppendingString:toAppend];
                if(![toAppend isEqual:@""])
                    if(![toAppend containsString:@"EOL"])
                        fileString = [fileString stringByAppendingString:@"EOL"];
            }
            
            [self SaveFileWithData:fileString Directory:aDir];
        }
    }
    else
    {
        NSLog(@"File does not exist");
    }
}

- (void)setState:(id)sender
{
    for(int i = 0; i < self.mArrayOfLocations.count; i++)
    {
        if([[[self.mArrayOfLocations objectAtIndex:i] getOnOff] isEqual:sender])
        {
            LocationStruct *temp = [self.mArrayOfLocations objectAtIndex:i];
            [self SwapData:[temp ToString] AtID:[temp getID] Directory:self.StoreLocationsSaveLocation];
            [self.mArrayOfLocations replaceObjectAtIndex:i withObject:temp];
        }
    }
}

-(UISwitch*)AddLocationToContainer:(NSString*)aAddress WithState:(bool)aState{
    CGRect buttonFrame = CGRectMake(5.0f, 5.0f, 10.0f, 40.0f);
    CGRect textFrame = CGRectMake(5.0f, 5.0f, self.UIScrollMainPage.frame.size.width-100.0f, 40.0f);\
    
    buttonFrame.origin.x = self.UIScrollMainPage.frame.size.width-50.0f;
    buttonFrame.origin.y += self.mArrayOfLocations.count * 40.0f;
    
    textFrame.origin.y += self.mArrayOfLocations.count * 40.0f;
        
    UISwitch *toggle = [[UISwitch alloc] init];
    [toggle setFrame:buttonFrame];
    [toggle setTag:self.mArrayOfLocations.count];
    [toggle setOn:aState];
    [toggle addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
    
    UITextField* text = [[UITextField alloc] init];
    [text setFrame:textFrame];
    [text setText:aAddress];
    [text setEnabled:NO];
    [text setTag:self.mArrayOfLocations.count];
    
    [self.UIScrollMainPage addSubview:toggle];
    [self.UIScrollMainPage addSubview:text];
    
    CGSize contentSize = self.UIScrollMainPage.frame.size;//[UIScreen mainScreen].applicationFrame.size;
    contentSize.height = buttonFrame.origin.y;
    [self.UIScrollMainPage setContentSize:contentSize];
    
    return toggle;
}

-(void)CreateDirectory:(NSString*)aDir {
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:aDir])	//Does directory already exist?
    {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:aDir
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&error])
        {
            NSLog(@"Create directory error: %@", error);
        }
    }
}

//Location Stuff
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        if(![self.mOldLocation isEqual:nil])
        {
            //TODO: Distance check? No, I don't think thta is necessary
            if(![self.mOldHeading isEqual:nil])
            {
                //Heading check to see if the angle was sharp enough
            }
            else
            {
                //Set the heading because it is nil
            }
        }
        else
        {
            //Set the location because it is nil
        }
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Unable to start location manager. Error:%@", [error description]);
}

@end
