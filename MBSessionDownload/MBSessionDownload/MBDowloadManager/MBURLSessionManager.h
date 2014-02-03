//
//  MBURLSessionManager.h
//  MBSessionDownloadManager
//
//  Created by Moonbeom Kyle KWON on 1/31/14.
//  Copyright (c) 2014 Moonbeom Kyle KWON. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^FirstBlock)(NSUInteger taskID);
typedef void (^ProgressBlock)(NSUInteger taskID, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);
typedef void (^ErrorBlock)(NSUInteger taskID, NSError *error);
typedef void (^CompleteBlock)(NSUInteger taskID, BOOL isFinish, NSString *fielPath);


@interface MBURLSessionManager : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>


@property (strong, nonatomic) ProgressBlock progressBlock;
@property (strong, nonatomic) ErrorBlock errorBlock;
@property (strong, nonatomic) CompleteBlock completeBlock;


-(NSURLSession *)getSessionWithConfiguration:(NSURLSessionConfiguration *)configuration
                               progressBlock:(ProgressBlock)progressBlock
                                  errorBlock:(ErrorBlock)errorBlock
                               completeBolck:(CompleteBlock)completeBlock;

@end
