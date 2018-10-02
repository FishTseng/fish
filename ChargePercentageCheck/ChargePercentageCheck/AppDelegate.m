//
//  AppDelegate.m
//  ChargePercentageCheck
//
//  Created by  Fish on 9/26/18.
//  Copyright © 2018  Fish. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate
//@synthesize window = _window,resultTable;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [_resultTable setEnabled:false];
    [_resultTable setAllowsColumnResizing:false];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(void)windowShouldClose:(NSNotification *)notification {
    
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
    
}


- (IBAction)SelectFolder:(NSButton *)sender {
    
    globalDict=[[NSMutableDictionary alloc] init];
    directoryListStr=[[NSArray alloc] init];
    for (int i=0; i<3; i++) {
        tableData[i]=[[NSMutableArray alloc] init];
    }
    
    NSOpenPanel *pnl=[NSOpenPanel openPanel];
    [pnl setCanChooseDirectories:YES];
    [pnl runModal];
    
    NSString *folderPath = [NSString stringWithFormat:@"%@",[[pnl URLs] objectAtIndex:0]];
    
    if ([folderPath containsString:@"file://"]) {
        folderPath = [folderPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    }
    
    //NSLog(@"[folderPath]:%@", folderPath);
    filePath = [NSString stringWithString:folderPath];
    
    [txtSelectedFile setTextColor:[NSColor blueColor]];
    [txtSelectedFile setStringValue:filePath];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directoryList = [fm contentsOfDirectoryAtURL:[[pnl URLs] objectAtIndex:0]
                               includingPropertiesForKeys:nil
                                                  options:NSDirectoryEnumerationSkipsHiddenFiles
                                                    error:nil];
    directoryListStr = [fm contentsOfDirectoryAtPath:filePath error:nil];
    NSLog(@"directoryList:%@",directoryList);
    NSLog(@"directoryListStr:%@",directoryListStr);
    
  
    for (int i=0; i<[directoryList count]; i++) {
        
        NSURL *fileURL = [directoryList objectAtIndex:i];
        [self findFile:fileURL];
        
    }
    [self dataProcessing];
    [_resultTable setEnabled:true];
    [_resultTable updateConstraints];
    [_resultTable updateConstraintsForSubtreeIfNeeded];
    
    
}

- (IBAction)cleanVariable:(NSButton *)sender {
    
    for (int i=0; i<3; i++) {
        [tableData[i] removeAllObjects];
    }
    
    [_resultTable setEnabled:false];
    [_resultTable updateConstraints];
    [_resultTable updateConstraintsForSubtreeIfNeeded];
    
    
}


- (void)findFile:(NSURL *)thisURL{
    
    NSFileManager *fm=[NSFileManager defaultManager];
    NSArray *fileList = [fm contentsOfDirectoryAtURL:thisURL
                               includingPropertiesForKeys:nil
                                                  options:NSDirectoryEnumerationSkipsHiddenFiles
                                                    error:nil];
    //NSLog(@"[fileList]:%@",fileList);
    
    NSString *thisStr = @"";
    NSString *thisFolder = [self GetSpecStr:[NSString stringWithFormat:@"%@", [fileList objectAtIndex:1]] thestartStr:filePath theendStr:@"/"];
    for (int i=0; i<[fileList count]; i++) {
        thisStr = [NSString stringWithFormat:@"%@", [fileList objectAtIndex:i]];
        if ([thisStr containsString:@"Smokey.log"]) {
            [self findData:[fileList objectAtIndex:i] folder:thisFolder];
            break;
        }
    }

    //NSLog(@"[globalDict]:%@",globalDict);
    
}

- (void)findData:(NSURL *)thisURL folder:(NSString *)thisFolder{
    
    NSString *fileContents = [NSString stringWithContentsOfURL:thisURL encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *tmpArr = [[NSMutableArray alloc] init];
    NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
    NSString *startStr = @":-) dev -k gasgauge -p";
    NSString *endStr = @"pairing-count:";
    NSUInteger loc = 0;
    
    while ([fileContents containsString:startStr]) {
        [tmpArr addObject:[self GetSpecStr:fileContents thestartStr:startStr theendStr:endStr]];
        loc=[fileContents rangeOfString:endStr].location+endStr.length;
        fileContents = [fileContents substringFromIndex:loc];
    }
    //NSLog(@"tmpArr:%@", tmpArr);
    
    NSMutableString *firstPower = [[NSMutableString alloc] init];
    NSMutableString *lastPower = [[NSMutableString alloc] init];
    firstPower = [tmpArr objectAtIndex:0];
    [tmpDict setObject:[self GetSpecStr:firstPower thestartStr:@"charge-percentage: \"" theendStr:@"\""] forKey:@"first"];;
    
    lastPower = [tmpArr lastObject];
    [tmpDict setObject:[self GetSpecStr:lastPower thestartStr:@"charge-percentage: \"" theendStr:@"\""] forKey:@"last"];
    
    [globalDict setObject:tmpDict forKey:thisFolder];
    
}

- (void)dataProcessing{
    
    [tableData[0] addObjectsFromArray:[globalDict allKeys]];
    
    for (int i=0; i<[tableData[0] count]; i++) {
        NSLog(@"[tableData[0] objectAtIndex:i]:%@",[tableData[0] objectAtIndex:i]);
        NSLog(@"[globalDict objectForKey:[tableData[0] objectAtIndex:i]]:%@",[globalDict objectForKey:[tableData[0] objectAtIndex:i]]);
        [tableData[1] addObject:[[globalDict objectForKey:[tableData[0] objectAtIndex:i]] objectForKey:@"first"]];
        [tableData[2] addObject:[[globalDict objectForKey:[tableData[0] objectAtIndex:i]] objectForKey:@"last"]];
    }
    
}

- (id)tableView: (NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
    
    NSString *identifier=[aTableColumn identifier];
    
    if ([identifier isEqualToString:@"File"]) {
        if ([tableData[0] count]>0 && rowIndex<[tableData[0] count]) {
            return [tableData[0] objectAtIndex:rowIndex];
        }
        
    }else if ([identifier isEqualToString:@"Start"]){
        if ([tableData[1] count]>0 && rowIndex<[tableData[1] count]) {
            return [tableData[1] objectAtIndex:rowIndex];
        }
        
    }else if ([identifier isEqualToString:@"End"]){
        if ([tableData[2] count]>0 && rowIndex<[tableData[2] count]) {
            return [tableData[2] objectAtIndex:rowIndex];
        }
    }
    return @"";

}

- (void)tableView: (NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
    
    if (rowIndex<[tableData[0] count]) {
        [aCell setTextColor:[NSColor blueColor]];
    }

}

- (NSUInteger) numberOfRowsInTableView: (NSTableView *)tableView
{
    return 10;
}

- (NSString *)GetSpecStr:(NSString *)Original thestartStr:(NSString *)startStr theendStr:(NSString *)endStr
{
    if([startStr length]>0 && [Original rangeOfString:startStr].length)
    {
        NSUInteger sP=[Original rangeOfString:startStr].location;
        sP=sP+[startStr length];
        Original=[Original substringFromIndex:sP];
    }
    if([endStr length]>0 && [Original rangeOfString:endStr].length)
    {
        NSUInteger eL=[Original rangeOfString:endStr].location;
        return [Original substringToIndex:eL];
    }
    return Original;
}



@end
