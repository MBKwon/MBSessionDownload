//
//  MBURLSessionManager.m
//  MBSessionDownloadManager
//
//  Created by Moonbeom Kyle KWON on 1/31/14.
//  Copyright (c) 2014 Moonbeom Kyle KWON. All rights reserved.
//

#import "MBURLSessionManager.h"
#import "MBDownloadManager.h"

@implementation MBURLSessionManager

-(NSURLSession *)getSessionWithConfiguration:(NSURLSessionConfiguration *)configuration
                               progressBlock:(ProgressBlock)progressBlock
                                  errorBlock:(ErrorBlock)errorBlock
                               completeBolck:(CompleteBlock)completeBlock
{
    _progressBlock = progressBlock;
    _errorBlock = errorBlock;
    _completeBlock = completeBlock;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    return session;
}

#pragma mark - delegate for download task <NSURLSessionDownloadDelegate>
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
#if DEBUG
    NSLog(@"Download Task : %@  progress : %lf", downloadTask, (double) totalBytesWritten/(double) totalBytesExpectedToWrite);
#endif
    
    if (_progressBlock) {
        NSString *destinationKey = [NSString stringWithFormat:@"%lu", (unsigned long)downloadTask.taskIdentifier];
        id identifier = [MBDownloadManager.defaultManager.userInfo objectForKey:destinationKey];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _progressBlock([downloadTask taskIdentifier], bytesWritten, totalBytesWritten, totalBytesExpectedToWrite, identifier);
        });
    }
}


-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //NSURL *originalURL = [[downloadTask originalRequest] URL];  // Why???!!!
    NSError *errorCopy;
    
    NSString *destinationKey = [NSString stringWithFormat:@"%lu", (unsigned long)downloadTask.taskIdentifier];
    NSString *destinationPath = [MBDownloadManager.defaultManager.destinationList objectForKey:destinationKey];
    
    NSURL *destinationURL = nil;
    if (destinationPath) {
        destinationURL = [NSURL fileURLWithPath:destinationPath];
    }
    
    BOOL success = NO;
    
    if (destinationURL) {
        BOOL isDirectoryExist = YES;
        
        if (![fileManager isExecutableFileAtPath:[destinationURL.path stringByDeletingLastPathComponent]]) {
            
            NSError *anErr = nil;
            isDirectoryExist = [fileManager createDirectoryAtPath:[destinationURL.path stringByDeletingLastPathComponent]
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:&anErr];
        }
        
        if (isDirectoryExist) {
            [fileManager removeItemAtURL:destinationURL error:NULL];
            
            // Moving is faster than copying by neoroman on 31/10/2014
            //success = [fileManager copyItemAtURL:location toURL:destinationURL error:&errorCopy];
            success = [fileManager moveItemAtURL:location toURL:destinationURL error:&errorCopy];
        }
    }
    
    id identifier = [MBDownloadManager.defaultManager.userInfo objectForKey:destinationKey];
    if (success) {
        
        if (_completeBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _completeBlock([downloadTask taskIdentifier], success, [destinationURL absoluteString], identifier);
                
                if (MBDownloadManager.defaultManager.delegate
                    && [MBDownloadManager.defaultManager.delegate respondsToSelector:@selector(downloadTaskFinished:userInfo:)]) {
                    [MBDownloadManager.defaultManager.delegate performSelector:@selector(downloadTaskFinished:userInfo:) withObject:downloadTask withObject:identifier];
                }
            });
        }
        
    } else {
        
#if DEBUG
        NSLog(@"Error during the copy : %@", [errorCopy localizedDescription]);
        NSLog(@"Error during the copy : location.path => %@", location.path);
        NSLog(@"Error during the copy : destinationURL.path => %@", destinationURL.path);
        NSLog(@"Error during the copy : destinationURL.path executable? => %@", [fileManager isExecutableFileAtPath:[destinationURL.path stringByDeletingLastPathComponent]] ? @"YES" : @"NO");
        
#endif
        if (_errorBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _errorBlock([downloadTask taskIdentifier], errorCopy, identifier);
            });
        }
    }
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}



#pragma mark - delegate for session task <NSURLSessionTaskDelegate, NSURLSessionDelegate>
//-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
//{
//    if (error == nil) {
//        NSLog(@"Task ; %@  complete successfully", task);
//    } else {
//        NSLog(@"Task : %@  complete with error : %@", task, [error localizedDescription]);
//    }
//
//    double progress = (double) task.countOfBytesReceived/(double) task.countOfBytesExpectedToReceive;
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        _progressView.progress = progress;
//    });
//
//    _downloadTask = nil;
//}
//
//-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
//{
//    AppDelegate *appdelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//
//    if (appdelegate.backgroundSessionCompletionHandler) {
//        void (^completionHAndler)() = appdelegate.backgroundSessionCompletionHandler;
//        appdelegate.backgroundSessionCompletionHandler = nil;
//        completionHAndler();
//    }
//
//    NSLog(@"Alltask are finished");
//}

@end
