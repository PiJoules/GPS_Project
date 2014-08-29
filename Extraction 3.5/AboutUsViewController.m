//
//  AboutUsViewController.m
//  Extraction 3.5
//
//  Created by Leonard Chan on 11/10/13.
//  Copyright (c) 2013 Leonard Chan. All rights reserved.
//

#import "AboutUsViewController.h"

@interface AboutUsViewController ()

@end

@implementation AboutUsViewController

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
    
    int fontSize = 12;
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, scroll.frame.size.width-10, scroll.frame.size.height)];
    label1.numberOfLines = 0;
    label1.font = [UIFont boldSystemFontOfSize:16];
    //label1.backgroundColor = [UIColor colorWithRed:(210/255) green:(180/255) blue:(140/255) alpha:1];
    label1.text = @"What does this app do?";
    [label1 sizeToFit];
    [label1 setFrame:CGRectMake(scroll.frame.size.width/2-label1.frame.size.width/2, label1.frame.origin.y, label1.frame.size.width, label1.frame.size.height)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 2+label1.frame.size.height+label1.frame.origin.y, scroll.frame.size.width-10, scroll.frame.size.height)];
    label.text = @"The GPS Extractor allows you to use your finger to make any shape on a map in order to “Extract” GPS coordinates in various increments (feet, yards, meters, kilometers, miles). Before you needed to have a computer to use special software that allows you to find coordinates anywhere on a map. With this app, you can get any coordinates of free hand drawing, straight lines, rectangles and circles, anywhere in the world, straight from your mobile phone.";
    label.numberOfLines = 0;
    label.font = [label.font fontWithSize:fontSize];
    //label.backgroundColor = [UIColor greenColor];
    [label sizeToFit];
    
    UILabel *midLabel = [self lineLabel:CGRectMake(22, label.frame.size.height+label.frame.origin.y+10, scroll.frame.size.width-44, 20)];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(5, 10+midLabel.frame.size.height+midLabel.frame.origin.y, scroll.frame.size.width-10, scroll.frame.size.height)];
    label3.numberOfLines = 0;
    label3.font = [UIFont boldSystemFontOfSize:16];
    //label3.backgroundColor = [UIColor yellowColor];
    label3.text = @"What does this app feature?";
    [label3 sizeToFit];
    [label3 setFrame:CGRectMake(scroll.frame.size.width/2-label3.frame.size.width/2, label3.frame.origin.y, label3.frame.size.width, label3.frame.size.height)];
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(5, 2+label3.frame.size.height+label3.frame.origin.y, scroll.frame.size.width-10, scroll.frame.size.height)];
    label4.text = @"\u2022 Can go to any location in the world to find coordinates\r\u2022 Several options to draw on the map (free hand, line, rectangle, circle)\r\u2022 Allows you to change increments of coordinate extractions (feet, yards, meters, kilometers, miles). The smaller the unit, the more coordinate points will show.\r\u2022 Can change the map type (normal, satellite, terrain, hybrid)\r\u2022 ON/OFF button to snap to starting point\r\u2022 Saves previous search location history (option to delete)\r\u2022 Can save the markings done on the phone and it will be saved under “Saved Extractions”";
    label4.numberOfLines = 0;
    label4.font = [label4.font fontWithSize:fontSize];
    //label4.backgroundColor = [UIColor greenColor];
    [label4 sizeToFit];
    [label4 setFrame:CGRectMake(scroll.frame.size.width/2-label4.frame.size.width/2, label4.frame.origin.y, label4.frame.size.width, label4.frame.size.height)];
    
    UILabel *midLabel2 = [self lineLabel:CGRectMake(22, label4.frame.size.height+label4.frame.origin.y+10, scroll.frame.size.width-44, 20)];
    
    UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(5, 10+midLabel2.frame.size.height+midLabel2.frame.origin.y, scroll.frame.size.width, scroll.frame.size.height)];
    label5.text = @"What is this app for?";
    label5.numberOfLines = 0;
    label5.font = [UIFont boldSystemFontOfSize:16];
    //label5.backgroundColor = [UIColor grayColor];
    [label5 sizeToFit];
    [label5 setFrame:CGRectMake(scroll.frame.size.width/2-label5.frame.size.width/2, label5.frame.origin.y, label5.frame.size.width, label5.frame.size.height)];
    
    UILabel *label6 = [[UILabel alloc] initWithFrame:CGRectMake(5, 2+label5.frame.size.height+label5.frame.origin.y, scroll.frame.size.width-10, scroll.frame.size.height)];
    label6.text = @"This app was created for users to easily obtain GPS coordinates from anywhere in the world without having to go on a computer. This app can be used for any vehicle that receives GPS signals such as drones, airplanes, helicopters, cars and much more. The coordinates can be used as a path or invisible boundary for various vehicles.";
    label6.numberOfLines = 0;
    label6.font = [label6.font fontWithSize:fontSize];
    //label6.backgroundColor = [UIColor greenColor];
    [label6 sizeToFit];
    [label6 setFrame:CGRectMake(scroll.frame.size.width/2-label6.frame.size.width/2, label6.frame.origin.y, label6.frame.size.width, label6.frame.size.height)];
    
    UILabel *midLabel3 = [self lineLabel:CGRectMake(22, label6.frame.size.height+label6.frame.origin.y+10, scroll.frame.size.width-44, 20)];
    
    UILabel *label0 = [[UILabel alloc] initWithFrame:CGRectMake(5, 20+midLabel3.frame.size.height+midLabel3.frame.origin.y, scroll.frame.size.width, scroll.frame.size.height)];
    label0.numberOfLines = 0;
    label0.font = [UIFont italicSystemFontOfSize:16];
    label0.text = @"A Thank You from Us";
    [label0 sizeToFit];
    [label0 setFrame:CGRectMake(scroll.frame.size.width/2-label0.frame.size.width/2, label0.frame.origin.y, label0.frame.size.width, label0.frame.size.height)];
    
    UILabel *thanksLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 2+label0.frame.size.height+label0.frame.origin.y, scroll.frame.size.width-10, scroll.frame.size.height)];
    thanksLabel.numberOfLines = 0;
    thanksLabel.font = [thanksLabel.font fontWithSize:fontSize];
    thanksLabel.text = @"We would like to thank you for purchasing this app. We thank you for supporting us and we hope to release more apps in the future as well as updates for this app. Please send us feed back and suggestions for ways we can improve this app or other apps.\rThanks from us,\r\rLeonard Chan\rDaniel Diazdelcastillo\rGPScoordinateextractor@gmail.com";
    [thanksLabel sizeToFit];
    [thanksLabel setFrame:CGRectMake(scroll.frame.size.width/2-thanksLabel.frame.size.width/2, thanksLabel.frame.origin.y, thanksLabel.frame.size.width, thanksLabel.frame.size.height)];
    
    //[scroll setContentSize:CGSizeMake(scroll.contentSize.width, 60+label0.frame.size.height+thanksLabel.frame.size.height+label1.frame.size.height+label.frame.size.height+label3.frame.size.height+label4.frame.size.height+label5.frame.size.height+label6.frame.size.height)];
    [scroll setContentSize:CGSizeMake(scroll.contentSize.width, 30+thanksLabel.frame.origin.y+thanksLabel.frame.size.height)];
    //scroll.backgroundColor = [UIColor colorWithRed:(210/255) green:(180/255) blue:(140/255) alpha:1];
    //scroll.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BACKGROUND]];
    [scroll addSubview:label0];
    [scroll addSubview:thanksLabel];
    [scroll addSubview:label1];
    [scroll addSubview:label];
    [scroll addSubview:label3];
    [scroll addSubview:label4];
    [scroll addSubview:label5];
    [scroll addSubview:label6];
    [scroll addSubview:midLabel];
    [scroll addSubview:midLabel2];
    [scroll addSubview:midLabel3];
}

- (UILabel *)lineLabel:(CGRect)area{
    UILabel *label = [[UILabel alloc] initWithFrame:area];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"_________________________________";
    label.font = [UIFont boldSystemFontOfSize:16];
    label.numberOfLines = 0;
    [label sizeToFit];
    
    return label;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
