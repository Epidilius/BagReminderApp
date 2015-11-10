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
//TODO: Install to phone, test it out!
//TODO: Add two buttons to test notifs.
    //Or just have the two that are there do that
    //Have them call the notifs function, then return

//dataUsingEncoding:NSUTF8StringEncoding

@interface FirstViewController ()

@end

@implementation FirstViewController

enum {
    kTagTextView = 1000,
    kTagButton = 2000,
    kTagToggle = 3000,
};

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mArrayOfLocations = [[NSMutableArray alloc] init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    
    self.HomeLocationSaveLocation = [documentsPath stringByAppendingString:@"/HomeLocation"];
    self.StoreLocationsSaveLocation = [documentsPath stringByAppendingString:@"/StoreLocations"];
    
    [self CreateDirectory:self.HomeLocationSaveLocation];
    [self CreateDirectory:self.StoreLocationsSaveLocation];
    
    self.HomeLocationSaveLocation = [self.HomeLocationSaveLocation stringByAppendingString:@".txt"];
    self.StoreLocationsSaveLocation = [self.StoreLocationsSaveLocation stringByAppendingString:@".txt"];
    
    self.mOldHeading = -1;
    self.mOldLocation = nil;
    self.mHomeCoordinates = CLLocationCoordinate2DMake(0, 0);
    self.mDidGoToStore = NO;
    
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
    
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(LoadButtonsAndHome)
                                   userInfo:nil
                                    repeats:NO];
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
    //TODO: Cancel notifs
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
    
    [self SetLocationCallback];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)SetHomeButton:(id)sender {
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(51.5108396, -0.0922251);
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001);
    CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001);
    GMSCoordinateBounds *viewport = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast
                                                                         coordinate:southWest];
    GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:viewport];
    self.mHomePicker = [[GMSPlacePicker alloc] initWithConfig:config];
    
    [self.mHomePicker pickPlaceWithCallback:^(GMSPlace *place, NSError *error) {
        if (error != nil) {
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            return;
        }
        
        if (place != nil) {
            NSLog(@"Place name %@", place.name);
            NSLog(@"Place address %@", place.formattedAddress);
            NSLog(@"Place attributions %@", place.attributions.string);
            
            [self SetHomeLocation:place.formattedAddress
                         Latitude:place.coordinate.latitude
                        Longitude:place.coordinate.longitude];
            
        } else {
            NSLog(@"No place selected");
        }
    }];
}

- (void)SetHomeLocation:(NSString*)aHomeLoc Latitude:(float)aLat Longitude:(float)aLng {
    self.HomeLocationTextBox.text = aHomeLoc;
    self.mLocation = aHomeLoc;
    
    self.mHomeCoordinates = CLLocationCoordinate2DMake(aLat, aLng);
    
    NSString* lat = [NSString stringWithFormat:@"%f", self.mHomeCoordinates.latitude];
    NSString* lng = [NSString stringWithFormat:@"%f", self.mHomeCoordinates.longitude];
    
    NSString* textToSave = [self.mLocation stringByAppendingString:@"|"];
    textToSave = [textToSave stringByAppendingString:lat];
    textToSave = [textToSave stringByAppendingString:@"|"];
    textToSave = [textToSave stringByAppendingString:lng];
    
    [self SaveFileWithData:textToSave Directory:self.HomeLocationSaveLocation];
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
                self.mHomeCoordinates = place.coordinate;
                //self.mLocation = [[place.formattedAddress componentsSeparatedByString:@", "] componentsJoinedByString:@"\n"];
                self.mLocation = place.name;
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
                
                NSArray* splitHome = [homeStr componentsSeparatedByString:@"|"];
                //0 = Locatin
                //1 = Latitude
                //2 = Longitude
                
                self.HomeLocationTextBox.text = [splitHome objectAtIndex:0];
                self.mLocation = [splitHome objectAtIndex:0];
                
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
                
                float lat = [numberFormatter numberFromString:[splitHome objectAtIndex:1]].floatValue;
                float lng = [numberFormatter numberFromString:[splitHome objectAtIndex:2]].floatValue;
                
                self.mHomeCoordinates = CLLocationCoordinate2DMake(lat, lng);
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
            int idToSwap = -1;
            NSString* fileString = [[NSString alloc] initWithData:file encoding:NSUTF8StringEncoding];
            
            NSMutableArray* locStringArray = [fileString componentsSeparatedByString:@"EOL"];
            
            for(int i = 0; i < locStringArray.count; i++)
            {
                NSArray* locSingle = [[locStringArray objectAtIndex:i] componentsSeparatedByString:@"|"];
                //0 = ID
                if([[locSingle objectAtIndex:0] intValue] == aID)
                {
                    idToSwap = i;
                    break;
                }

            }
            [locStringArray replaceObjectAtIndex:idToSwap withObject:aFileData];
            
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

-(void)deleteButton:(id)sender {
    //TODO: Ask for confiramtion, use address
    // kTagTextView = 1000,
    //kTagButton = 2000,
    //kTagToggle = 3000,
    
    float tagButton = [sender tag];
    float tagText = tagButton - 1000.0f;
    float tagToggle = tagButton + 1000.0f;
    
    float idToSwap = -1.0f;
    int index = -1;
    
    for(int i = 0; i < self.mArrayOfLocations.count; i++)
    {
        if([[[self.mArrayOfLocations objectAtIndex:i] getOnOff] tag] == tagToggle)
        {
            idToSwap = [[self.mArrayOfLocations objectAtIndex:i] getID];
            index = i;
            break;
        }
    }
    
    
    for(UIView* subview in [self.UIScrollMainPage subviews])
    {
        CGRect frame;
        
        if([subview isKindOfClass:[UITextView class]])
        {
            if([subview tag] > tagText)
            {
                int tag = [subview tag];
                
                //Start with UITextView
                frame = [self.UIScrollMainPage viewWithTag:(tag)].frame;
                frame.origin.y -= 40;
                [[self.UIScrollMainPage viewWithTag:(tag)] setFrame:frame];
            }
        }
        
        else if([subview isKindOfClass:[UIButton class]])
        {
            if([subview tag] > tagButton)
            {
                int tag = [subview tag];
                
                //Then Button
                frame = [self.UIScrollMainPage viewWithTag:(tag)].frame;
                frame.origin.y -= 40;
                [[self.UIScrollMainPage viewWithTag:(tag)] setFrame:frame];
            }
        }
        else if([subview isKindOfClass:[UISwitch class]])
        {
            if([subview tag] > tagToggle)
            {
                int tag = [subview tag];
                
                //Finally Toggle
                frame = [self.UIScrollMainPage viewWithTag:(tag)].frame;
                frame.origin.y -= 40;
                [[self.UIScrollMainPage viewWithTag:(tag)] setFrame:frame];
            }
        }
        //TODO: Make this work
    }
    
    [[self.UIScrollMainPage viewWithTag:tagButton]removeFromSuperview];
    [[self.UIScrollMainPage viewWithTag:tagText]removeFromSuperview];
    [[self.UIScrollMainPage viewWithTag:tagToggle]removeFromSuperview];
    
    [self.mArrayOfLocations removeObjectAtIndex:index];
    
    [self SwapData:@"" AtID:idToSwap Directory:self.StoreLocationsSaveLocation];
    
    //TODO: Refresh
}

-(UISwitch*)AddLocationToContainer:(NSString*)aAddress WithState:(bool)aState{
    CGRect buttonFrame = CGRectMake(5.0f, 5.0f, 25.0f, 25.0f);
    CGRect toggleFrame = CGRectMake(5.0f, 5.0f, 10.0f, 40.0f);
    CGRect textFrame = CGRectMake(5.0f, 5.0f, self.UIScrollMainPage.frame.size.width-100.0f, 40.0f);\
    
    //Setting Height
    toggleFrame.origin.x = self.UIScrollMainPage.frame.size.width-50.0f;
    toggleFrame.origin.y += self.mArrayOfLocations.count * 40.0f;
    
    textFrame.origin.y += self.mArrayOfLocations.count * 40.0f;
    
    buttonFrame.origin.x = toggleFrame.origin.x-40.0f;
    buttonFrame.origin.y += toggleFrame.origin.y;
    
    //Make the toggle
    UISwitch *toggle = [[UISwitch alloc] init];
    [toggle setFrame:toggleFrame];
    [toggle setOn:aState];
    [toggle addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
    [toggle setTag:(self.mArrayOfLocations.count + kTagToggle)];
    
    //Make the text
    UITextView* text = [[UITextView alloc] init];
    [text setFrame:textFrame];
    [text setText:aAddress];
    [text setEditable:NO];
    [text setScrollEnabled:YES];
    [text setTag:(self.mArrayOfLocations.count + kTagTextView)];
    
    //Make the delete button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(deleteButton:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"X" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setFrame:buttonFrame];
    button.layer.cornerRadius = 8;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor blueColor].CGColor;
    [button setBackgroundColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:0.5f]];
    [button setTag:(self.mArrayOfLocations.count + kTagButton)];
    
    [self.UIScrollMainPage addSubview:toggle];
    [self.UIScrollMainPage addSubview:text];
    [self.UIScrollMainPage addSubview:button];
    
    CGSize contentSize = self.UIScrollMainPage.frame.size;//[UIScreen mainScreen].applicationFrame.size;
    contentSize.height = toggleFrame.origin.y + 40.0f;
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
    if (abs(howRecent) < 15.0)
    {
        if(self.mOldHeading == -1)
        {
            self.mOldHeading = location.course;
        }
        
        //Check for within 200 meters of home
        if([self DistanceBetweenOrigin:location.coordinate Destination:self.mHomeCoordinates] < 200 && self.mDidGoToStore)
        {
            //If this isn't nil it means you've made a sharp turn
            if(self.mOldLocation != nil)
            {
                if([self DistanceBetweenOrigin:self.mOldLocation.coordinate Destination:location.coordinate] > 3)
                {
                    [self.mTimer invalidate];
                    self.mTimer = nil;
                    self.mOldLocation = nil;
                }
            }
            //Heading check to see if the angle was sharp enough
            if(self.mOldHeading != location.course && fabs(self.mOldHeading - location.course) >= 20)
            {
                self.mOldLocation = location;
                self.mTimer =   [NSTimer scheduledTimerWithTimeInterval:5.0
                                                                 target:self
                                                               selector:@selector(ArrivedHome)
                                                               userInfo:nil
                                                                repeats:NO];
            }
        }
        
        for(int i = 0; i < self.mArrayOfLocations.count; i++)
        {
            if(![[self.mArrayOfLocations objectAtIndex:i] getOnOff].on)
                continue;
            
            CLLocationDegrees tempLat = [[self.mArrayOfLocations objectAtIndex:i] getLat];
            CLLocationDegrees tempLng = [[self.mArrayOfLocations objectAtIndex:i] getLng];
            CLLocationCoordinate2D tempCoords = CLLocationCoordinate2DMake(tempLat, tempLng);
            
            //Check for within 200 meters of store
            if([self DistanceBetweenOrigin:location.coordinate Destination:tempCoords] < 200)
            {
                //If this isn't nil it means you've made a sharp turn
                if(self.mOldLocation != nil)
                {
                    if([self DistanceBetweenOrigin:self.mOldLocation.coordinate Destination:location.coordinate] > 3)
                    {
                        [self.mTimer invalidate];
                        self.mTimer = nil;
                        self.mOldLocation = nil;
                    }
                    
                    break;
                }
                //Heading check to see if the angle was sharp enough
                if(self.mOldHeading != location.course && fabs(self.mOldHeading - location.course) >= 40)
                {
                    self.mOldLocation = location;
                    self.mTimer =   [NSTimer scheduledTimerWithTimeInterval:5.0
                                                                     target:self
                                                                   selector:@selector(ArrivedAtStore)
                                                                   userInfo:nil
                                                                    repeats:NO];
                    
                    break;
                }
            }
        }
    }
}

- (void)ArrivedAtStore {
    self.mDidGoToStore = YES;
    self.mOldLocation = nil;
    [self SendNotificationFromHome:NO];
}

- (void)ArrivedHome {
    self.mDidGoToStore = NO;
    self.mOldLocation = nil;
    [self SendNotificationFromHome:YES];
}

- (void)SendNotificationFromHome:(bool)aFromHome {
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    
    // current time plus 10 secs
    NSDate *now = [NSDate date];
    NSDate *dateToFire = [now dateByAddingTimeInterval:5];
    
    localNotification.fireDate = dateToFire;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    if(aFromHome)
        localNotification.alertBody = @"Don't forget to take your bags back to your car!";
    else
        localNotification.alertBody = @"Don't forget to take your bags!";
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Unable to start location manager. Error:%@", [error description]);
}

-(double)DistanceBetweenOrigin:(CLLocationCoordinate2D)aOrigin Destination:(CLLocationCoordinate2D)aDestination {
    float meters = 6371000;
    
    double lat1 = aOrigin.latitude;
    double lng1 = aOrigin.longitude;
    double lat2 = aDestination.latitude;
    double lng2 = aDestination.longitude;
    
    double lat1InRads = lat1 * (M_PI / 180.0f);
    double lat2InRads = lat2 * (M_PI / 180.0f);
    
    double thetaLat = (lat2 - lat1) * (M_PI / 180.0f);
    double thetaLng = (lng2 - lng1) * (M_PI / 180.0f);
    
    double dist =   sinf(thetaLat / 2) * sinf(thetaLat / 2) +
                    cosf(lat1InRads) * cosf(lat2InRads) *
                    sinf(thetaLng / 2) * sinf(thetaLng / 2);
    
    double otherDist = 2 * atan2(sqrt(dist), sqrt(1 - dist));
    
    double finalDist = meters * otherDist;
    
    return finalDist;
}



//TEST FUNCTIONS
- (IBAction)TestHomeNotif:(id)sender {
    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(ArrivedHome)
                                   userInfo:nil
                                    repeats:NO];
}

- (IBAction)TestStoreNotif:(id)sender {
    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(ArrivedAtStore)
                                   userInfo:nil
                                    repeats:NO];
}

@end
