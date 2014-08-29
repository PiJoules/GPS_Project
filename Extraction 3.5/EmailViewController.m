//
//  EmailViewController.m
//  Extraction 3.5
//
//  Created by Leonard Chan on 10/13/13.
//  Copyright (c) 2013 Leonard Chan. All rights reserved.
//

#import "EmailViewController.h"
#import "savePath.h"
#import "Reachability.h"
#import <CoreLocation/CoreLocation.h>

#define FONTSIZE    14  //change this to adjust for text; if changing this, then must change the frequency a new label is created (currently at 400)

@interface EmailViewController ()

@end

static NSString *const kKeychainItemName = @"Google Drive Quickstart";
static NSString *const kClientID = @"569640802108.apps.googleusercontent.com";
static NSString *const kClientSecret = @"FeqpZK47P5BRL4_MmVayCSZy";

@implementation EmailViewController{
    
    BOOL checkedAccout;
    savePath *sp;
    
    MFMailComposeViewController *mc;
    NSMutableArray *textHolderArray;
    NSMutableArray *viewArray;
    NSMutableArray *units;
    NSMutableString *string;
    
    NSString *coordinatestitle;
    NSString *type;
    int numberOfCoordinates;
    
    //free hand/line properties
    /*NSString *firstLocation;
    NSString *lastLocation;
    NSString *totalDistance;*/
    CLLocation *firstLocation;
    CLLocation *lastLocation;
    double totalDistance;
    
    //circle properties
    /*NSString *circleArea;
    NSString *circlePerimeter;
    NSString *circleRadius;
    NSString *circleCenter;*/
    double circleArea;
    double circlePerimeter;
    double circleRadius;
    CLLocation *circleCenter;
    
    //rectangle properties
    /*NSString *rectangleArea;
    NSString *rectanglePerimeter;
    NSString *rectangleLength;
    NSString *rectangleWidth;*/
    double rectangleArea;
    double rectanglePerimeter;
    double rectangleLength;
    double rectangleWidth;
    NSMutableArray *corner;
}

@synthesize savedPathNumber;
@synthesize restClient;
@synthesize driveService;

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
    
    checkedAccout = false;
    
    [unitSegmentedControl setSelectedSegmentIndex:2];
    [unitSegmentedControl addTarget:self action:@selector(rewriteLabel) forControlEvents:UIControlEventValueChanged];
    units = [[NSMutableArray alloc] init];
    
    sp = [[savePath alloc] init];
    
    NSString *selectedIncrementalUnit = [NSString stringWithFormat:@"%@", sp.savedSettings[1]];
    int minDistance;
    
    //0.30480000001831 m = 1 ft;
    //0.91440000005494 m = 1 yd;
    //1 m = 1 m;
    //1000 m = 1 km;
    //1609.34400009669 m = 1 mi;
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithDouble:0.30480000001831], [NSNumber numberWithDouble:0.91440000005494], [NSNumber numberWithDouble:1], [NSNumber numberWithDouble:1000], [NSNumber numberWithDouble:1609.34400009669], nil] forKeys:[NSArray arrayWithObjects:@"Feet (ft)", @"Yards (yd)", @"Meters (m)", @"Kilometers (km)", @"Miles (mi)", nil]];
    NSEnumerator *keyEnumerator = [dictionary keyEnumerator];
    id key;
    while ((key = [keyEnumerator nextObject])) {
        if ([key isEqualToString:selectedIncrementalUnit]){
            minDistance = [[dictionary objectForKey:key] doubleValue];
            break;
        }
    }

    [units insertObject:[NSString stringWithFormat:@"m"] atIndex:0];
    [units insertObject:[NSString stringWithFormat:@"m\u00B2"] atIndex:1];
    
    textHolderArray = [[NSMutableArray alloc] init];
    textHolderArray = [self createStringArray:textHolderArray];
    viewArray = [[NSMutableArray alloc] init];
    

    if ([self internetConnection]){
        if (![[DBSession sharedSession] isLinked]) {
            [[DBSession sharedSession] linkFromController:self];
        }
    }
    
    label.font = [label.font fontWithSize:FONTSIZE];
    label.text = string;
    [label sizeToFit];
    [labelView setFrame:CGRectMake(labelView.frame.origin.x, labelView.frame.origin.y, labelView.frame.size.width, label.frame.size.height+label.frame.origin.y+10)];
    [emailer setFrame:CGRectMake(emailer.frame.origin.x, labelView.frame.origin.y+labelView.frame.size.height, emailer.frame.size.width, emailer.frame.size.height)];
    [dropboxer setFrame:CGRectMake(dropboxer.frame.origin.x, labelView.frame.origin.y+labelView.frame.size.height, dropboxer.frame.size.width, dropboxer.frame.size.height)];
    [driver setFrame:CGRectMake(driver.frame.origin.x, labelView.frame.origin.y+labelView.frame.size.height, driver.frame.size.width, driver.frame.size.height)];
    
    // Initialize the drive service & load existing credentials from the keychain if available
    self.driveService = [[GTLServiceDrive alloc] init];
    self.driveService.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                                         clientID:kClientID
                                                                                     clientSecret:kClientSecret];
    
    if (![self isAuthorized])
    {
        // Not yet authorized, request authorization and push the login UI onto the navigation stack.
        //[cameraUI pushViewController:[self createAuthController] animated:YES];
        [self presentViewController:[self createAuthController] animated:true completion:nil];
    }
}
/*
//google drive starts here
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Always display the camera UI.
    [self showCamera];
}

- (void)showCamera
{
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else
    {
        // In case we're running the iPhone simulator, fall back on the photo library instead.
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            [self showAlert:@"Error" message:@"Sorry, iPad Simulator not supported!"];
            return;
        }
    };
    cameraUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    cameraUI.allowsEditing = YES;
    cameraUI.delegate = self;
    //[self presentModalViewController:cameraUI animated:YES];
    [self presentViewController:cameraUI animated:true completion:nil];
    
    if (![self isAuthorized])
    {
        // Not yet authorized, request authorization and push the login UI onto the navigation stack.
        [cameraUI pushViewController:[self createAuthController] animated:YES];
    }
}

// Handle selection of an image
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:true completion:nil];
    [self uploadPhoto:image];
}

// Handle cancel from image picker/camera.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:true completion:nil];
}*/

// sending image to drive starts here
// Helper to check if user is authorized
- (BOOL)isAuthorized
{
    return [((GTMOAuth2Authentication *)self.driveService.authorizer) canAuthorize];
}

// Creates the auth controller for authorizing access to Google Drive.
- (GTMOAuth2ViewControllerTouch *)createAuthController
{
    GTMOAuth2ViewControllerTouch *authController;
    authController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDriveFile
                                                                clientID:kClientID
                                                            clientSecret:kClientSecret
                                                        keychainItemName:kKeychainItemName
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}

// Handle completion of the authorization process, and updates the Drive service
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error
{
    if (error != nil)
    {
        [self showAlert:@"Authentication Error" message:error.localizedDescription];
        self.driveService.authorizer = nil;
    }
    else
    {
        self.driveService.authorizer = authResult;
    }
}

// Uploads a photo to Google Drive
//- (void)uploadPhoto:(UIImage*)image
- (void)uploadCoordinates
{
    //NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    //[dateFormat setDateFormat:@"'Coordinates ('EEEE MMMM d, YYYY h:mm a, zzz')"];
    
    GTLDriveFile *file = [GTLDriveFile object];
    //file.title = [dateFormat stringFromDate:[NSDate date]];
    file.title = [[NSString alloc] initWithFormat:@"%@_Coordinates", sp.savedPaths[savedPathNumber][0]];
    file.descriptionProperty = @"Uploaded from the GPS Coordinate Extractor";
    //file.mimeType = @"image/png";
    file.mimeType = @"text/plain";
    
    /*//create attachment
    NSString *string3 = [NSString stringWithFormat:@"%@", [self createStringFromArray:textHolderArray]];
    //NSLog(@"%@", string);
    NSString *attachedFileName = [NSString stringWithFormat:@"%@ coordinates.txt", sp.savedPaths[savedPathNumber][0]];
    [mc addAttachmentData:[string3 dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"text/plain" fileName:attachedFileName];*/
    
    NSString *dataString = [NSString stringWithFormat:@"%@", [self createStringFromArray:textHolderArray]];
    
    //NSData *data = UIImagePNGRepresentation((UIImage *)image);
    GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithData:[dataString dataUsingEncoding:NSUTF8StringEncoding] MIMEType:file.mimeType];
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:file
                                                       uploadParameters:uploadParameters];
    
    UIAlertView *waitIndicator = [self showWaitIndicator:@"Uploading to Google Drive"];
    
    [self.driveService executeQuery:query
                  completionHandler:^(GTLServiceTicket *ticket,
                                      GTLDriveFile *insertedFile, NSError *error) {
                      [waitIndicator dismissWithClickedButtonIndex:0 animated:YES];
                      if (error == nil)
                      {
                          NSLog(@"File ID: %@", insertedFile.identifier);
                          [self showAlert:@"Google Drive" message:@"File saved!"];
                      }
                      else
                      {
                          NSLog(@"An error occurred: %@", error);
                          [self showAlert:@"Google Drive" message:@"Sorry, an error occurred!"];
                      }
                  }];
}

// Helper for showing a wait indicator in a popup
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
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.center = CGPointMake(progressAlert.bounds.size.width / 2,
                                      progressAlert.bounds.size.height - 45);
    
    [progressAlert addSubview:activityView];
    [activityView startAnimating];
    return progressAlert;
}

// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle: title
                                       message: message
                                      delegate: nil
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
    [alert show];
}
//google drive ends here

- (void)rewriteLabel{
    [units removeAllObjects];
    
    if (unitSegmentedControl.selectedSegmentIndex == 0){
        [units insertObject:[NSString stringWithFormat:@"ft"] atIndex:0];
        [units insertObject:[NSString stringWithFormat:@"ft\u00B2"] atIndex:1];
    }
    else if (unitSegmentedControl.selectedSegmentIndex == 1){
        [units insertObject:[NSString stringWithFormat:@"yd"] atIndex:0];
        [units insertObject:[NSString stringWithFormat:@"yd\u00B2"] atIndex:1];
    }
    else if (unitSegmentedControl.selectedSegmentIndex == 2){
        [units addObject:[NSString stringWithFormat:@"m"]];
        [units addObject:[NSString stringWithFormat:@"m\u00B2"]];
    }
    else if (unitSegmentedControl.selectedSegmentIndex == 3){
        [units insertObject:[NSString stringWithFormat:@"km"] atIndex:0];
        [units insertObject:[NSString stringWithFormat:@"km\u00B2"] atIndex:1];
    }
    else if (unitSegmentedControl.selectedSegmentIndex == 4){
        [units insertObject:[NSString stringWithFormat:@"mi"] atIndex:0];
        [units insertObject:[NSString stringWithFormat:@"mi\u00B2"] atIndex:1];
    }else{}
    
    //[textHolderArray removeAllObjects];
    //textHolderArray = [self createStringArray:textHolderArray];
    [self rewriteFirstPartOfString];
    label.text = string;
}

- (void)didPressLink {
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    NSLog(@"check memory");
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    //pfffttt I just copied this code, I dunno how to use switch-case, I USE IF-ELSE!!!!!!!!!
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }

    // Close the Mail Interface
    [self dismissViewControllerAnimated:true completion:nil];
    
    if (result == MFMailComposeResultSent){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"File has been sent" message:nil delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
    }
}

- (NSMutableArray *)createStringArray:(NSMutableArray *)textHolder{
    
    NSMutableArray *pathList = [NSMutableArray arrayWithArray:sp.savedPaths[savedPathNumber]];
    
    string = [[NSMutableString alloc] init];
    coordinatestitle = [NSString stringWithFormat:@"Path Name: %@ ", pathList[0]];
    type = [NSString stringWithFormat:@"Path Type: %@ ", pathList[1]];
    [string appendString:coordinatestitle];
    [string appendString:@"\r"];
    [string appendString:type];
    [string appendString:@"\r"];
    
    [string appendString:@"\r"];
    if ([pathList[1] isEqualToString:@"Free Hand"] || [pathList[1] isEqualToString:@"Line"]){
        //totalDistance = [NSString stringWithFormat:@"%@ ", pathList[2]];
        double initTotalDistance = [pathList[2] doubleValue];
        
        totalDistance = [self changeVariable:initTotalDistance toUnit:unitSegmentedControl.selectedSegmentIndex withExponent:1];
        
        //[string appendString:totalDistance];
        [string appendString:[NSString stringWithFormat:@"Length of Path: %f %@ ", totalDistance, units.firstObject]];
        [string appendString:@"\r"];
        [pathList removeObjectAtIndex:2];
        
        for (int i = 0; i < 7; i++){
            [pathList removeObjectAtIndex:2];
        }
        
        //firstLocation = [NSString stringWithFormat:@"First Point: (%@) ", pathList[2]];
        //lastLocation = [NSString stringWithFormat:@"Last Point: (%@) ", [pathList lastObject]];
        firstLocation = [[CLLocation alloc] initWithLatitude:[[pathList[2] firstObject] doubleValue] longitude:[[pathList[2] lastObject] doubleValue]];
        lastLocation = [[CLLocation alloc] initWithLatitude:[[pathList.lastObject firstObject] doubleValue] longitude:[[pathList.lastObject lastObject] doubleValue]];
        //[string appendString:firstLocation];
        [string appendString:[NSString stringWithFormat:@"First Point: (%f,%f) ", firstLocation.coordinate.latitude, firstLocation.coordinate.longitude]];
        [string appendString:@"\r"];
        //[string appendString:lastLocation];
        [string appendString:[NSString stringWithFormat:@"Last Point: (%f,%f) ", lastLocation.coordinate.latitude, lastLocation.coordinate.longitude]];
        [string appendString:@"\r"];
        
        numberOfCoordinates = pathList.count-2;
        [string appendString:@"\r"];
        [string appendString:[NSString stringWithFormat:@"Number of Points Extracted: %d ", numberOfCoordinates]];
        [string appendString:@"\r"];
    }
    else if ([pathList[1] isEqualToString:@"Circle"]){
        //circleArea = [NSString stringWithFormat:@"%@ ", pathList[2]];
        double initCircleArea = [pathList[2] doubleValue];
        circleArea = [self changeVariable:initCircleArea toUnit:unitSegmentedControl.selectedSegmentIndex withExponent:2];
        //[string appendString:circleArea];
        [string appendString:[NSString stringWithFormat:@"Area: %f %@ ", circleArea, units.lastObject]];
        [string appendString:@"\r"];
        [pathList removeObjectAtIndex:2];
        
        //circlePerimeter = [NSString stringWithFormat:@"%@ ", pathList[2]];
        double initCirclePerimeter = [pathList[2] doubleValue];
        circlePerimeter = [self changeVariable:initCirclePerimeter toUnit:unitSegmentedControl.selectedSegmentIndex withExponent:1];
        //[string appendString:circlePerimeter];
        [string appendString:[NSString stringWithFormat:@"Circumference: %f %@ ", circlePerimeter, units.firstObject]];
        [string appendString:@"\r"];
        [pathList removeObjectAtIndex:2];
        
        //circleRadius = [NSString stringWithFormat:@"%@ ", pathList[2]];
        double initCircleRadius = [pathList[2] doubleValue];
        circleRadius = [self changeVariable:initCircleRadius toUnit:unitSegmentedControl.selectedSegmentIndex withExponent:1];
        //[string appendString:circleRadius];
        [string appendString:[NSString stringWithFormat:@"Radius: %f %@ ", circleRadius, units.firstObject]];
        [string appendString:@"\r"];
        [pathList removeObjectAtIndex:2];
        
        for (int i = 0; i < 5; i++){
            [pathList removeObjectAtIndex:2];
        }
        
        //circleCenter = [NSString stringWithFormat:@"Center: (%@) ", pathList[2]];
        circleCenter = [[CLLocation alloc] initWithLatitude:[[pathList[2] firstObject] doubleValue] longitude:[[pathList[2] lastObject] doubleValue]];
        //[string appendString:circleCenter];
        [string appendString:[NSString stringWithFormat:@"Center: (%f,%f) ", circleCenter.coordinate.latitude, circleCenter.coordinate.longitude]];
        [string appendString:@"\r"];
        [pathList removeObjectAtIndex:2];
        
        numberOfCoordinates = pathList.count-2;
        [string appendString:@"\r"];
        [string appendString:[NSString stringWithFormat:@"Number of Points Extracted: %d ", numberOfCoordinates]];
        [string appendString:@"\r"];
    }
    else if ([pathList[1] isEqualToString:@"Rectangle"]){
        //rectangleArea = [NSString stringWithFormat:@"%@ ", pathList[2]];
        double initRectangleArea = [pathList[2] doubleValue];
        rectangleArea = [self changeVariable:initRectangleArea toUnit:unitSegmentedControl.selectedSegmentIndex withExponent:2];
        //[string appendString:rectangleArea];
        [string appendString:[NSString stringWithFormat:@"Area: %f %@ ", rectangleArea, units.lastObject]];
        [string appendString:@"\r"];
        [pathList removeObjectAtIndex:2];
        
        //rectanglePerimeter = [NSString stringWithFormat:@"%@ ", pathList[2]];
        double initRectanglePerimeter = [pathList[2] doubleValue];
        rectanglePerimeter = [self changeVariable:initRectanglePerimeter toUnit:unitSegmentedControl.selectedSegmentIndex withExponent:1];
        //[string appendString:rectanglePerimeter];
        [string appendString:[NSString stringWithFormat:@"Perimeter: %f %@ ", rectanglePerimeter, units.firstObject]];
        [string appendString:@"\r"];
        [pathList removeObjectAtIndex:2];
        
        //rectangleLength = [NSString stringWithFormat:@"%@ ", pathList[2]];
        double initRectangleLength = [pathList[2] doubleValue];
        rectangleLength = [self changeVariable:initRectangleLength toUnit:unitSegmentedControl.selectedSegmentIndex withExponent:1];
        //[string appendString:rectangleLength];
        [string appendString:[NSString stringWithFormat:@"Length: %f %@ ", rectangleLength, units.firstObject]];
        [string appendString:@"\r"];
        [pathList removeObjectAtIndex:2];
        
        //rectangleWidth = [NSString stringWithFormat:@"%@ ", pathList[2]];
        double initRectangleWidth = [pathList[2] doubleValue];
        rectangleWidth = [self changeVariable:initRectangleWidth toUnit:unitSegmentedControl.selectedSegmentIndex withExponent:1];
        //[string appendString:rectangleWidth];
        [string appendString:[NSString stringWithFormat:@"Width: %f %@ ", rectangleWidth, units.firstObject]];
        [string appendString:@"\r"];
        [pathList removeObjectAtIndex:2];
        
        [string appendString:@"\r"];
        corner = [[NSMutableArray alloc] init];
        
        /*[corner insertObject:[NSString stringWithFormat:@"Corner 1: (%@)", pathList[2]] atIndex:0];
        [pathList removeObjectAtIndex:2];
        [corner insertObject:[NSString stringWithFormat:@"Corner 2: (%@)", pathList[2]] atIndex:1];
        [pathList removeObjectAtIndex:2];
        [corner insertObject:[NSString stringWithFormat:@"Corner 3: (%@)", pathList[2]] atIndex:2];
        [pathList removeObjectAtIndex:2];
        [corner insertObject:[NSString stringWithFormat:@"Corner 4: (%@)", pathList[2]] atIndex:3];
        [pathList removeObjectAtIndex:2];*/
        for (int i = 2; i < 6; i++){
            CLLocation *cornerLocation = [[CLLocation alloc] initWithLatitude:[[pathList[2] firstObject] doubleValue] longitude:[[pathList[2] lastObject] doubleValue]];
            [corner insertObject:[NSString stringWithFormat:@"Corner %d: (%f,%f) ", i-1, cornerLocation.coordinate.latitude, cornerLocation.coordinate.longitude] atIndex:i-2];
            [pathList removeObjectAtIndex:2];
        }
        
        for (int i = 2; i < 6; i++) {
            [string appendString:corner[i-2]];
            [string appendString:@"\r"];
        }
        
        numberOfCoordinates = pathList.count-2;
        [string appendString:@"\r"];
        [string appendString:[NSString stringWithFormat:@"Number of Points Extracted: %d ", numberOfCoordinates]];
        [string appendString:@"\r"];
        
    }else{}
    
    [textHolder insertObject:string atIndex:0];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (int i = 2; i < [pathList count]; i++){
        //[array insertObject:pathList[i] atIndex:i-2];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[[pathList[i] firstObject] doubleValue] longitude:[[pathList[i] lastObject] doubleValue]];
        [array insertObject:[NSString stringWithFormat:@"(%f,%f)", location.coordinate.latitude, location.coordinate.longitude] atIndex:i-2];
    }
    
    NSMutableString *otherString = [[NSMutableString alloc] init];
    int i = 0;
    int j = 0;
    int k = 1;
    while (i < array.count){
        if (j == 400){
            [textHolder insertObject:otherString atIndex:k];
            k++;
            j = 0;
            otherString = nil;
            otherString = [[NSMutableString alloc] init];
        }
        
        /*if ([[NSString stringWithFormat:@"%@", array[i]] isEqualToString:[pathList lastObject]]){
            NSLog(@"%d: %@", i+1, array[i]);
        }*/
        CLLocation *lastCoordinate = [[CLLocation alloc] initWithLatitude:[[pathList.lastObject firstObject] doubleValue] longitude:[[pathList.lastObject lastObject] doubleValue]];
        if ([array[i] isEqualToString:[NSString stringWithFormat:@"(%f,%f)", lastCoordinate.coordinate.latitude, lastCoordinate.coordinate.longitude]]){
            NSLog(@"%d: %@", i+1, array[i]);
        }
        
        [otherString appendString:[NSString stringWithFormat:@"%@: %d", array[i], i+1]];
        //[otherString appendString:[NSString stringWithFormat:@"%@ ", array[i]]];
        [otherString appendString:@"\r"];
        i++;
        j++;
    }
    [textHolder insertObject:otherString atIndex:k];
    
    return textHolder;
}

- (void)rewriteFirstPartOfString{
    
    NSMutableArray *pathList = [NSMutableArray arrayWithArray:sp.savedPaths[savedPathNumber]];
    
    string = nil;
    string = [[NSMutableString alloc] init];
    coordinatestitle = [NSString stringWithFormat:@"Path Name: %@ ", pathList[0]];
    type = [NSString stringWithFormat:@"Path Type: %@ ", pathList[1]];
    [string appendString:coordinatestitle];
    [string appendString:@"\r"];
    [string appendString:type];
    [string appendString:@"\r"];
    
    [string appendString:@"\r"];
    if ([pathList[1] isEqualToString:@"Free Hand"] || [pathList[1] isEqualToString:@"Line"]){
        //totalDistance = [NSString stringWithFormat:@"%@ ", pathList[2]];
        double initTotalDistance = [pathList[2] doubleValue];
        
        totalDistance = [self changeVariable:initTotalDistance toUnit:unitSegmentedControl.selectedSegmentIndex withExponent:1];
        
        //[string appendString:totalDistance];
        [string appendString:[NSString stringWithFormat:@"Length of Path: %f %@ ", totalDistance, units.firstObject]];
        [string appendString:@"\r"];
        [pathList removeObjectAtIndex:2];
        
        for (int i = 0; i < 7; i++){
            [pathList removeObjectAtIndex:2];
        }
        
        //firstLocation = [NSString stringWithFormat:@"First Point: (%@) ", pathList[2]];
        //lastLocation = [NSString stringWithFormat:@"Last Point: (%@) ", [pathList lastObject]];
        firstLocation = [[CLLocation alloc] initWithLatitude:[[pathList[2] firstObject] doubleValue] longitude:[[pathList[2] lastObject] doubleValue]];
        lastLocation = [[CLLocation alloc] initWithLatitude:[[pathList.lastObject firstObject] doubleValue] longitude:[[pathList.lastObject lastObject] doubleValue]];
        //[string appendString:firstLocation];
        [string appendString:[NSString stringWithFormat:@"First Point: (%f,%f) ", firstLocation.coordinate.latitude, firstLocation.coordinate.longitude]];
        [string appendString:@"\r"];
        //[string appendString:lastLocation];
        [string appendString:[NSString stringWithFormat:@"Last Point: (%f,%f) ", lastLocation.coordinate.latitude, lastLocation.coordinate.longitude]];
        [string appendString:@"\r"];
        
        numberOfCoordinates = pathList.count-2;
        [string appendString:@"\r"];
        [string appendString:[NSString stringWithFormat:@"Number of Points Extracted: %d ", numberOfCoordinates]];
        [string appendString:@"\r"];
    }
    else if ([pathList[1] isEqualToString:@"Circle"]){
        //circleArea = [NSString stringWithFormat:@"%@ ", pathList[2]];
        double initCircleArea = [pathList[2] doubleValue];
        circleArea = [self changeVariable:initCircleArea toUnit:unitSegmentedControl.selectedSegmentIndex withExponent:2];
        //[string appendString:circleArea];
        [string appendString:[NSString stringWithFormat:@"Area: %f %@ ", circleArea, units.lastObject]];
        [string appendString:@"\r"];
        [pathList removeObjectAtIndex:2];
        
        //circlePerimeter = [NSString stringWithFormat:@"%@ ", pathList[2]];
        double initCirclePerimeter = [pathList[2] doubleValue];
        circlePerimeter = [self changeVariable:initCirclePerimeter toUnit:unitSegmentedControl.selectedSegmentIndex withExponent:1];
        //[string appendString:circlePerimeter];
        [string appendString:[NSString stringWithFormat:@"Circumference: %f %@ ", circlePerimeter, units.firstObject]];
        [string appendString:@"\r"];
        [pathList removeObjectAtIndex:2];
        
        //circleRadius = [NSString stringWithFormat:@"%@ ", pathList[2]];
        double initCircleRadius = [pathList[2] doubleValue];
        circleRadius = [self changeVariable:initCircleRadius toUnit:unitSegmentedControl.selectedSegmentIndex withExponent:1];
        //[string appendString:circleRadius];
        [string appendString:[NSString stringWithFormat:@"Radius: %f %@ ", circleRadius, units.firstObject]];
        [string appendString:@"\r"];
        [pathList removeObjectAtIndex:2];
        
        for (int i = 0; i < 5; i++){
            [pathList removeObjectAtIndex:2];
        }
        
        //circleCenter = [NSString stringWithFormat:@"Center: (%@) ", pathList[2]];
        circleCenter = [[CLLocation alloc] initWithLatitude:[[pathList[2] firstObject] doubleValue] longitude:[[pathList[2] lastObject] doubleValue]];
        //[string appendString:circleCenter];
        [string appendString:[NSString stringWithFormat:@"Center: (%f,%f) ", circleCenter.coordinate.latitude, circleCenter.coordinate.longitude]];
        [string appendString:@"\r"];
        [pathList removeObjectAtIndex:2];
        
        numberOfCoordinates = pathList.count-2;
        [string appendString:@"\r"];
        [string appendString:[NSString stringWithFormat:@"Number of Points Extracted: %d ", numberOfCoordinates]];
        [string appendString:@"\r"];
    }
    else if ([pathList[1] isEqualToString:@"Rectangle"]){
        //rectangleArea = [NSString stringWithFormat:@"%@ ", pathList[2]];
        double initRectangleArea = [pathList[2] doubleValue];
        rectangleArea = [self changeVariable:initRectangleArea toUnit:unitSegmentedControl.selectedSegmentIndex withExponent:2];
        //[string appendString:rectangleArea];
        [string appendString:[NSString stringWithFormat:@"Area: %f %@ ", rectangleArea, units.lastObject]];
        [string appendString:@"\r"];
        [pathList removeObjectAtIndex:2];
        
        //rectanglePerimeter = [NSString stringWithFormat:@"%@ ", pathList[2]];
        double initRectanglePerimeter = [pathList[2] doubleValue];
        rectanglePerimeter = [self changeVariable:initRectanglePerimeter toUnit:unitSegmentedControl.selectedSegmentIndex withExponent:1];
        //[string appendString:rectanglePerimeter];
        [string appendString:[NSString stringWithFormat:@"Perimeter: %f %@ ", rectanglePerimeter, units.firstObject]];
        [string appendString:@"\r"];
        [pathList removeObjectAtIndex:2];
        
        //rectangleLength = [NSString stringWithFormat:@"%@ ", pathList[2]];
        double initRectangleLength = [pathList[2] doubleValue];
        rectangleLength = [self changeVariable:initRectangleLength toUnit:unitSegmentedControl.selectedSegmentIndex withExponent:1];
        //[string appendString:rectangleLength];
        [string appendString:[NSString stringWithFormat:@"Length: %f %@ ", rectangleLength, units.firstObject]];
        [string appendString:@"\r"];
        [pathList removeObjectAtIndex:2];
        
        //rectangleWidth = [NSString stringWithFormat:@"%@ ", pathList[2]];
        double initRectangleWidth = [pathList[2] doubleValue];
        rectangleWidth = [self changeVariable:initRectangleWidth toUnit:unitSegmentedControl.selectedSegmentIndex withExponent:1];
        //[string appendString:rectangleWidth];
        [string appendString:[NSString stringWithFormat:@"Width: %f %@ ", rectangleWidth, units.firstObject]];
        [string appendString:@"\r"];
        [pathList removeObjectAtIndex:2];
        
        [string appendString:@"\r"];
        corner = [[NSMutableArray alloc] init];
        
        /*[corner insertObject:[NSString stringWithFormat:@"Corner 1: (%@)", pathList[2]] atIndex:0];
         [pathList removeObjectAtIndex:2];
         [corner insertObject:[NSString stringWithFormat:@"Corner 2: (%@)", pathList[2]] atIndex:1];
         [pathList removeObjectAtIndex:2];
         [corner insertObject:[NSString stringWithFormat:@"Corner 3: (%@)", pathList[2]] atIndex:2];
         [pathList removeObjectAtIndex:2];
         [corner insertObject:[NSString stringWithFormat:@"Corner 4: (%@)", pathList[2]] atIndex:3];
         [pathList removeObjectAtIndex:2];*/
        for (int i = 2; i < 6; i++){
            CLLocation *cornerLocation = [[CLLocation alloc] initWithLatitude:[[pathList[2] firstObject] doubleValue] longitude:[[pathList[2] lastObject] doubleValue]];
            [corner insertObject:[NSString stringWithFormat:@"Corner %d: (%f,%f) ", i-1, cornerLocation.coordinate.latitude, cornerLocation.coordinate.longitude] atIndex:i-2];
            [pathList removeObjectAtIndex:2];
        }
        
        for (int i = 2; i < 6; i++) {
            [string appendString:corner[i-2]];
            [string appendString:@"\r"];
        }
        
        numberOfCoordinates = pathList.count-2;
        [string appendString:@"\r"];
        [string appendString:[NSString stringWithFormat:@"Number of Points Extracted: %d ", numberOfCoordinates]];
        [string appendString:@"\r"];
        
    }else{}
    
    [textHolderArray replaceObjectAtIndex:0 withObject:string];
}

- (NSString *)createStringFromArray:(NSArray *)textHolder{
    NSMutableString *string2 = [[NSMutableString alloc] init];
    for (int i = 0; i < textHolder.count; i++){
        [string2 appendString:textHolder[i]];
    }
    return string2;
}

- (IBAction)emailButton:(id)sender {
    
    // Email Subject
    NSString *emailTitle = [NSString stringWithFormat:@"GPS Coordinate Extractions: %@", sp.savedPaths[savedPathNumber][0]];
    // Email Content (w/HTML EDITING!!!!)
    //NSString *messageBody = @"Like us on Myspace and 4chan!!!!!";
    NSString *messageBody = @"";
    // To address
    //NSArray *toRecipents = [NSArray arrayWithObject:@"enteryourcreditcardnumberhere@totallyrealwebsite.gov"];
    NSArray *toRecipents = [NSArray arrayWithObject:@""];
    
    mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:true];
    [mc setToRecipients:toRecipents];
    
    //create attachment
    NSString *string3 = [NSString stringWithFormat:@"%@", [self createStringFromArray:textHolderArray]];
    //NSLog(@"%@", string);
    NSString *attachedFileName = [NSString stringWithFormat:@"%@_coordinates.txt", sp.savedPaths[savedPathNumber][0]];
    [mc addAttachmentData:[string3 dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"text/plain" fileName:attachedFileName];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:true completion:nil];
}

- (IBAction)dropboxButton:(id)sender {
    
    UIAlertView *alertIndicator = [self showWaitIndicator:@"Sending File"];
    
    // Build the path, and create if needed.
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileName = [NSString stringWithFormat:@"%@_Coordinates.txt", sp.savedPaths[savedPathNumber][0]];
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    
    // The main act...
    [[[NSString stringWithFormat:@"%@", [self createStringFromArray:textHolderArray]] dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO];

    
    [[self restClient] uploadFile:fileName toPath:@"/" withParentRev:nil fromPath:fileAtPath];
    
    [alertIndicator dismissWithClickedButtonIndex:0 animated:true];
}

- (IBAction)googleDriveButton:(id)sender {
    //[self showCamera];
    
    /*if (![self isAuthorized])
    {
        // Not yet authorized, request authorization and push the login UI onto the navigation stack.
        //[cameraUI pushViewController:[self createAuthController] animated:YES];
        [self presentViewController:[self createAuthController] animated:true completion:^{checkedAccout = true;}];
    }
    else if (checkedAccout){*/
        [self uploadCoordinates];
    //}else{}
}

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"File uploaded successfully" message:nil delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
    [alert show];
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    NSLog(@"File upload failed with error - %@", error);
    
    self.driveService = [[GTLServiceDrive alloc] init];
    self.driveService.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                                         clientID:kClientID
                                                                                     clientSecret:kClientSecret];
    
    //if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    //}
    [self dropboxButton:self];
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

- (double)changeVariable:(double)variable toUnit:(int)unitSelection withExponent:(int)exponent{
    
    //0.30480000001831 m = 1 ft;
    //0.91440000005494 m = 1 yd;
    //1 m = 1 m;
    //1000 m = 1 km;
    //1609.34400009669 m = 1 mi;
    
    if (unitSelection == 0){
        variable /= pow(0.30480000001831, exponent);
    }
    else if (unitSelection == 1){
        variable /= pow(0.91440000005494, exponent);
    }
    else if (unitSelection == 2){
        variable = variable;
    }
    else if (unitSelection == 3){
        variable /= pow(1000, exponent);
    }
    else if (unitSelection == 4){
        variable /= pow(1609.34400009669, exponent);
    }
    else{
        variable = variable;
    }
    
    return variable;
}

@end
