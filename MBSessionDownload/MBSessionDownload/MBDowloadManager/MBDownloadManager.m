//
//  MBDownloadManager.m
//  MBSessionDownloadManager
//
//  Created by Moonbeom Kyle KWON on 1/31/14.
//  Copyright (c) 2014 Moonbeom Kyle KWON. All rights reserved.
//

#import "MBDownloadManager.h"
#import "EGOCache.h"

#define DEFAULT_DESTINATION NSTemporaryDirectory()

#define MAKE_KEY(s) [[[s stringByRemovingPercentEncoding] stringByReplacingOccurrencesOfString:@"/" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""]

@interface MBDownloadManager ()

@property (strong, nonatomic) MBURLSessionManager *sessionManager;
@property (strong, nonatomic) NSMutableArray *sessionList;
@property (strong, nonatomic) NSURLSessionConfiguration *configuration;
@property (strong, nonatomic) NSMutableArray *sessionTaskList;

@end

@implementation MBDownloadManager

+(MBDownloadManager *)defaultManager
{
    static MBDownloadManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
        
        instance.configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.MBKWON.MBSessionDownload - BackgroundSession"];
        
        instance.sessionManager = [MBURLSessionManager new];
        instance.sessionList = [NSMutableArray new];
        instance.sessionTaskList = [NSMutableArray new];
        instance.destinationList = [NSMutableDictionary new];
    });
    
    return instance;
}

-(NSUInteger)makeSessionWithProgressBlock:(ProgressBlock)progressBlock
                               errorBlock:(ErrorBlock)errorBlock
                            completeBolck:(CompleteBlock)completeBlock
{
    NSURLSession *session = [_sessionManager getSessionWithConfiguration:_configuration
                                                           progressBlock:progressBlock
                                                              errorBlock:errorBlock
                                                           completeBolck:completeBlock];
    [_sessionList addObject:session];
    return [_sessionList indexOfObject:session];
}


-(NSUInteger)startDownloadWithURL:(NSString *)downloadURLString sessionID:(NSUInteger)sessionID
{
    return [self startDownloadWithURL:downloadURLString destination:DEFAULT_DESTINATION sessionID:sessionID];
}

-(NSUInteger)startDownloadWithURL:(NSString *)downloadURLString destination:(NSString *)destination sessionID:(NSUInteger)sessionID
{
    NSString *key = MAKE_KEY(downloadURLString);
    NSData *resumeData = [[EGOCache globalCache] dataForKey:key];
    NSURLSessionDownloadTask *downloadTask;
    
    if (resumeData != nil) {
        
        [[EGOCache globalCache] removeCacheForKey:key];
        downloadTask = [[_sessionList objectAtIndex:sessionID] downloadTaskWithResumeData:resumeData];
        
    } else {
        
        NSURL *downloadURL = [NSURL URLWithString:downloadURLString];
        NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
        downloadTask = [[_sessionList objectAtIndex:sessionID] downloadTaskWithRequest:request];
    }
    
    NSString *destinationKey = [NSString stringWithFormat:@"%lu", (unsigned long)downloadTask.taskIdentifier];
    [_destinationList setObject:destination forKey:destinationKey];
    [_sessionTaskList addObject:downloadTask];
    [downloadTask resume];
    
    return [downloadTask taskIdentifier];
}


#pragma mark - pause download
-(void)pauseDownloadWithIdentifier:(NSUInteger)taskID
{
    NSURLSessionDownloadTask *pausedTask;
    
    for (NSURLSessionDownloadTask *task in _sessionTaskList) {
        if (task.taskIdentifier == taskID) {
            pausedTask = task;
            break;
        }
    }
    
    if (pausedTask != nil) {
        [pausedTask cancelByProducingResumeData:^(NSData *resumeData){
            if (resumeData != nil) {
                
                NSString *key = MAKE_KEY(pausedTask.originalRequest.URL.absoluteString);
                [[EGOCache globalCache] setData:resumeData forKey:key withTimeoutInterval:A_WEEK];
            }
        }];
        [_sessionTaskList removeObject:pausedTask];
    }
}

-(void)pauseAllTasks
{
    for (NSURLSessionDownloadTask *pausedTask in _sessionTaskList) {
        
        if (pausedTask != nil) {
            [pausedTask cancelByProducingResumeData:^(NSData *resumeData){
                if (resumeData != nil) {
                    
                    NSString *key = MAKE_KEY(pausedTask.originalRequest.URL.absoluteString);
                    [[EGOCache globalCache] setData:resumeData forKey:key withTimeoutInterval:A_WEEK];
                }
            }];
        }
    }
    
    [_sessionTaskList removeAllObjects];
}


#pragma mark - stop download
-(void)stopDownloadWithIdentifier:(NSUInteger)taskID
{
    for (NSURLSessionDownloadTask *stopTask in _sessionTaskList) {
        if (stopTask.taskIdentifier == taskID) {
            [stopTask cancel];
            [_sessionTaskList removeObject:stopTask];
            break;
        }
    }
}

-(void)stopAllTasks
{
    for (NSURLSessionDownloadTask *stopTask in _sessionTaskList) {
        
        if (stopTask != nil) {
            [stopTask cancel];
        }
    }
    
    [_sessionTaskList removeAllObjects];
}




@end
