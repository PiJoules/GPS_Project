//
//  SettingsView.m
//  Extraction 3.5
//
//  Created by Leonard Chan on 10/19/13.
//  Copyright (c) 2013 Leonard Chan. All rights reserved.
//

#import "SettingsView.h"
#import "savePath.h"

@interface SettingsView ()

@end

@implementation SettingsView{
    NSDictionary *dictionary;
    NSMutableArray *maps;
    NSArray *unitsArray;
    savePath *sp;
    
    NSString *initIncrementalUnit;
    NSNumber *initMapType;
}

@synthesize selection;
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
    
    
    //set up map type
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
    
    //setup incremental units
    unitsArray = [NSArray arrayWithObjects:@"Feet (ft)", @"Yards (yd)", @"Meters (m)", @"Kilometers (km)", @"Miles (mi)", nil];
    initIncrementalUnit = [NSString stringWithFormat:@"%@", incrementalUnit];
    initMapType = [NSNumber numberWithInt:mapType];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (![initIncrementalUnit isEqualToString:incrementalUnit] || [initMapType intValue] != mapType){
        sp = [[savePath alloc] init];
        NSMutableArray *array = [NSMutableArray arrayWithArray:sp.savedSettings];
        
        if ([selection isEqualToString:@"Map Types"]){
            [array replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:mapType]];
        }
        else if ([selection isEqualToString:@"Incremental Units"]){
            [array replaceObjectAtIndex:1 withObject:incrementalUnit];
        }else{}
        
        [sp saveArray:array toSavePath:@"savedSettings"];
    }
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
    if ([selection isEqualToString:@"Map Types"]){
        return maps.count;
    }
    else if ([selection isEqualToString:@"Incremental Units"]){
        return unitsArray.count;
    }else{}
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    if ([selection isEqualToString:@"Map Types"]){
        cell.textLabel.text = maps[indexPath.row];
        cell.detailTextLabel.text = @"";
        if (indexPath.row == mapType-1){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else if ([selection isEqualToString:@"Incremental Units"]){
        cell.textLabel.text = unitsArray[indexPath.row];
        cell.detailTextLabel.text = @"";
        if ([unitsArray[indexPath.row] isEqualToString:incrementalUnit]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }else{}
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //savePath *sp = [[savePath alloc] init];
    //NSMutableArray *array = [NSMutableArray arrayWithArray:sp.savedSettings];
    
    //if ([selection isEqualToString:@"Map Types"]){
        mapType = indexPath.row+1;
        //[array replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:mapType]];
    //}
    //else if ([selection isEqualToString:@"Incremental Units"]){
        incrementalUnit = unitsArray[indexPath.row];
        //[array replaceObjectAtIndex:1 withObject:incrementalUnit];
    //}else{}
    
    //[sp saveArray:array toSavePath:@"savedSettings"];
    [tableView reloadData];
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
