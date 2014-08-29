//
//  Settings.h
//  Extraction 3.5
//
//  Created by Leonard Chan on 10/13/13.
//  Copyright (c) 2013 Leonard Chan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProcessDataDelegate <NSObject>
@required
- (void)processSuccessful:(BOOL)success withString:(NSString *)string;
@end

@interface Settings : UITableViewController<UITableViewDataSource, UITableViewDelegate>{
    id <ProcessDataDelegate> delegate;
    IBOutlet UITableView *settingsTableView;
}

@property (retain) id delegate;

- (void)startSomeProcess;

@end