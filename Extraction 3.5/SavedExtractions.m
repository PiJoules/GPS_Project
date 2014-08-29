//
//  SavedExtractions.m
//  Extraction 3.5
//
//  Created by Leonard Chan on 10/9/13.
//  Copyright (c) 2013 Leonard Chan. All rights reserved.
//

#import "SavedExtractions.h"
#import "GoogleMaps.h"
#import "savePath.h"
#import "GCGeocodingService.h"
#import "EmailViewController.h"

@interface SavedExtractions ()

@end

@implementation SavedExtractions{
    NSMutableArray *savedExtractions;
    NSMutableArray *savedImages;
    NSMutableArray *savedCoordinates;
    NSString *address;
    int selectedPath;
    
    savePath *sp;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    sp = [[savePath alloc] init];
    
    savedExtractions = [NSMutableArray arrayWithArray:sp.savedPaths];
    savedImages = [NSMutableArray arrayWithArray:sp.savedImages];
    
    if (savedImages.count != 0){
        UIImage *image = [UIImage imageWithData:[savedImages objectAtIndex:0]];
        savedExtractionsImageView.image = image;
    }
    
    if (savedExtractions.count != 0){
        
        //transfer coordinate arrays stored in savedExtractions into savedCoordinates as actual coordinates instead of strings
        savedCoordinates = [[NSMutableArray alloc] init];
        for (int i = 0; i < savedExtractions.count; i++){
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int j = 10; j < [[savedExtractions objectAtIndex:i] count]; j++){
                NSArray *coordinate = savedExtractions[i][j];
                double lat = [[coordinate objectAtIndex:0] doubleValue];
                double lng = [[coordinate objectAtIndex:1] doubleValue];
                CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
                [array insertObject:location atIndex:j-10];
            }
            [savedCoordinates insertObject:array atIndex:i];
        }
        
        //get address of first coordinate
        CLLocation *coordinate = [[CLLocation alloc] init];
        coordinate = [[savedCoordinates objectAtIndex:0] objectAtIndex:0];
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.coordinate.latitude longitude:coordinate.coordinate.longitude];
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
            
            address = [NSString stringWithFormat:@"%@ %@ %@ %@", placemark.subThoroughfare, placemark.thoroughfare, placemark.locality, placemark.postalCode];
            //NSLog(@"First Interesting Place near Area: %@", [[placemark areasOfInterest] objectAtIndex:0]);
            
            GCGeocodingService *gs1 = [[GCGeocodingService alloc] init];
            [gs1 geocodeAddress:address];
            GCGeocodingService *gs2 = [[GCGeocodingService alloc] init];
            [gs2 geocodeAddress:[[placemark areasOfInterest] objectAtIndex:0]];
            if (gs1.searchResults.count != 0){
                address = [gs1.geocode objectForKey:@"address"];
                NSLog(@"address1: %@", address);
                locationLabel.text = address;
            }
            else if ([[gs1.geocode objectForKey:@"address"] length] != 0){
                NSLog(@"interesting places count: %d", gs2.searchResults.count);
                address = [gs2.geocode objectForKey:@"address"];
                NSLog(@"address2: %@", address);
                locationLabel.text = address;
            }
            else{
                //yeeeeeeaaaaaaahhhhhhhhhh :-|
                NSLog(@"address3: %@", address);
                locationLabel.text = address;
            }
            if (!placemark){
                locationLabel.text = @"not connected to internet";
            }
            if ([locationLabel.text isEqualToString:@"(null) (null) (null) (null)"]){
                locationLabel.text = @"Could not identify location";
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
        }];
    }
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    locationLabel.numberOfLines = 0;
    
    
    //setting up the views
    /*NSMutableArray *imageArray = [NSMutableArray arrayWithArray:sp.savedImages];
    UIImage *image = [UIImage imageWithData:[imageArray objectAtIndex:0]];
    savedExtractionsImageView.image =image;*/
    //UIColor *color = [UIColor clearColor];
    savedExtractionsImageView.layer.cornerRadius = 15;
    savedExtractionsImageView.clipsToBounds = true;
    savedExtractionsImageView.layer.borderWidth = 2;
    savedExtractionsImageView.layer.borderColor = [[UIColor blackColor] CGColor];
    //savedExtractionsTableView.backgroundView = nil;
    //savedExtractionsTableView.backgroundColor = color;
    //subView.backgroundColor = color;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//savePath for savedPaths (this name was on accident :D)
- (NSString *)extractionSavePath{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    return [[path objectAtIndex:0] stringByAppendingPathComponent:@"savedPaths.plist"];
}



#pragma mark CONTROL THE TABLEVIEW

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return savedExtractions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[savedExtractions objectAtIndex:indexPath.row] objectAtIndex:0]];
    
    return cell;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    [savedExtractionsTableView setEditing:editing animated:true];
    if (editing){
        
    }
    else{
        
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //MUST ALWAYS FIRST REMOVE THE OBJECT FROM THE LIST PLACED ONTO THE TABLEVIEW
        [savedExtractions removeObjectAtIndex:indexPath.row];
        [savedImages removeObjectAtIndex:indexPath.row];
        [[[savePath alloc] init] saveArray:savedExtractions toSavePath:@"savedPaths"];
        [[[savePath alloc] init] saveArray:savedImages toSavePath:@"savedImages"];
        
        //THEN DELETE THE ROW
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if (savedExtractions.count != 0){
            UIImage *image = [UIImage imageWithData:[savedImages objectAtIndex:0]];
            savedExtractionsImageView.image = image;
            
            [savedCoordinates removeAllObjects];
            for (int i = 0; i < savedExtractions.count; i++){
                NSMutableArray *array = [[NSMutableArray alloc] init];
                for (int j = 10; j < [[savedExtractions objectAtIndex:i] count]; j++){
                    //NSArray *coordinate = [[[savedExtractions objectAtIndex:i] objectAtIndex:j] componentsSeparatedByString:@","];
                    NSArray *coordinate = savedExtractions[i][j];
                    double lat = [[coordinate objectAtIndex:0] doubleValue];
                    double lng = [[coordinate objectAtIndex:1] doubleValue];
                    CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
                    [array insertObject:location atIndex:j-10];
                }
                [savedCoordinates insertObject:array atIndex:i];
            }
            
            CLLocation *coordinate = [[CLLocation alloc] init];
            coordinate = [[savedCoordinates objectAtIndex:0] objectAtIndex:0];
            CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.coordinate.latitude longitude:coordinate.coordinate.longitude];
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
                
                address = [NSString stringWithFormat:@"%@ %@ %@ %@", placemark.subThoroughfare, placemark.thoroughfare, placemark.locality, placemark.postalCode];
                //NSLog(@"First Interesting Place near Area: %@", [[placemark areasOfInterest] objectAtIndex:0]);
                
                GCGeocodingService *gs1 = [[GCGeocodingService alloc] init];
                [gs1 geocodeAddress:address];
                GCGeocodingService *gs2 = [[GCGeocodingService alloc] init];
                [gs2 geocodeAddress:[[placemark areasOfInterest] objectAtIndex:0]];
                if (gs1.searchResults.count != 0){
                    address = [gs1.geocode objectForKey:@"address"];
                    NSLog(@"address1: %@", address);
                    locationLabel.text = address;
                }
                else if ([[gs1.geocode objectForKey:@"address"] length] != 0){
                    NSLog(@"interesting places count: %d", gs2.searchResults.count);
                    address = [gs2.geocode objectForKey:@"address"];
                    NSLog(@"address2: %@", address);
                    locationLabel.text = address;
                }
                else{
                    //yeeeeeeaaaaaaahhhhhhhhhh :-|
                    NSLog(@"address3: %@", address);
                    locationLabel.text = address;
                }
                if (!placemark){
                    locationLabel.text = @"not connected to internet";
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
            }];
        }
        else{
            savedExtractionsImageView.image = nil;
            locationLabel.text = @"no saved extractions";
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Saved Extractions";
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    UIImage *image = [UIImage imageWithData:[savedImages objectAtIndex:indexPath.row]];
    savedExtractionsImageView.image = image;
    //locationLabel.text = [NSString stringWithFormat:@"%@", [[savedExtractions objectAtIndex:indexPath.row] objectAtIndex:0]];
    
    CLLocation *coordinate = [[CLLocation alloc] init];
    coordinate = [[savedCoordinates objectAtIndex:indexPath.row] objectAtIndex:0];
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.coordinate.latitude longitude:coordinate.coordinate.longitude];
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
        
        address = [NSString stringWithFormat:@"%@ %@ %@ %@", placemark.subThoroughfare, placemark.thoroughfare, placemark.locality, placemark.postalCode];
        //NSLog(@"First Interesting Place near Area: %@", [[placemark areasOfInterest] objectAtIndex:0]);
        
        GCGeocodingService *gs1 = [[GCGeocodingService alloc] init];
        [gs1 geocodeAddress:address];
        GCGeocodingService *gs2 = [[GCGeocodingService alloc] init];
        [gs2 geocodeAddress:[[placemark areasOfInterest] objectAtIndex:0]];
        if (gs1.searchResults.count != 0){
            address = [gs1.geocode objectForKey:@"address"];
            NSLog(@"address1: %@", address);
            locationLabel.text = address;
        }
        else if ([[gs1.geocode objectForKey:@"address"] length] != 0){
            NSLog(@"interesting places count: %d", gs2.searchResults.count);
            address = [gs2.geocode objectForKey:@"address"];
            NSLog(@"address2: %@", address);
            locationLabel.text = address;
        }
        else{
            //yeeeeeeaaaaaaahhhhhhhhhh :-|
            NSLog(@"address3: %@", address);
            locationLabel.text = address;
        }
        if (!placemark) {
            locationLabel.text = @"not connected to internet";
        }
        if ([locationLabel.text isEqualToString:@"(null) (null) (null) (null)"]){
            locationLabel.text = @"Could not identify location";
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
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //[self performSegueWithIdentifier:@"toGoogleMaps" sender:self];
    selectedPath = indexPath.row;
    
    
    
    UIImage *image = [UIImage imageWithData:[savedImages objectAtIndex:indexPath.row]];
    savedExtractionsImageView.image = image;
    //locationLabel.text = [NSString stringWithFormat:@"%@", [[savedExtractions objectAtIndex:indexPath.row] objectAtIndex:0]];
    
    CLLocation *coordinate = [[CLLocation alloc] init];
    coordinate = [[savedCoordinates objectAtIndex:indexPath.row] objectAtIndex:0];
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.coordinate.latitude longitude:coordinate.coordinate.longitude];
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
        
        address = [NSString stringWithFormat:@"%@ %@ %@ %@", placemark.subThoroughfare, placemark.thoroughfare, placemark.locality, placemark.postalCode];
        //NSLog(@"First Interesting Place near Area: %@", [[placemark areasOfInterest] objectAtIndex:0]);
        
        GCGeocodingService *gs1 = [[GCGeocodingService alloc] init];
        [gs1 geocodeAddress:address];
        GCGeocodingService *gs2 = [[GCGeocodingService alloc] init];
        [gs2 geocodeAddress:[[placemark areasOfInterest] objectAtIndex:0]];
        if (gs1.searchResults.count != 0){
            address = [gs1.geocode objectForKey:@"address"];
            NSLog(@"address1: %@", address);
            locationLabel.text = address;
        }
        else if ([[gs1.geocode objectForKey:@"address"] length] != 0){
            NSLog(@"interesting places count: %d", gs2.searchResults.count);
            address = [gs2.geocode objectForKey:@"address"];
            NSLog(@"address2: %@", address);
            locationLabel.text = address;
        }
        else{
            //yeeeeeeaaaaaaahhhhhhhhhh :-|
            NSLog(@"address3: %@", address);
            locationLabel.text = address;
        }
        if (!placemark) {
            locationLabel.text = @"not connected to internet";
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
    }];
    
    
    
    [self performSegueWithIdentifier:@"toEmail" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toEmail"]){
        EmailViewController *email = [segue destinationViewController];
        email.savedPathNumber = selectedPath;
    }
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
