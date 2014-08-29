//
//  savePath.m
//  Extraction 3.5
//
//  Created by Leonard Chan on 10/10/13.
//  Copyright (c) 2013 Leonard Chan. All rights reserved.
//

#import "savePath.h"

@implementation savePath

@synthesize searchHistory;
@synthesize savedPaths;
@synthesize savedImages;
@synthesize savedSettings;
@synthesize savedMapData;

- (id)init{
    self = [super init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString *documentPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentPath stringByAppendingPathComponent:@"Data.plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]){
        plistPath = [[NSBundle mainBundle] pathForResource:@"Data" ofType:@"plist"];
    }
    
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSDictionary *dictionary = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
    if (!dictionary){
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }
    searchHistory = [NSMutableArray arrayWithArray:[dictionary objectForKey:@"searchHistory"]];
    savedPaths = [NSMutableArray arrayWithArray:[dictionary objectForKey:@"savedPaths"]];
    savedImages = [NSMutableArray arrayWithArray:[dictionary objectForKey:@"savedImages"]];
    savedSettings = [NSMutableArray arrayWithArray:[dictionary objectForKey:@"savedSettings"]];
    savedMapData = [NSMutableArray arrayWithArray:[dictionary objectForKey:@"savedMapData"]];
    
    return self;
}

- (void)saveArray:(NSArray *)array toSavePath:(NSString *)savePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString *documentPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentPath stringByAppendingPathComponent:@"Data.plist"];
    
    if ([savePath isEqualToString:@"searchHistory"]){
        searchHistory = [NSMutableArray arrayWithArray:array];
    }
    if ([savePath isEqualToString:@"savedPaths"]){
        savedPaths = [NSMutableArray arrayWithArray:array];
    }
    if ([savePath isEqualToString:@"savedImages"]){
        savedImages = [NSMutableArray arrayWithArray:array];
    }
    if ([savePath isEqualToString:@"savedSettings"]){
        savedSettings = [NSMutableArray arrayWithArray:array];
    }
    if ([savePath isEqualToString:@"savedMapDataa"]){
        savedMapData = [NSMutableArray arrayWithArray:array];
    }
    
    //NSDictionary *plistDictionary = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:searchHistory, savedPaths, nil] forKey:[NSArray arrayWithObjects:@"searchHistory", @"savedPaths", nil]];
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:searchHistory, savedPaths, savedImages, savedSettings, savedMapData, nil] forKeys:[NSArray arrayWithObjects:@"searchHistory", @"savedPaths", @"savedImages", @"savedSettings", @"savedMapData", nil]];
    
    NSString *error = nil;
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDictionary format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    
    if (plistData){
        [plistData writeToFile:plistPath atomically:true];
    }
    else{
        NSLog(@"Error in saveArray: %@", error);
    }
}

@end
