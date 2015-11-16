//
//  LocationStruct.h
//  BagReminderApp
//
//  Created by Joel Cright on 2015-11-08.
//  Copyright © 2015 Joel Cright. All rights reserved.
//

#ifndef LocationStruct_h
#define LocationStruct_h

#import <UIKit/UIKit.h>
@interface LocationStruct : NSObject

@property int objID;
@property NSString* placeID;
@property NSString* placeName;
@property UISwitch* onOff;
@property float lat;
@property float lng;
@property NSString* address;

-(int)getID;
-(NSString*)getPlaceID;
-(NSString*)getPlaceName;
-(UISwitch*)getOnOff;
-(float)getLat;
-(float)getLng;
-(NSString*)getAddress;

-(NSString*)ToString;

@end

#endif /* LocationStruct_h */
