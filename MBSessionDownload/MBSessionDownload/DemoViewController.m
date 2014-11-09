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

@property (strong, nonatomic) NSURLSession *currentSession;
@property (assign, nonatomic) NSUInteger currentTaskID;

@end

@implementation DemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    _currentSession = [[MBDownloadManager defaultManager]
                       makeSessionWithProgressBlock:^(NSUInteger taskID, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite, id identifier) {
                           
                           NSLog(@"received data lenth : %lld \ntotal received data length : %lld \ntotal data length : %lld", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
                           [_progress setProgress:((double)totalBytesWritten/(double)totalBytesExpectedToWrite)];
                           
                       } errorBlock:^(NSUInteger taskID, NSError *error, NSString *identifier) {
                           
                           NSLog(@"download error : %@", [error localizedDescription]);
                           
                       } completeBlock:^(NSUInteger taskID, BOOL isFinish, NSString *filePath, NSString *identifier) {
                           
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
    _currentTaskID = [[MBDownloadManager defaultManager]
                      session:_currentSession startDownloadWithURL:DownloadURLString];
}

-(IBAction)pauseDownload:(id)sender
{
    [[MBDownloadManager defaultManager] pauseDownloadWithIdentifier:_currentTaskID];
}

-(IBAction)stopDownload:(id)sender
{
    [[MBDownloadManager defaultManager] stopAllTasks];
}

@end
