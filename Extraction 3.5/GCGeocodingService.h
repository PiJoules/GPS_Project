//
//  GCGeocodingService.h
//  Extraction
//
//  Created by Daniel Diazdelcastillo on 8/27/13.
//  Copyright (c) 2013 Daniel Diazdelcastillo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLGeocoder.h>
#import <CoreLocation/CLPlacemark.h>
#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface GCGeocodingService : NSObject

- (id)init;
- (void)geocodeAddress : (NSString *)address;
- (void)reverseGeocodeLocation:(id)sender latitude:(double)lat longitude:(double)lng;

@property (nonatomic, strong) NSDictionary *geocode;
@property (nonatomic, strong) NSMutableArray *searchResults;

@end
