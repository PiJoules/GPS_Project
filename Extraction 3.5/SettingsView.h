//
//  SettingsView.h
//  Extraction 3.5
//
//  Created by Leonard Chan on 10/19/13.
//  Copyright (c) 2013 Leonard Chan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface SettingsView : UITableViewController{
    
}

@property NSString *selection;
@property GMSMapViewType mapType;
@property NSString *incrementalUnit;

@end
