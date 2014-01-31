//
//  DemoViewController.h
//  MBSessionDownloadManager
//
//  Created by Moonbeom Kyle KWON on 1/31/14.
//  Copyright (c) 2014 Moonbeom Kyle KWON. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DemoViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIProgressView *progress;


-(IBAction)startDownload:(id)sender;
-(IBAction)pauseDownload:(id)sender;
-(IBAction)stopDownload:(id)sender;

@end
