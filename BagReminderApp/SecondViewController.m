//
//  SecondViewController.m
//  BagReminderApp
//
//  Created by Joel Cright on 2015-11-04.
//  Copyright (c) 2015 Joel Cright. All rights reserved.
//

#import "SecondViewController.h"
@import GoogleMaps;

@interface SecondViewController ()

@end

@implementation SecondViewController

@synthesize MarkerArray = mMarkerArray;
GMSMapView *mMapView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mMarkerArray = [[NSMutableArray alloc] init];
    self.mLocationClient = [[GMSPlacesClient alloc] init];
    self.mLocationManager = [[CLLocation alloc] init];
    //self.mPlacePicker = [[GMSPlacePicker alloc] init];
    
    //[self.mLocationManager requestWhenInUseAuthorization];
    //[self.mLocationManager requestAlwaysAuthorization];
    
    [self SetUpMap];
    [self SetUpCallback];
}
- (IBAction)SearchForLocation:(id)sender {
    //TODO: Search and place marker
    //TODO: Send this to the first view controller's function that adds buttons
    //By that, I mean when a user clicks on the marker and says "this one" do that
    
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
        } else {
            NSLog(@"No place selected");
        }
    }];
}

// The code snippet below shows how to create a GMSPlacePicker
// centered on Sydney, and output details of a selected place.
- (IBAction)pickPlace:(UIButton *)sender {
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
        } else {
            NSLog(@"No place selected");
        }
    }];
}

-(void)SetUpCallback {
    [self.mLocationClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *likelihoodList, NSError *error) {
        if (error != nil) {
            NSLog(@"Current Place error %@", [error localizedDescription]);
            return;
        }
        
        for (GMSPlaceLikelihood *likelihood in likelihoodList.likelihoods) {
            GMSPlace* place = likelihood.place;
            NSLog(@"Current Place name %@ at likelihood %g", place.name, likelihood.likelihood);
            NSLog(@"Current Place address %@", place.formattedAddress);
            NSLog(@"Current Place attributions %@", place.attributions);
            NSLog(@"Current PlaceID %@", place.placeID);
        }        
    }];
}

-(void)SetUpMap {
    // Create a GMSCameraPosition that tells the map to display coords at the zoom level
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:48.1667
                                                            longitude:100.1667
                                                                 zoom:6];
    
    mMapView = [GMSMapView mapWithFrame:self.MapView.bounds camera: camera];
    mMapView.myLocationEnabled = YES;
    [self.MapView addSubview:mMapView];
}

-(void)AddMarkerToMapWithTitle:(NSString*)aTitle Latitude:(float)aLat Longitude:(float)aLng {
    //TODO: args for lat, lng, and title
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(aLat, aLng);
    marker.title = aTitle;
    //marker.snippet = @"Australia";
    marker.map = mMapView;
    
    [mMarkerArray addObject:marker];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
