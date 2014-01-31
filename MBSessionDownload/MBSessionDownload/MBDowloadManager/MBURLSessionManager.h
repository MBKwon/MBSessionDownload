//
//  MBURLSessionManager.h
//  MBSessionDownloadManager
//
//  Created by Moonbeom Kyle KWON on 1/31/14.
//  Copyright (c) 2014 Moonbeom Kyle KWON. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^FirstBlock)(NSUInteger taskID);
typedef void (^ProgressBlock)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);
typedef void (^ErrorBlock)(NSError *error);
typedef void (^CompleteBlock)(BOOL isFinish, NSString *fielPath);


@interface MBURLSessionManager : NSURLSession <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>

@property (strong, nonatomic) FirstBlock firstBlock;
@property (strong, nonatomic) ProgressBlock progressBlock;
@property (strong, nonatomic) ErrorBlock errorBlock;
@property (strong, nonatomic) CompleteBlock completeBlock;


-(NSURLSession *)getSessionwithConfiguration:(NSURLSessionConfiguration *)configuration
                                  firstBlock:(FirstBlock)firstBlock
                               progressBlock:(ProgressBlock)progressBlock
                                  errorBlock:(ErrorBlock)errorBlock
                                completBolck:(CompleteBlock)completeBlock;

@end
