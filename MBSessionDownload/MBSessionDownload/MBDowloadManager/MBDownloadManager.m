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
@property (strong, nonatomic) NSURLSessionConfiguration *configuration;

@end

@implementation MBDownloadManager

+(MBDownloadManager *)defaultManager
{
    static MBDownloadManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
        
        if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending) {
            instance.configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.MBKWON.MBSessionDownload - BackgroundSession"];
        }
        else {
            instance.configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.MBKWON.MBSessionDownload - BackgroundSession"];
        }
        instance.configuration.sharedContainerIdentifier = @"group.com.uangel.tomokids";
        instance.configuration.allowsCellularAccess = YES;          // NO to WiFi only
        instance.configuration.timeoutIntervalForRequest = 30.0;    // 30 seconds
        instance.configuration.timeoutIntervalForResource = 60.0;   // 60 seconds
        instance.configuration.HTTPMaximumConnectionsPerHost = 3;   // default value is 3
        
        instance.sessionManager = [MBURLSessionManager new];
        instance.sessionTaskList = [NSMutableArray new];
        instance.destinationList = [NSMutableDictionary new];
        instance.userInfo = [NSMutableDictionary new];
    });
    
    return instance;
}

- (NSURLSession *)makeSessionWithProgress
{
    return [self makeSessionWithProgressBlock:[_sessionManager progressBlock]
                                   errorBlock:[_sessionManager errorBlock]
                                completeBlock:[_sessionManager completeBlock]];
}
- (NSURLSession *)makeSessionWithCompleteBlock:(CompleteBlock)completeBlock
{
    if (completeBlock) {
        return [self makeSessionWithProgressBlock:[_sessionManager progressBlock]
                                       errorBlock:[_sessionManager errorBlock]
                                    completeBlock:completeBlock];
    }
    else {
        return [self makeSessionWithProgress];
    }
}
- (NSURLSession *)makeSessionWithProgressBlock:(ProgressBlock)progressBlock
                                    errorBlock:(ErrorBlock)errorBlock
                                 completeBlock:(CompleteBlock)completeBlock
{
    NSURLSession *session = [_sessionManager getSessionWithConfiguration:_configuration
                                                           progressBlock:progressBlock
                                                              errorBlock:errorBlock
                                                           completeBolck:completeBlock];
    return session;
}


-(NSInteger)session:(NSURLSession*)session startDownloadWithURL:(NSString *)downloadURLString;
{
    return [self session:session startDownloadWithURL:downloadURLString destination:DEFAULT_DESTINATION];
}

-(NSInteger)session:(NSURLSession*)session startDownloadWithURL:(NSString *)downloadURLString destination:(NSString *)destination;
{
    return [self session:session startDownloadWithURL:downloadURLString destination:destination withIdentifier:nil];
}
-(NSInteger)session:(NSURLSession*)session startDownloadWithURL:(NSString *)downloadURLString destination:(NSString *)destination withIdentifier:(id)identifier
{
    if (downloadURLString) {
        NSString *key = MAKE_KEY(downloadURLString);
        NSData *resumeData = [[EGOCache globalCache] dataForKey:key];
        NSURLSessionDownloadTask *downloadTask;
        
        if (resumeData != nil) {
            
            [[EGOCache globalCache] removeCacheForKey:key];
            downloadTask = [session downloadTaskWithResumeData:resumeData];
            
        } else {
            
            NSURL *downloadURL = [NSURL URLWithString:downloadURLString];
            NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
            downloadTask = [session downloadTaskWithRequest:request];
        }
        
        NSString *destinationKey = [NSString stringWithFormat:@"%lu", (unsigned long)downloadTask.taskIdentifier];
        [_destinationList setObject:destination forKey:destinationKey];
        if (identifier) {
            [_userInfo setObject:identifier forKey:destinationKey];
        }
        [_sessionTaskList addObject:downloadTask];
        [downloadTask resume];
        
        return [downloadTask taskIdentifier];
    }
    else {
        return -1;
    }
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

- (void)removeDownloadTaskForUserInfoKey:(id)userKey
{
    if ([userKey isKindOfClass:[NSNumber class]]) {
        for (NSString *tKey in [_userInfo allKeys]) {
            if ([[_userInfo objectForKey:tKey] isEqualToNumber:userKey]) {
                [self pauseDownloadWithIdentifier:[tKey integerValue]];
                [self stopDownloadWithIdentifier:[tKey integerValue]];
                [_userInfo removeObjectForKey:tKey];
                break;
            }
        }
    }
}


#pragma mark - Setup blocks
- (void)setErrorBlock:(ErrorBlock)errorBlock
{
    if (errorBlock) {
        [_sessionManager setErrorBlock:errorBlock];
    }
}
- (void)setProgressBlock:(ProgressBlock)progressBlock
{
    if (progressBlock) {
        [_sessionManager setProgressBlock:progressBlock];
    }
}
- (void)setCompleteBlock:(CompleteBlock)completeBlock
{
    if (completeBlock) {
        [_sessionManager setCompleteBlock:completeBlock];
    }
}


#pragma mark - Check blocks
- (BOOL)hasErrorBlock
{
    if ([_sessionManager errorBlock])
        return YES;
    else
        return NO;
}
- (BOOL)hasProgressBlock
{
    if ([_sessionManager progressBlock])
        return YES;
    else
        return NO;
}
- (BOOL)hasCompleteBlock
{
    if ([_sessionManager completeBlock])
        return YES;
    else
        return NO;
}


#pragma mark - Number of Download Task
- (NSUInteger)maxDownloadTasks
{
    return [self.configuration HTTPMaximumConnectionsPerHost];
}
- (NSUInteger)currentDownloadTasks
{
    return [_sessionTaskList count];
}


#pragma mark - User Info methods
- (NSArray *)userInfosByCurrentDownloadTasks
{
    return [self userInfosByCurrentDownloadTasks:YES];
}

- (NSArray *)userInfosByCurrentDownloadTasks:(BOOL)includeWaiting
{
    NSMutableArray *waitingArr = [NSMutableArray new];
    NSMutableArray *downloadingArr = [NSMutableArray new];
    
    for (NSURLSessionDownloadTask *aTask in _sessionTaskList) {
        NSString *aKey = [NSString stringWithFormat:@"%lu", (unsigned long)aTask.taskIdentifier];
        id userKey = [_userInfo objectForKey:aKey];
        
        if (aTask.state == NSURLSessionTaskStateRunning) {
            if (aTask.countOfBytesReceived > 0) {
                [downloadingArr addObject:userKey];
            }
            else {
                [waitingArr addObject:userKey];
            }
        }
    }
    
    NSArray *retArr = nil;
    
    if ([downloadingArr count]) {
        retArr = [NSArray arrayWithArray:downloadingArr];
    }
    
    if (!includeWaiting && [waitingArr count]) {
        if (!retArr) {
            retArr = [NSArray arrayWithArray:waitingArr];
        }
        else {
            retArr = [retArr arrayByAddingObjectsFromArray:waitingArr];
        }
    }
    
    return retArr;
}

@end
