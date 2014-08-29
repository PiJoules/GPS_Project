//
//  savePath.h
//  Extraction 3.5
//
//  Created by Leonard Chan on 10/10/13.
//  Copyright (c) 2013 Leonard Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface savePath : NSObject

- (id)init;
- (void)saveArray:(NSArray *)array toSavePath:(NSString *)savePath;
@property (nonatomic, strong) NSMutableArray *searchHistory;
@property (nonatomic, strong) NSMutableArray *savedPaths;
@property (nonatomic, strong) NSMutableArray *savedImages;
@property (nonatomic, strong) NSMutableArray *savedSettings;
@property (nonatomic, strong) NSMutableArray *savedMapData;

@end
