//
//  SavedExtractions.h
//  Extraction 3.5
//
//  Created by Leonard Chan on 10/9/13.
//  Copyright (c) 2013 Leonard Chan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SavedExtractions : UIViewController<UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate>{
    
    IBOutlet UITableView *savedExtractionsTableView;
    IBOutlet UIImageView *savedExtractionsImageView;
    IBOutlet UIView *subView;
    IBOutlet UILabel *locationLabel;
}

@end
