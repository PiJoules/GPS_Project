//
//  AboutUsViewController.h
//  Extraction 3.5
//
//  Created by Leonard Chan on 11/10/13.
//  Copyright (c) 2013 Leonard Chan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutUsViewController : UIViewController <UIScrollViewDelegate, UIScrollViewAccessibilityDelegate>{
    
    __weak IBOutlet UIScrollView *scroll;
}

@end
