//
//  ViewController.h
//  Extraction 3.5
//
//  Created by Leonard Chan on 9/28/13.
//  Copyright (c) 2013 Leonard Chan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface MainScreen : UIViewController <UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate>{
    IBOutlet UITableView *searchHistoryTableView;
}

@property (nonatomic, strong) NSString *initialLocation;

@end
