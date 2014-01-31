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

@interface MBDownloadManager ()

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionConfiguration *configuration;
@property (strong, nonatomic) MBURLSessionManager *sessionManager;
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
        
        instance.sessionTaskList = [NSMutableArray new];
        instance.sessionManager = [MBURLSessionManager new];
    });
    
    return instance;
}

-(void)initWithFirstBlock:(FirstBlock)firstBlock
            progressBlock:(ProgressBlock)progressBlock
               errorBlock:(ErrorBlock)errorBlock
             completBolck:(CompleteBlock)completeBlock
{
    if (_session == nil) {
        _session = [_sessionManager getSessionwithConfiguration:_configuration
                                                     firstBlock:firstBlock
                                                  progressBlock:progressBlock
                                                     errorBlock:errorBlock
                                                   completBolck:completeBlock];
    }
}


-(void)stratDownloadWithURL:(NSString *)downloadURLString
{
    [self stratDownloadWithURL:downloadURLString destination:DEFAULT_DESTINATION];
}

-(void)stratDownloadWithURL:(NSString *)downloadURLString destination:(NSString *)destination
{
    
    NSData *resumeData = (NSData *) [[EGOCache globalCache] objectForKey:downloadURLString];
    NSURLSessionDownloadTask *downloadTask;
    
    if (resumeData != nil) {
        
        downloadTask = [_session downloadTaskWithResumeData:resumeData];
        
    } else {
        
        NSURL *downloadURL = [NSURL URLWithString:downloadURLString];
        NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
        downloadTask = [_session downloadTaskWithRequest:request];
        [_sessionTaskList addObject:downloadTask];
    }
    
    [downloadTask setDestination:destination];
    [downloadTask resume];
    _sessionManager.firstBlock([downloadTask taskIdentifier]);
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
                [[EGOCache globalCache] setObject:resumeData forKey:pausedTask.originalRequest.URL.absoluteString withTimeoutInterval:A_WEEK];
            }
        }];
    }
}

-(void)pauseAllTasks
{
    for (NSURLSessionDownloadTask *task in _sessionTaskList) {
        
        if (task != nil) {
            [task cancelByProducingResumeData:^(NSData *resumeData){
                if (resumeData != nil) {
                    [[EGOCache globalCache] setObject:resumeData forKey:task.originalRequest.URL.absoluteString withTimeoutInterval:A_WEEK];
                }
            }];
        }
    }
    
    [_sessionTaskList removeAllObjects];
}


#pragma mark - stop download
-(void)stopDownloadWithIdentifier:(NSUInteger)taskID
{
}

-(void)stopAllTasks
{
}




@end
