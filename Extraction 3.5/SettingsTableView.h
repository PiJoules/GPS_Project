//
//  SettingsTableView.h
//  Extraction 3.5
//
//  Created by Leonard Chan on 10/13/13.
//  Copyright (c) 2013 Leonard Chan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UITapGestureRecognizer.h>
#import <GoogleMaps/GoogleMaps.h>

@interface SettingsTableView : UITableViewController<UIPickerViewDelegate, UIPickerViewDataSource, UIPickerViewAccessibilityDelegate, UIGestureRecognizerDelegate>{
    
}

@property GMSMapViewType mapType;
@property NSString *incrementalUnit;

@end
