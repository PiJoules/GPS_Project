//
//  InstructionsController.m
//  GPS Coordinate Extractor
//
//  Created by Leonard Chan on 11/17/13.
//  Copyright (c) 2013 Leonard Chan. All rights reserved.
//

#import "InstructionsController.h"

#define FONTSIZE 12
#define LINESTART 22
#define LINEEND 44

@interface InstructionsController ()

@end

@implementation InstructionsController

@synthesize previousController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if ([previousController isEqualToString:@"Main Screen"]){
        scroll = [self mainScreenScroll];
    }
    if ([previousController isEqualToString:@"Exporting Saved Paths"]){
        scroll = [self exportingPaths];
    }
    if ([previousController isEqualToString:@"Google Maps Interface"]){
        scroll = [self GMInterface];
    }
    if ([previousController isEqualToString:@"Google Maps Settings"]){
        scroll = [self GMSettings];
    }
    if ([previousController isEqualToString:@"Free Hand Drawings"]){
        scroll = [self freeHandInstructions];
    }
    if ([previousController isEqualToString:@"Line Drawings"]){
        scroll = [self lineInstructions];
    }
    if ([previousController isEqualToString:@"Circle Drawings"]){
        scroll = [self circleInstructions];
    }
    if ([previousController isEqualToString:@"Rectangle Drawings"]){
        scroll = [self rectangleInstructions];
    }
    if ([previousController isEqualToString:@"Reviewing Coordinates"]){
        scroll = [self reviewingCoordinates];
    }
    
    self.view = scroll;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIScrollView *)mainScreenScroll{
    
    UIScrollView *mainScreen = [[UIScrollView alloc] initWithFrame:self.view.frame];
    mainScreen.backgroundColor = [UIColor whiteColor];
    //mainScreen.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BACKGROUND]];
    
    UILabel *title1 = [self bigBoldTitleWithArea:CGRectMake(5, 5, mainScreen.frame.size.width-10, mainScreen.frame.size.height) title:@"Understanding the Main Screen" addToScrollView:mainScreen];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/8, 10+title1.frame.size.height+title1.frame.origin.y, self.view.frame.size.width*3/4, self.view.frame.size.height*3/4)];
    imageView.image = [UIImage imageNamed:@"MainScreen.png"];
    
    UILabel *introLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, imageView.frame.size.height+imageView.frame.origin.y+10, self.view.frame.size.width-10, self.view.frame.size.height)];
    introLabel.numberOfLines = 0;
    introLabel.font = [UIFont italicSystemFontOfSize:FONTSIZE];
    introLabel.text = @"The Main Screen contains the directory that allows you to navigate through this app, and a list of your recent search history that you entered while on the map. Just tap on the row, and you will be directed to a different page in the app.";
    [introLabel sizeToFit];
    [introLabel setFrame:CGRectMake(mainScreen.frame.size.width/2-introLabel.frame.size.width/2, introLabel.frame.origin.y, introLabel.frame.size.width, introLabel.frame.size.height)];
    
    UILabel *lineLabel = [self lineLabelWithArea:CGRectMake(22, 10+introLabel.frame.size.height+introLabel.frame.origin.y, mainScreen.frame.size.width-44, mainScreen.frame.size.height) addToScrollView:mainScreen];
    
    UILabel *title2 = [self boldTitleWithArea:CGRectMake(5, 10+lineLabel.frame.size.height+lineLabel.frame.origin.y, mainScreen.frame.size.width-10, mainScreen.frame.size.height) title:@"Directory" addToScrollView:mainScreen];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, title2.frame.size.height+title2.frame.origin.y+2, self.view.frame.size.width-10, self.view.frame.size.height)];
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    label.font = [label.font fontWithSize:FONTSIZE];
    label.text = @"\u2022New Search - This brings you to the map provided by Google Maps. Here is where you draw your paths for exporting later. The default location on the map is set to Drexel university.\r\r\u2022Saved Extractions - Here is where you can see a list of all your saved paths drawn on the map. From here, you can see the different paths you have drawn and where they are located.\r\r\u2022About This App - Here is where you can learn more about the purpose and features of this app.\r\r\u2022References/Instructions - If you ever forget how to perform a certain function or what a button does, you can refer to here on the various functions on this app.\r\r\u2022Clear All Data - If you have too much data stored on the app, you can clear all your search history and saved paths here.";
    [label sizeToFit];
    [label setFrame:CGRectMake(mainScreen.frame.size.width/2-label.frame.size.width/2, label.frame.origin.y, label.frame.size.width, label.frame.size.height)];
    
    UILabel *title3 = [self boldTitleWithArea:CGRectMake(5, 10+label.frame.size.height+label.frame.origin.y, mainScreen.frame.size.width-10, mainScreen.frame.size.height) title:@"Recent Searches" addToScrollView:mainScreen];
    
    NSString *descr1 = [[NSString alloc] init];
    descr1 = @"The section on the bottom of the screen contains a list of all locations you have searched on the map. Clicking on these will bring you to the map starting at that location.";
    UILabel *label2 = [self stringLabel:CGRectMake(5, 2+title3.frame.size.height+title3.frame.origin.y, mainScreen.frame.size.width-10, mainScreen.frame.size.height) string:descr1 addToScrollView:mainScreen];
    
    //[mainScreen setContentSize:CGSizeMake(mainScreen.contentSize.width, 50+imageView.frame.size.height+imageView.frame.origin.y + label.frame.size.height + introLabel.frame.size.height)];
    [mainScreen setContentSize:CGSizeMake(mainScreen.contentSize.width, 30+label2.frame.size.height+label2.frame.origin.y)];
    [mainScreen addSubview:imageView];
    [mainScreen addSubview:introLabel];
    [mainScreen addSubview:label];
    
    return mainScreen;
}

- (UIScrollView *)GMInterface{
    
    UIScrollView *tempScroll = [[UIScrollView alloc] initWithFrame:self.view.frame];
    //tempScroll.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BACKGROUND]];
    tempScroll.backgroundColor = [UIColor whiteColor];
    
    UILabel *title1 = [self bigBoldTitleWithArea:CGRectMake(5, 5, tempScroll.frame.size.width, tempScroll.frame.size.height) title:@"Understanding the Map Interface" addToScrollView:tempScroll];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/8, 10+title1.frame.size.height+title1.frame.origin.y, self.view.frame.size.width*3/4, self.view.frame.size.height*3/4)];
    imageView.image = [UIImage imageNamed:@"GMInterface.png"];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, imageView.frame.origin.y+imageView.frame.size.height+10, tempScroll.frame.size.width-10, tempScroll.frame.size.height)];
    label.numberOfLines = 0;
    label.font = [UIFont italicSystemFontOfSize:FONTSIZE];
    label.text = @"This is the Google Maps interface on which you can draw paths and search for locations. Upon first loading the map, a blue marker will appear containing showing the default address. Tapping on this marker will make it disappear. A button that is blue is enabled and can be pressed, but a button that is gray is cannot be used at the moment and is disabled.";
    [label sizeToFit];
    [label setFrame:CGRectMake(tempScroll.frame.size.width/2-label.frame.size.width/2, label.frame.origin.y, label.frame.size.width, label.frame.size.height)];
    
    UILabel *lineLabel1 = [self lineLabelWithArea:CGRectMake(LINESTART, 10+label.frame.size.height+label.frame.origin.y, tempScroll.frame.size.width-LINEEND, tempScroll.frame.size.height) addToScrollView:tempScroll];
    
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/4, 20+lineLabel1.frame.size.height+lineLabel1.frame.origin.y, self.view.frame.size.width/2, 40)];
    imageView2.image = [UIImage imageNamed:@"topbuttons.png"];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(5, imageView2.frame.origin.y+imageView2.frame.size.height+10, tempScroll.frame.size.width-10, tempScroll.frame.size.height)];
    label2.numberOfLines = 0;
    label2.font = [label2.font fontWithSize:FONTSIZE];
    label2.text = @"\u2022The gear button brings you to the settings where you can adjust different features of the map.\r\r\u2022The middle button toggles the visibility of the toolbar on the bottom of the screen. You can hide the toolbar if you need more room for drawing, and show it when you are finsihed drawing.\r\r\u2022The magnifying glass toggles the visibility of the search bar. Enter an address in the search bar to move the map to that location. When drawing, the user can also drag markers to edit the path.";
    [label2 sizeToFit];
    [label2 setFrame:CGRectMake(tempScroll.frame.size.width/2-label2.frame.size.width/2, label2.frame.origin.y, label2.frame.size.width, label2.frame.size.height)];
    
    UILabel *lineLabel2 = [self lineLabelWithArea:CGRectMake(LINESTART, 10+label2.frame.size.height+label2.frame.origin.y, tempScroll.frame.size.width-LINEEND, tempScroll.frame.size.height) addToScrollView:tempScroll];
    
    UIImageView *imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/8, 20+lineLabel2.frame.size.height+lineLabel2.frame.origin.y, self.view.frame.size.width*3/4, 30)];
    imageView3.image = [UIImage imageNamed:@"bottombuttons.png"];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(5, imageView3.frame.origin.y+imageView3.frame.size.height+10, tempScroll.frame.size.width-10, tempScroll.frame.size.height)];
    label3.numberOfLines = 0;
    label3.font = [label3.font fontWithSize:FONTSIZE];
    label3.text = @"\u2022The first button toggles the tab bar containing the various types of paths you can draw on the map.\r\r\u2022The X button will clear any paths on the map and cancel the user's drawing.\r\r\u2022While drawing, pressing the Undo button will undo the user's previous action.\r\r\u2022Once the user is done drawing their path, tapping the Done button will prevent the user from drawing anymore and extract the individual coordinates that make uo the path. The user then has the option of immediately saving the path or review the path first.\r\r\u2022The Save button saves the path for exporting later.\r\r\u2022The triangle button allows the user to observe the individual points that make up the path by dragging the red marker that will appear.\r\r\u2022The last button will move the map to the first point of a path that is currently on the map.";
    [label3 sizeToFit];
    [label3 setFrame:CGRectMake(tempScroll.frame.size.width/2-label3.frame.size.width/2, label3.frame.origin.y, label3.frame.size.width, label3.frame.size.height)];
    
    //[tempScroll setContentSize:CGSizeMake(tempScroll.frame.size.width, 50+imageView.frame.origin.y+imageView.frame.size.height+label.frame.size.height+imageView2.frame.size.height+label2.frame.size.height+imageView3.frame.size.height+label3.frame.size.height)];
    [tempScroll setContentSize:CGSizeMake(tempScroll.frame.size.width, 30+label3.frame.origin.y+label3.frame.size.height)];
    [tempScroll addSubview:imageView];
    [tempScroll addSubview:label];
    [tempScroll addSubview:imageView2];
    [tempScroll addSubview:label2];
    [tempScroll addSubview:imageView3];
    [tempScroll addSubview:label3];
    
    return tempScroll;
}

- (UIScrollView *)GMSettings{
    
    UIScrollView *tempScroll = [[UIScrollView alloc] initWithFrame:self.view.frame];
    tempScroll.backgroundColor = [UIColor whiteColor];
    
    UILabel *title1 = [self bigBoldTitleWithArea:CGRectMake(5, 5, tempScroll.frame.size.width-10, tempScroll.frame.size.height) title:@"Understanding the Map Settings" addToScrollView:tempScroll];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/8, 10+title1.frame.size.height+title1.frame.origin.y, self.view.frame.size.width*3/4, self.view.frame.size.height*3/4)];
    imageView.image = [UIImage imageNamed:@"GMSettings.png"];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, imageView.frame.origin.y+imageView.frame.size.height+10, tempScroll.frame.size.width-10, tempScroll.frame.size.height)];
    label.numberOfLines = 0;
    label.font = [UIFont italicSystemFontOfSize:FONTSIZE];
    label.text = @"These are the settings for the map. Toggling and changing them will adjust various features on the map.";
    [label sizeToFit];
    [label setFrame:CGRectMake(tempScroll.frame.size.width/2-label.frame.size.width/2, label.frame.origin.y, label.frame.size.width, label.frame.size.height)];
    
    UILabel *lineLabel1 = [self lineLabelWithArea:CGRectMake(LINESTART, 10+label.frame.size.height+label.frame.origin.y, tempScroll.frame.size.width-LINEEND, tempScroll.frame.size.height) addToScrollView:tempScroll];
    
    UILabel *title2 = [self boldTitleWithArea:CGRectMake(5, 10+lineLabel1.frame.size.height+lineLabel1.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) title:@"Settings" addToScrollView:tempScroll];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(5, title2.frame.origin.y+title2.frame.size.height+2, tempScroll.frame.size.width-10, tempScroll.frame.size.height)];
    label2.numberOfLines = 0;
    label2.font = [label2.font fontWithSize:FONTSIZE];
    label2.text = @"\u2022Map Type - The map style in which Google Maps will be displayed. The default is Normal.\r\r\u2022Incremental Units - When the user finsihes drawing, coordinates are then extracted every incremental unit. The incremental units range from Feet (ft) to Miles (mi). The default is in Meters (m).\r\r\u2022Snap to starting point - While drawing a path using Free Hand or Line, the user has can snap the last point in the path to the first point. For Free Hand, a red circle will appear indicating you can snap the end of the path to its starting point. For Line, tapping at an already existing marker will snap the path to that marker.\r\r\u2022Hints - While drawing, several hint boxes are displayed at the top of the screen. The hints can be toggled on and off if there is not enough space on the map to draw.";
    [label2 sizeToFit];
    [label2 setFrame:CGRectMake(tempScroll.frame.size.width/2-label2.frame.size.width/2, label2.frame.origin.y, label2.frame.size.width, label2.frame.size.height)];
    
    [tempScroll setContentSize:CGSizeMake(tempScroll.frame.size.width, 30+label2.frame.size.height+label2.frame.origin.y)];
    [tempScroll addSubview:imageView];
    [tempScroll addSubview:label];
    [tempScroll addSubview:label2];
    
    return tempScroll;
}

- (UIScrollView *)freeHandInstructions{
    
    UIScrollView *tempScroll = [[UIScrollView alloc] initWithFrame:self.view.frame];
    tempScroll.backgroundColor = [UIColor whiteColor];
    
    UILabel *title1 = [self bigBoldTitleWithArea:CGRectMake(5, 5, tempScroll.frame.size.width, tempScroll.frame.size.height) title:@"Drawing a Free Hand Line" addToScrollView:tempScroll];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/8, 10+title1.frame.size.height+tempScroll.frame.origin.y, self.view.frame.size.width*3/4, self.view.frame.size.height*3/4)];
    imageView.image = [UIImage imageNamed:@"tabbar.png"];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, imageView.frame.origin.y+imageView.frame.size.height+10, tempScroll.frame.size.width-10, tempScroll.frame.size.height)];
    label.numberOfLines = 0;
    label.font = [label.font fontWithSize:FONTSIZE];
    label.text = @"1. To begin drawing a Free Hand path, select the compose button on the left side of the bottom toolbar. Then select the tab named Free Hand.";
    [label sizeToFit];
    [label setFrame:CGRectMake(tempScroll.frame.size.width/2-label.frame.size.width/2, label.frame.origin.y, label.frame.size.width, label.frame.size.height)];
    
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/8, 20+label.frame.size.height+label.frame.origin.y, self.view.frame.size.width*3/4, tempScroll.frame.size.height*3/4)];
    imageView2.image = [UIImage imageNamed:@"freehand1.png"];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(5, imageView2.frame.origin.y+imageView2.frame.size.height+10, tempScroll.frame.size.width-10, tempScroll.frame.size.height)];
    label2.numberOfLines = 0;
    label2.font = [label2.font fontWithSize:FONTSIZE];
    label2.text = @"2. Press down at a location until a marker appears on the screen.";
    [label2 sizeToFit];
    [label2 setFrame:CGRectMake(tempScroll.frame.size.width/2-label2.frame.size.width/2, label2.frame.origin.y, label2.frame.size.width, label2.frame.size.height)];
    
    UIImageView *imageView3 = [self screenCaptureAfterView:label2 image:@"freehand2.png" addToScrollView:tempScroll];
    
    NSString *string = [[NSString alloc] init];
    string = @"3. Once the marker appears, press down on it until the screen shifts slightly upwards. Now you can draw your path by dragging the marker. The map shift will always be what indicates when you can start dragging the marker.";
    UILabel *label3 = [self stringLabel:CGRectMake(5, 10+imageView3.frame.size.height+imageView3.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string addToScrollView:tempScroll];
    
    UIImageView *imageView4 = [self screenCaptureAfterView:label3 image:@"freehand3" addToScrollView:tempScroll];
    
    NSString *string2 = [[NSString alloc] init];
    string2 = @"4. Take your finger off the marker to stop drawing. From here on, you can either finish drawing by pressing the Done button or continue drawing by pressing on the marker (until the map shifts) and dragging it again. In the event you make a mistake, you can press the Undo button to erase the last coordinate that makes up the path. If you want to stop alltogether, you can do so by pressing the X button to clear the map and stop the drawing process.";
    UILabel *label4 = [self stringLabel:CGRectMake(5, 10+imageView4.frame.size.height+imageView4.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string2 addToScrollView:tempScroll];
    
    UIImageView *imageView5 = [self screenCaptureAfterView:label4 image:@"freehand4" addToScrollView:tempScroll];
    
    NSString *string3 = [[NSString alloc] init];
    string3 = @"5. If you have the map setting 'Snap to starting point' set On, then ending your path near its starting point will cause a red circle to appear around your starting point. Release the marker within the red circle to automatically snap the path to the starting point.";
    UILabel *label5 = [self stringLabel:CGRectMake(5, 10+imageView5.frame.size.height+imageView5.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string3 addToScrollView:tempScroll];
    
    UIImageView *imageView6 = [self screenCaptureAfterView:label5 image:@"freehand5" addToScrollView:tempScroll];
    
    NSString *string4 = [[NSString alloc] init];
    string4 = @"6. When you are finished drawing, press the Done button to finish your path. You will then have the option of going back to continue drawing by hitting Cancel, or finish your path for review then saving.";
    UILabel *label6 = [self stringLabel:CGRectMake(5, 10+imageView6.frame.size.height+imageView6.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string4 addToScrollView:tempScroll];
    
    UIImageView *imageView7 = [self screenCaptureAfterView:label6 image:@"freehand6" addToScrollView:tempScroll];
    
    NSString *string5 = [[NSString alloc] init];
    string5 = @"7. The green path will then turn red, indicating that you cannot edit the path any more, and the individual longitude and latitude coordinates making the path were extarcted every incremental unit. From here, you can either save the path, or review the individual coordinates first before you save it.";
    UILabel *label7 = [self stringLabel:CGRectMake(5, 10+imageView7.frame.size.height+imageView7.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string5 addToScrollView:tempScroll];
    
    UIImageView *imageView8 = [self screenCaptureAfterView:label7 image:@"freehand8" addToScrollView:tempScroll];
    
    NSString *string6 = [[NSString alloc] init];
    string6 = @"8. When you are done reviewing over your coordinates, tap the Save button to save your path for exporting later. You have now completed the tutorial for drawing a Free Hand drawing.";
    UILabel *label8 = [self stringLabel:CGRectMake(5, 10+imageView8.frame.size.height+imageView8.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string6 addToScrollView:tempScroll];
    
    UILabel *lineLabel1 = [self lineLabelWithArea:CGRectMake(LINESTART, label8.frame.origin.y+10+label8.frame.size.height, tempScroll.frame.size.width-10, tempScroll.frame.size.height) addToScrollView:tempScroll];
    
    UILabel *title2 = [self boldTitleWithArea:CGRectMake(5, lineLabel1.frame.size.height+10+lineLabel1.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) title:@"Free Hand Tips" addToScrollView:tempScroll];
    
    NSString *string7 = [[NSString alloc] init];
    string7 = @"\u2022Free Hand is mainly used for drawing out curved or abstarct paths that cannot be drawn with Line.\r\r\u2022Set the incremental units appropriately beforehand to fit the size of the path you will draw. This may coase your path not to appear on the screen. For example, a path that is meant to be drawn 1 meter in length will not appear on the map if the incremental units are set to miles or kilometers.";
    UILabel *label9 = [self stringLabel:CGRectMake(5, 2+title2.frame.size.height+title2.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string7 addToScrollView:tempScroll];
    
    [tempScroll setContentSize:CGSizeMake(tempScroll.frame.size.width, 30+label9.frame.size.height+label9.frame.origin.y)];
    [tempScroll addSubview:imageView];
    [tempScroll addSubview:label];
    [tempScroll addSubview:imageView2];
    [tempScroll addSubview:label2];
    
    return tempScroll;
}

- (UIScrollView *)lineInstructions{
    
    UIScrollView *tempScroll = [[UIScrollView alloc] initWithFrame:self.view.frame];
    tempScroll.backgroundColor = [UIColor whiteColor];
    
    UILabel *title1 = [self bigBoldTitleWithArea:CGRectMake(5, 5, tempScroll.frame.size.width, tempScroll.frame.size.height) title:@"Drawing a Polyline" addToScrollView:tempScroll];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/8, 10+title1.frame.size.height+tempScroll.frame.origin.y, self.view.frame.size.width*3/4, self.view.frame.size.height*3/4)];
    imageView.image = [UIImage imageNamed:@"tabbar.png"];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, imageView.frame.origin.y+imageView.frame.size.height+10, tempScroll.frame.size.width-10, tempScroll.frame.size.height)];
    label.numberOfLines = 0;
    label.font = [label.font fontWithSize:FONTSIZE];
    label.text = @"1. To begin drawing a Line path, select the compose button on the left side of the bottom toolbar. Then select the tab named Line.";
    [label sizeToFit];
    [label setFrame:CGRectMake(tempScroll.frame.size.width/2-label.frame.size.width/2, label.frame.origin.y, label.frame.size.width, label.frame.size.height)];
    
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/8, 20+label.frame.size.height+label.frame.origin.y, self.view.frame.size.width*3/4, tempScroll.frame.size.height*3/4)];
    imageView2.image = [UIImage imageNamed:@"line1.png"];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(5, imageView2.frame.origin.y+imageView2.frame.size.height+10, tempScroll.frame.size.width-10, tempScroll.frame.size.height)];
    label2.numberOfLines = 0;
    label2.font = [label2.font fontWithSize:FONTSIZE];
    label2.text = @"2. Tap at the location where you want the line to start. A green marker will appear to indicate where the starting point is.";
    [label2 sizeToFit];
    [label2 setFrame:CGRectMake(tempScroll.frame.size.width/2-label2.frame.size.width/2, label2.frame.origin.y, label2.frame.size.width, label2.frame.size.height)];
    
    UIImageView *imageView3 = [self screenCaptureAfterView:label2 image:@"line2.png" addToScrollView:tempScroll];
    
    NSString *string = [[NSString alloc] init];
    string = @"3. Tap another point on the map to set the second point on the line.";
    UILabel *label3 = [self stringLabel:CGRectMake(5, 10+imageView3.frame.size.height+imageView3.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string addToScrollView:tempScroll];
    
    UIImageView *imageView4 = [self screenCaptureAfterView:label3 image:@"line3.png" addToScrollView:tempScroll];
    
    NSString *string2 = [[NSString alloc] init];
    string2 = @"4. You can either continue tapping at various points on the map to add to the polyline, or finish your line by pressing the Done button.";
    UILabel *label4 = [self stringLabel:CGRectMake(5, 10+imageView4.frame.size.height+imageView4.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string2 addToScrollView:tempScroll];
    
    UIImageView *imageView5 = [self screenCaptureAfterView:label4 image:@"line4.png" addToScrollView:tempScroll];
    
    NSString *string3 = [[NSString alloc] init];
    string3 = @"5. If you have the map setting 'Snap to starting point' set On, then you have the option of clicking on a marker to snap the next point of the line to that marker's location.";
    UILabel *label5 = [self stringLabel:CGRectMake(5, 10+imageView5.frame.size.height+imageView5.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string3 addToScrollView:tempScroll];
    
    UIImageView *imageView6 = [self screenCaptureAfterView:label5 image:@"line5.png" addToScrollView:tempScroll];
    
    NSString *string4 = [[NSString alloc] init];
    string4 = @"6. At any point during the drawing process, you can draw a marker the same way you would drag a marker in Free Hand. Press down on any marker until you see the map shift upwards, then you can drag that marker to move that point in the line.";
    UILabel *label6 = [self stringLabel:CGRectMake(5, 10+imageView6.frame.size.height+imageView6.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string4 addToScrollView:tempScroll];
    
    UIImageView *imageView7 = [self screenCaptureAfterView:label6 image:@"line6.png" addToScrollView:tempScroll];
    
    NSString *string5 = [[NSString alloc] init];
    string5 = @"7. Once you are finished drawing, press the Done button to begin the coordinate extarcting process. Once finished, the path will become red, and you have the option to view each extratced coordinate by clicking on the triangle button in the bottom toolbar, or save your path for exporting by clicking the Save button.";
    UILabel *label7 = [self stringLabel:CGRectMake(5, 10+imageView7.frame.size.height+imageView7.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string5 addToScrollView:tempScroll];
    
    UIImageView *imageView8 = [self screenCaptureAfterView:label7 image:@"line8.png" addToScrollView:tempScroll];
    
    NSString *string6 = [[NSString alloc] init];
    string6 = @"8. When you are done reviewing over your coordinates, tap the Save button to save your path for exporting later. You have now completed the tutorial for drawing a Line drawing.";
    UILabel *label8 = [self stringLabel:CGRectMake(5, 10+imageView8.frame.size.height+imageView8.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string6 addToScrollView:tempScroll];
    
    UILabel *lineLabel1 = [self lineLabelWithArea:CGRectMake(LINESTART, label8.frame.origin.y+10+label8.frame.size.height, tempScroll.frame.size.width-10, tempScroll.frame.size.height) addToScrollView:tempScroll];
    
    UILabel *title2 = [self boldTitleWithArea:CGRectMake(5, lineLabel1.frame.size.height+10+lineLabel1.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) title:@"Line Tips" addToScrollView:tempScroll];
    
    NSString *string7 = [[NSString alloc] init];
    string7 = @"\u2022Line is mainly used for drawing neat straight paths.\r\r\u2022Because the map this app uses is shown as a Mercator Projection, lines on the map are shown as geodesic segments. Geodesic segments follow the shortest path along the Earth's curved surface, so lines may not always appear straight.";
    UILabel *label9 = [self stringLabel:CGRectMake(5, 2+title2.frame.size.height+title2.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string7 addToScrollView:tempScroll];
    
    [tempScroll setContentSize:CGSizeMake(tempScroll.frame.size.width, 30+label9.frame.size.height+label9.frame.origin.y)];
    [tempScroll addSubview:imageView];
    [tempScroll addSubview:label];
    [tempScroll addSubview:imageView2];
    [tempScroll addSubview:label2];
    
    return tempScroll;
}

- (UIScrollView *)circleInstructions{
    
    UIScrollView *tempScroll = [[UIScrollView alloc] initWithFrame:self.view.frame];
    tempScroll.backgroundColor = [UIColor whiteColor];
    
    UILabel *title1 = [self bigBoldTitleWithArea:CGRectMake(5, 5, tempScroll.frame.size.width, tempScroll.frame.size.height) title:@"Drawing a Circle" addToScrollView:tempScroll];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/8, 10+title1.frame.size.height+tempScroll.frame.origin.y, self.view.frame.size.width*3/4, self.view.frame.size.height*3/4)];
    imageView.image = [UIImage imageNamed:@"tabbar.png"];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, imageView.frame.origin.y+imageView.frame.size.height+10, tempScroll.frame.size.width-10, tempScroll.frame.size.height)];
    label.numberOfLines = 0;
    label.font = [label.font fontWithSize:FONTSIZE];
    label.text = @"1. To begin drawing a Circle path, select the compose button on the left side of the bottom toolbar. Then select the tab named Circle.";
    [label sizeToFit];
    [label setFrame:CGRectMake(tempScroll.frame.size.width/2-label.frame.size.width/2, label.frame.origin.y, label.frame.size.width, label.frame.size.height)];
    
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/8, 20+label.frame.size.height+label.frame.origin.y, self.view.frame.size.width*3/4, tempScroll.frame.size.height*3/4)];
    imageView2.image = [UIImage imageNamed:@"circle1.png"];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(5, imageView2.frame.origin.y+imageView2.frame.size.height+10, tempScroll.frame.size.width-10, tempScroll.frame.size.height)];
    label2.numberOfLines = 0;
    label2.font = [label2.font fontWithSize:FONTSIZE];
    label2.text = @"2. Tap at the location where you want the center of the circle to be. A green marker will appear to indicate where the center is.";
    [label2 sizeToFit];
    [label2 setFrame:CGRectMake(tempScroll.frame.size.width/2-label2.frame.size.width/2, label2.frame.origin.y, label2.frame.size.width, label2.frame.size.height)];
    
    UIImageView *imageView3 = [self screenCaptureAfterView:label2 image:@"circle2.png" addToScrollView:tempScroll];
    
    NSString *string = [[NSString alloc] init];
    string = @"3. Tap another point on the map to set the radius of the circle.";
    UILabel *label3 = [self stringLabel:CGRectMake(5, 10+imageView3.frame.size.height+imageView3.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string addToScrollView:tempScroll];
    
    UIImageView *imageView4 = [self screenCaptureAfterView:label3 image:@"circle3.png" addToScrollView:tempScroll];
    
    NSString *string2 = [[NSString alloc] init];
    string2 = @"4. Three draggable markers appear on the screen that are used to edit the circle. You can either edit the circle by dragging these markers, or save your path for exporting later by tapping the Save button.";
    UILabel *label4 = [self stringLabel:CGRectMake(5, 10+imageView4.frame.size.height+imageView4.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string2 addToScrollView:tempScroll];
    
    UIImageView *imageView5 = [self screenCaptureAfterView:label4 image:@"circle4.png" addToScrollView:tempScroll];
    
    NSString *string3 = [[NSString alloc] init];
    string3 = @"5. You can drag the circle altogether by holding down on the green marker, then dragging it.";
    UILabel *label5 = [self stringLabel:CGRectMake(5, 10+imageView5.frame.size.height+imageView5.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string3 addToScrollView:tempScroll];
    
    UIImageView *imageView6 = [self screenCaptureAfterView:label5 image:@"circle5.png" addToScrollView:tempScroll];
    
    NSString *string4 = [[NSString alloc] init];
    string4 = @"6. You can set the diameter of the circle by holding down and dragging on the purple marker. This works by locking the red marker so you can drag the purple marker on the opposite end of the circle.";
    UILabel *label6 = [self stringLabel:CGRectMake(5, 10+imageView6.frame.size.height+imageView6.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string4 addToScrollView:tempScroll];
    
    UIImageView *imageView7 = [self screenCaptureAfterView:label6 image:@"circle6.png" addToScrollView:tempScroll];
    
    NSString *string5 = [[NSString alloc] init];
    string5 = @"7. You can set the radius of the circle by holding down and dragging on the red marker. This works by locking the green marker so you can drag the red marker on the circumference of the circle.";
    UILabel *label7 = [self stringLabel:CGRectMake(5, 10+imageView7.frame.size.height+imageView7.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string5 addToScrollView:tempScroll];
    
    UIImageView *imageView8 = [self screenCaptureAfterView:label7 image:@"circle7.png" addToScrollView:tempScroll];
    
    NSString *string6 = [[NSString alloc] init];
    string6 = @"8. When you are done editing your path, press the Done button to finish and name your path.";
    UILabel *label8 = [self stringLabel:CGRectMake(5, 10+imageView8.frame.size.height+imageView8.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string6 addToScrollView:tempScroll];
    
    UIImageView *imageView9 = [self screenCaptureAfterView:label8 image:@"circle8.png" addToScrollView:tempScroll];
    
    NSString *string7 = [[NSString alloc] init];
    string7 = @"9. You can review each individual coordinate making up the circumference of the circle by pressing the triangle button on the bottom toolbar and moving the red marker that will appear.";
    UILabel *label9 = [self stringLabel:CGRectMake(5, 10+imageView9.frame.size.height+imageView9.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string7 addToScrollView:tempScroll];
    
    UIImageView *imageView10 = [self screenCaptureAfterView:label9 image:@"circle9.png" addToScrollView:tempScroll];
    
    NSString *string8 = [[NSString alloc] init];
    string8 = @"10. When you are done reviewing over your coordinates, tap the Save button to save your path for exporting later. You have now completed the tutorial for drawing a Circle drawing.";
    UILabel *label10 = [self stringLabel:CGRectMake(5, 10+imageView10.frame.size.height+imageView10.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string8 addToScrollView:tempScroll];
    
    UILabel *lineLabel1 = [self lineLabelWithArea:CGRectMake(LINESTART, label10.frame.origin.y+10+label10.frame.size.height, tempScroll.frame.size.width-10, tempScroll.frame.size.height) addToScrollView:tempScroll];
    
    UILabel *title2 = [self boldTitleWithArea:CGRectMake(5, lineLabel1.frame.size.height+10+lineLabel1.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) title:@"Circle Tips" addToScrollView:tempScroll];
    
    NSString *string9 = [[NSString alloc] init];
    string9 = @"\u2022Because the map is shown as a Mercator Projection, the equations for drawing a circle are not the same as those for drawing a 2D circle. The equations used for calculating the radius, circumference, and area of this circle are derived from spherical caps on a sphere.";
    UILabel *label11 = [self stringLabel:CGRectMake(5, 2+title2.frame.size.height+title2.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string9 addToScrollView:tempScroll];
    
    [tempScroll setContentSize:CGSizeMake(tempScroll.frame.size.width, 30+label11.frame.size.height+label11.frame.origin.y)];
    [tempScroll addSubview:imageView];
    [tempScroll addSubview:label];
    [tempScroll addSubview:imageView2];
    [tempScroll addSubview:label2];
    
    return tempScroll;
}

- (UIScrollView *)rectangleInstructions{
    
    UIScrollView *tempScroll = [[UIScrollView alloc] initWithFrame:self.view.frame];
    tempScroll.backgroundColor = [UIColor whiteColor];
    
    UILabel *title1 = [self bigBoldTitleWithArea:CGRectMake(5, 5, tempScroll.frame.size.width, tempScroll.frame.size.height) title:@"Drawing a Rectangle" addToScrollView:tempScroll];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/8, 10+title1.frame.size.height+tempScroll.frame.origin.y, self.view.frame.size.width*3/4, self.view.frame.size.height*3/4)];
    imageView.image = [UIImage imageNamed:@"tabbar.png"];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, imageView.frame.origin.y+imageView.frame.size.height+10, tempScroll.frame.size.width-10, tempScroll.frame.size.height)];
    label.numberOfLines = 0;
    label.font = [label.font fontWithSize:FONTSIZE];
    label.text = @"1. To begin drawing a Rectangle path, select the compose button on the left side of the bottom toolbar. Then select the tab named Rectangle.";
    [label sizeToFit];
    [label setFrame:CGRectMake(tempScroll.frame.size.width/2-label.frame.size.width/2, label.frame.origin.y, label.frame.size.width, label.frame.size.height)];
    
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/8, 20+label.frame.size.height+label.frame.origin.y, self.view.frame.size.width*3/4, tempScroll.frame.size.height*3/4)];
    imageView2.image = [UIImage imageNamed:@"rectangle1.png"];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(5, imageView2.frame.origin.y+imageView2.frame.size.height+10, tempScroll.frame.size.width-10, tempScroll.frame.size.height)];
    label2.numberOfLines = 0;
    label2.font = [label2.font fontWithSize:FONTSIZE];
    label2.text = @"2. Tap at the location where you want the first corner of the rectangle to be. A red marker will appear to indicate where the corner is.";
    [label2 sizeToFit];
    [label2 setFrame:CGRectMake(tempScroll.frame.size.width/2-label2.frame.size.width/2, label2.frame.origin.y, label2.frame.size.width, label2.frame.size.height)];
    
    UIImageView *imageView3 = [self screenCaptureAfterView:label2 image:@"rectangle2.png" addToScrollView:tempScroll];
    
    NSString *string = [[NSString alloc] init];
    string = @"3. Tap another point on the map to set opposite corner of the rectangle.";
    UILabel *label3 = [self stringLabel:CGRectMake(5, 10+imageView3.frame.size.height+imageView3.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string addToScrollView:tempScroll];
    
    UIImageView *imageView4 = [self screenCaptureAfterView:label3 image:@"rectangle3.png" addToScrollView:tempScroll];
    
    NSString *string2 = [[NSString alloc] init];
    string2 = @"4. Three draggable markers appear on the screen that are used to edit the rectangle. You can either edit the rectangle by dragging these markers, or save your path for exporting later by tapping the Save button.";
    UILabel *label4 = [self stringLabel:CGRectMake(5, 10+imageView4.frame.size.height+imageView4.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string2 addToScrollView:tempScroll];
    
    UIImageView *imageView5 = [self screenCaptureAfterView:label4 image:@"rectangle4.png" addToScrollView:tempScroll];
    
    NSString *string3 = [[NSString alloc] init];
    string3 = @"5. You can drag the rectangle altogether by holding down on the green marker, then dragging it.";
    UILabel *label5 = [self stringLabel:CGRectMake(5, 10+imageView5.frame.size.height+imageView5.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string3 addToScrollView:tempScroll];
    
    UIImageView *imageView6 = [self screenCaptureAfterView:label5 image:@"rectangle5.png" addToScrollView:tempScroll];
    
    NSString *string4 = [[NSString alloc] init];
    string4 = @"6. You can set the diagonal of the rectangle by holding down and dragging on the purple marker. This works by locking the red marker so you can drag the purple marker on the opposite corner of the rectangle.";
    UILabel *label6 = [self stringLabel:CGRectMake(5, 10+imageView6.frame.size.height+imageView6.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string4 addToScrollView:tempScroll];
    
    UIImageView *imageView7 = [self screenCaptureAfterView:label6 image:@"rectangle6.png" addToScrollView:tempScroll];
    
    NSString *string5 = [[NSString alloc] init];
    string5 = @"7. You can set the distance of one corner of the rectangle to the center by holding down and dragging on the red marker. This works by locking the green marker so you can drag the red marker on the corner of the rectangle.";
    UILabel *label7 = [self stringLabel:CGRectMake(5, 10+imageView7.frame.size.height+imageView7.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string5 addToScrollView:tempScroll];
    
    UIImageView *imageView8 = [self screenCaptureAfterView:label7 image:@"rectangle7.png" addToScrollView:tempScroll];
    
    NSString *string6 = [[NSString alloc] init];
    string6 = @"8. When you are done editing your path, press the Done button to finish and name your path.";
    UILabel *label8 = [self stringLabel:CGRectMake(5, 10+imageView8.frame.size.height+imageView8.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string6 addToScrollView:tempScroll];
    
    UIImageView *imageView9 = [self screenCaptureAfterView:label8 image:@"rectangle8.png" addToScrollView:tempScroll];
    
    NSString *string7 = [[NSString alloc] init];
    string7 = @"9. You can review each individual coordinate making up the perimeter of the rectangle by pressing the triangle button on the bottom toolbar and moving the red marker that will appear.";
    UILabel *label9 = [self stringLabel:CGRectMake(5, 10+imageView9.frame.size.height+imageView9.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string7 addToScrollView:tempScroll];
    
    UIImageView *imageView10 = [self screenCaptureAfterView:label9 image:@"rectangle9.png" addToScrollView:tempScroll];
    
    NSString *string8 = [[NSString alloc] init];
    string8 = @"10. When you are done reviewing over your coordinates, tap the Save button to save your path for exporting later. You have now completed the tutorial for drawing a Rectangle drawing.";
    UILabel *label10 = [self stringLabel:CGRectMake(5, 10+imageView10.frame.size.height+imageView10.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string8 addToScrollView:tempScroll];
    
    UILabel *lineLabel1 = [self lineLabelWithArea:CGRectMake(LINESTART, label10.frame.origin.y+10+label10.frame.size.height, tempScroll.frame.size.width-10, tempScroll.frame.size.height) addToScrollView:tempScroll];
    
    UILabel *title2 = [self boldTitleWithArea:CGRectMake(5, lineLabel1.frame.size.height+10+lineLabel1.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) title:@"Rectangle Tips" addToScrollView:tempScroll];
    
    NSString *string9 = [[NSString alloc] init];
    string9 = @"\u2022Because the map this app uses is shown as a Mercator Projection, lines on the map are shown as geodesic segments. Geodesic segments follow the shortest path along the Earth's curved surface, so the lines composing the rectangle may not always appear straight.";
    UILabel *label11 = [self stringLabel:CGRectMake(5, 2+title2.frame.size.height+title2.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:string9 addToScrollView:tempScroll];
    
    [tempScroll setContentSize:CGSizeMake(tempScroll.frame.size.width, 30+label11.frame.size.height+label11.frame.origin.y)];
    [tempScroll addSubview:imageView];
    [tempScroll addSubview:label];
    [tempScroll addSubview:imageView2];
    [tempScroll addSubview:label2];
    
    return tempScroll;
}

- (UIScrollView *)reviewingCoordinates{
    UIScrollView *tempScroll = [[UIScrollView alloc] initWithFrame:self.view.frame];
    tempScroll.backgroundColor = [UIColor whiteColor];
    
    UILabel *title1 = [self bigBoldTitleWithArea:CGRectMake(5, 5, tempScroll.frame.size.width-10, tempScroll.frame.size.height) title:@"How to Review Coordinates" addToScrollView:tempScroll];
    
    UIImageView *imageView1 = [self screenCaptureAfterView:title1 image:@"circle8.png" addToScrollView:tempScroll];
    
    UILabel *label1 = [self stringLabel:CGRectMake(5, 10+imageView1.frame.size.height+imageView1.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:@"After pressing the Done button, you then have the option to view each of these coordinates by tapping on the triangle button on the bottom toolbar. This will bring up a red marker located on the first point of the path, and a small view containing the longitude and latitude of the marker and a stepper." addToScrollView:tempScroll];
    label1.font = [UIFont italicSystemFontOfSize:FONTSIZE];
    
    UILabel *label2 = [self stringLabel:CGRectMake(5, 10+label1.frame.size.height+label1.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:@"\u2022You can view the longitude and latitude coordinates of a location by dragging the marker to that location the same way you would edit paths. Hold down on the marker until you see the map shift, then drag the marker to the location you want to see. The marker will then snap to that location.\r\r\u2022You can also view coordinates by using the stepper. Press the minus button to move the marker to the path's previous coordinate and the plus button to move the marker to the path's next coordinate." addToScrollView:tempScroll];
    
    [tempScroll setContentSize:CGSizeMake(tempScroll.frame.size.width, 20+label2.frame.size.height+label2.frame.origin.y)];
    
    return tempScroll;
}

- (UIScrollView *)exportingPaths{
    UIScrollView *tempScroll = [[UIScrollView alloc] initWithFrame:self.view.frame];
    tempScroll.backgroundColor = [UIColor whiteColor];
    
    UILabel *title1 = [self bigBoldTitleWithArea:CGRectMake(5, 5, tempScroll.frame.size.width-10, tempScroll.frame.size.height) title:@"Exporting Your Saved Paths" addToScrollView:tempScroll];
    
    UIImageView *imageView1 = [self screenCaptureAfterView:title1 image:@"MainScreen.png" addToScrollView:tempScroll];
    
    UILabel *title2 = [self italicsTitleWithArea:CGRectMake(5, 10+imageView1.frame.size.height+imageView1.frame.origin.y, imageView1.frame.size.width-10, imageView1.frame.size.height) title:@"After finishing drawing and saving your path, you can now export it from your phone. The extraction will be sent as a text file containing all the coordinates making up the path and other useful information about the path. Start exporting your coordinates by navigating to the Main Screen and selecting the row named Saved Extarctions." addToScrollView:tempScroll];
    
    UIImageView *imageView2 = [self screenCaptureAfterView:title2 image:@"export1.png" addToScrollView:tempScroll];
    
    UILabel *label1 = [self stringLabel:CGRectMake(5, 10+imageView2.frame.origin.y+imageView2.frame.size.height, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:@"This is the Saved Extractions page where you can see a list of all the paths you have saved. On the top you will see an image of the currently selected path and the address of the first point on the path." addToScrollView:tempScroll];
    
    UIImageView *imageView3 = [self screenCaptureAfterView:label1 image:@"export2.png" addToScrollView:tempScroll];
    
    UILabel *label2 = [self stringLabel:CGRectMake(5, 10+imageView3.frame.origin.y+imageView3.frame.size.height, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:@"You can view the different images and locations of each path by tapping on the information (i's) in the right side of the screen." addToScrollView:tempScroll];
    
    UIImageView *imageView4 = [self screenCaptureAfterView:label2 image:@"export3.png" addToScrollView:tempScroll];
    
    UILabel *label3 = [self stringLabel:CGRectMake(5, 10+imageView4.frame.size.height+imageView4.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:@"You can also delete saved paths by pressing the edit button on the top right corner of the screen and deleting the rows. Press Done to finish editing. When you are finsihed reviewing this page, select a path to export by tapping on it." addToScrollView:tempScroll];
    
    UIImageView *imageView5 = [self screenCaptureAfterView:label3 image:@"export4.png" addToScrollView:tempScroll];
    
    UILabel *label4 = [self stringLabel:CGRectMake(5, 10+imageView5.frame.origin.y+imageView5.frame.size.height, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:@"Here is the Export page where the path extarction is sent as a text file. This page contains details about the path depending on what type of path it is." addToScrollView:tempScroll];
    
    UIImageView *imageView6 = [self screenCaptureAfterView:label4 image:@"export5.png" addToScrollView:tempScroll];
    
    UILabel *label5 = [self stringLabel:CGRectMake(5, 10+imageView6.frame.size.height+imageView6.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:@"The tabs on the top of the page cn be selected to change the units you wish to export your path as." addToScrollView:tempScroll];
    
    UIImageView *imageView7  =[self screenCaptureAfterView:label5 image:@"export6.png" addToScrollView:tempScroll];
    [imageView7 setFrame:CGRectMake(imageView7.frame.origin.x, imageView7.frame.origin.y, imageView7.frame.size.width, 70)];
    
    UILabel *label6 = [self stringLabel:CGRectMake(5, 10+imageView7.frame.size.height+imageView7.frame.origin.y, tempScroll.frame.size.width-10, tempScroll.frame.size.height) string:@"You can select how you want to export your path in one of three ways: Email, Dropbox, or Google Drive." addToScrollView:tempScroll];
    
    [tempScroll setContentSize:CGSizeMake(tempScroll.frame.size.width, 30+label6.frame.size.height+label6.frame.origin.y)];
    
    return tempScroll;
}

- (UILabel *)lineLabelWithArea:(CGRect)area addToScrollView:(UIScrollView *)scrollView{
    UILabel *label = [[UILabel alloc] initWithFrame:area];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"_________________________________";
    label.font = [UIFont boldSystemFontOfSize:16];
    label.numberOfLines = 0;
    [label sizeToFit];
    [scrollView addSubview:label];
    
    return label;
}

- (UILabel *)bigBoldTitleWithArea:(CGRect)area title:(NSString *)title addToScrollView:(UIScrollView *)scrollView{
    UILabel *bold = [[UILabel alloc] initWithFrame:area];
    bold.numberOfLines = 0;
    bold.font = [UIFont boldSystemFontOfSize:20];
    bold.backgroundColor = [UIColor clearColor];
    bold.text = title;
    bold.textAlignment = NSTextAlignmentCenter;
    [bold sizeToFit];
    [bold setFrame:CGRectMake(scrollView.frame.size.width/2-bold.frame.size.width/2, bold.frame.origin.y, bold.frame.size.width, bold.frame.size.height)];
    [scrollView addSubview:bold];
    
    return bold;
}

- (UILabel *)boldTitleWithArea:(CGRect)area title:(NSString *)title addToScrollView:(UIScrollView *)scrollView{
    UILabel *bold = [[UILabel alloc] initWithFrame:area];
    bold.numberOfLines = 0;
    bold.font = [UIFont boldSystemFontOfSize:16];
    bold.backgroundColor = [UIColor clearColor];
    bold.text = title;
    bold.textAlignment = NSTextAlignmentCenter;
    [bold sizeToFit];
    [bold setFrame:CGRectMake(scrollView.frame.size.width/2-bold.frame.size.width/2, bold.frame.origin.y, bold.frame.size.width, bold.frame.size.height)];
    [scrollView addSubview:bold];
    
    return bold;
}

- (UILabel *)italicsTitleWithArea:(CGRect)area title:(NSString *)title addToScrollView:(UIScrollView *)scrollView{
    UILabel *italics = [[UILabel alloc] initWithFrame:area];
    italics.numberOfLines = 0;
    italics.font = [UIFont italicSystemFontOfSize:16];
    italics.backgroundColor = [UIColor clearColor];
    italics.text = title;
    italics.textAlignment =NSTextAlignmentCenter;
    [italics sizeToFit];
    [italics setFrame:CGRectMake(scrollView.frame.size.width/2-italics.frame.size.width/2, italics.frame.origin.y, italics.frame.size.width, italics.frame.size.height)];
    [scrollView addSubview:italics];
    
    return italics;
}

- (UILabel *)stringLabel:(CGRect)area string:(NSString *)string addToScrollView:(UIScrollView *)scrollView{
    UILabel *label = [[UILabel alloc] initWithFrame:area];
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    label.font = [label.font fontWithSize:FONTSIZE];
    label.text = string;
    [label sizeToFit];
    [scrollView addSubview:label];
    [label setFrame:CGRectMake(scrollView.frame.size.width/2-label.frame.size.width/2, label.frame.origin.y, label.frame.size.width, label.frame.size.height)];
    
    return label;
}

- (UIImageView *)screenCaptureAfterView:(UIView *)view image:(NSString *)imageName addToScrollView:(UIScrollView *)scrollView{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(scrollView.frame.size.width/8, 20+view.frame.size.height+view.frame.origin.y, scrollView.frame.size.width*3/4, scrollView.frame.size.height*3/4)];
    imageView.image = [UIImage imageNamed:imageName];
    [scrollView addSubview:imageView];
    
    return imageView;
}

@end
