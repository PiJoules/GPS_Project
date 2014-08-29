//
//  SettingsTableView.m
//  Extraction 3.5
//
//  Created by Leonard Chan on 10/13/13.
//  Copyright (c) 2013 Leonard Chan. All rights reserved.
//

#import "SettingsTableView.h"
#import "savePath.h"
#import "SettingsView.h"

@interface SettingsTableView ()

@end

@implementation SettingsTableView{
    UISegmentedControl *mapTypeSelection;
    UIPickerView *picker;
    UIView *subview;
    NSMutableArray *settingsArray;
    NSMutableArray *maps;
    NSArray *unitsArray;
    NSDictionary *dictionary;
    double rowHeight;
    
    NSString *selection;
}

@synthesize mapType;
@synthesize incrementalUnit;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //set up tableview
    settingsArray = [NSMutableArray arrayWithObjects:@"Map Types", @"Incremental Units", @"Snap to starting point", nil];
    unitsArray = [NSArray arrayWithObjects:@"Feet (ft)", @"Yards (yd)", @"Meters (m)", @"Kilometers (km)", @"Miles (mi)", nil];
    rowHeight = self.tableView.rowHeight;   //44.00
    
    //set up segmented control for map type
    dictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:kGMSTypeNormal], [NSNumber numberWithInt:kGMSTypeSatellite], [NSNumber numberWithInt:kGMSTypeTerrain], [NSNumber numberWithInt:kGMSTypeHybrid], nil] forKeys:[NSArray arrayWithObjects:@"Normal", @"Satellite", @"Terrain", @"Hybrid", nil]];
    
    maps = [[NSMutableArray alloc] initWithCapacity:4];
    for (int i = 0; i < 4; i++){
        NSEnumerator *keyEnumerator = [dictionary keyEnumerator];
        id key;
        while ((key = [keyEnumerator nextObject])) {
            if ([[dictionary objectForKey:key] intValue] == i+1){
                [maps insertObject:key atIndex:i];
            }
        }
    }
    
    mapTypeSelection = [[UISegmentedControl alloc] initWithItems:maps];
    mapTypeSelection.segmentedControlStyle = UISegmentedControlStylePlain;
    [mapTypeSelection setFrame:CGRectMake(0, 0, 301, rowHeight)];
    [mapTypeSelection addTarget:self action:@selector(changeMapType:) forControlEvents:UIControlEventValueChanged];
    
    savePath *sp = [[savePath alloc] init];
    if (sp.savedSettings.count != 0){
        mapType = [sp.savedSettings[0] intValue];
        [mapTypeSelection setSelectedSegmentIndex:mapType-1];
    }
    else{
        mapType = kGMSTypeNormal;
        [mapTypeSelection setSelectedSegmentIndex:mapType-1];
        NSMutableArray *array = [NSMutableArray arrayWithArray:sp.savedSettings];
        [array insertObject:[NSNumber numberWithInt:mapType] atIndex:0];
        [sp saveArray:array toSavePath:@"savedSettings"];
    }
    
    //set up incremental units
    picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 200, 320, 250)];
    picker.delegate = self;
    picker.showsSelectionIndicator = true;
    [self.view addSubview:picker];
    picker.hidden = true;
    
    if (sp.savedSettings.count > 1){
        incrementalUnit = [NSString stringWithFormat:@"%@", sp.savedSettings[1]];
        for (int i = 0; i < unitsArray.count; i++){
            if ([incrementalUnit isEqualToString:unitsArray[i]]){
                [picker selectRow:i inComponent:0 animated:true];
            }
        }
    }
    else{
        incrementalUnit = [NSString stringWithFormat:@"Meters (m)"];
        [picker selectRow:2 inComponent:0 animated:true];
        NSMutableArray *array = [NSMutableArray arrayWithArray:sp.savedSettings];
        [array insertObject:incrementalUnit atIndex:1];
        [sp saveArray:array toSavePath:@"savedSettings"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissPicker{
    [subview removeFromSuperview];
    picker.hidden = true;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toSettings"]){
        SettingsView *sv = [segue destinationViewController];
        sv.selection = selection;
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    //return 1;
    return settingsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    //return settingsArray.count;
    if (section == 0){
        return 3;
    }
    else if (section == 1){
        return 2;
    }
    else if (section == 2){
        return 2;
    }
    else{
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    //row titles
    for (int i = 0; i < settingsArray.count; i++){
        if (indexPath.section == i && indexPath.row == 0){
            cell.textLabel.text = [settingsArray objectAtIndex:i];
            if (indexPath.section == 0){
                //cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            if ([[settingsArray objectAtIndex:i] isEqualToString:@"Map Types"]){
                cell.detailTextLabel.text = maps[mapType-1];
            }
            else if ([[settingsArray objectAtIndex:i] isEqualToString:@"Incremental Units"]){
                cell.detailTextLabel.text = incrementalUnit;
            }
            else{
                
            }
        }
    }
    
    
    if (indexPath.section == 0 && indexPath.row == 1){
        [cell.contentView addSubview:mapTypeSelection];
    }
    if (indexPath.section == 0 && indexPath.row == 2){
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 291, rowHeight*2.5-10)];
        label.layer.cornerRadius = 5;
        label.numberOfLines = 0;
        if (mapType == kGMSTypeNormal){
            label.text = @"Typical road map. Roads, some man-made features, and natural features such as rivers are shown. Road and feature labels are also visible.";
        }
        else if (mapType == kGMSTypeHybrid){
            label.text = @"Satellite photograph data with road maps added. Road and feature labels are also visible.";
        }
        else if (mapType == kGMSTypeSatellite){
            label.text = @"Satellite photograph data. Road and feature labels are not visible.";
        }
        else if (mapType == kGMSTypeTerrain){
            label.text = @"Topographic data. The map includes colors, contour lines and labels, and perspective shading. Some roads and labels are also visible.";
        }
        else{
            label.text = @"";
        }
        [cell.contentView addSubview:label];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == 1){
        int pick;
        for (int i = 0; i < unitsArray.count; i++){
            if ([incrementalUnit isEqualToString:unitsArray[i]]){
                pick = i;
            }
        }
        if (indexPath.row == 0){
            //cell.detailTextLabel.text = incrementalUnit;
        }
        if (indexPath.row == 1){
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 291, rowHeight*3-10)];
            label.layer.cornerRadius = 5;
            label.numberOfLines = 0;
            label.text = @"A coordinate's longitude and latitude will be recorded every incremental unit. If the designed path is smaller than the incremental unit, only the longitude and latitude of the path's start and end points will be recorded.";
            [cell.contentView addSubview:label];
        }
    }
    
    if (indexPath.section == 2){
        if (indexPath.row == 0){
            cell.detailTextLabel.text = @"";
        }
        if (indexPath.row == 1){
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 291, rowHeight*2.5-10)];
            label.layer.cornerRadius = 5;
            label.numberOfLines = 0;
            label.text = @"Ending a path near its staring point will cause it to snap to the starting point (for Line and Free Hnad paths only).";
            [cell.contentView addSubview:label];
        }
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    /*if (indexPath.section == 1 && indexPath.row == 0){
        picker.hidden = false;
        
        //add gesture that hides picker when clicked on background
        UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPicker)];
        tapper.delegate = self;
        tapper.numberOfTapsRequired = 1;
        subview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
        subview.tag = 7;
        [self.view addSubview:subview];
        [subview addGestureRecognizer:tapper];
    }*/
    
    //[tableView deselectRowAtIndexPath:indexPath animated:true];
    
    selection = [NSString stringWithFormat:@"%@",[settingsArray objectAtIndex:indexPath.section]];
    [self performSegueWithIdentifier:@"toSettings" sender:self];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return unitsArray.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return unitsArray[row];
}

//control the pivker
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    incrementalUnit = unitsArray[row];
    
    savePath *sp = [[savePath alloc] init];
    NSMutableArray *array = [NSMutableArray arrayWithArray:sp.savedSettings];
    [array replaceObjectAtIndex:1 withObject:incrementalUnit];
    [sp saveArray:array toSavePath:@"savedSettings"];
    
    [self.tableView reloadData];
}

- (IBAction)changeMapType:(id)sender{
    UISegmentedControl *sc = (UISegmentedControl *)sender;
    int segment = [sc selectedSegmentIndex];
    mapType = segment+1;
    
    savePath *sp = [[savePath alloc] init];
    NSMutableArray *array = [NSMutableArray arrayWithArray:sp.savedSettings];
    [array replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:mapType]];
    [sp saveArray:array toSavePath:@"savedSettings"];
    
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 2){
        return rowHeight*2.5;
    }
    else if (indexPath.section == 1 && indexPath.row == 1){
        return rowHeight*3;
    }
    else if (indexPath.section == 2 && indexPath.row == 1){
        return rowHeight*2.5;
    }
    else{
        return rowHeight;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
