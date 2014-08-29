//
//  GCGeocodingService.m
//  Extraction
//
//  Created by Daniel Diazdelcastillo on 8/27/13.
//  Copyright (c) 2013 Daniel Diazdelcastillo. All rights reserved.
//

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#import "GCGeocodingService.h"

@interface GCGeocodingService ()

@end

@implementation GCGeocodingService{
    NSData *_data;
    NSString *address;
}

@synthesize geocode;
@synthesize searchResults;

- (id)init{
    self = [super init];
    geocode = [[NSDictionary alloc] initWithObjectsAndKeys: @"0.0", @"lat", @"0.0", @"lng", @"Null Island", @"address", nil];
    return self;
}

- (void)geocodeAddress : (NSString *)address_{
    if (![self internetConnection]){
        NSDictionary *noneFound = [[NSDictionary alloc] initWithObjectsAndKeys:nil, @"lat", nil, @"lng", nil, @"address", nil];
        geocode = noneFound;
    }
    else if (address_){
        
        NSString *geocodingBaseUrl = @"http://maps.googleapis.com/maps/api/geocode/json?";
        NSString *url = [NSString stringWithFormat : @"%@address=%@&sensor=false", geocodingBaseUrl, address_];
        url = [url stringByAddingPercentEscapesUsingEncoding : NSUTF8StringEncoding];
    
        NSURL *queryUrl = [NSURL URLWithString : url];
        dispatch_sync(kBgQueue, ^{
            NSData *data = [NSData dataWithContentsOfURL : queryUrl];
            [self fetchedData : data];
            //NSLog(@"there is data");
            });
    }
    else{
        NSDictionary *noneFound = [[NSDictionary alloc] initWithObjectsAndKeys:nil, @"lat", nil, @"lng", nil, @"address", nil];
        geocode = noneFound;
    }
}

- (void)fetchedData : (NSData *)data{
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData : data options : kNilOptions error : &error];
    
    NSArray *results = [json objectForKey : @"results"];
    NSString *address_ = [[NSString alloc] init];
    NSString *lat = [[NSString alloc] init];
    NSString *lng = [[NSString alloc] init];
    
    if (results.count != 0){
        
        NSDictionary *result = [results objectAtIndex : 0]; //HERES THE PROBLEMJKHSVHVJKB!!!!!!!!!!!!
        address_ = [result objectForKey : @"formatted_address"];
    
        searchResults = [[NSMutableArray alloc] init];
        for (int i = 0; i < results.count; i++){
            //the array of filtered address results
            //NSLog(@"address %d: %@", i, [[results objectAtIndex:i] objectForKey:@"formatted_address"]);
            [searchResults insertObject:[[results objectAtIndex:i] objectForKey:@"formatted_address"] atIndex:i];
        }
        //NSLog(@"results.count: %d searchResults.count: %d", results.count, searchResults.count);
    
        NSDictionary *geometry = [result objectForKey : @"geometry"];
        NSDictionary *location = [geometry objectForKey : @"location"];
        lat = [location objectForKey : @"lat"];
        lng = [location objectForKey : @"lng"];
    }
    else{
        address = nil;
        lat = @"39.956613";
        lng = @"-75.189947";
        searchResults = [[NSMutableArray alloc] initWithObjects: nil];
    }
    
    NSDictionary *gc = [[NSDictionary alloc] initWithObjectsAndKeys : lat, @"lat", lng, @"lng", address_, @"address", nil];
    
    geocode = gc;
}

- (void)reverseGeocodeLocation:(id)sender latitude:(double)lat longitude:(double)lng{
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
        //NSLog(@"lat2: %f lng2: %f", lat, lng);
        address = [NSString stringWithFormat:@"%@ %@ %@ %@", placemark.subThoroughfare, placemark.thoroughfare, placemark.locality, placemark.postalCode];
        //NSLog(@"First Interesting Place near Area: %@", [[placemark areasOfInterest] objectAtIndex:0]);
        
        GCGeocodingService *gs1 = [[GCGeocodingService alloc] init];
        [gs1 geocodeAddress:address];
        GCGeocodingService *gs2 = [[GCGeocodingService alloc] init];
        [gs2 geocodeAddress:[[placemark areasOfInterest] objectAtIndex:0]];
        if (gs1.searchResults.count != 0){
            address = [gs1.geocode objectForKey:@"address"];
            //NSLog(@"address1: %@", address);
        }
        else if ([[gs1.geocode objectForKey:@"address"] length] != 0){
            //NSLog(@"interesting places count: %d", gs2.searchResults.count);
            address = [gs2.geocode objectForKey:@"address"];
            //NSLog(@"address2: %@", address);
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
        NSDictionary *rg = [[NSDictionary alloc] initWithObjectsAndKeys : [NSString stringWithFormat:@"%f", lat], @"lat", [NSString stringWithFormat:@"%f", lng], @"lng", address, @"address", nil];
        geocode = rg;
    }];
}

//CHECK FOR INTERNET CONNECTION
- (BOOL)internetConnection{
    Reachability *internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    NetworkStatus netStatus = [internetReachable currentReachabilityStatus];
    if (netStatus == ReachableViaWWAN){
        NSLog(@"found internet through WWAN");
        return true;
    }
    if (netStatus == ReachableViaWiFi) {
        NSLog(@"found internets through WIFI");
        return true;
    }
    if (netStatus == NotReachable) {
        NSLog(@"there is no internets found");
        return false;
    }
    else{
        return false;
    }
}

@end
