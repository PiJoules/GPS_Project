//
//  GoogleMaps.h
//  Extraction 3.5
//
//  Created by Leonard Chan on 9/28/13.
//  Copyright (c) 2013 Leonard Chan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <QuartzCore/QuartzCore.h>

#import "MagnifierView.h"

@interface GoogleMaps : UIViewController <GMSMapViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITabBarDelegate, UITabBarControllerDelegate, UIAlertViewDelegate, UIToolbarDelegate, UIGestureRecognizerDelegate, UINavigationBarDelegate, UISearchDisplayDelegate>{
    IBOutlet GMSMapView *mapView;
    IBOutlet UILabel *googleMapsLabel;
    IBOutlet UILabel *coordinatesLabel;
    IBOutlet UIStepper *coordinateStepper;
    IBOutlet UIView *coordinatesView;
    IBOutlet UIToolbar *buttonToolbar;
    IBOutlet UITabBar *pathPenTabBar;
    IBOutlet UISearchBar *gmSearchBar;
    IBOutlet UIBarButtonItem *drawButton;
    IBOutlet UIBarButtonItem *cancelButton;
    IBOutlet UIBarButtonItem *undoButton;
    IBOutlet UIBarButtonItem *doneButton;
    IBOutlet UIBarButtonItem *saveButton;
    IBOutlet UIBarButtonItem *coordinatesSearch;
    IBOutlet UIBarButtonItem *centerButton;
}
- (IBAction)searchButton:(id)sender;
- (IBAction)settingsButton:(id)sender;
- (IBAction)drawButton:(id)sender;
- (IBAction)cancelButton:(id)sender;
- (IBAction)undoButton:(id)sender;
- (IBAction)doneButton:(id)sender;
- (IBAction)saveButton:(id)sender;
- (IBAction)coordinatesSearch:(id)sender;
- (IBAction)centerButton:(id)sender;

@property (nonatomic, strong) NSString *searchLocation;
@property (nonatomic, strong) NSMutableArray *searches;

@end