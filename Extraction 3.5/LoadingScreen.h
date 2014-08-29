//
//  LoadingScreen.h
//  Extraction 3.5
//
//  Created by Leonard Chan on 9/28/13.
//  Copyright (c) 2013 Leonard Chan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LoadingScreen : UIViewController<CLLocationManagerDelegate>{
    __weak IBOutlet UIImageView *firstImage;
}

@end
