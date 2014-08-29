//
//  LoadingScreen.m
//  Extraction 3.5
//
//  Created by Leonard Chan on 9/28/13.
//  Copyright (c) 2013 Leonard Chan. All rights reserved.
//

#import "LoadingScreen.h"
#import "GCGeocodingService.h"
#import "savePath.h"
#import "MainScreen.h"

@interface LoadingScreen ()

@end

@implementation LoadingScreen{
    double currentLng;
    double currentLat;
    NSString *address;
    UIActivityIndicatorView *activityIndicator;
    CLLocationManager *locationManager;
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
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:self.view.frame];
    activityIndicator.backgroundColor = [UIColor clearColor];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    savePath *sp = [[savePath alloc] init];
    //[sp saveArray:[NSArray arrayWithArray:nil] toSavePath:@"searchHistory"];
    //[sp saveArray:[NSArray arrayWithArray:nil] toSavePath:@"savedImages"];
    //[sp saveArray:[NSArray arrayWithArray:nil] toSavePath:@"savedPaths"];
    //[sp saveArray:[NSArray arrayWithArray:nil] toSavePath:@"savedSettings"];
    //[sp saveArray:[NSArray arrayWithArray:nil] toSavePath:@"savedMapData"];
    
    //set everything alltogether
    if (sp.savedSettings.count == 0){
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array insertObject:[NSNumber numberWithInt:1] atIndex:0];
        [array insertObject:[NSString stringWithFormat:@"Meters (m)"] atIndex:1];
        [array insertObject:[NSNumber numberWithBool:true] atIndex:2];
        [array insertObject:[NSNumber numberWithBool:true] atIndex:3];
        [sp saveArray:array toSavePath:@"savedSettings"];
    }
    
    //display image depending on iPhone
    int height = [[UIScreen mainScreen] bounds].size.height;
    if (height > 500){  //iphone 5; default is already shown
        UIImage *image = [UIImage imageNamed:@"iphone 5 icon.png"];
        firstImage.image = image;
    }
    
    [activityIndicator stopAnimating];
    
    //Check for internet connection
    if (![self internetConnection]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not connect to internet. Please check your connection and try again." message:@"" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert addButtonWithTitle:@"Try Again"];
        [alert show];
    }
    //otherwise, ask for current location
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GPS Extractor would like to use your current location" message:@"" delegate:self cancelButtonTitle:@"Don't allow" otherButtonTitles:nil];
        [alert addButtonWithTitle:@"Ok"];
        [alert show];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [activityIndicator stopAnimating];
    firstImage = nil;
}

//control the alert views
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    //create a loop with view controller unless user wishes to continue without any internet
    if ([alertView.title isEqualToString:@"Could not connect to internet. Please check your connection and try again."]){
        if (buttonIndex == 0){
            [self performSegueWithIdentifier:@"toMainScreen" sender:self];
            [activityIndicator startAnimating];
        }
        else{
            [activityIndicator startAnimating];
            if ([self internetConnection]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GPS Extractor would like to use your current location" message:@"" delegate:self cancelButtonTitle:@"Don't allow" otherButtonTitles:nil];
                [alert addButtonWithTitle:@"Ok"];
                [alert show];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not connect to internet. Please check your connection and try again." message:@"" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
                [alert addButtonWithTitle:@"Try Again"];
                [alert show];
            }
            [activityIndicator stopAnimating];
        }
    }
    else{
        
        [activityIndicator startAnimating];
        
        if (buttonIndex == 0){
            [self performSegueWithIdentifier:@"toMainScreen" sender:self];
            [activityIndicator startAnimating];
        }
        else{
            
            locationManager = [[CLLocationManager alloc] init];
            locationManager.delegate = self;
            
            locationManager.distanceFilter = kCLDistanceFilterNone; //update location whenever we move
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;  //kCLLocationAccuracyBest is already default, but change if working on larger scale
            locationManager.pausesLocationUpdatesAutomatically = false;
            [locationManager startUpdatingLocation];    //here it finds the current location
            currentLng = locationManager.location.coordinate.longitude;
            currentLat = locationManager.location.coordinate.latitude;
            
            CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:currentLat longitude:currentLng];
            [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                
                //get neaby addresses from NSArray placemarks
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                
                address = [NSString stringWithFormat:@"%@ %@ %@ %@", placemark.subThoroughfare, placemark.thoroughfare, placemark.locality, placemark.postalCode];
                
                GCGeocodingService *gs1 = [[GCGeocodingService alloc] init];
                [gs1 geocodeAddress:address];
                GCGeocodingService *gs2 = [[GCGeocodingService alloc] init];
                [gs2 geocodeAddress:[[placemark areasOfInterest] objectAtIndex:0]];
                if (gs1.searchResults.count != 0){
                    address = [gs1.geocode objectForKey:@"address"];\
                }
                else if ([[gs1.geocode objectForKey:@"address"] length] != 0){
                    address = [gs2.geocode objectForKey:@"address"];
                }
                else{
                    //yeeeeeeaaaaaaahhhhhhhhhh :-|
                    //NSLog(@"address3: %@", address);
                    address = nil;
                }
                
                [locationManager stopUpdatingLocation];
                
                if (![address isEqualToString:@"could not locate address"] && address != nil && ![address isEqualToString: @"(null)"]){
                    savePath *sp = [[savePath alloc] init];
                    NSMutableArray *searches = [NSMutableArray arrayWithArray:sp.searchHistory];
                    [searches insertObject:address atIndex:0];
                    while (searches.count > 10) {
                        [searches removeLastObject];
                    }
                    [sp saveArray:searches toSavePath:@"searchHistory"];
                }
                NSLog(@"address: %@", address);
                [self performSegueWithIdentifier:@"toMainScreen" sender:self];
            }];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"using too much memory");
}

//CHECK FOR INTERNET CONNECTION
- (BOOL)internetConnection{
    Reachability *internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    NetworkStatus netStatus = [internetReachable currentReachabilityStatus];
    if (netStatus == ReachableViaWWAN){
        //NSLog(@"found internet through WWAN");
        return true;
    }
    if (netStatus == ReachableViaWiFi) {
        //NSLog(@"found internets through WIFI");
        return true;
    }
    if (netStatus == NotReachable) {
        //NSLog(@"there is no internets found");
        return false;
    }
    else{
        return false;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toMainScreen"]){
        if (address != nil){
            MainScreen *ms = (MainScreen *)[[segue destinationViewController] topViewController];
            ms.initialLocation = address;
        }
    }
}

@end
