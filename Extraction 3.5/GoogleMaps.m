//
//  GoogleMaps.m
//  Extraction 3.5
//
//  Created by Leonard Chan on 9/28/13.
//  Copyright (c) 2013 Leonard Chan. All rights reserved.
//

#import "GoogleMaps.h"
#import "GCGeocodingService.h"
#import "savePath.h"
#import "SettingsController.h"

@interface GoogleMaps ()

@end

@implementation GoogleMaps{
    savePath *sp;
    GCGeocodingService *gs;
    GMSMarker *marker;
    GMSMarker *circleCenterMarker;  //Circle markers
    GMSMarker *circleRadiusMarker;
    GMSMarker *circleDiameterMarker;
    GMSMarker *rectangleMidpointMarker;    //Rectangle Markers
    GMSMarker *rectangleResizeMarker;
    GMSMarker *rectangleDimensionMarker;
    GMSPolyline *poly;
    GMSCircle *circle;
    NSMutableArray *newSearches;
    NSMutableArray *listOfCoordinates;
    NSMutableArray *listOfDeletedCoordinates;
    NSMutableArray *listOfReplacedCoordinateNumbers;
    NSMutableArray *chosenMarkerArray;
    NSArray *searchResults; //the arraylist that is displayed on SearchDisplayController
    NSString *typeOfObject;
    NSString *objectTitle;
    NSString *incrementalUnit;
    CLLocation *firstCoordinate;
    CLLocation *nextCoordinate;
    UIBarButtonItem *searchBarButton;
    UIBarButtonItem *toolbarButton;
    UIBarButtonItem *settingButton;
    CGPoint firstPoint;
    CGPoint nextPoint;
    UISearchDisplayController *searchController;
    //UIActivityIndicatorView *activityIndicator;
    UIAlertView *loadingMap;
    BOOL selectedFreeHand;
    BOOL selectedLine;
    BOOL selectedCircle;
    BOOL selectedRectangle;
    BOOL pastBounds;
    BOOL finishedDrawing;
    BOOL addedGlass;
    BOOL snapOn;
    BOOL hintsOn;
    int taps;
    int stepperValue;
    int selectedMarker;
    double firstCoordinateLatitude;
    double firstCoordinateLongitude;
    double secondCoordinateLatitude;
    double secondCoordinateLongitude;
    double minDistance; //incremental unit
    double initCameraBearing;
    
    //dictionary
    NSDictionary *dictionary;
    NSEnumerator *keyEnumerator;
    id key;
    
    //line/free hand properties
    CLLocation *firstLocation;
    CLLocation *lastLocation;
    double totalDistance;
    
    //circle properties
    double circleArea;
    double circleCircumference;
    double radius;
    CLLocation *circleCenter;
    
    //rectangle properties
    double rectangleArea;
    double rectangleLength;
    double rectangleWidth;
    double rectanglePerimeter;
    NSMutableArray *corner;
}

@synthesize searchLocation;
@synthesize searches;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    /*activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:self.view.frame];
    activityIndicator.backgroundColor = [UIColor clearColor];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];*/
    loadingMap = [self showWaitIndicator:@"Loading Map"];
    
    //initialize google stuff
    gs = [[GCGeocodingService alloc] init];
    
    if (searchLocation != nil && [self internetConnection]){    //will be set to nil if hit New Search on MainScreen
        
        [gs geocodeAddress:searchLocation];
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[[gs.geocode objectForKey:@"lat"] doubleValue] longitude:[[gs.geocode objectForKey:@"lng"] doubleValue] zoom:15];
        [mapView setCamera:camera];
        
        GMSMarker *initialPosition = [GMSMarker markerWithPosition:camera.target];
        initialPosition.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        NSArray *stringArray = [searchLocation componentsSeparatedByString:@","];
        initialPosition.title = [NSString stringWithFormat:@"%@", stringArray.firstObject];
        initialPosition.snippet = [NSString stringWithFormat:@"location: (%f,%f)", camera.target.latitude, camera.target.longitude];
        initialPosition.tappable = true;
        initialPosition.draggable = false;
        initialPosition.map = mapView;
        [mapView setSelectedMarker:initialPosition];
    }
    else{   //default coordinates are set to Drexel
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:39.956613 longitude:-75.189947 zoom:15];
        [mapView setCamera:camera];
        
        GMSMarker *initialPosition = [GMSMarker markerWithPosition:camera.target];
        initialPosition.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        initialPosition.title = @"Drexel University";
        initialPosition.snippet = [NSString stringWithFormat:@"location: (%f,%f)", camera.target.latitude, camera.target.longitude];
        initialPosition.tappable = true;
        initialPosition.draggable = false;
        initialPosition.map = mapView;
        [mapView setSelectedMarker:initialPosition];
    }
    
    listOfCoordinates = [[NSMutableArray alloc] init];
    
    mapView.delegate = self;
    
    //initialize other stuff
    self.tabBarController.delegate = self;
    self.tabBarController.tabBar.delegate = self;
    searchController = [[UISearchDisplayController alloc] initWithSearchBar:gmSearchBar contentsController:self];
    searchController.delegate = self;
    searchController.searchResultsDelegate = self;
    searchController.searchResultsDataSource = self;
    buttonToolbar.barTintColor = [[UIColor alloc] initWithRed:1 green:1 blue:0 alpha:1];
    undoButton.tintColor = [UIColor blueColor];
    doneButton.tintColor = [UIColor blueColor];
    saveButton.tintColor = [UIColor blueColor];
    buttonToolbar.tintColor = [UIColor blueColor];
    buttonToolbar.opaque = true;
    searchBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButton:)];
    toolbarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(toolbarButton:)];
    settingButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear 25x25.png"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButton:)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:searchBarButton, toolbarButton, settingButton, nil];
    [coordinateStepper addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
    listOfDeletedCoordinates = [[NSMutableArray alloc] init];
    listOfReplacedCoordinateNumbers = [[NSMutableArray alloc] init];
    chosenMarkerArray = [[NSMutableArray alloc] init];
    [coordinatesView setFrame:CGRectMake(coordinatesView.frame.origin.x, buttonToolbar.frame.origin.y-coordinatesView.frame.size.height, coordinatesView.frame.size.width, coordinatesView.frame.size.height)];
    newSearches = [[NSMutableArray alloc] initWithArray:searches];
    
    //0.30480000001831 m = 1 ft;
    //0.91440000005494 m = 1 yd;
    //1 m = 1 m;
    //1000 m = 1 km;
    //1609.34400009669 m = 1 mi;
    dictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithDouble:0.30480000001831], [NSNumber numberWithDouble:0.91440000005494], [NSNumber numberWithDouble:1], [NSNumber numberWithDouble:1000], [NSNumber numberWithDouble:1609.34400009669], nil] forKeys:[NSArray arrayWithObjects:@"Feet (ft)", @"Yards (yd)", @"Meters (m)", @"Kilometers (km)", @"Miles (mi)", nil]];
    keyEnumerator = [dictionary keyEnumerator];
    
    //BOOLS
    selectedFreeHand = false;
    selectedLine = false;
    selectedCircle = false;
    selectedRectangle = false;
    finishedDrawing = false;
    addedGlass = false;
    //UILABEL
    googleMapsLabel.textColor = [UIColor blackColor];
    googleMapsLabel.backgroundColor = [UIColor whiteColor];
    googleMapsLabel.layer.cornerRadius = 5;
    googleMapsLabel.numberOfLines = 0;
    coordinatesLabel.numberOfLines = 0;
    coordinatesLabel.font = [coordinatesLabel.font fontWithSize:12];
    
    //HIDDENS
    gmSearchBar.hidden = true;
    pathPenTabBar.hidden = true;
    googleMapsLabel.hidden = true;
    buttonToolbar.hidden = false;
    coordinatesView.hidden = true;
    
    //ENABLED's
    drawButton.enabled = true;
    cancelButton.enabled = false;
    undoButton.enabled = false;
    doneButton.enabled = false;
    saveButton.enabled = false;
    coordinatesSearch.enabled = false;
    centerButton.enabled = false;
}
- (void)changeValue:(UIStepper *)sender{
    
    stepperValue = sender.value;
    
    NSMutableString *string = [[NSMutableString alloc] init];
    [string appendString:[NSString stringWithFormat:@"lat: %f", [listOfCoordinates[stepperValue] coordinate].latitude]];
    [string appendString:@"\r"];
    [string appendString:[NSString stringWithFormat:@"lng: %f", [listOfCoordinates[stepperValue] coordinate].longitude]];
    coordinatesLabel.text = string;
    
    marker.map = nil;
    marker = nil;
    marker = [GMSMarker markerWithPosition:[listOfCoordinates[stepperValue] coordinate]];
    marker.draggable = true;
    marker.map = mapView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"too much memory usage");
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //[activityIndicator startAnimating];
    if (!loadingMap.visible){
        loadingMap = [self showWaitIndicator:@"Loading Map"];
    }
    
    sp = [[savePath alloc] init];
    
    //map type
    //if (sp.savedSettings.count != 0){
    mapView.mapType = [sp.savedSettings[0] intValue];
    //}
    //else{
        //mapView.mapType = kGMSTypeNormal;
    //}
    
    //incremental units
    //if (sp.savedSettings.count > 1){
        incrementalUnit = [NSString stringWithFormat:@"%@", sp.savedSettings[1]];
    /*}
    else{
        incrementalUnit = [NSString stringWithFormat:@"Meters (m)"];
    }*/
    
    //snapOn
    //if (sp.savedSettings.count > 2){
        snapOn = [sp.savedSettings[2] boolValue];
    /*}
    else{
        snapOn = true;
    }*/
    
    //hintsOn
    //if (sp.savedSettings.count > 3){
        hintsOn = [sp.savedSettings[3] boolValue];
    /*}
    else{
        hintsOn = true;
    }*/
    
    //0.30480000001831 m = 1 ft;
    //0.91440000005494 m = 1 yd;
    //1 m = 1 m;
    //1000 m = 1 km;
    //1609.34400009669 m = 1 mi;
    /*NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithDouble:0.30480000001831], [NSNumber numberWithDouble:0.91440000005494], [NSNumber numberWithDouble:1], [NSNumber numberWithDouble:1000], [NSNumber numberWithDouble:1609.34400009669], nil] forKeys:[NSArray arrayWithObjects:@"Feet (ft)", @"Yards (yd)", @"Meters (m)", @"Kilometers (km)", @"Miles (mi)", nil]];
    NSEnumerator *keyEnumerator = [dictionary keyEnumerator];
    id key;*/
    while ((key = [keyEnumerator nextObject])) {
        if ([key isEqualToString:incrementalUnit]){
            minDistance = [[dictionary objectForKey:key] doubleValue];
            break;
        }
    }
    
    //[activityIndicator stopAnimating];
    [loadingMap dismissWithClickedButtonIndex:0 animated:true];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    //loadingMap = [self showWaitIndicator:@"Closing Map"];
    
    if (searches.count != newSearches.count){
        while (newSearches.count > 10) {
            [newSearches removeLastObject];
        }
        [sp saveArray:newSearches toSavePath:@"searchHistory"];
    }
}

/*- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [loadingMap dismissWithClickedButtonIndex:0 animated:true];
}*/

- (UIAlertView*)showWaitIndicator:(NSString *)title
{
    UIAlertView *progressAlert;
    progressAlert = [[UIAlertView alloc] initWithTitle:title
                                               message:@"Please wait..."
                                              delegate:nil
                                     cancelButtonTitle:nil
                                     otherButtonTitles:nil];
    [progressAlert show];
    
    UIActivityIndicatorView *activityView;
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center = CGPointMake(progressAlert.bounds.size.width / 2,
                                      progressAlert.bounds.size.height - 45);
    
    [progressAlert addSubview:activityView];
    [activityView startAnimating];
    return progressAlert;
}


#pragma mark CONTROLLING THE SEARCH DISPLAY CONTROLLER

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return gs.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    //control what text is displayed on searchDisplayController
    if (tableView == searchController.searchResultsTableView){
        cell.textLabel.text = [gs.searchResults objectAtIndex:indexPath.row];
    }
    
    return cell;
}

//FILTERS INITIAL SEARCHRESULTS BASED ON TEXT IN SEARCH BAR
//this is actually unecessary because the filtered searchResult array is the same as the array of addresses provided by the google maps GCGeocodingService, but keep it just in case
/*
- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchText];
    //[gs geocodeAddress:searchText];
    GCGeocodingService *tempGS = [[GCGeocodingService alloc] init];
    [tempGS geocodeAddress:searchText];
    
    //will find results from array gs.searchResults
    if (!searchResults){
    searchResults = [[NSArray alloc] initWithArray:[tempGS.searchResults filteredArrayUsingPredicate:resultPredicate]];
        NSLog(@"array was initially emptry");
    }
    else{
        searchResults = [tempGS.searchResults filteredArrayUsingPredicate:resultPredicate];
    }
}*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [gs geocodeAddress:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
    double lat = [[gs.geocode objectForKey : @"lat"] doubleValue];
    double lng = [[gs.geocode objectForKey : @"lng"] doubleValue];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude : lat longitude : lng zoom : 15];
    [mapView setCamera : camera];
    
    //save new search in storage space
    //NSMutableArray *previousSearches = [NSMutableArray arrayWithArray:sp.searchHistory];
    //[previousSearches insertObject:[tableView cellForRowAtIndexPath:indexPath].textLabel.text atIndex:0];
    [newSearches insertObject:[tableView cellForRowAtIndexPath:indexPath].textLabel.text atIndex:0];
    /*while (previousSearches.count > 10) {
        [previousSearches removeLastObject];
    }*/
    //[previousSearches writeToFile:[self savePath] atomically:true];
    //[sp saveArray:previousSearches toSavePath:@"searchHistory"];
    
    pathPenTabBar.hidden = true;
    gmSearchBar.hidden = true;
    
    [gs.searchResults removeAllObjects];
    for (int i = 0; i < 20; i++){
        [gs.searchResults addObject:@"hello"];
    }
    
    [searchController setActive:false animated:true];
}

//did click search button on first responder
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [gs geocodeAddress:searchBar.text];
    double lat = [[gs.geocode objectForKey : @"lat"] doubleValue];
    double lng = [[gs.geocode objectForKey : @"lng"] doubleValue];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude : lat longitude : lng zoom : 15];
    [mapView setCamera : camera];
    
    //save new search in storage space
    //NSMutableArray *previousSearches = [NSMutableArray arrayWithArray:sp.searchHistory];
    //[previousSearches insertObject:searchBar.text atIndex:0];
    [newSearches insertObject:searchBar.text atIndex:0];
    /*while (previousSearches.count > 10) {
        [previousSearches removeLastObject];
    }*/
    //[previousSearches writeToFile:[self savePath] atomically:true];
    //[sp saveArray:previousSearches toSavePath:@"searchHistory"];
    
    pathPenTabBar.hidden = true;
    gmSearchBar.hidden = true;
    
    [searchController setActive:false animated:true];
}

//REFRESHES SEACRCHDISPLAYCONTROLLER EACH TIME A BUTTON ON FIRST RESPONDER IS PRESSED
//when using searchdisplaycontroller, add at least 2 scopes to make the search bar display in the searchdisplaycontroller
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    //[self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    [gs geocodeAddress:searchString];
    
    return true;
}



#pragma mark CONTROL TOOLBAR AT BOTTOM OF SCREEN

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    [mapView clear];
    
    if ([item.title isEqual: @"Free Hand"]){
        selectedFreeHand = true;
        googleMapsLabel.text = @"Hold down where start of the path will be. A marker will appear at this location to help you draw.";
        typeOfObject = [[NSString alloc] initWithFormat:@"Free Hand"];
    }
    if ([item.title isEqualToString:@"Line"]) {
        selectedLine = true;
        googleMapsLabel.text = @"Please select the first point of the line";
        taps = 0;
        typeOfObject = [[NSString alloc] initWithFormat:@"Line"];
    }
    if ([item.title isEqualToString:@"Circle"]) {
        selectedCircle = true;
        googleMapsLabel.text = @"Please select where the center of the circle will be";
        taps = 0;
        typeOfObject = [[NSString alloc] initWithFormat:@"Circle"];
    }
    if ([item.title isEqualToString:@"Rectangle"]){
        selectedRectangle = true;
        googleMapsLabel.text = @"Please select where the first corner of rectangle will be";
        taps = 0;
        typeOfObject = [[NSString alloc] initWithFormat:@"Rectangle"];
    }
    [tabBar setSelectedItem:nil];
    
    if (hintsOn){
        googleMapsLabel.hidden = false;
    }
    gmSearchBar.hidden = true;
    pathPenTabBar.hidden = true;
    drawButton.enabled = false;
    cancelButton.enabled = true;
}



#pragma mark CONTROL GOOGLEMAPS VIEW AND STUFF DISPLAYED ON IT

//process for free form drawing
- (void)mapView:(GMSMapView *)mapView_ didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate{
    if (selectedFreeHand){
        if (!marker && !poly){
            marker = [GMSMarker markerWithPosition:coordinate];
            marker.draggable = true;
            marker.flat = true;
            marker.map = mapView_;
            
            googleMapsLabel.text = @"Hold down on the marker, then drag the marker to from the path.";
        }
        pastBounds = false;
    }
}

- (void)mapView:(GMSMapView *)mapView_ didBeginDraggingMarker:(GMSMarker *)marker_{
    
    if (selectedFreeHand){
        firstCoordinate = [[CLLocation alloc] initWithLatitude:marker_.position.latitude longitude:marker_.position.longitude];
        [listOfCoordinates addObject:firstCoordinate];
        centerButton.enabled = true;
    }
    
    if (selectedLine){
        for (int i = 0; i < listOfCoordinates.count; i++){
            if (marker_.position.latitude == [listOfCoordinates[i] coordinate].latitude && marker_.position.longitude == [listOfCoordinates[i] coordinate].longitude){
                [chosenMarkerArray addObject:[NSNumber numberWithInt:i]];
            }
        }
    }
    
    if (selectedCircle){
        if (marker_.position.latitude == [listOfCoordinates[0] coordinate].latitude && marker_.position.longitude == [listOfCoordinates[0] coordinate].longitude){
            selectedMarker = 0;
        }
        else if (marker_.position.latitude == [listOfCoordinates[1] coordinate].latitude && marker_.position.longitude == [listOfCoordinates[1] coordinate].longitude){
            selectedMarker = 1;
        }
        else{   //third marker
            selectedMarker = 2;
        }
    }
    
    if (selectedRectangle){
        if (marker_.position.latitude == [listOfCoordinates[0] coordinate].latitude && marker_.position.longitude == [listOfCoordinates[0] coordinate].longitude){  //resize marker
            selectedMarker = 1;
        }
        else if (marker_.position.latitude == [listOfCoordinates[2] coordinate].latitude && marker_.position.longitude == [listOfCoordinates[2] coordinate].longitude){ //dimensions marker
            selectedMarker = 2;
        }
        else{   //midpoint marker
            selectedMarker = 0;
        }
    }
}

- (void)mapView:(GMSMapView *)mapView_ didDragMarker:(GMSMarker *)marker_{
    
    if (selectedFreeHand){
        
        undoButton.enabled = true;
        nextCoordinate = [[CLLocation alloc] initWithLatitude:marker_.position.latitude longitude:marker_.position.longitude];
        
        if (firstCoordinate != nextCoordinate && [self findDistanceBetween:self lat1:firstCoordinate.coordinate.latitude lng1:firstCoordinate.coordinate.longitude lat2:nextCoordinate.coordinate.latitude lng2:nextCoordinate.coordinate.longitude] >= minDistance){
            
            [listOfCoordinates addObject:nextCoordinate];
            GMSMutablePath *path = [GMSMutablePath path];
            for (int i = 0; i < listOfCoordinates.count; i++){
                [path addCoordinate:[[listOfCoordinates objectAtIndex:i] coordinate]];
            }
            poly.map = nil;
            poly.path = nil;
            poly = nil;
            poly = [GMSPolyline polylineWithPath:path];
            poly.strokeColor = [UIColor greenColor];
            poly.strokeWidth = 5;
            poly.geodesic = true;
            poly.map = mapView_;
            
            if (snapOn){
                CLLocation *location = [listOfCoordinates objectAtIndex:0];
                double lat = location.coordinate.latitude;
                double lng = location.coordinate.longitude;
                
                if (!pastBounds && [self findDistanceBetween:self lat1:lat lng1:lng lat2:nextCoordinate.coordinate.latitude lng2:nextCoordinate.coordinate.longitude] > 2*pow(10, 6)*pow(M_E, -0.657*mapView_.camera.zoom)/2){
                    pastBounds = true;
                }
                
                if (pastBounds && [self findDistanceBetween:self lat1:lat lng1:lng lat2:nextCoordinate.coordinate.latitude lng2:nextCoordinate.coordinate.longitude] <= 2*pow(10, 6)*pow(M_E, -0.657*mapView_.camera.zoom)/2){
                    googleMapsLabel.text = @"End the path inside the red circle to connect the path back to the starting point.";
                    circle.map = nil;
                    circle = nil;
                    circle = [GMSCircle circleWithPosition:location.coordinate radius:2*pow(10, 6)*pow(M_E, -0.657*mapView_.camera.zoom)/2];
                    circle.strokeWidth = 5;
                    circle.strokeColor = [UIColor redColor];
                    circle.map = mapView_;
                }
                else{
                    circle.map = nil;
                    circle = nil;
                }
            }
            firstCoordinate = nextCoordinate;
        }
    }
    if (selectedLine){
        poly.map = nil;
        poly = nil;
        
        for (int i = 0; i < chosenMarkerArray.count; i++){
            [listOfCoordinates replaceObjectAtIndex:[chosenMarkerArray[i] intValue] withObject:[[CLLocation alloc] initWithLatitude:marker_.position.latitude longitude:marker_.position.longitude]];
        }
        GMSMutablePath *path = [GMSMutablePath path];
        for (int i = 0; i < listOfCoordinates.count; i++){
            [path addCoordinate:[listOfCoordinates[i] coordinate]];
        }
        poly = [GMSPolyline polylineWithPath:path];
        poly.strokeColor = [UIColor greenColor];
        poly.strokeWidth = 5;
        poly.geodesic = true;
        poly.map = mapView_;
    }
    if (selectedCircle){
        double circRadius = 0;
        if (listOfCoordinates.count > 1) {
            circRadius = [self findDistanceBetween:self lat1:[listOfCoordinates[0] coordinate].latitude lng1:[listOfCoordinates[0] coordinate].longitude lat2:[listOfCoordinates[1] coordinate].latitude lng2:[listOfCoordinates[1] coordinate].longitude];
        }
        
        if (selectedMarker == 0){   //center
            if (listOfCoordinates.count > 1){
                circle.map = nil;
                circle = nil;
                double bearing2r = [self initialBearingBetweenLat1:[listOfCoordinates[0] coordinate].latitude Lng1:[listOfCoordinates[0] coordinate].longitude andLat2:[listOfCoordinates[1] coordinate].latitude Lng2:[listOfCoordinates[1] coordinate].longitude];
                double bearing2d = [self finalBearingBetweenLat1:[listOfCoordinates[1] coordinate].latitude Lng1:[listOfCoordinates[1] coordinate].longitude andLat2:[listOfCoordinates[0] coordinate].latitude Lng2:[listOfCoordinates[0] coordinate].longitude];
                [listOfCoordinates replaceObjectAtIndex:0 withObject:[[CLLocation alloc] initWithLatitude:marker_.position.latitude longitude:marker_.position.longitude]];
                CLLocation *radiusMarkerLocation = [self nextLocationFromStartingPoint:listOfCoordinates[0] initialBearing:bearing2r distance:circRadius];
                CLLocation *diameterMarkerLocation = [self nextLocationFromStartingPoint:listOfCoordinates[0] initialBearing:bearing2d distance:circRadius];
                [listOfCoordinates replaceObjectAtIndex:1 withObject:radiusMarkerLocation];
                
                circleRadiusMarker.map = nil;
                circleRadiusMarker = nil;
                circleRadiusMarker = [GMSMarker markerWithPosition:radiusMarkerLocation.coordinate];
                circleRadiusMarker.draggable = true;
                circleRadiusMarker.map = mapView_;
                
                circleDiameterMarker.map = nil;
                circleDiameterMarker = nil;
                circleDiameterMarker = [GMSMarker markerWithPosition:diameterMarkerLocation.coordinate];
                circleDiameterMarker.icon = [GMSMarker markerImageWithColor:[UIColor purpleColor]];
                circleDiameterMarker.draggable = true;
                circleDiameterMarker.map = mapView_;
                
                circle = [GMSCircle circleWithPosition:[listOfCoordinates[0] coordinate] radius:circRadius];
                circle.strokeColor = [UIColor greenColor];
                circle.strokeWidth = 5;
                circle.map = mapView_;
            }
        }
        
        else if (selectedMarker == 1){  //second marker (red)
            circle.map = nil;
            circle = nil;
            [listOfCoordinates replaceObjectAtIndex:1 withObject:[[CLLocation alloc] initWithLatitude:marker_.position.latitude longitude:marker_.position.longitude]];
            circRadius = [self findDistanceBetween:self lat1:[listOfCoordinates[0] coordinate].latitude lng1:[listOfCoordinates[0] coordinate].longitude lat2:[listOfCoordinates[1] coordinate].latitude lng2:[listOfCoordinates[1] coordinate].longitude];
            double bearing2d = [self finalBearingBetweenLat1:marker_.position.latitude Lng1:marker_.position.longitude andLat2:[listOfCoordinates[0] coordinate].latitude Lng2:[listOfCoordinates[0] coordinate].longitude];
            CLLocation *diameterMarkerLocation = [self nextLocationFromStartingPoint:listOfCoordinates[0] initialBearing:bearing2d distance:circRadius];
            
            circleDiameterMarker.map = nil;
            circleDiameterMarker = nil;
            circleDiameterMarker = [GMSMarker markerWithPosition:diameterMarkerLocation.coordinate];
            circleDiameterMarker.icon = [GMSMarker markerImageWithColor:[UIColor purpleColor]];
            circleDiameterMarker.draggable = true;
            circleDiameterMarker.map = mapView_;
            
            circle = [GMSCircle circleWithPosition:[listOfCoordinates[0] coordinate] radius:circRadius];
            circle.strokeColor = [UIColor greenColor];
            circle.strokeWidth = 5;
            circle.map = mapView_;
        }
        else{   //third marker
            circle.map = nil;
            circle = nil;
            CLLocation *midpoint = [self midPointFromStartingPoint:listOfCoordinates[1] finalPoint:[[CLLocation alloc] initWithLatitude:marker_.position.latitude longitude:marker_.position.longitude]];
            [listOfCoordinates replaceObjectAtIndex:0 withObject:midpoint];
            circRadius = [self findDistanceBetween:self lat1:[listOfCoordinates[1] coordinate].latitude lng1:[listOfCoordinates[1] coordinate].longitude lat2:marker_.position.latitude lng2:marker_.position.longitude]/2;
            
            circleCenterMarker.map = nil;
            circleCenterMarker = nil;
            circleCenterMarker = [GMSMarker markerWithPosition:midpoint.coordinate];
            circleCenterMarker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
            circleCenterMarker.draggable = true;
            circleCenterMarker.map = mapView_;
            
            circle = [GMSCircle circleWithPosition:[listOfCoordinates[0] coordinate] radius:circRadius];
            circle.strokeColor = [UIColor greenColor];
            circle.strokeWidth = 5;
            circle.map = mapView_;
        }
    }
    if (selectedRectangle){
        if (selectedMarker == 1){
            if (listOfCoordinates.count > 1){
                poly.map = nil;
                poly = nil;
                
                CLLocation *midpoint = [self midPointFromStartingPoint:listOfCoordinates[0] finalPoint:listOfCoordinates[2]];
                double finalBearing = [self finalBearingBetweenLat1:marker_.position.latitude Lng1:marker_.position.longitude andLat2:midpoint.coordinate.latitude Lng2:midpoint.coordinate.longitude];
                double distance = [self findDistanceBetween:self lat1:marker_.position.latitude lng1:marker_.position.longitude lat2:midpoint.coordinate.latitude lng2:midpoint.coordinate.longitude];
                CLLocation *oppositeCorner = [self nextLocationFromStartingPoint:midpoint initialBearing:finalBearing distance:distance];
                
                [listOfCoordinates removeAllObjects];
                [listOfCoordinates addObject:[[CLLocation alloc] initWithLatitude:marker_.position.latitude longitude:marker_.position.longitude]];
                [listOfCoordinates addObject:oppositeCorner];
                
                rectangleDimensionMarker.map = nil;
                rectangleDimensionMarker = nil;
                rectangleDimensionMarker = [GMSMarker markerWithPosition:[listOfCoordinates.lastObject coordinate]];
                rectangleDimensionMarker.icon = [GMSMarker markerImageWithColor:[UIColor purpleColor]];
                rectangleDimensionMarker.draggable = true;
                rectangleDimensionMarker.map = mapView_;
                
                [self redrawRectangleCoordinates];  //get other corners
                
                GMSMutablePath *path = [GMSMutablePath path];
                for (int i = 0; i < listOfCoordinates.count; i++){
                    [path addCoordinate:[listOfCoordinates[i] coordinate]];
                }
                poly.map = nil;
                poly = nil;
                poly = [GMSPolyline polylineWithPath:path];
                poly.strokeColor = [UIColor greenColor];
                poly.strokeWidth = 5;
                poly.geodesic = true;
                poly.map = mapView_;
            }
        }
        else if (selectedMarker == 2){
            poly.map = nil;
            poly = nil;
            
            CLLocation *stationaryCorner = [[CLLocation alloc] initWithLatitude:[listOfCoordinates[0] coordinate].latitude longitude:[listOfCoordinates[0] coordinate].longitude];
            [listOfCoordinates removeAllObjects];
            [listOfCoordinates addObject:stationaryCorner];
            [listOfCoordinates addObject:[[CLLocation alloc] initWithLatitude:marker_.position.latitude longitude:marker_.position.longitude]];
            CLLocation *midpoint = [self midPointFromStartingPoint:listOfCoordinates.firstObject finalPoint:listOfCoordinates.lastObject];
            
            [self redrawRectangleCoordinates];
            
            rectangleMidpointMarker.map = nil;
            rectangleMidpointMarker = nil;
            rectangleMidpointMarker = [GMSMarker markerWithPosition:midpoint.coordinate];
            rectangleMidpointMarker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
            rectangleMidpointMarker.draggable = true;
            rectangleMidpointMarker.map = mapView_;
            
            GMSMutablePath *path = [GMSMutablePath path];
            for (int i = 0; i < listOfCoordinates.count; i++){
                [path addCoordinate:[listOfCoordinates[i] coordinate]];
            }
            
            poly = [GMSPolyline polylineWithPath:path];
            poly.strokeColor = [UIColor greenColor];
            poly.strokeWidth = 5;
            poly.geodesic = true;
            poly.map = mapView_;
        }
        else{
            poly.map = nil;
            poly = nil;
            
            CLLocation *midpoint = [self midPointFromStartingPoint:listOfCoordinates[0] finalPoint:listOfCoordinates[2]];
            double initialBearing1 = [self initialBearingBetweenLat1:midpoint.coordinate.latitude Lng1:midpoint.coordinate.longitude andLat2:[listOfCoordinates[0] coordinate].latitude Lng2:[listOfCoordinates[0] coordinate].longitude];
            double initialBearing2 = [self initialBearingBetweenLat1:midpoint.coordinate.latitude Lng1:midpoint.coordinate.longitude andLat2:[listOfCoordinates[2] coordinate].latitude Lng2:[listOfCoordinates[2] coordinate].longitude];
            double distance = [self findDistanceBetween:self lat1:midpoint.coordinate.latitude lng1:midpoint.coordinate.longitude lat2:[listOfCoordinates[0] coordinate].latitude lng2:[listOfCoordinates[0] coordinate].longitude];
            
            [listOfCoordinates removeAllObjects];
            
            [listOfCoordinates addObject:[self nextLocationFromStartingPoint:[[CLLocation alloc] initWithLatitude:marker_.position.latitude longitude:marker_.position.longitude] initialBearing:initialBearing1 distance:distance]];
            [listOfCoordinates addObject:[self nextLocationFromStartingPoint:[[CLLocation alloc] initWithLatitude:marker_.position.latitude longitude:marker_.position.longitude] initialBearing:initialBearing2 distance:distance]];
            
            [self redrawRectangleCoordinates];
            
            rectangleResizeMarker.map = nil;
            rectangleResizeMarker = nil;
            rectangleResizeMarker = [GMSMarker markerWithPosition:[listOfCoordinates[0] coordinate]];
            rectangleResizeMarker.draggable = true;
            rectangleResizeMarker.map = mapView_;
            
            rectangleDimensionMarker.map = nil;
            rectangleDimensionMarker = nil;
            rectangleDimensionMarker = [GMSMarker markerWithPosition:[listOfCoordinates[2] coordinate]];
            rectangleDimensionMarker.icon = [GMSMarker markerImageWithColor:[UIColor purpleColor]];
            rectangleDimensionMarker.draggable = true;
            rectangleDimensionMarker.map = mapView_;
            
            GMSMutablePath *path = [GMSMutablePath path];
            for (int i = 0; i < listOfCoordinates.count; i++){
                [path addCoordinate:[listOfCoordinates[i] coordinate]];
            }
            poly = [GMSPolyline polylineWithPath:path];
            poly.strokeColor = [UIColor greenColor];
            poly.strokeWidth = 5;
            poly.geodesic = true;
            poly.map = mapView_;
        }
    }
}

- (void)mapView:(GMSMapView *)mapView_ didEndDraggingMarker:(GMSMarker *)marker_{
    if (selectedFreeHand){
        if (snapOn){
            CLLocation *location1 = listOfCoordinates[0];
            CLLocation *location2 = listOfCoordinates[listOfCoordinates.count-1];
            if (pastBounds && [self findDistanceBetween:self lat1:location1.coordinate.latitude lng1:location1.coordinate.longitude lat2:location2.coordinate.latitude lng2:location2.coordinate.longitude] <= 2*pow(10, 6)*pow(M_E, -0.657*mapView_.camera.zoom)/2){
                NSLog(@"ahhh");
                [listOfCoordinates addObject:listOfCoordinates[0]];
                pastBounds = false;
                circle.map = nil;
                circle = nil;
            }
        }
        
        GMSMutablePath *path = [GMSMutablePath path];
        for (int i = 0; i < listOfCoordinates.count; i++){
            [path addCoordinate:[listOfCoordinates[i] coordinate]];
        }
        poly.map = nil;
        poly.path = nil;
        poly = nil;
        marker.map = nil;
        marker = nil;
        
        poly = [GMSPolyline polylineWithPath:path];
        poly.strokeColor = [UIColor greenColor];
        poly.strokeWidth = 5;
        poly.geodesic = true;
        poly.map = mapView_;
        marker = [GMSMarker markerWithPosition:[[listOfCoordinates lastObject] coordinate]];
        marker.draggable = true;
        marker.map = mapView_;
        
        googleMapsLabel.text = @"Press done to name the path or continue drawing.";
        doneButton.enabled = true;
    }
    
    if (finishedDrawing){
        
        int coordinateNumber;
        
        double distance = [self findDistanceBetween:self lat1:marker.position.latitude lng1:marker.position.longitude lat2:[listOfCoordinates[0] coordinate].latitude lng2:[listOfCoordinates[0] coordinate].longitude];
        for (int i = 1; i < listOfCoordinates.count; i++){
            if (distance > [self findDistanceBetween:self lat1:marker.position.latitude lng1:marker.position.longitude lat2:[listOfCoordinates[i] coordinate].latitude lng2:[listOfCoordinates[i] coordinate].longitude]){
                coordinateNumber = i;
                distance = [self findDistanceBetween:self lat1:marker.position.latitude lng1:marker.position.longitude lat2:[listOfCoordinates[i] coordinate].latitude lng2:[listOfCoordinates[i] coordinate].longitude];
            }
        }
        
        stepperValue = coordinateNumber;
        coordinateStepper.value = stepperValue;
        [self changeValue:coordinateStepper];
    }
    
    if (selectedLine){
        poly.map = nil;
        poly = nil;
        for (int i = 0; i < chosenMarkerArray.count; i++){
            [listOfCoordinates replaceObjectAtIndex:[chosenMarkerArray[i] intValue] withObject:[[CLLocation alloc] initWithLatitude:marker_.position.latitude longitude:marker_.position.longitude]];
        }
        GMSMutablePath *path = [GMSMutablePath path];
        for (int i = 0; i < listOfCoordinates.count; i++){
            [path addCoordinate:[listOfCoordinates[i] coordinate]];
        }
        poly = [GMSPolyline polylineWithPath:path];
        poly.strokeColor = [UIColor greenColor];
        poly.strokeWidth = 5;
        poly.geodesic = true;
        poly.map = mapView_;
        
        [listOfDeletedCoordinates addObject:[[CLLocation alloc] initWithLatitude:marker_.position.latitude longitude:marker_.position.longitude]];
        [chosenMarkerArray addObject:[NSNumber numberWithInt:listOfDeletedCoordinates.count-1]];
        [listOfReplacedCoordinateNumbers addObject:[NSMutableArray arrayWithArray:chosenMarkerArray]];
        [chosenMarkerArray removeAllObjects];
    }
    if (selectedCircle){
        CLLocation *oldCenter = [listOfDeletedCoordinates.lastObject firstObject];
        CLLocation *oldRadius = [listOfDeletedCoordinates.lastObject lastObject];
        
        if (listOfCoordinates.count > 1){
            if ((oldCenter.coordinate.latitude != [listOfCoordinates[0] coordinate].latitude && oldCenter.coordinate.longitude != [listOfCoordinates[0] coordinate].longitude) || (oldRadius.coordinate.latitude != [listOfCoordinates[1] coordinate].latitude && oldRadius.coordinate.longitude != [listOfCoordinates[1] coordinate].longitude)){
                [listOfDeletedCoordinates addObject:[NSMutableArray arrayWithObjects:listOfCoordinates[0], listOfCoordinates[1], nil]];
            }
        }
        else{
            if (oldCenter.coordinate.latitude != marker_.position.latitude && oldCenter.coordinate.longitude != marker_.position.longitude){
                
                double markerLat = marker_.position.latitude;
                double markerLng = marker_.position.longitude;
                [listOfCoordinates removeLastObject];
                CLLocation *newCenter = [[CLLocation alloc] initWithLatitude:markerLat longitude:markerLng];
                [listOfCoordinates addObject:newCenter];
                [listOfDeletedCoordinates addObject:[NSMutableArray arrayWithArray:listOfCoordinates]];
            }
        }
        
    }
    if (selectedRectangle){
        if (listOfCoordinates.count > 1){
            CLLocation *firstCorner = [listOfDeletedCoordinates.lastObject firstObject];
            CLLocation *secondCorner = listOfDeletedCoordinates.lastObject[2];
            
            if ((firstCorner.coordinate.latitude != [listOfCoordinates[0] coordinate].latitude && firstCorner.coordinate.longitude != [listOfCoordinates[0] coordinate].longitude) || (secondCorner.coordinate.latitude != [listOfCoordinates[2] coordinate].latitude && [listOfCoordinates[2] coordinate].longitude)){
                [listOfDeletedCoordinates addObject:[NSMutableArray arrayWithArray:listOfCoordinates]];
            }
        }
        else if (listOfCoordinates.count > 0){
            [listOfCoordinates replaceObjectAtIndex:0 withObject:[[CLLocation alloc] initWithLatitude:marker_.position.latitude longitude:marker_.position.longitude]];
            [listOfDeletedCoordinates addObject:[NSMutableArray arrayWithObject:listOfCoordinates[0]]];
        }else{}
    }
    
    NSLog(@"taps: %d", taps);
    NSLog(@"listofcoordinates: %d", listOfCoordinates.count);
    NSLog(@"listofdeletedcoordinates: %d", listOfDeletedCoordinates.count);
    NSLog(@"replaced coords: %@", listOfReplacedCoordinateNumbers);
}

- (void)mapView:(GMSMapView *)mapView_ didChangeCameraPosition:(GMSCameraPosition *)position{
    if (selectedRectangle && listOfCoordinates.count == 5 && initCameraBearing != position.bearing){
        
        poly.map = nil;
        poly = nil;
        
        double deltaBearing = position.bearing-initCameraBearing;
        if (deltaBearing > 180){    //big number (from 0 to 359(
            deltaBearing = fabs(360-deltaBearing);
        }
        else if (deltaBearing < 0){ //~-1
            deltaBearing *= -1;
        }
        else if (deltaBearing > 0){ //~1
            deltaBearing *= -1;
        }else{}
        
        CLLocation *midpoint = [self midPointFromStartingPoint:listOfCoordinates[0] finalPoint:listOfCoordinates[2]];
        
        double initialBearing1 = [self initialBearingBetweenLat1:midpoint.coordinate.latitude Lng1:midpoint.coordinate.longitude andLat2:[listOfCoordinates[0] coordinate].latitude Lng2:[listOfCoordinates[0] coordinate].longitude];
        
        double initialBearing2 = [self initialBearingBetweenLat1:midpoint.coordinate.latitude Lng1:midpoint.coordinate.longitude andLat2:[listOfCoordinates[2] coordinate].latitude Lng2:[listOfCoordinates[2] coordinate].longitude];
        double distance = [self findDistanceBetween:self lat1:midpoint.coordinate.latitude lng1:midpoint.coordinate.longitude lat2:[listOfCoordinates[0] coordinate].latitude lng2:[listOfCoordinates[0] coordinate].longitude];
        initialBearing1 -= deltaBearing;
        initialBearing2 -= deltaBearing;
        if (initialBearing1 < 0){
            initialBearing1 += 360;
        }
        else if (initialBearing1 >= 360){
            initialBearing1 -= 360;
        }else{}
        if (initialBearing2 < 0){
            initialBearing2 += 360;
        }
        else if (initialBearing2 >= 360){
            initialBearing2 -= 360;
        }
        
        [listOfCoordinates removeAllObjects];
        [listOfCoordinates addObject:[self nextLocationFromStartingPoint:midpoint initialBearing:initialBearing1 distance:distance]];
        [listOfCoordinates addObject:[self nextLocationFromStartingPoint:midpoint initialBearing:initialBearing2 distance:distance]];
        
        [self redrawRectangleCoordinates];
        
        rectangleResizeMarker.map = nil;
        rectangleResizeMarker = nil;
        rectangleResizeMarker = [GMSMarker markerWithPosition:[listOfCoordinates[0] coordinate]];
        rectangleResizeMarker.draggable  =true;
        rectangleResizeMarker.map = mapView_;
        
        rectangleDimensionMarker.map = nil;
        rectangleDimensionMarker = nil;
        rectangleDimensionMarker = [GMSMarker markerWithPosition:[listOfCoordinates[2] coordinate]];
        rectangleDimensionMarker.icon = [GMSMarker markerImageWithColor:[UIColor purpleColor]];
        rectangleDimensionMarker.draggable = true;
        rectangleDimensionMarker.map = mapView_;
        
        GMSMutablePath *path = [GMSMutablePath path];
        for (int i = 0; i < listOfCoordinates.count; i++){
            [path addCoordinate:[listOfCoordinates[i] coordinate]];
        }
        poly = [GMSPolyline polylineWithPath:path];
        poly.strokeColor = [UIColor greenColor];
        poly.strokeWidth = 5;
        poly.geodesic = true;
        poly.map = mapView_;
        
        initCameraBearing = position.bearing;
    }
}

//process for lines, circles, and rectangles
- (void)mapView:(GMSMapView *)mapView_ didTapAtCoordinate:(CLLocationCoordinate2D)coordinate{
    if (selectedLine){
        if (taps == 0){
            firstCoordinateLatitude = coordinate.latitude;
            firstCoordinateLongitude = coordinate.longitude;
            [listOfCoordinates addObject:[[CLLocation alloc] initWithLatitude:firstCoordinateLatitude longitude:firstCoordinateLongitude]];
            [listOfDeletedCoordinates addObject:listOfCoordinates.lastObject];
            [listOfReplacedCoordinateNumbers addObject:[NSMutableArray arrayWithCapacity:0]];
            googleMapsLabel.text = @"Please tap at second location to finish line";
            
            GMSMarker *arrayMarker = [GMSMarker markerWithPosition:[listOfCoordinates[0] coordinate]];
            arrayMarker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
            arrayMarker.draggable = true;
            arrayMarker.map = mapView_;
            
            taps += 1;
        }
        else if (taps == 1){
            secondCoordinateLatitude = coordinate.latitude;
            secondCoordinateLongitude = coordinate.longitude;
            [listOfCoordinates addObject:[[CLLocation alloc] initWithLatitude:secondCoordinateLatitude longitude:secondCoordinateLongitude]];
            [listOfDeletedCoordinates addObject:listOfCoordinates.lastObject];
            [listOfReplacedCoordinateNumbers addObject:[NSMutableArray arrayWithCapacity:0]];
            GMSMutablePath *path = [GMSMutablePath path];
            for (int i = 0; i < listOfCoordinates.count; i++) {
                [path addCoordinate:[[listOfCoordinates objectAtIndex:i] coordinate]];
            }
            
            poly.map = nil;
            poly = nil;
            poly = [GMSPolyline polylineWithPath:path];
            poly.strokeColor = [UIColor greenColor];
            poly.strokeWidth = 5;
            poly.geodesic = true;
            poly.map = mapView_;
            googleMapsLabel.text = @"Continue adding to line or press Done to name the path.";
            
            GMSMarker *arrayMarker = [GMSMarker markerWithPosition:[listOfCoordinates[1] coordinate]];
            arrayMarker.draggable = true;
            arrayMarker.map = mapView_;
            
            taps += 1;
        }
        else{
            if (snapOn){
                CLLocation *location = [listOfCoordinates objectAtIndex:0];
                double lat = location.coordinate.latitude;
                double lng = location.coordinate.longitude;
                if ([self findDistanceBetween:self lat1:lat lng1:lng lat2:coordinate.latitude lng2:coordinate.longitude] <= 2*pow(10, 6)*pow(M_E, -0.657*mapView_.camera.zoom)/2){
                    [listOfCoordinates addObject:[listOfCoordinates objectAtIndex:0]];
                    [listOfDeletedCoordinates addObject:listOfCoordinates.lastObject];
                    [listOfReplacedCoordinateNumbers addObject:[NSMutableArray arrayWithCapacity:0]];
                }
                else{
                    [listOfCoordinates addObject:[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude]];
                    [listOfDeletedCoordinates addObject:listOfCoordinates.lastObject];
                    [listOfReplacedCoordinateNumbers addObject:[NSMutableArray arrayWithCapacity:0]];
                }
            }
            else{
                [listOfCoordinates addObject:[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude]];
                [listOfDeletedCoordinates addObject:listOfCoordinates.lastObject];
                [listOfReplacedCoordinateNumbers addObject:[NSMutableArray arrayWithCapacity:0]];
            }
            
            GMSMutablePath *path = [GMSMutablePath path];
            for (int i = 0; i < listOfCoordinates.count; i++) {
                [path addCoordinate:[[listOfCoordinates objectAtIndex:i] coordinate]];
            }
            
            poly.map = nil;
            poly = nil;
            poly = [GMSPolyline polylineWithPath:path];
            poly.strokeColor = [UIColor greenColor];
            poly.strokeWidth = 5;
            poly.geodesic = true;
            poly.map = mapView_;
            
            if (listOfCoordinates.lastObject != listOfCoordinates.firstObject){
                GMSMarker *arrayMarker = [GMSMarker markerWithPosition:[listOfCoordinates.lastObject coordinate]];
                arrayMarker.draggable = true;
                arrayMarker.map = mapView_;
            }
            
            taps += 1;
        }
    }
    if (selectedCircle){
        if (taps == 0){
            firstCoordinateLatitude = coordinate.latitude;
            firstCoordinateLongitude = coordinate.longitude;
            [listOfCoordinates addObject:[[CLLocation alloc] initWithLatitude:firstCoordinateLatitude longitude:firstCoordinateLongitude]];
            [listOfDeletedCoordinates addObject:[NSMutableArray arrayWithArray:listOfCoordinates]];
            
            circleCenterMarker.map = nil;
            circleCenterMarker = nil;
            circleCenterMarker = [GMSMarker markerWithPosition:[listOfCoordinates[0] coordinate]];
            circleCenterMarker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
            circleCenterMarker.draggable = true;
            circleCenterMarker.map = mapView_;
            
            googleMapsLabel.text = @"Please tap at second location to establish radius of circle";
            taps += 1;
        }
        else if (taps == 1){
            secondCoordinateLatitude = coordinate.latitude;
            secondCoordinateLongitude = coordinate.longitude;
            [listOfCoordinates addObject:[[CLLocation alloc] initWithLatitude:secondCoordinateLatitude longitude:secondCoordinateLongitude]];
            
            //marker for adjusting radius
            circleRadiusMarker.map = nil;
            circleRadiusMarker = nil;
            circleRadiusMarker = [GMSMarker markerWithPosition:[listOfCoordinates[1] coordinate]];
            circleRadiusMarker.draggable = true;
            circleRadiusMarker.map = mapView_;
            
            //marker for adjusting diameter
            double bearing = [self finalBearingBetweenLat1:circleRadiusMarker.position.latitude Lng1:circleRadiusMarker.position.longitude andLat2:[listOfCoordinates[0] coordinate].latitude Lng2:[listOfCoordinates[0] coordinate].longitude];
            CLLocation *oppositeCoordinate = [self nextLocationFromStartingPoint:listOfCoordinates[0] initialBearing:bearing distance:[self findDistanceBetween:self lat1:[listOfCoordinates[0] coordinate].latitude lng1:[listOfCoordinates[0] coordinate].longitude lat2:[listOfCoordinates[1] coordinate].latitude lng2:[listOfCoordinates[1] coordinate].longitude]];
            circleDiameterMarker = [GMSMarker markerWithPosition:oppositeCoordinate.coordinate];
            circleDiameterMarker.icon = [GMSMarker markerImageWithColor:[UIColor purpleColor]];
            circleDiameterMarker.draggable = true;
            circleDiameterMarker.map = mapView_;
            
            [listOfDeletedCoordinates addObject:[NSMutableArray arrayWithArray:listOfCoordinates]];
            
            //note, radious of GMSCircle is in METERS!!!!
            circle.map = nil;
            circle = nil;
            circle = [GMSCircle circleWithPosition:CLLocationCoordinate2DMake([listOfCoordinates[0] coordinate].latitude, [listOfCoordinates[0] coordinate].longitude) radius:[self findDistanceBetween:self lat1:[listOfCoordinates[0] coordinate].latitude lng1:[listOfCoordinates[0] coordinate].longitude lat2:[listOfCoordinates[1] coordinate].latitude lng2:[listOfCoordinates[1] coordinate].longitude]];
            circle.strokeColor = [UIColor greenColor];
            circle.strokeWidth = 5;
            circle.map = mapView_;
            googleMapsLabel.text = @"Press done to name the path";
            taps += 1;
        }
        else{
            googleMapsLabel.text = @"Press done to name the path";
        }
    }
    if (selectedRectangle){
        
        if (taps == 0){
            firstCoordinateLatitude = coordinate.latitude;
            firstCoordinateLongitude = coordinate.longitude;
            [listOfCoordinates addObject:[[CLLocation alloc] initWithLatitude:firstCoordinateLatitude longitude:firstCoordinateLongitude]];
            [listOfDeletedCoordinates addObject:[NSMutableArray arrayWithObject:listOfCoordinates[0]]];
            
            rectangleResizeMarker.map = nil;
            rectangleResizeMarker = nil;
            rectangleResizeMarker = [GMSMarker markerWithPosition:coordinate];
            rectangleResizeMarker.draggable = true;
            rectangleResizeMarker.map = mapView_;
            
            
            googleMapsLabel.text = @"Please tap where opposite corner of rectangle will be";
            taps += 1;
        }
        else if (taps == 1){
            secondCoordinateLatitude = coordinate.latitude;
            secondCoordinateLongitude = coordinate.longitude;
            [listOfCoordinates addObject:[[CLLocation alloc] initWithLatitude:secondCoordinateLatitude longitude:secondCoordinateLongitude]];
            
            [self redrawRectangleCoordinates];
            
            CLLocation *midpoint = [self midPointFromStartingPoint:listOfCoordinates[0] finalPoint:listOfCoordinates[2]];
            
            initCameraBearing = mapView_.camera.bearing;
            
            if (!rectangleResizeMarker){
                rectangleResizeMarker.map = nil;
                rectangleResizeMarker = nil;
                rectangleResizeMarker = [GMSMarker markerWithPosition:[listOfCoordinates[0] coordinate]];
                rectangleResizeMarker.draggable = true;
                rectangleResizeMarker.map = mapView_;
            }
            
            rectangleMidpointMarker.map = nil;
            rectangleMidpointMarker = nil;
            rectangleMidpointMarker = [GMSMarker markerWithPosition:midpoint.coordinate];
            rectangleMidpointMarker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
            rectangleMidpointMarker.draggable = true;
            rectangleMidpointMarker.map = mapView_;
            
            rectangleDimensionMarker.map = nil;
            rectangleDimensionMarker = nil;
            rectangleDimensionMarker = [GMSMarker markerWithPosition:[listOfCoordinates[2] coordinate]];
            rectangleDimensionMarker.icon = [GMSMarker markerImageWithColor:[UIColor purpleColor]];
            rectangleDimensionMarker.draggable = true;
            rectangleDimensionMarker.map = mapView_;
            
            GMSMutablePath *path = [GMSMutablePath path];
            [path addCoordinate:[listOfCoordinates[0] coordinate]];
            [path addCoordinate:[listOfCoordinates[1] coordinate]];
            [path addCoordinate:[listOfCoordinates[2] coordinate]];
            [path addCoordinate:[listOfCoordinates[3] coordinate]];
            [path addCoordinate:[listOfCoordinates[0] coordinate]];
            
            [listOfDeletedCoordinates addObject:[NSMutableArray arrayWithObjects:listOfCoordinates[0], listOfCoordinates[1], listOfCoordinates[2], listOfCoordinates[3], listOfCoordinates[4], nil]];
            
            poly.map = nil;
            poly = nil;
            poly = [GMSPolyline polylineWithPath:path];
            poly.strokeColor = [UIColor greenColor];
            poly.strokeWidth = 5;
            poly.geodesic = true;
            poly.map = mapView_;
            googleMapsLabel.text = @"Press done to name path";
            taps += 1;
        }
        else{
            googleMapsLabel.text = @"Press done to name path";
        }
    }
    if (taps > 1){
        doneButton.enabled = true;
    }
    if (taps > 0){
        undoButton.enabled = true;
    }
    
    if (listOfCoordinates.count > 0){
        centerButton.enabled = true;
    }
    
    NSLog(@"taps: %d", taps);
    NSLog(@"listofcoordinates: %d", listOfCoordinates.count);
    NSLog(@"coordinates: %@", listOfCoordinates);
    NSLog(@"listofdeletedcoordinates: %d", listOfDeletedCoordinates.count);
    NSLog(@"deletedcoordinates: %@", listOfDeletedCoordinates);
}

- (BOOL)mapView:(GMSMapView *)mapView_ didTapMarker:(GMSMarker *)marker_{
    if (selectedLine){
        if (taps > 1){
            if (snapOn && marker_.position.latitude != [listOfCoordinates.lastObject coordinate].latitude && marker_.position.longitude != [listOfCoordinates.lastObject coordinate].longitude){
                [listOfCoordinates addObject:[[CLLocation alloc] initWithLatitude:marker_.position.latitude longitude:marker_.position.longitude]];
                [listOfDeletedCoordinates addObject:listOfCoordinates.lastObject];
                GMSMutablePath *path = [GMSMutablePath path];
                for (int i = 0; i < listOfCoordinates.count; i++){
                    [path addCoordinate:[listOfCoordinates[i] coordinate]];
                }
                poly.map = nil;
                poly = nil;
                poly = [GMSPolyline polylineWithPath:path];
                poly.strokeColor = [UIColor greenColor];
                poly.strokeWidth = 5;
                poly.geodesic = true;
                poly.map = mapView_;
                
                taps++;
            }
        }
        NSLog(@"taps: %d", taps);
        NSLog(@"listofcoordinates: %d", listOfCoordinates.count);
        NSLog(@"listofdeletedcoordinates: %d", listOfDeletedCoordinates.count);
    }
    
    if (!marker_.draggable){
        [mapView_ clear];
    }
    
    return true;
}

- (void)redrawRectangleCoordinates{
    
    //algorithm for drawing rectangle always parallel to screen
    double cameraBearing = mapView.camera.bearing;
    double deltaCameraBearing = 360-cameraBearing;
    if (deltaCameraBearing == 360){
        deltaCameraBearing = 0;
    }
    
    //switch the points
    double initialBearing = [self initialBearingBetweenLat1:[listOfCoordinates[0] coordinate].latitude Lng1:[listOfCoordinates[0] coordinate].longitude andLat2:[listOfCoordinates[1] coordinate].latitude Lng2:[listOfCoordinates[1] coordinate].longitude];
    if (cameraBearing < 180){
        if (!(cameraBearing < initialBearing && initialBearing < cameraBearing+180)){
            [listOfCoordinates insertObject:listOfCoordinates[1] atIndex:0];
            [listOfCoordinates removeLastObject];
        }
    }
    else{
        if (!(cameraBearing < initialBearing || initialBearing < cameraBearing-180)){
            [listOfCoordinates insertObject:listOfCoordinates[1] atIndex:0];
            [listOfCoordinates removeLastObject];
        }
    }
    
    CLLocation *midpoint = [self midPointFromStartingPoint:listOfCoordinates[0] finalPoint:listOfCoordinates[1]];
    
    double gamma = ([self initialBearingBetweenLat1:[listOfCoordinates[0] coordinate].latitude Lng1:[listOfCoordinates[0] coordinate].longitude andLat2:[listOfCoordinates[1] coordinate].latitude Lng2:[listOfCoordinates[1] coordinate].longitude]-90+deltaCameraBearing)*M_PI/180;
    double alpha = (360-([self finalBearingBetweenLat1:[listOfCoordinates[0] coordinate].latitude Lng1:[listOfCoordinates[0] coordinate].longitude andLat2:[listOfCoordinates[1] coordinate].latitude Lng2:[listOfCoordinates[1] coordinate].longitude]+180)-deltaCameraBearing)*M_PI/180;
    double distance = [self findDistanceBetween:self  lat1:[listOfCoordinates[0] coordinate].latitude lng1:[listOfCoordinates[0] coordinate].longitude lat2:midpoint.coordinate.latitude lng2:midpoint.coordinate.longitude]*2;
    double beta = acos(sin(alpha)*sin(gamma)*cos(distance/6371/1000)-cos(alpha)*cos(gamma));
    double angleA = acos((cos(alpha)+cos(beta)*cos(gamma))/sin(beta)/sin(gamma));
    double distanceA = angleA*6371*1000;
    CLLocation *nextCoordinate2 = [self nextLocationFromStartingPoint:listOfCoordinates[0] initialBearing:90-deltaCameraBearing distance:distanceA];
    
    double initBearing = [self finalBearingBetweenLat1:nextCoordinate2.coordinate.latitude Lng1:nextCoordinate2.coordinate.longitude andLat2:midpoint.coordinate.latitude Lng2:midpoint.coordinate.longitude];
    CLLocation *nextCoordinate3 = [self nextLocationFromStartingPoint:midpoint initialBearing:initBearing distance:distance/2];
    
    //switch the points back
    if (cameraBearing < 180){
        if (!(cameraBearing < initialBearing && initialBearing < cameraBearing+180)){
            [listOfCoordinates insertObject:listOfCoordinates[1] atIndex:0];
            [listOfCoordinates removeLastObject];
        }
    }
    else{
        if (!(cameraBearing < initialBearing || initialBearing < cameraBearing-180)){
            [listOfCoordinates insertObject:listOfCoordinates[1] atIndex:0];
            [listOfCoordinates removeLastObject];
        }
    }
    
    [listOfCoordinates insertObject:nextCoordinate2 atIndex:1];
    [listOfCoordinates addObject:nextCoordinate3];
    [listOfCoordinates addObject:listOfCoordinates[0]];
    //end of algorithm
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



#pragma mark GOOGLE MAPS EQUATIONS!!!!!

//input in degrees, solution in meters
- (double)findDistanceBetween:(id)sender lat1:(double)lat1 lng1:(double)lng1 lat2:(double)lat2 lng2:(double)lng2{
    double deltaLat = lat2 - lat1;
    double deltaLng = lng2 - lng1;
    double a = pow(sin(deltaLat/2*M_PI/180), 2) + cos(lat1*M_PI/180)*cos(lat2*M_PI/180)*pow(sin(deltaLng/2*M_PI/180), 2);
    
    return 6371*2*1000*atan2(sqrt(a), sqrt(1-a));
}

//input in degrees, solution in degrees (already in geodedic mode)
- (double)initialBearingBetweenLat1:(double)lat1 Lng1:(double)lng1 andLat2:(double)lat2 Lng2:(double)lng2{
    double d2r = M_PI/180;
    double deltaLng = (lng2 - lng1)*d2r;
    lat1 *= d2r;
    lat2 *= d2r;
    
    double theta = atan2(sin(deltaLng)*cos(lat2), cos(lat1)*sin(lat2)-sin(lat1)*cos(lat2)*cos(deltaLng));
    theta /= d2r;
    if (theta < 0){
        theta += 360;
    }
    
    return theta;
}

//input in degrees, solution in degrees
- (double)finalBearingBetweenLat1:(double)lat1 Lng1:(double)lng1 andLat2:(double)lat2 Lng2:(double)lng2{
    double theta = [self initialBearingBetweenLat1:lat2 Lng1:lng2 andLat2:lat1 Lng2:lng1];
    theta += 180;
    if (theta < 360){
        return theta;
    }
    else{
        return theta -= 360;
    }
}

//input 2 locations (in degrees), solution location in degrees
- (CLLocation *)midPointFromStartingPoint:(CLLocation *)startingPoint finalPoint:(CLLocation *)finalPoint{
    double lat1 = startingPoint.coordinate.latitude*M_PI/180;
    double lng1 = startingPoint.coordinate.longitude*M_PI/180;
    double lat2 = finalPoint.coordinate.latitude*M_PI/180;
    double lng2 = finalPoint.coordinate.longitude*M_PI/180;
    double deltaLng = lng2 - lng1;
    
    double Bx = cos(lat2)*cos(deltaLng);
    double By = cos(lat2)*sin(deltaLng);
    
    double latM = atan2(sin(lat1) + sin(lat2), sqrt(pow(cos(lat1)+Bx, 2)+pow(By, 2)))*180/M_PI;
    double lngM = lng1*180/M_PI + atan2(By, cos(lat1)+Bx)*180/M_PI;
    
    return [[CLLocation alloc] initWithLatitude:latM longitude:lngM];
}

//input degrees and meters, solition in degrees
- (CLLocation *)nextLocationFromStartingPoint:(CLLocation *)startingPoint initialBearing:(double)bearing distance:(double)distance{
    distance /= 1000;
    double d2r = M_PI/180;
    bearing *= d2r;
    double R = 6371; //Earth's radius in km
    
    double lat1 = startingPoint.coordinate.latitude*d2r;
    double lng1 = startingPoint.coordinate.longitude*d2r;
    double lat2 = asin(sin(lat1)*cos(distance/R) + cos(lat1)*sin(distance/R)*cos(bearing));
    double lng2 = lng1 + atan2(sin(bearing)*sin(distance/R)*cos(lat1), cos(distance/R)-sin(lat1)*sin(lat2));
    
    return [[CLLocation alloc] initWithLatitude:lat2/d2r longitude:lng2/d2r];
}

//gets more coordinates if line, circle, or rectangle
- (void)getCoordinates{
    //UIAlertView *gettingCoordinates = [self showWaitIndicator:@"Calculating individual coordinates"];
    
    if (selectedLine || selectedFreeHand || selectedRectangle){
        
        //get distance
        if (selectedLine || selectedFreeHand){
            totalDistance = 0;
            for (int i = 1; i < listOfCoordinates.count; i++){
                totalDistance += [self findDistanceBetween:self lat1:[listOfCoordinates[i-1] coordinate].latitude lng1:[listOfCoordinates[i-1] coordinate].longitude lat2:[listOfCoordinates[i] coordinate].latitude lng2:[listOfCoordinates[i] coordinate].longitude];
            }
            firstLocation = listOfCoordinates[0];
            lastLocation = [listOfCoordinates lastObject];
        }
        else{   //rectangle
            rectanglePerimeter = 0;
            for (int i = 1; i < listOfCoordinates.count; i++){
                rectanglePerimeter += [self findDistanceBetween:self lat1:[listOfCoordinates[i-1] coordinate].latitude lng1:[listOfCoordinates[i-1] coordinate].longitude lat2:[listOfCoordinates[i] coordinate].latitude lng2:[listOfCoordinates[i] coordinate].longitude];
            }
            rectangleLength = [self findDistanceBetween:self lat1:[listOfCoordinates[0] coordinate].latitude lng1:[listOfCoordinates[0] coordinate].longitude lat2:[listOfCoordinates[1] coordinate].latitude lng2:[listOfCoordinates[1] coordinate].longitude];
            rectangleWidth = [self findDistanceBetween:self lat1:[listOfCoordinates[1] coordinate].latitude lng1:[listOfCoordinates[1] coordinate].longitude lat2:[listOfCoordinates[2] coordinate].latitude lng2:[listOfCoordinates[2] coordinate].longitude];
            if (rectangleWidth > rectangleLength){  //switch if width is greater than length
                rectangleLength = rectangleWidth;
                rectangleWidth = [self findDistanceBetween:self lat1:[listOfCoordinates[0] coordinate].latitude lng1:[listOfCoordinates[0] coordinate].longitude lat2:[listOfCoordinates[1] coordinate].latitude lng2:[listOfCoordinates[1] coordinate].longitude];
            }
            
            //get area (approximate area)
            if (mapView.camera.zoom <= 6){
                double lat1 = [[listOfCoordinates firstObject] coordinate].latitude*M_PI/180;
                double lng1 = [[listOfCoordinates firstObject] coordinate].longitude*M_PI/180;
                double lat2 = [listOfCoordinates[2] coordinate].latitude;
                double lng2 = [listOfCoordinates[2] coordinate].longitude;
                rectangleArea = M_PI/180*pow(6371*1000, 2)*fabs(sin(lat2)-sin(lat1))*fabs(lng2-lng1);
            }
            else{   //actual spherical equation works better on larger scale, but not small scale
                rectangleArea = rectangleLength*rectangleWidth;
            }
            
            corner = [[NSMutableArray alloc] init];
            for (int i = 0; i < listOfCoordinates.count-1; i++){
                [corner addObject:listOfCoordinates[i]];
            }
        }
        
        //get individual points between corners
        NSMutableArray *tempList = [[NSMutableArray alloc] init];
        for (int i = 0; i < listOfCoordinates.count-1; i++){
            [tempList insertObject:[[NSMutableArray alloc] init] atIndex:i];
        }
        
        for (int i = 1; i < listOfCoordinates.count; i++){
            CLLocation *location1 = listOfCoordinates[i-1];
            CLLocation *location2 = listOfCoordinates[i];
            double distance = [self findDistanceBetween:self lat1:location1.coordinate.latitude lng1:location1.coordinate.longitude lat2:location2.coordinate.latitude lng2:location2.coordinate.longitude];
            double bearing = [self initialBearingBetweenLat1:location1.coordinate.latitude Lng1:location1.coordinate.longitude andLat2:location2.coordinate.latitude Lng2:location2.coordinate.longitude];
            double sum = 0;
            
            int j = 0;
            while (sum <= distance) {
                location2 = [self nextLocationFromStartingPoint:location1 initialBearing:bearing distance:minDistance];
                bearing = [self finalBearingBetweenLat1:location1.coordinate.latitude Lng1:location1.coordinate.longitude andLat2:location2.coordinate.latitude Lng2:location2.coordinate.longitude];
                [tempList[i-1] insertObject:location2 atIndex:j];
                //location1 = location2;
                location1 = [self nextLocationFromStartingPoint:location1 initialBearing:bearing distance:minDistance];
                
                j++;
                sum += minDistance;
            }
            [tempList[i-1] removeLastObject];
        }
        
        int k = 1;
        for (int i = 0; i < tempList.count; i++){
            for (int j = 0; j < [tempList[i] count]; j++){
                [listOfCoordinates insertObject:tempList[i][j] atIndex:k+j];
            }
            k += [tempList[i] count]+1;
        }
    }
    else if (selectedCircle){
        double lat1 = [listOfCoordinates[0] coordinate].latitude;
        double lng1 = [listOfCoordinates[0] coordinate].longitude;
        double lat2 = [listOfCoordinates[1] coordinate].latitude;
        double lng2 = [listOfCoordinates[1] coordinate].longitude;
        double d2r = M_PI/180;
        double R = 6371*1000;    //km
        
        radius = [self findDistanceBetween:self lat1:lat1 lng1:lng1 lat2:lat2 lng2:lng2];
        CLLocation *northPoint = [self nextLocationFromStartingPoint:[[CLLocation alloc] initWithLatitude:lat1 longitude:lng1] initialBearing:0 distance:radius];
        double deltaLat = northPoint.coordinate.latitude - lat1;
        deltaLat *= d2r;    //radians
        
        circleCircumference = 2*M_PI*R*sin(deltaLat);   //meters
        circleArea = M_PI*pow(radius, 2);               //meters squared
        circleCenter = [[CLLocation alloc] initWithLatitude:lat1 longitude:lng1];
        NSLog(@"radius: %f area: %f circumference: %f", radius, circleArea, circleCircumference);
        
        double sum = 0;
        int i = 1;
        double angleA = minDistance/R;  //radians
        double angleB = radius/R;       //radians
        double alpha = 180/M_PI*acos((cos(angleA) - cos(angleB)*cos(angleB))/(sin(angleB)*sin(angleB)));
        double initialBearing = [self initialBearingBetweenLat1:lat1 Lng1:lng1 andLat2:lat2 Lng2:lng2];
        while (sum <= circleCircumference) {
            double currentBearing = initialBearing + alpha*i;
            if (currentBearing >= 360){
                currentBearing -= 360;
            }
            CLLocation *nextLocation = [self nextLocationFromStartingPoint:[[CLLocation alloc] initWithLatitude:lat1 longitude:lng1] initialBearing:currentBearing distance:radius];
            [listOfCoordinates addObject:nextLocation];
            
            i++;
            sum += minDistance;
        }
        [listOfCoordinates removeLastObject];
        [listOfCoordinates addObject:listOfCoordinates[1]];
    }else{}
    
    //[gettingCoordinates dismissWithClickedButtonIndex:0 animated:true];
}



#pragma mark CONTROL THE BUTTONS!!!

- (IBAction)searchButton:(id)sender {
    if (gmSearchBar.hidden){
        gmSearchBar.hidden = false;
    }
    else{
        gmSearchBar.hidden = true;
    }
}

- (IBAction)toolbarButton:(id)sender{
    if (buttonToolbar.hidden && pathPenTabBar.hidden){
        buttonToolbar.hidden = false;
    }
    else if (!buttonToolbar.hidden && pathPenTabBar.hidden){
        buttonToolbar.hidden = true;
    }
    else if (!buttonToolbar.hidden && !pathPenTabBar.hidden){
        buttonToolbar.hidden = true;
        pathPenTabBar.hidden = true;
    }else{}
    
    if (!coordinatesView.hidden){
        [self coordinatesSearch:self];
    }
}

- (IBAction)settingsButton:(id)sender {
    [self performSegueWithIdentifier:@"toSettings" sender:self];
}

- (IBAction)drawButton:(id)sender {
    if (pathPenTabBar.hidden){
        pathPenTabBar.hidden = false;
    }
    else{
        pathPenTabBar.hidden = true;
    }
}

- (IBAction)cancelButton:(id)sender {
    [mapView clear];
    [listOfCoordinates removeAllObjects];
    [listOfDeletedCoordinates removeAllObjects];
    [listOfReplacedCoordinateNumbers removeAllObjects];
    
    //re-enable/disable
    drawButton.enabled = true;
    cancelButton.enabled = false;
    undoButton.enabled = false;
    doneButton.enabled = false;
    saveButton.enabled = false;
    coordinatesSearch.enabled = false;
    centerButton.enabled = false;
    
    //hide
    googleMapsLabel.hidden = true;
    coordinatesView.hidden = true;
    
    //set false
    selectedFreeHand = false;
    selectedLine = false;
    selectedCircle = false;
    selectedRectangle = false;
    finishedDrawing = false;
    addedGlass = false;
    
    //set nil
    taps = 0;
    firstCoordinateLatitude = 0;
    firstCoordinateLongitude = 0;
    secondCoordinateLatitude = 0;
    secondCoordinateLongitude = 0;
    marker.map = nil;
    marker = nil;
    poly.map = nil;
    poly = nil;
}

- (IBAction)undoButton:(id)sender {
    poly.map = nil;
    poly.path = nil;
    poly = nil;
    marker.map = nil;
    marker = nil;
    
    if (selectedLine || selectedCircle || selectedRectangle){
        [mapView clear];
    }
    
    if (selectedRectangle && listOfDeletedCoordinates.count > 0){
        if (listOfDeletedCoordinates.count == 1 && listOfCoordinates.count == 1){   //just created first point
            [listOfDeletedCoordinates removeLastObject];
            [listOfCoordinates removeLastObject];
        }
        else if (listOfCoordinates.count == 1 && listOfDeletedCoordinates.count > 1){   //moved first point around
            [listOfDeletedCoordinates removeLastObject];
            listOfCoordinates = [NSMutableArray arrayWithArray:listOfDeletedCoordinates.lastObject];
            taps++;
            
        }
        else if (listOfCoordinates.count == 5 && listOfDeletedCoordinates.count == 2){  //just created full rectangle
            [listOfDeletedCoordinates removeLastObject];
            [listOfCoordinates removeAllObjects];
            listOfCoordinates = [NSMutableArray arrayWithArray:listOfDeletedCoordinates.lastObject];
            
        }
        else if (listOfCoordinates.count == 5 && listOfDeletedCoordinates.count > 2){   //after moving full rectangle
            [listOfCoordinates removeAllObjects];
            [listOfDeletedCoordinates removeLastObject];
            listOfCoordinates = [NSMutableArray arrayWithArray:listOfDeletedCoordinates.lastObject];
            if ([listOfDeletedCoordinates.lastObject count] > 1){
                taps++;
            }
        }else{}
        if (listOfCoordinates.count == 5){
            rectangleMidpointMarker.map = nil;
            rectangleMidpointMarker = nil;
            rectangleResizeMarker.map = nil;
            rectangleResizeMarker = nil;
            rectangleDimensionMarker.map = nil;
            rectangleDimensionMarker = nil;
            
            rectangleMidpointMarker = [GMSMarker markerWithPosition:[self midPointFromStartingPoint:listOfCoordinates[0] finalPoint:listOfCoordinates[2]].coordinate];
            rectangleMidpointMarker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
            rectangleMidpointMarker.draggable = true;
            rectangleMidpointMarker.map = mapView;
            
            rectangleResizeMarker = [GMSMarker markerWithPosition:[listOfCoordinates[0] coordinate]];
            rectangleResizeMarker.draggable = true;
            rectangleResizeMarker.map = mapView;
            
            rectangleDimensionMarker = [GMSMarker markerWithPosition:[listOfCoordinates[2] coordinate]];
            rectangleDimensionMarker.icon = [GMSMarker markerImageWithColor:[UIColor purpleColor]];
            rectangleDimensionMarker.draggable = true;
            rectangleDimensionMarker.map = mapView;
        }
        else if (listOfCoordinates.count == 1){
            rectangleResizeMarker.map = nil;
            rectangleResizeMarker = nil;
            rectangleMidpointMarker = [GMSMarker markerWithPosition:[listOfCoordinates[0] coordinate]];
            rectangleMidpointMarker.draggable = true;
            rectangleMidpointMarker.map = mapView;
        }else{}
    }
    else if (selectedLine){
        if ([listOfReplacedCoordinateNumbers.lastObject count] == 0){
            [listOfCoordinates removeLastObject];
            [listOfDeletedCoordinates removeLastObject];
            [listOfReplacedCoordinateNumbers removeLastObject];
        }
        else{
            taps++; //cancel out the taps--
            [listOfDeletedCoordinates removeLastObject];
            [listOfReplacedCoordinateNumbers removeLastObject];
            [listOfCoordinates removeAllObjects];
            listOfCoordinates = [NSMutableArray arrayWithArray:listOfDeletedCoordinates];
            
            for (int i = 0; i < listOfReplacedCoordinateNumbers.count; i++){
                if ([listOfReplacedCoordinateNumbers[i] count] != 0){
                    for (int j = 0; j < [listOfReplacedCoordinateNumbers[i] count]-1; j++){
                        [listOfCoordinates replaceObjectAtIndex:[listOfReplacedCoordinateNumbers[i][j] intValue] withObject:listOfDeletedCoordinates[[[listOfReplacedCoordinateNumbers[i] lastObject] intValue]]];
                    }
                    [listOfCoordinates removeObjectAtIndex:[[listOfReplacedCoordinateNumbers[i] lastObject] intValue]];
                }
            }
        }
    }
    else if (selectedCircle){
        if (listOfCoordinates.count == 1 && listOfDeletedCoordinates.count == 1){
            [listOfCoordinates removeLastObject];
            [listOfDeletedCoordinates removeLastObject];
        }
        else if (listOfCoordinates.count == 1 && listOfDeletedCoordinates.count > 1){
            [listOfCoordinates removeLastObject];
            [listOfDeletedCoordinates removeLastObject];
            listOfCoordinates = [NSMutableArray arrayWithArray:listOfDeletedCoordinates.lastObject];
            taps++;
        }
        else if (listOfCoordinates.count == 2 && listOfDeletedCoordinates.count == 2){
            [listOfCoordinates removeAllObjects];
            [listOfDeletedCoordinates removeLastObject];
            listOfCoordinates = [NSMutableArray arrayWithArray:listOfDeletedCoordinates.lastObject];
        }
        else if (listOfCoordinates.count == 2 && listOfDeletedCoordinates.count > 2){
            [listOfCoordinates removeAllObjects];
            [listOfDeletedCoordinates removeLastObject];
            listOfCoordinates = [NSMutableArray arrayWithArray:listOfDeletedCoordinates.lastObject];
            
            if ([listOfDeletedCoordinates.lastObject count] > 1){
                taps++;
            }
        }else{}
        
        if (listOfCoordinates.count == 1){
            circleCenterMarker.map = nil;
            circleCenterMarker = nil;
            circleCenterMarker = [GMSMarker markerWithPosition:[listOfCoordinates[0] coordinate]];
            circleCenterMarker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
            circleCenterMarker.draggable = true;
            circleCenterMarker.map = mapView;
        }
        else if (listOfCoordinates.count > 1){
            circle.map = nil;
            circle = nil;
            circle = [GMSCircle circleWithPosition:[listOfCoordinates[0] coordinate] radius:[self findDistanceBetween:self lat1:[listOfCoordinates[0] coordinate].latitude lng1:[listOfCoordinates[0] coordinate].longitude lat2:[listOfCoordinates[1] coordinate].latitude lng2:[listOfCoordinates[1] coordinate].longitude]];
            circle.strokeColor = [UIColor greenColor];
            circle.strokeWidth = 5;
            circle.map = mapView;
            
            circleCenterMarker.map = nil;
            circleRadiusMarker.map = nil;
            circleDiameterMarker.map = nil;
            circleCenterMarker = nil;
            circleRadiusMarker = nil;
            circleDiameterMarker = nil;
            
            circleCenterMarker = [GMSMarker markerWithPosition:[listOfCoordinates[0] coordinate]];
            circleCenterMarker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
            circleCenterMarker.draggable = true;
            circleCenterMarker.map = mapView;
            
            circleRadiusMarker = [GMSMarker markerWithPosition:[listOfCoordinates[1] coordinate]];
            circleRadiusMarker.draggable = true;
            circleRadiusMarker.map = mapView;
            
            double bearing2d = [self finalBearingBetweenLat1:[listOfCoordinates[1] coordinate].latitude Lng1:[listOfCoordinates[1] coordinate].longitude andLat2:[listOfCoordinates[0] coordinate].latitude Lng2:[listOfCoordinates[0] coordinate].longitude];
            double distance = [self findDistanceBetween:self lat1:[listOfCoordinates[0] coordinate].latitude lng1:[listOfCoordinates[0] coordinate].longitude lat2:[listOfCoordinates[1] coordinate].latitude lng2:[listOfCoordinates[1] coordinate].longitude];
            circleDiameterMarker = [GMSMarker markerWithPosition:[[self nextLocationFromStartingPoint:listOfCoordinates[0] initialBearing:bearing2d distance:distance] coordinate]];
            circleDiameterMarker.icon = [GMSMarker markerImageWithColor:[UIColor purpleColor]];
            circleDiameterMarker.draggable = true;
            circleDiameterMarker.map = mapView;
        }else{}
    }
    else{
        [listOfCoordinates removeLastObject];
    }
    
    if (listOfCoordinates.count > 0){
        if (!selectedCircle){
            GMSMutablePath *path = [GMSMutablePath path];
            for (int i = 0; i < listOfCoordinates.count; i++){
                [path addCoordinate:[listOfCoordinates[i] coordinate]];
            }
            poly = [GMSPolyline polylineWithPath:path];
            poly.strokeColor = [UIColor greenColor];
            poly.strokeWidth = 5;
            poly.geodesic = true;
            poly.map = mapView;
            
            if (selectedFreeHand){
                marker = [GMSMarker markerWithPosition:[[listOfCoordinates lastObject] coordinate]];
                marker.draggable = true;
                marker.map = mapView;
            }
        }

    }

    
    taps--;
    
    if (!selectedFreeHand && !selectedRectangle){
        if (selectedLine && listOfCoordinates.count != 0){
            GMSMarker *arrayMarker = [GMSMarker markerWithPosition:[listOfCoordinates[0] coordinate]];
            arrayMarker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
            arrayMarker.draggable = true;
            arrayMarker.map = mapView;
            //make sure markers don't repeat
            for (int i = 1; i < listOfCoordinates.count; i++){
                int errorCount = 0;
                for (int j = 0; j < i; j++){
                    if ([listOfCoordinates[i] coordinate].latitude == [listOfCoordinates[j] coordinate].latitude && [listOfCoordinates[i] coordinate].longitude == [listOfCoordinates[j] coordinate].longitude){
                        errorCount++;
                        break;
                    }
                }
                if (errorCount == 0){
                    GMSMarker *nextArrayMarker = [GMSMarker markerWithPosition:[listOfCoordinates[i] coordinate]];
                    nextArrayMarker.draggable = true;
                    nextArrayMarker.map = mapView;
                }
            }
        }
        else if (!selectedCircle){
            if (taps > 0){
                GMSMarker *marker2 = [GMSMarker markerWithPosition:[listOfCoordinates[0] coordinate]];
                marker2.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
                marker2.draggable = false;
                marker2.map = mapView;
            }
            if (taps < 2 || listOfCoordinates.count < 2){
                doneButton.enabled = false;
            }
        }else{}
    }
    
    if (taps < 1){
        if (selectedLine){
            googleMapsLabel.text = @"Please select the first point of the line";
            undoButton.enabled = false;
        }
        if (selectedCircle){
            googleMapsLabel.text = @"Please tap where the center of the circle will be";
            undoButton.enabled = false;
        }
        if (selectedRectangle){
            googleMapsLabel.text = @"Please tap where the first corner of the rectangle will be";
            undoButton.enabled = false;
        }
    }
    else if (taps < 2){
        if (selectedLine){
            googleMapsLabel.text = @"Please tap at second location to finish line.";
        }
        if (selectedCircle){
            googleMapsLabel.text = @"Please tap at second location to establish radius of circle";
        }
        if (selectedRectangle){
            googleMapsLabel.text = @"Please tap where opposite corner of rectangle will be";
        }
    }else{}
    
    if (selectedFreeHand){
        googleMapsLabel.text = @"You can continue your segment by holding down on the marker";
        if (listOfCoordinates.count < 1){
            undoButton.enabled = false;
            googleMapsLabel.text = @"You can create a new marker by holding down at a new location.";
        }
        if (listOfCoordinates.count < 2){
            doneButton.enabled = false;
        }
    }
    if (listOfCoordinates.count < 2){
        doneButton.enabled = false;
    }
    if (listOfCoordinates.count < 1){
        centerButton.enabled = false;
    }
    NSLog(@"taps: %d", taps);
    NSLog(@"listofcoordinates: %d", listOfCoordinates.count);
    NSLog(@"coordinates: %@", listOfCoordinates);
    NSLog(@"listofdeletedcoordinates: %d", listOfDeletedCoordinates.count);
    NSLog(@"deletedcoordinates: %@", listOfDeletedCoordinates);
}

- (IBAction)doneButton:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"What do you want to name this file?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    [alert addButtonWithTitle:@"Done"];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (IBAction)saveButton:(id)sender {
    
    //[activityIndicator startAnimating];
    loadingMap = [self showWaitIndicator:@"Saving Path"];
    
    marker.map = nil;
    marker = nil;
    coordinatesView.hidden = true;
    
    //take screenshot then save it to savedImages
    UIGraphicsBeginImageContext(mapView.bounds.size);
    [mapView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImagePNGRepresentation(screenShot);
    NSMutableArray *savedImages = [NSMutableArray arrayWithArray:sp.savedImages];
    [savedImages insertObject:imageData atIndex:0];
    [sp saveArray:savedImages toSavePath:@"savedImages"];
    
    //save list of coordinates as arrays of numbers
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < listOfCoordinates.count; i++) {
        double lat = [[listOfCoordinates objectAtIndex:i] coordinate].latitude;
        double lng = [[listOfCoordinates objectAtIndex:i] coordinate].longitude;
        
        NSArray *coordinates = [NSArray arrayWithObjects:[NSNumber numberWithDouble:lat], [NSNumber numberWithDouble:lng], nil];
        
        [array insertObject:coordinates atIndex:i];
    }
    
    //add extra details
    if ([typeOfObject isEqualToString:@"Free Hand"] || [typeOfObject isEqualToString:@"Line"]){
        [array insertObject:[NSNumber numberWithDouble:totalDistance] atIndex:0];
        for (int i = 0; i < 7; i++){
            [array insertObject:[NSNumber numberWithDouble:0] atIndex:1];
        }
    }
    else if ([typeOfObject isEqualToString:@"Circle"]){
        [array insertObject:[NSNumber numberWithDouble:circleArea] atIndex:0];
        [array insertObject:[NSNumber numberWithDouble:circleCircumference] atIndex:1];
        [array insertObject:[NSNumber numberWithDouble:radius] atIndex:2];
        
        for (int i = 0; i < 5; i++){
            [array insertObject:[NSNumber numberWithDouble:0] atIndex:3];
        }
    }
    else if ([typeOfObject isEqualToString:@"Rectangle"]){
        for (int i = 0; i < corner.count; i++){
            double lat = [corner[i] coordinate].latitude;
            double lng = [corner[i] coordinate].longitude;
            
            NSArray *cornerCoordinate = [NSArray arrayWithObjects:[NSNumber numberWithDouble:lat], [NSNumber numberWithDouble:lng], nil];
            
            [array insertObject:cornerCoordinate atIndex:i];
        }
        
        [array insertObject:[NSNumber numberWithDouble:rectangleArea] atIndex:0];
        [array insertObject:[NSNumber numberWithDouble:rectanglePerimeter] atIndex:1];
        [array insertObject:[NSNumber numberWithDouble:rectangleLength] atIndex:2];
        [array insertObject:[NSNumber numberWithDouble:rectangleWidth] atIndex:3];
        
    }else{}
    //
    
    [array insertObject:typeOfObject atIndex:0];
    [array insertObject:objectTitle atIndex:0];
    NSMutableArray *savedPaths = [NSMutableArray arrayWithArray:sp.savedPaths];
    [savedPaths insertObject:array atIndex:0];
    [sp saveArray:savedPaths toSavePath:@"savedPaths"];
    
    //then empty the listOfCoordinates because things are already saved
    typeOfObject = nil;
    objectTitle = nil;
    [listOfCoordinates removeAllObjects];
    finishedDrawing = false;
    addedGlass = false;
    coordinatesView.hidden = true;
    marker.map = nil;
    marker = nil;
    
    drawButton.enabled = true;
    cancelButton.enabled = false;
    undoButton.enabled = false;
    doneButton.enabled = false;
    saveButton.enabled = false;
    coordinatesSearch.enabled = false;
    centerButton.enabled = false;
    
    //[activityIndicator stopAnimating];
    [loadingMap dismissWithClickedButtonIndex:0 animated:true];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your path has been saved and can be accessed in Saved Extractions" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (IBAction)coordinatesSearch:(id)sender {
    coordinatesView.hidden = !coordinatesView.hidden;
    
    if (coordinatesView.hidden){
        marker.map = nil;
        marker = nil;
    }
    else{
        marker.map = nil;
        marker = nil;
        marker = [GMSMarker markerWithPosition:[listOfCoordinates[stepperValue] coordinate]];
        marker.draggable = true;
        marker.map = mapView;
    }
}

- (IBAction)centerButton:(id)sender {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[listOfCoordinates.firstObject coordinate].latitude longitude:[listOfCoordinates.firstObject coordinate].longitude zoom:mapView.camera.zoom];
    [mapView setCamera:camera];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:@"What do you want to name this file?"]) {
        if (buttonIndex == 1){
            
            UIAlertView *gettingCoordinates = [self showWaitIndicator:@"Calculating individual coordinates"];
            [self getCoordinates];
            [gettingCoordinates dismissWithClickedButtonIndex:0 animated:true];
             
             //keep it now
            [mapView clear];
            GMSMutablePath *path = [GMSMutablePath path];
            if (!selectedCircle){
                for (int i = 0; i < listOfCoordinates.count; i++){
                    [path addCoordinate:[listOfCoordinates[i] coordinate]];
                }
            }
            else{
                for (int i = 1; i < listOfCoordinates.count; i++){
                    [path addCoordinate:[listOfCoordinates[i] coordinate]];
                }
            }
            
            poly.map = nil;
            poly = nil;
            poly = [GMSPolyline polylineWithPath:path];
            poly.strokeColor = [UIColor redColor];
            poly.strokeWidth = 5;
            poly.geodesic = true;
            poly.map = mapView;
            finishedDrawing = true;
             //keep this now
            
            objectTitle = [[NSString alloc] initWithFormat:@"%@", [alertView textFieldAtIndex:0].text];
            
            drawButton.enabled = false;
            cancelButton.enabled = true;
            undoButton.enabled = false;
            doneButton.enabled = false;
            saveButton.enabled = true;
            coordinatesSearch.enabled = true;
            addedGlass = true;
            
            //hide
            googleMapsLabel.hidden = true;
            googleMapsLabel.text = @"Press Save to save the path later for exporting.";
            
            //set false
            selectedFreeHand = false;
            selectedLine = false;
            selectedCircle = false;
            selectedRectangle = false;
            
            //set nil
            taps = 0;
            firstCoordinateLatitude = 0;
            firstCoordinateLongitude = 0;
            secondCoordinateLatitude = 0;
            secondCoordinateLongitude = 0;
            marker.map = nil;
            marker = nil;
            
            //others
            coordinateStepper.maximumValue = listOfCoordinates.count;
            stepperValue = 0;
            [coordinateStepper setValue:stepperValue];
            NSMutableString *string = [[NSMutableString alloc] init];
            [string appendString:[NSString stringWithFormat:@"lat: %f", [listOfCoordinates[stepperValue] coordinate].latitude]];
            [string appendString:@"\r"];
            [string appendString:[NSString stringWithFormat:@"lng: %f", [listOfCoordinates[stepperValue] coordinate].longitude]];
            coordinatesLabel.text = string;
            
            [listOfDeletedCoordinates removeAllObjects];
            [listOfReplacedCoordinateNumbers removeAllObjects];
        }
    }
}

@end
