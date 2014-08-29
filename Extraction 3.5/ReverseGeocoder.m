//
//  ReverseGeocoder.m
//  Extraction 3.5
//
//  Created by Leonard Chan on 10/5/13.
//  Copyright (c) 2013 Leonard Chan. All rights reserved.
//

#import "ReverseGeocoder.h"

@interface ReverseGeocoder ()

@end

@implementation ReverseGeocoder

@synthesize address;
@synthesize addressBook;
@synthesize areaOfInterest;

- (id)init{
    self = [super init];
    address = [[NSString alloc] init];
    areaOfInterest = [[NSString alloc] init];
    addressBook = [[NSDictionary alloc] initWithObjectsAndKeys: @"Null Island", @"address", nil];
    return self;
}

/*
 CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
 CLLocation *startingLocation = [[CLLocation alloc] initWithLatitude:self.Latitude longitude:self.Longitude];
 [geoCoder reverseGeocodeLocation: startingLocation completionHandler: ^(NSArray *placemarks, NSError *error) {
 
 //Get nearby address
 //NSLog(@"%d", placemarks.count);
 CLPlacemark *placemark = [placemarks objectAtIndex:0];
 
 //Print the location to console
 NSLog(@"Country: %@",placemark.country);
 NSLog(@"City: %@",placemark.locality);
 NSLog(@"Abbreviated Country Name: %@",placemark.ISOcountryCode);
 NSLog(@"Placemark Name: %@", placemark.name);
 NSLog(@"Postal Code: %@", placemark.postalCode);
 NSLog(@"State/Province: %@", placemark.administrativeArea);
 NSLog(@"Aditional Administrative Area Info: %@", placemark.subAdministrativeArea);
 NSLog(@"Additional City-level Info: %@", placemark.subLocality);
 NSLog(@"Street Address: %@", placemark.thoroughfare);
 NSLog(@"Additional Street-level Info: %@", placemark.subThoroughfare);
 NSLog(@"Geographic Region: %@", placemark.region);
 NSLog(@"First Interesting Place near Area: %@", [[placemark areasOfInterest] objectAtIndex:0]);
 
 self.areaOfInterest = [[placemark areasOfInterest] objectAtIndex:0];
 if (!self.listOfLocations){
 self.listOfLocations = [[NSMutableArray alloc] initWithObjects:self.areaOfInterest, nil];
 }
 self.streetAddress = [NSString stringWithFormat:@"%@ %@ %@ %@", placemark.subThoroughfare, placemark.thoroughfare, placemark.locality, placemark.postalCode];
 
 //NSLog(@"%@", self.streetAddress);
 }];*/

- (void)reverseGeocodeLocation:(id)sender latitude:(double)lat longitude:(double)lng{
//- (void)reverseGeocodeLocation:(double)lat :(double)lng{
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        //get neaby addresses from NSArray placemarks
        CLPlacemark *placemark = [placemarks objectAtIndex:0];  //closest location
        /*
        //Print the location to console
        NSLog(@"Country: %@",placemark.country);
        NSLog(@"City: %@",placemark.locality);
        NSLog(@"Abbreviated Country Name: %@",placemark.ISOcountryCode);
        NSLog(@"Placemark Name: %@", placemark.name);
        NSLog(@"Postal Code: %@", placemark.postalCode);
        NSLog(@"State/Province: %@", placemark.administrativeArea);
        NSLog(@"Aditional Administrative Area Info: %@", placemark.subAdministrativeArea);
        NSLog(@"Additional City-level Info: %@", placemark.subLocality);
        NSLog(@"Street Address: %@", placemark.thoroughfare);
        NSLog(@"Additional Street-level Info: %@", placemark.subThoroughfare);
        NSLog(@"Geographic Region: %@", placemark.region);
        NSLog(@"First Interesting Place near Area: %@", [[placemark areasOfInterest] objectAtIndex:0]); //area of interest closest to location*/
        
        //WORK ON THE THREE VERSIONS OF THE ADDRESS
        //1 THROUGH GCGEOCODER (GIVEN THE STREET ADDRESS)
        //2 THROUGH GCGEOCODER (GIVEN THE FIRST AREA OF INTEREST)
        //3 THE STREET ADDRESS GIVEN HERE
        NSLog(@"lat2: %f lng2: %f", lat, lng);
        address = [NSString stringWithFormat:@"%@ %@ %@ %@", placemark.subThoroughfare, placemark.thoroughfare, placemark.locality, placemark.postalCode];
        //NSLog(@"First Interesting Place near Area: %@", [[placemark areasOfInterest] objectAtIndex:0]);
        
        GCGeocodingService *gs1 = [[GCGeocodingService alloc] init];
        [gs1 geocodeAddress:address];
        GCGeocodingService *gs2 = [[GCGeocodingService alloc] init];
        [gs2 geocodeAddress:[[placemark areasOfInterest] objectAtIndex:0]];
        if (gs1.searchResults.count != 0){
            address = [gs1.geocode objectForKey:@"address"];
            NSLog(@"address1: %@", address);
        }
        else if ([[gs1.geocode objectForKey:@"address"] length] != 0){
            NSLog(@"interesting places count: %d", gs2.searchResults.count);
            address = [gs2.geocode objectForKey:@"address"];
            NSLog(@"address2: %@", address);
        }
        else{
            //yeeeeeeaaaaaaahhhhhhhhhh :-|
            NSLog(@"address3: %@", address);
        }
        /*address = [gs1.geocode objectForKey:@"address"];
        NSLog(@"address1: %@", address);
        address = [gs2.geocode objectForKey:@"address"];
        NSLog(@"address2: %@", address);
        address = [NSString stringWithFormat:@"%@ %@ %@ %@", placemark.subThoroughfare, placemark.thoroughfare, placemark.locality, placemark.postalCode];
        NSLog(@"address3: %@", address);
        if ([address isEqualToString:@"(null) (null) (null) (null)"]){
            NSLog(@"address is null");
        }*/
        NSDictionary *rg = [[NSDictionary alloc] initWithObjectsAndKeys:address, @"address", nil];
        addressBook = rg;
    }];
}

- (NSString *)getAddress{
    return address;
}

@end
