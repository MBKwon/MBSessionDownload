//
//  MBDownloadManager.h
//  MBSessionDownloadManager
//
//  Created by Moonbeom Kyle KWON on 1/31/14.
//  Copyright (c) 2014 Moonbeom Kyle KWON. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBURLSessionManager.h"


@protocol MBDownloadTaskDelegate <NSObject>
@optional
- (void)downloadTaskFinished:(NSURLSessionDownloadTask *)task userInfo:(id)userInfo;
@end


@interface MBDownloadManager : NSObject

@property (nonatomic, assign) id<MBDownloadTaskDelegate> delegate;

@property (strong, nonatomic) NSMutableArray *sessionTaskList;
@property (strong, nonatomic) NSMutableDictionary *destinationList;
@property (strong, nonatomic) NSMutableDictionary *userInfo;



+(MBDownloadManager *)defaultManager;
- (NSURLSession *)makeSessionWithProgress;
- (NSURLSession *)makeSessionWithCompleteBlock:(CompleteBlock)completeBlock;
- (NSURLSession *)makeSessionWithProgressBlock:(ProgressBlock)progressBlock
                                    errorBlock:(ErrorBlock)errorBlock
                                 completeBlock:(CompleteBlock)completeBlock;


-(NSInteger)session:(NSURLSession*)session startDownloadWithURL:(NSString *)downloadURLString;
-(NSInteger)session:(NSURLSession*)session startDownloadWithURL:(NSString *)downloadURLString destination:(NSString *)destination;
-(NSInteger)session:(NSURLSession*)session startDownloadWithURL:(NSString *)downloadURLString destination:(NSString *)destination withIdentifier:(id)identifier;


-(void)pauseDownloadWithIdentifier:(NSUInteger)taskID;
-(void)pauseAllTasks;


-(void)stopDownloadWithIdentifier:(NSUInteger)taskID;
-(void)stopAllTasks;

- (void)removeDownloadTaskForUserInfoKey:(id)userKey;

- (void)setErrorBlock:(ErrorBlock)errorBlock;
- (void)setProgressBlock:(ProgressBlock)progressBlock;
- (void)setCompleteBlock:(CompleteBlock)completeBlock;
- (BOOL)hasErrorBlock;
- (BOOL)hasProgressBlock;
- (BOOL)hasCompleteBlock;

- (NSUInteger)maxDownloadTasks;
- (NSUInteger)currentDownloadTasks;

- (NSArray *)userInfosByCurrentDownloadTasks;
- (NSArray *)userInfosByCurrentDownloadTasks:(BOOL)includeWaiting;

@end
