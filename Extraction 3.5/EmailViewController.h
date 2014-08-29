//
//  EmailViewController.h
//  Extraction 3.5
//
//  Created by Leonard Chan on 10/13/13.
//  Copyright (c) 2013 Leonard Chan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <DropboxSDK/DropboxSDK.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"

@interface EmailViewController : UIViewController <MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, DBRestClientDelegate, UIImagePickerControllerDelegate>{
    
    //IBOutlet UIScrollView *scrollView;
    IBOutlet UIView *labelView;
    IBOutlet UILabel *label;
    IBOutlet UISegmentedControl *unitSegmentedControl;
    
    IBOutlet UIButton *emailer;
    IBOutlet UIButton *dropboxer;
    IBOutlet UIButton *driver;
}

@property int savedPathNumber;
@property (nonatomic, readonly) DBRestClient *restClient;
@property (nonatomic, retain) GTLServiceDrive *driveService;

- (IBAction)emailButton:(id)sender;
- (IBAction)dropboxButton:(id)sender;
- (IBAction)googleDriveButton:(id)sender;

@end
