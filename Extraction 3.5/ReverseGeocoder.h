//
//  ReverseGeocoder.h
//  Extraction 3.5
//
//  Created by Leonard Chan on 10/5/13.
//  Copyright (c) 2013 Leonard Chan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLGeocoder.h>
#import <CoreLocation/CLPlacemark.h>
#import "GCGeocodingService.h"

@interface ReverseGeocoder : NSObject{
    
}
- (id)init;
- (void)reverseGeocodeLocation:(id)sender latitude:(double)lat longitude:(double)lng;
//- (void)reverseGeocodeLocation:(double)lat :(double)lng;
- (NSString *)getAddress;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSDictionary *addressBook;
@property (nonatomic, strong) NSString *areaOfInterest;

@end
