//
//  LocationStruct.m
//  BagReminderApp
//
//  Created by Joel Cright on 2015-11-08.
//  Copyright © 2015 Joel Cright. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationStruct.h"

@interface LocationStruct ()

@end

@implementation LocationStruct


//GETTERS
-(int)getID {
    if(self)
        return self.objID;
    else
        return -1;
}

-(NSString*)getPlaceID {
    return self.placeID;
}

-(NSString*)getPlaceName {
    return self.placeName;
}

-(UISwitch*)getOnOff {
    return self.onOff;
    
}

-(float)getLat {
    return self.lat;
}

-(float)getLng {
    return self.lng;
}

-(NSString*)getAddress {
    return self.address;
}

-(NSString*)ToString {
    NSString* idStr = [[NSString stringWithFormat:@"%d", self.objID] stringByAppendingString:@"|"];
    NSString* placeName = [self.placeName stringByAppendingString:@"|"];
    NSString* placeIDStr = [self.placeID stringByAppendingString:@"|"];
    NSString* onOffString = @"";
    if(self.onOff.on == YES)
        onOffString = [@"YES" stringByAppendingString:@"|"];
    else
        onOffString = [@"NO" stringByAppendingString:@"|"];
    NSString* latStr = [[NSString stringWithFormat:@"%f", self.lat] stringByAppendingString:@"|"];
    NSString* lngStr = [[NSString stringWithFormat:@"%f", self.lng] stringByAppendingString:@"|"];
    NSString* addressStr = [self.address stringByAppendingString:@"|"];
    
    NSString* finalString = idStr;
    finalString = [finalString stringByAppendingString:placeIDStr];
    finalString = [finalString stringByAppendingString:placeName];
    finalString = [finalString stringByAppendingString:onOffString];
    finalString = [finalString stringByAppendingString:latStr];
    finalString = [finalString stringByAppendingString:lngStr];
    finalString = [finalString stringByAppendingString:addressStr];
    finalString = [finalString stringByAppendingString:@"EOL"];
    
    return finalString;
}

@end
