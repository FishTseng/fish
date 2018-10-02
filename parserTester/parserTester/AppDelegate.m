//
//  AppDelegate.m
//  parserTester
//
//  Created by  Fish on 5/3/17.
//  Copyright © 2017  Fish. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(IBAction)selectFile:(NSButton *)sender {
    
    NSOpenPanel *pnl=[NSOpenPanel openPanel];
    [pnl runModal];
    
    NSString *mdFilePath = [NSString stringWithFormat:@"%@",[[pnl URLs] objectAtIndex:0]];
    
    [txtFileNameCell setTextColor:[NSColor blueColor]];
    [txtFileNameCell setStringValue:mdFilePath];
    [txtFileNameField display];
    
    if ([mdFilePath containsString:@"file://"]) {
        mdFilePath = [mdFilePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    }
    
    //[Cmbn QT] Add parsing Header file in
    NSError *error = nil;
    parser = [FFParse new];
    [parser addParseDefinitionFile:mdFilePath error:&error];
    
    //Retrive all commands from MD file
    NSMutableDictionary *tmpCommands = [parser allCommands];
    cmdArr = [[tmpCommands allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    [popUpCommand removeAllItems];
    [popUpCommand addItemsWithTitles:cmdArr];
    
    
}

- (IBAction)retriveCMD:(NSPopUpButton *)sender {
    
    theCommand = @"";
    theCommand = [cmdArr objectAtIndex:[[popUpCommand objectValue] integerValue]];
    NSLog(@"thisCommand:%@", theCommand);
    

}

- (IBAction)btnTest:(NSButton *)sender {
    
    
    NSString *thisResponse = [txtResponse string];
    NSArray *tempArray = [[NSArray alloc] init];
    tempArray = [parser parseCommand:theCommand deviceResponse:thisResponse error:nil];
    
    NSRange matchedRange;
    NSRange notMatchedRange;
    NSDictionary *cleanedResponse = tempArray[0];
    NSDictionary *regexMetaData = cleanedResponse[@"__regex_metadata__"];
    
    //If there is no feedback then no need to add 1 for the length to remove anything
    matchedRange = NSMakeRange([regexMetaData[@"location"] unsignedIntegerValue], [regexMetaData[@"length"] unsignedIntegerValue]);
    notMatchedRange = NSMakeRange(0, [regexMetaData[@"location"] unsignedIntegerValue]);
    
    
    NSString *thisOutput = @"";
    NSArray *keyArr = [[cleanedResponse allKeys] sortedArrayUsingSelector:@selector(compare:)];
    BOOL flag=0;
    
    if ([regexMetaData[@"location"] unsignedIntegerValue]==0)
    {
        for (int i=0; i<[cleanedResponse count]; i++) {
            
            if ([[keyArr objectAtIndex:i] containsString:@"__regex_metadata__"]) {
                flag=1;
                break;
            }else{
                thisOutput = [thisOutput stringByAppendingFormat:@"%@:\t%@\n", [keyArr objectAtIndex:i], [cleanedResponse objectForKey:[keyArr objectAtIndex:i]]];
            }
        }

    }
    
    [txtOutput setTextColor:[NSColor blueColor]];
    if (flag==0) {
        thisOutput = [NSString stringWithFormat:@"Can Not Match!! :("];
        [txtOutput setTextColor:[NSColor redColor]];
    }else{
        thisOutput = [NSString stringWithFormat:@"Match!! :D\n\n%@", thisOutput];
        [txtOutput setTextColor:[NSColor blueColor]];
    }
    
    [txtOutput setString:thisOutput];
    
    
}




@end