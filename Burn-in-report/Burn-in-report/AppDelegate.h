//
//  AppDelegate.h
//  Burn-in-report
//
//  Created by  Fish on 5/18/18.
//  Copyright © 2018  Fish. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>{
    
    IBOutlet NSTextView *txtFileList;
    
}

@property (strong) IBOutlet NSTextField *txtFolderField;

- (IBAction)selectFolder:(NSButton *)sender;


@end

NSMutableDictionary *csvFiles;
NSMutableDictionary *pdcaFiles;
NSMutableDictionary *pucksnDict;
NSMutableDictionary *failuresDict;
NSMutableDictionary *StatusCodeDict;
NSMutableArray *snArr;
NSString *filePath;
NSString *dateStr;
