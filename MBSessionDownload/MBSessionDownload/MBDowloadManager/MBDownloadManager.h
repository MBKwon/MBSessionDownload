//
//  MBDownloadManager.h
//  MBSessionDownloadManager
//
//  Created by Moonbeom Kyle KWON on 1/31/14.
//  Copyright (c) 2014 Moonbeom Kyle KWON. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBURLSessionManager.h"

@interface MBDownloadManager : NSObject


+(MBDownloadManager *)defaultManager;
-(void)initWithFirstBlock:(FirstBlock)firstBlock
            progressBlock:(ProgressBlock)progressBlock
               errorBlock:(ErrorBlock)errorBlock
             completBolck:(CompleteBlock)completeBlock;


-(void)stratDownloadWithURL:(NSString *)downloadURLString;
-(void)stratDownloadWithURL:(NSString *)downloadURLString destination:(NSString *)destination;


-(void)pauseDownloadWithIdentifier:(NSUInteger)taskID;
-(void)pauseAllTasks;


-(void)stopDownloadWithIdentifier:(NSUInteger)taskID;
-(void)stopAllTasks;

@end
