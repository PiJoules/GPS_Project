//
//  SettingsController.m
//  Extraction 3.5
//
//  Created by Leonard Chan on 10/19/13.
//  Copyright (c) 2013 Leonard Chan. All rights reserved.
//

#import "SettingsController.h"
#import "SettingsView.h"
#import "savePath.h"

#define CELLHEIGHT  44
#define LABELWIDTH  291

@interface SettingsController ()

@end

@implementation SettingsController{
    GMSMapViewType mapType;
    savePath *sp;
    UISwitch *snapSwitch;
    UISwitch *hintSwitch;
    NSDictionary *dictionary;
    NSMutableArray *settingsArray;
    NSMutableArray *maps;
    NSString *selection;
    NSString *incrementalUnit;
    BOOL snapOn;
    BOOL hintsOn;
    NSNumber *initSnap;
    NSNumber *initHints;
}

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
    
    sp = [[savePath alloc] init];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    settingsArray = [NSMutableArray arrayWithObjects:@"Map Types", @"Incremental Units", @"Snap to starting point", @"Hints", nil];
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
    
    snapOn = [sp.savedSettings[2] boolValue];
    initSnap = [NSNumber numberWithBool:snapOn];
    hintsOn = [sp.savedSettings[3] boolValue];
    initHints = [NSNumber numberWithBool:hintsOn];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (snapOn != [initSnap boolValue] || hintsOn != [initHints boolValue]){
        NSMutableArray *array = [NSMutableArray arrayWithArray:sp.savedSettings];
        if ([initSnap boolValue] != snapOn){
            [array replaceObjectAtIndex:2 withObject:[NSNumber numberWithBool:snapOn]];
        }
        if ([initHints boolValue] != hintsOn){
            [array replaceObjectAtIndex:3 withObject:[NSNumber numberWithBool:hintsOn]];
        }
        [sp saveArray:array toSavePath:@"savedSettings"];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    sp = [[savePath alloc] init];
    
    //map type setup
    //if (sp.savedSettings.count != 0){
    mapType = [sp.savedSettings[0] intValue];
    /*}
    else{
        mapType = kGMSTypeNormal;
        NSMutableArray *array = [NSMutableArray arrayWithArray:sp.savedSettings];
        [array insertObject:[NSNumber numberWithInt:mapType] atIndex:0];
        [sp saveArray:array toSavePath:@"savedSettings"];
    }*/
    
    //incremental units setup
    //if (sp.savedSettings.count > 1){
        incrementalUnit = [NSString stringWithFormat:@"%@",sp.savedSettings[1]];
    /*}
    else{
        incrementalUnit = [NSString stringWithFormat:@"Meters (m)"];
        NSMutableArray *array = [NSMutableArray arrayWithArray:sp.savedSettings];
        [array insertObject:incrementalUnit atIndex:1];
        [sp saveArray:array toSavePath:@"savedSettings"];
    }*/
    
    //snap marker
    /*if (sp.savedSettings.count > 2){
        snapOn = [sp.savedSettings[2] boolValue];
    }
    else{
        snapOn = true;
        NSMutableArray *array = [NSMutableArray arrayWithArray:sp.savedSettings];
        [array insertObject:[NSNumber numberWithBool:snapOn] atIndex:2];
        [sp saveArray:array toSavePath:@"savedSettings"];
    }
    
    //hints available
    if (sp.savedSettings.count > 3){
        hintsOn = [sp.savedSettings[3] boolValue];
    }
    else{
        hintsOn = true;
        NSMutableArray *array = [NSMutableArray arrayWithArray:sp.savedSettings];
        [array insertObject:[NSNumber numberWithBool:hintsOn] atIndex:3];
        [sp saveArray:array toSavePath:@"savedSettings"];
    }*/
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return settingsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = settingsArray[indexPath.row];
    if (indexPath.row == 0){
        cell.detailTextLabel.text = maps[mapType-1];
    }
    else if (indexPath.row == 1){
        cell.detailTextLabel.text = incrementalUnit;
    }
    else if (indexPath.row == 2){
        cell.detailTextLabel.text = @"";
        if (!snapSwitch){
            snapSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(240, CELLHEIGHT/5, 50, CELLHEIGHT/2)];
            [snapSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
            snapSwitch.on = snapOn;
            [cell.contentView addSubview:snapSwitch];
        }
    }
    else if (indexPath.row == 3){
        cell.detailTextLabel.text = @"";
        if (!hintSwitch){
            hintSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(240, CELLHEIGHT/5, 50, CELLHEIGHT/2)];
            [hintSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
            hintSwitch.on = hintsOn;
            [cell.contentView addSubview:hintSwitch];
        }
    }else{}
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CELLHEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < 2){
        selection = [NSString stringWithFormat:@"%@", settingsArray[indexPath.row]];
        [self performSegueWithIdentifier:@"toSettings" sender:self];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toSettings"]){
        SettingsView *sv = [segue destinationViewController];
        sv.selection = selection;
        sv.mapType = mapType;
        sv.incrementalUnit = incrementalUnit;
    }
}

- (void)changeSwitch:(UISwitch *)swatch{
    if ([swatch isEqual:snapSwitch]){
        snapOn = !snapOn;
    }
    else if ([swatch isEqual:hintSwitch]){
        hintsOn = !hintsOn;
    }else{}
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
