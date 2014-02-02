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

@property (strong, nonatomic) NSMutableDictionary *destinationList;


+(MBDownloadManager *)defaultManager;
-(void)initWithFirstBlock:(FirstBlock)firstBlock
            progressBlock:(ProgressBlock)progressBlock
               errorBlock:(ErrorBlock)errorBlock
             completeBolck:(CompleteBlock)completeBlock;


-(void)startDownloadWithURL:(NSString *)downloadURLString;
-(void)startDownloadWithURL:(NSString *)downloadURLString destination:(NSString *)destination;


-(void)pauseDownloadWithIdentifier:(NSUInteger)taskID;
-(void)pauseAllTasks;


-(void)stopDownloadWithIdentifier:(NSUInteger)taskID;
-(void)stopAllTasks;

@end
