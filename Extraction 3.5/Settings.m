//
//  Settings.m
//  Extraction 3.5
//
//  Created by Leonard Chan on 10/13/13.
//  Copyright (c) 2013 Leonard Chan. All rights reserved.
//

#import "Settings.h"

@interface Settings ()

@end

@implementation Settings{
    NSMutableArray *settingsArray;
}

@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    settingsArray = [[NSMutableArray alloc] initWithObjects:@"Map Type", @"Incremental Units", nil];
    
    self.tableView = settingsTableView;
}

- (void)processComplete{
    [[self delegate] processSuccessful:true withString:@"PLEASE SEE THIS"];
}

- (void)startSomeProcess{
    [self performSelector:@selector(processComplete)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark CONTROL THE TABLE VIEW

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return settingsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [settingsArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0){
        //[settingsArray insertObject:@"Hello" atIndex:indexPath.row+1];
        //[settingsTableView reloadData];
        [settingsArray insertObject:@"" atIndex:indexPath.row+1];
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

@end
