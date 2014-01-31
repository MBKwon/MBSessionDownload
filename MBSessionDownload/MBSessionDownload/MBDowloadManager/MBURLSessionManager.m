//
//  MBURLSessionManager.m
//  MBSessionDownloadManager
//
//  Created by Moonbeom Kyle KWON on 1/31/14.
//  Copyright (c) 2014 Moonbeom Kyle KWON. All rights reserved.
//

#import "MBURLSessionManager.h"

@implementation MBURLSessionManager

-(NSURLSession *)getSessionwithConfiguration:(NSURLSessionConfiguration *)configuration
                                  firstBlock:(FirstBlock)firstBlock
                               progressBlock:(ProgressBlock)progressBlock
                                  errorBlock:(ErrorBlock)errorBlock
                                completBolck:(CompleteBlock)completeBlock
{
    _firstBlock = firstBlock;
    _progressBlock = progressBlock;
    _errorBlock = errorBlock;
    _completeBlock = completeBlock;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    return session;
}

#pragma mark - delegate for download task <NSURLSessionDownloadDelegate>
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    double progress = (double) totalBytesWritten/(double) totalBytesExpectedToWrite;
    
    NSLog(@"Download Task : %@  progress : %lf", downloadTask, progress);
    
    if (_progressBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _progressBlock(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
        });
    }
}


-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *originalURL = [[downloadTask originalRequest] URL];
    NSURL *destinationURL = [NSURL URLWithString:downloadTask.destination];
    NSError *errorCopy;
    
    
    [fileManager removeItemAtURL:destinationURL error:NULL];
    BOOL success = [fileManager copyItemAtURL:originalURL toURL:destinationURL error:&errorCopy];
    
    if (success) {
        
        if (_completeBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _completeBlock(YES, [destinationURL absoluteString]);
            });
        }
        
    } else {
        
        NSLog(@"Error during the copy : %@", [errorCopy localizedDescription]);
        if (_errorBlock) {
            _errorBlock(errorCopy);
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



@implementation NSURLSessionDownloadTask (MBDownload)

-(void)setDestination:(NSString *)destination
{
    self.destination = destination;
}

-(NSString *)destination
{
    return self.destination;
}

@end
