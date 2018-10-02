//
//  AppDelegate.m
//  Burn-in-report
//
//  Created by  Fish on 5/18/18.
//  Copyright © 2018  Fish. All rights reserved.
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


- (IBAction)selectFolder:(NSButton *)sender {
    
    csvFiles= [[NSMutableDictionary alloc] init];
    pdcaFiles= [[NSMutableDictionary alloc] init];
    pucksnDict= [[NSMutableDictionary alloc] init];
    failuresDict= [[NSMutableDictionary alloc] init];
    snArr = [[NSMutableArray alloc] init];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"YYYY-MM-dd-HH-mm-ss"];
    dateStr=[form stringFromDate:date];
    
    NSOpenPanel *pnl=[NSOpenPanel openPanel];
    [pnl setCanChooseDirectories:YES];
    [pnl runModal];
    
    NSString *folderPath = [NSString stringWithFormat:@"%@",[[pnl URLs] objectAtIndex:0]];
    
    if ([folderPath containsString:@"file://"]) {
        folderPath = [folderPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    }
    
    NSLog(@"[folderPath]:%@", folderPath);
    filePath = [NSString stringWithString:folderPath];
    
    [_txtFolderField setTextColor:[NSColor blueColor]];
    [_txtFolderField setStringValue:folderPath];
    [_txtFolderField display];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directoryList = [fm contentsOfDirectoryAtURL:[[pnl URLs] objectAtIndex:0]
                               includingPropertiesForKeys:nil
                                                  options:NSDirectoryEnumerationSkipsHiddenFiles
                                                    error:nil];
    NSLog(@"directoryList:%@",directoryList);
    
    NSString *tmpStr = [[NSString alloc] init];
    NSArray *tmpArr = [[NSArray alloc] init];
    NSString *sn = [[NSString alloc] init];
    NSString *showInField = @"";
    NSString *puckSN = @"";
    
    for (int i=0; i<[directoryList count]; i++) {
        tmpStr = [NSString stringWithFormat:@"%@", [directoryList objectAtIndex:i]];
        tmpArr = [tmpStr componentsSeparatedByString:@"/"];
        sn = [NSString stringWithFormat:@"%@",[tmpArr objectAtIndex:[tmpArr count]-2]];
        [snArr addObject:sn];
        NSLog(@"***sn:%@",sn);
        
        [self fileRetrive:[directoryList objectAtIndex:i] thisSN:sn];
        puckSN = [self readPlist:[pdcaFiles objectForKey:sn] thisKey:@"WirelessChargerMCUSerialNumber"];
        if([puckSN isNotEqualTo:@""])
            [pucksnDict setObject:puckSN forKey:sn];
        else
            [pucksnDict setObject:@"No Data" forKey:sn];
        
        showInField = [showInField stringByAppendingFormat:@"**SN: %@\n",sn];
        showInField = [showInField stringByAppendingFormat:@"**puckSN: %@\n\n",puckSN];
        
        [self readFailureFile:[csvFiles objectForKey:sn] thisSN:sn];
    }
    
    
    NSLog(@"pucksnDict:%@", pucksnDict);
    NSLog(@"failuresDict:%@", failuresDict);
    
    [self writeLog];
    [self failQuantity];

    showInField = [showInField stringByAppendingFormat:@"file at /vault/burn-in-test_failures-%@.csv\n", dateStr];
    showInField = [showInField stringByAppendingFormat:@"file at /vault/burn-in-test-%@.csv\n", dateStr];
    [txtFileList setString:showInField];
    [txtFileList display];
    
}

- (NSString *)fileRetrive:(NSURL *)thisURL thisSN:(NSString *)sn{
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *tmpStr = @"";
    NSURL *tempDirURL = [[NSURL alloc] init];
    
    NSArray *fileList = [fm contentsOfDirectoryAtURL:thisURL
                          includingPropertiesForKeys:nil
                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                               error:nil];
    
    tmpStr = [NSString stringWithFormat:@"%@MobileMediaFactoryLogs/LogCollector/", [fileList objectAtIndex:0]];
    if ([tmpStr containsString:@"file://"]) {
        tmpStr = [tmpStr stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    }
    NSLog(@"tmpStr2:%@",tmpStr);
    tempDirURL = [NSURL fileURLWithPath:tmpStr];
    NSArray *fileList2 = [fm contentsOfDirectoryAtURL:tempDirURL
                           includingPropertiesForKeys:nil
                                              options:NSDirectoryEnumerationSkipsHiddenFiles
                                                error:nil];
    tmpStr = [NSString stringWithFormat:@"%@", [fileList2 objectAtIndex:0]];
    NSLog(@"tmpStr3:%@",tmpStr);
    
    NSArray *fileList3 = [fm contentsOfDirectoryAtURL:[fileList2 objectAtIndex:0]
                           includingPropertiesForKeys:nil
                                              options:NSDirectoryEnumerationSkipsHiddenFiles
                                                error:nil];
    
    NSString *showInField = @"";
    for(int i=0; i<[fileList3 count]; i++){
        
        tmpStr = [NSString stringWithFormat:@"%@", [fileList3 objectAtIndex:i]];
        if([tmpStr containsString:@"failures.csv"]){
            [csvFiles setObject:[fileList3 objectAtIndex:i] forKey:sn];
            showInField = [showInField stringByAppendingFormat:@"%@\n\n", tmpStr];
        }
        if([tmpStr containsString:@"pdca.plist"] && ![tmpStr containsString:@"decoded"] && ![tmpStr containsString:@"osdpkg"]){
            [pdcaFiles setObject:[fileList3 objectAtIndex:i] forKey:sn];
            showInField = [showInField stringByAppendingFormat:@"%@\n\n", tmpStr];
        }
        
    }
    NSLog(@"fileList1:%@",fileList);
    NSLog(@"fileList2:%@",fileList2);
    NSLog(@"fileList3:%@",fileList3);
    NSLog(@"csvFiles:%@",csvFiles);
    NSLog(@"pdcaFiles:%@",pdcaFiles);
    
    return showInField;
    
}

- (NSString *)readPlist:(NSURL *)thisFileURL thisKey:(NSString *)thisKey {
    
    NSString *result=@"";
    NSMutableDictionary *portSet = [[NSMutableDictionary alloc] init];
    portSet=[[NSMutableDictionary alloc] initWithContentsOfURL:thisFileURL];
    NSDictionary *attributes = [[NSDictionary alloc] initWithDictionary:[[portSet objectForKey:@"0"] objectForKey:@"Attributes"]];
    
    result = [attributes objectForKey:thisKey];

    return result;
}

- (void) readFailureFile:(NSURL *)thisFileURL thisSN:(NSString *)sn{
    
    NSError *error = nil;
    NSString *fileContents = [NSString stringWithContentsOfURL:thisFileURL encoding:NSUTF8StringEncoding error:&error];
    NSArray *rows = [fileContents componentsSeparatedByString:@"\n"];
    NSMutableArray *pdca_Key = [[NSMutableArray alloc] init];
    NSArray *tmpArr = [[NSArray alloc] init];
    NSString *tmpStr = @"";
    NSString *StatusCode = @"";
    StatusCodeDict = [[NSMutableDictionary alloc] init];
    
    for (NSString *row in rows) {
        tmpArr = [row componentsSeparatedByString:@","];
        if ([tmpArr count]>15 && [[tmpArr objectAtIndex:0] isNotEqualTo:@"TIMEOUT"]) {
            tmpStr = [tmpArr objectAtIndex:1];
            tmpStr = [tmpStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            if([tmpStr isNotEqualTo:@"PDCA Key"]){
                NSArray *myArr = [tmpStr componentsSeparatedByString:@"/"];
                NSLog(@"[myArr lastObject]:%@",[myArr lastObject]);
                if ([self isPureInt:[myArr lastObject]]) {
                    tmpStr = [tmpStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"/%@",[myArr lastObject]] withString:@""];
                }
                //tmpStr = [tmpStr stringByReplacingOccurrencesOfString:@"/1" withString:@""];
                [pdca_Key addObject:tmpStr];
            }
            
            //Save Status Code
            StatusCode = [tmpArr objectAtIndex:10];
            [StatusCodeDict setObject:StatusCode forKey:sn];
            NSLog(@"[StatusCodeDict]:%@", StatusCodeDict);
            
        }
        
    }
    NSLog(@"%@ => pdca_Key:%@", sn, pdca_Key);
    [failuresDict setObject:pdca_Key forKey:sn];
    
}

- (BOOL) isPureInt:(NSString *)thisStr{
    
    NSScanner *scan = [NSScanner scannerWithString:thisStr];
    int val;
    return [scan scanInt:&val];
    
}

- (void) writeLog{
    
    NSString *log = @"Test Result,SerialNumber,Puck SN,Status Code,List Of Failing Tests";
    NSArray *tmpArr = [[NSArray alloc] init];
    NSString *faillist = @"";
    NSString *statusCode = @"";
    for (int i=0; i<[snArr count]; i++) {
        tmpArr = [failuresDict objectForKey:[snArr objectAtIndex:i]];
        faillist = [tmpArr objectAtIndex:0];
        statusCode = @"";
        for (int j=1; j<[tmpArr count]; j++) {
            faillist = [faillist stringByAppendingFormat:@"; %@",[tmpArr objectAtIndex:j]];
        }
        if ([StatusCodeDict objectForKey:[snArr objectAtIndex:i]]) {
            statusCode = [StatusCodeDict objectForKey:[snArr objectAtIndex:i]];
        }
        log = [log stringByAppendingFormat:@"\n,%@,%@,%@,\"%@\"", [snArr objectAtIndex:i], [pucksnDict objectForKey:[snArr objectAtIndex:i]], statusCode, faillist];
    }
    
    NSString *csvfileName = [NSString stringWithFormat:@"/vault/burn-in-test-%@.csv", dateStr];
    [log writeToFile:csvfileName atomically:NO encoding:NSUTF8StringEncoding error:NULL];
    
}

- (void) failQuantity{
    
    //NSMutableArray *failuresArr = [[NSMutableArray alloc] init];
    NSMutableDictionary *cal_failuresDict = [[NSMutableDictionary alloc] init];
    for (int i=0; i<[snArr count]; i++) {
        NSArray *tmpArr = [failuresDict objectForKey:[snArr objectAtIndex:i]];

        for (NSString *item in tmpArr) {
            NSMutableArray *thisArr = [[NSMutableArray alloc] init];
            if (![[cal_failuresDict allKeys] containsObject:item]) {
                [thisArr addObject:[snArr objectAtIndex:i]];
                [cal_failuresDict setObject:thisArr forKey:item];
            }else{
                [thisArr setArray:[cal_failuresDict objectForKey:item]];
                [thisArr addObject:[snArr objectAtIndex:i]];
                [cal_failuresDict setObject:thisArr forKey:item];
            }
            //[thisArr removeAllObjects];
            
        }
        //[failuresArr addObjectsFromArray:[failuresDict objectForKey:[snArr objectAtIndex:i]]];
        
    }
    NSLog(@"cal_failuresDict:%@",cal_failuresDict);
    [self writeFailQuantityLog:cal_failuresDict];
    
}

- (void) writeFailQuantityLog:(NSMutableDictionary *) thisDict{
    
    NSArray *key=[[NSArray alloc] initWithArray:[thisDict allKeys]];
    NSString *log = @"Fail_Quantity,Fail Item,Quantity,SN";
    for (NSString *item in key) {
        NSArray *snArray = [thisDict objectForKey:item];
        NSString *snList = [NSString stringWithFormat:@"\"%@", [snArray objectAtIndex:0]];
        
        for (int i=1; i<[snArray count]; i++) {
            snList = [snList stringByAppendingFormat:@"\r\n%@",[snArray objectAtIndex:i]];
        }
        snList = [snList stringByAppendingString:@"\""];
        
        log = [log stringByAppendingFormat:@"\n,%@,%lu,%@", item, (unsigned long)[snArray count], snList];
    }
    
    NSString *csvfileName = [NSString stringWithFormat:@"/vault/burn-in-test_failures-%@.csv", dateStr];
    [log writeToFile:csvfileName atomically:NO encoding:NSUTF8StringEncoding error:NULL];
    
}



@end
