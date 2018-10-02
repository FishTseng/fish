//
//  AppDelegate.h
//  ChargePercentageCheck
//
//  Created by  Fish on 9/26/18.
//  Copyright © 2018  Fish. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>{
    
    IBOutlet NSTextField *txtSelectedFile;
    //IBOutlet NSTableView *resultTable;
    
}

- (IBAction)SelectFolder:(NSButton *)sender;
- (IBAction)cleanVariable:(NSButton *)sender;

@property (weak) IBOutlet NSTableView *resultTable;


@end

NSString *filePath;
NSArray *directoryListStr;
NSMutableDictionary *globalDict;
NSMutableArray *tableData[3];

