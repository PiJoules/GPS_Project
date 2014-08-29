//
//  InstructionsController.h
//  GPS Coordinate Extractor
//
//  Created by Leonard Chan on 11/17/13.
//  Copyright (c) 2013 Leonard Chan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstructionsController : UIViewController{
    IBOutlet UIScrollView *scroll;
}

@property (nonatomic, strong) NSString *previousController;

@end
