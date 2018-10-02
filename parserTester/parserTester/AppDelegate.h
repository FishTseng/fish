//
//  AppDelegate.h
//  parserTester
//
//  Created by  Fish on 5/3/17.
//  Copyright © 2017  Fish. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <FFParser/FFParse.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>{
@private
    
    IBOutlet NSTextField *txtFileNameField;
    IBOutlet NSTextFieldCell *txtFileNameCell;
    
    IBOutlet NSComboBox *txtCommandField;
    IBOutlet NSPopUpButton *popUpCommand;

    IBOutlet NSTextView *txtOutput;
    IBOutlet NSTextView *txtResponse;
    
    FFParse *parser;
    NSArray *cmdArr;
    NSString *theCommand;

    
}


- (IBAction)selectFile:(NSButton *)sender;
- (IBAction)retriveCMD:(NSPopUpButton *)sender;
- (IBAction)btnTest:(NSButton *)sender;






@end

