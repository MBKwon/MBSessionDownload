//
//  DemoViewController.m
//  MBSessionDownloadManager
//
//  Created by Moonbeom Kyle KWON on 1/31/14.
//  Copyright (c) 2014 Moonbeom Kyle KWON. All rights reserved.
//

#import "DemoViewController.h"
#import "MBDowloadManager/MBDownloadManager.h"


#define DownloadURLString @"https://googledrive.com/host/0B5BE_JEp3HGGVGJ2TllZa3ZtMTA/The%20Curse%20of%20dawn.mpg"

@interface DemoViewController ()

@property (assign, nonatomic) NSUInteger currentTaskID;

@end

@implementation DemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    [[MBDownloadManager defaultManager]  initWithFirstBlock:^(NSUInteger taskID){
        
        NSLog(@"task identifier : %d", taskID);
        _currentTaskID = taskID;
        
    } progressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite){
        
        NSLog(@"received data lenth : %lld \ntotal received data length : %lld \ntotal data length : %lld", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
        [_progress setProgress:((double)totalBytesWritten/(double)totalBytesExpectedToWrite)];
        
    } errorBlock:^(NSError *error){
        
        NSLog(@"download error : %@", [error localizedDescription]);
        
    } completeBolck:^(BOOL isFinish, NSString *filePath){
        
        if (isFinish) {
            NSLog(@"file path is %@", filePath);
        }
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)startDownload:(id)sender
{
    [[MBDownloadManager defaultManager] startDownloadWithURL:DownloadURLString];
}

-(IBAction)pauseDownload:(id)sender
{
    [[MBDownloadManager defaultManager] pauseDownloadWithIdentifier:_currentTaskID];
}

-(IBAction)stopDownload:(id)sender
{
    [[MBDownloadManager defaultManager] stopDownloadWithIdentifier:_currentTaskID];
}

@end
