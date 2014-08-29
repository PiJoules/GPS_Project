//
//  ViewController.m
//  Extraction 3.5
//
//  Created by Leonard Chan on 9/28/13.
//  Copyright (c) 2013 Leonard Chan. All rights reserved.
//

#import "MainScreen.h"
#import "GCGeocodingService.h"
#import "GoogleMaps.h"
#import "savePath.h"

@interface MainScreen ()

@end

@implementation MainScreen{
    NSMutableArray *searches;
    NSString *searchLocation;
    UIButton *button;
    UIViewController *clearDataController;
    savePath *sp;
    int selectedRow;
    BOOL clearedData;
}

@synthesize initialLocation;

//ONLY CALLED ONCE AFTER LOADINGSCREEN VIEW!!!!
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationController.navigationBar.barTintColor = [[UIColor alloc] initWithRed:1 green:1 blue:0 alpha:1];
    selectedRow = 0;
    sp = [[savePath alloc] init];
    searches = [NSMutableArray arrayWithArray:sp.searchHistory];
    
    if (initialLocation != nil){
        [searches insertObject:initialLocation atIndex:0];
    }
    
    clearedData = false;
}

//ADD STUFF HERE IF COMING FROM VIEW CONTROLLER (GOOGLEMAPS)!!!!!
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (selectedRow == 0 || clearedData){
        sp = [[savePath alloc] init];
        searches = [NSMutableArray arrayWithArray:sp.searchHistory];
        
        while (searches.count > 10) {
            [searches removeLastObject];
        }
        [sp saveArray:searches toSavePath:@"searchHistory"];
        
        //RELOADS TABLEVIEW EACH TIME THE VIEW APPEARS
        [searchHistoryTableView reloadData];
        
        clearedData = false;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (searches.count != sp.searchHistory.count){
        [sp saveArray:searches toSavePath:@"searchHistory"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"Using too much memory");
}

//if selected a previous search, will set initial location on map to that address; if it's a new search, address will be nil by default
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toGoogleMaps"]){
        GoogleMaps *gm1 = [segue destinationViewController];
        gm1.searchLocation = searchLocation;
        gm1.searches = searches;
    }
}



#pragma mark CONTROLLING THE TABLEVIEW

//Control what happens if a row is selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1){
        selectedRow = 0;
        searchLocation = [[NSString alloc] initWithString:[[[tableView cellForRowAtIndexPath:indexPath] textLabel] text]];
        [self performSegueWithIdentifier:@"toGoogleMaps" sender:self];
    }
    else{
        if (indexPath.row == 0) {
            searchLocation = nil;
            [self performSegueWithIdentifier:@"toGoogleMaps" sender:self];
        }
        if (indexPath.row == 1){
            [self performSegueWithIdentifier:@"toSavedExtractions" sender:self];
        }
        if (indexPath.row == 3){
            [self performSegueWithIdentifier:@"toAboutThisApp" sender:self];
        }
        if (indexPath.row == 2){
            [self performSegueWithIdentifier:@"toReferences" sender:self];
        }
        if (indexPath.row == 4){
            
            clearDataController = [[UIViewController alloc] init];
            clearDataController.view.backgroundColor = [UIColor whiteColor];
            
            UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(clearDataController.view.frame.size.width/8, clearDataController.view.frame.size.height*3/8, clearDataController.view.frame.size.width*3/4, clearDataController.view.frame.size.height/4)];
            slider.value = 0;
            [slider addTarget:self action:@selector(enableButton:) forControlEvents:UIControlEventValueChanged];
            [clearDataController.view addSubview:slider];
            
            UILabel *warning = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, clearDataController.view.frame.size.width, clearDataController.view.frame.size.height)];
            warning.numberOfLines = 0;
            warning.textAlignment = NSTextAlignmentCenter;
            warning.textColor = [UIColor blackColor];
            warning.text = @"*WARNING: ONCE YOU CLEAR ALL DATA, YOU WILL NOT BE ABLE TO RETRIEVE IT.\rDrag the slider all the way to the right, then press the red button to clear all saved data in the app.";
            [warning sizeToFit];
            [clearDataController.view addSubview:warning];
            [warning setFrame:CGRectMake(clearDataController.view.frame.origin.x+5, slider.frame.origin.y-warning.frame.size.height, clearDataController.view.frame.size.width-10, warning.frame.size.height)];
            
            button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.enabled = false;
            button.layer.cornerRadius = 5;
            [button setFrame:CGRectMake(clearDataController.view.frame.size.width*3/8, slider.frame.origin.y+slider.frame.size.height, clearDataController.view.frame.size.width/4, clearDataController.view.frame.size.height/8)];
            [button setTitle:@"Clear" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(clearAllData) forControlEvents:UIControlEventTouchUpInside];
            button.tintColor = [UIColor blackColor];
            button.backgroundColor = [UIColor lightGrayColor];
            [clearDataController.view addSubview:button];
            
            UIButton *returnButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            returnButton.layer.cornerRadius = 5;
            [returnButton setFrame:CGRectMake(button.frame.origin.x, button.frame.origin.y+button.frame.size.height*1.5, button.frame.size.width, button.frame.size.height)];
            [returnButton setTitle:@"Cancel" forState:UIControlStateNormal];
            [returnButton addTarget:self action:@selector(dismissController) forControlEvents:UIControlEventTouchUpInside];
            returnButton.backgroundColor = [UIColor greenColor];
            returnButton.tintColor = [UIColor blackColor];
            [clearDataController.view addSubview:returnButton];
            
            [self presentViewController:clearDataController animated:true completion:nil];
            
        }
        selectedRow = indexPath.row;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (void)dismissController{
    [clearDataController dismissViewControllerAnimated:true completion:nil];
    clearDataController = nil;
}

- (void)enableButton:(UISlider *)slider{
    if (slider.value == slider.maximumValue){
        button.enabled = true;
        button.backgroundColor = [UIColor redColor];
    }
    else{
        button.enabled = false;
        button.backgroundColor = [UIColor lightGrayColor];
    }
}

- (void)clearAllData{
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:clearDataController.view.frame];
    activity.backgroundColor = [UIColor clearColor];
    [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [clearDataController.view addSubview:activity];
    [activity startAnimating];
    
    [sp.searchHistory removeAllObjects];
    [sp.savedImages removeAllObjects];
    [sp.savedPaths removeAllObjects];
    [sp.savedSettings removeAllObjects];
    [sp.savedMapData removeAllObjects];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array insertObject:[NSNumber numberWithInt:1] atIndex:0];
    [array insertObject:[NSString stringWithFormat:@"Meters (m)"] atIndex:1];
    [array insertObject:[NSNumber numberWithBool:true] atIndex:2];
    [array insertObject:[NSNumber numberWithBool:true] atIndex:3];
    [sp saveArray:array toSavePath:@"savedSettings"];
    
    clearedData = true;
    
    [activity stopAnimating];
    
    [self dismissViewControllerAnimated:true completion:nil];
}

//do stuff when and when not editing
- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    [searchHistoryTableView setEditing:editing animated:true];
    
    //making changes to tableView
    if (editing){
        
    }
    //not making/saving changes
    else{
        
    }
}

//customize which rows get delete/insert edit buttons
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1){
        return UITableViewCellEditingStyleDelete;
    }
    else{
        return UITableViewCellEditingStyleNone;
    }
}

//contorl what happens if a delete/insert button is pressed
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //MUST ALWAYS FIRST REMOVE THE OBJECT FROM THE LIST PLACED ONTO THE TABLEVIEW
        [searches removeObjectAtIndex:indexPath.row];
        while (searches.count > 10) {
            [searches removeLastObject];
        }
        
        //THEN DELETE THE ROW
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

//set the number of rows for tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return 5;
    }
    else{
        return searches.count;
    }
}

//number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 1){
        return @"Recent Searches";
    }
    else{
        return @"Directory";
    }
}

//set what will be on each row of the tableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    if (indexPath.section == 0){
        if (indexPath.row == 0){
            cell.textLabel.text = @"New Search";
        }
        if (indexPath.row == 1){
            cell.textLabel.text = @"Saved Extractions";
        }
        if (indexPath.row == 3){
            cell.textLabel.text = @"About This App";
        }
        if (indexPath.row == 2){
            cell.textLabel.text = @"References/Instructions";
        }
        if (indexPath.row == 4){
            cell.textLabel.text = @"Clear All Data";
        }
    }
    else{
        cell.textLabel.text = [searches objectAtIndex:indexPath.row];
    }
    
    return cell;
}

@end
