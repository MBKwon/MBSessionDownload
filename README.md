MBSessionDownload
=================

MBSessionDownload is best way to download files in your apps. Your apps can download files in a foreground or background.

Requires **iOS 7.0 or later**.

======

## Features
1. Download files in background threads.
2. Use blocks!
3. Pause and resume a download.
4. Custom download path and auto path creation.
5. Continue to download files when your app is in a background

## Methods
#### MBDownloadManager
```objective-c
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
```

#### MBURLSessionManager
```objective-c
-(NSURLSession *)getSessionWithConfiguration:(NSURLSessionConfiguration *)configuration
                                  firstBlock:(FirstBlock)firstBlock
                               progressBlock:(ProgressBlock)progressBlock
                                  errorBlock:(ErrorBlock)errorBlock
                                completeBolck:(CompleteBlock)completeBlock;
```

## Usage


### 1. Blocks
To immediately start a download in the default MBDownloadManager directory (`tmp/` by default):

```objective-c
#import "MBDowloadManager/MBDownloadManager.h"

[[MBDownloadManager defaultManager]  initWithFirstBlock:^(NSUInteger taskID){
        
        NSLog(@"task identifier : %d", taskID);
        _currentTaskID = taskID;
        
    } progressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite){
        
        NSLog(@"received data lenth : %lld \ntotal received data length : %lld \ntotal data length : %lld", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
        [_progress setProgress:((double)totalBytesWritten/(double)totalBytesExpectedToWrite)];
        
    } errorBlock:^(NSError *error){
        
        NSLog(@"download error : %@", [error localizedDescription]);
        
    } completeBolck:^(BOOL isFinish, NSString *filePath){
        
        if (isFinish) {
            NSLog(@"file path is %@", filePath);
        }
        
    }];
```

If you set a customPath:

```objective-c

-(void)startDownloadWithURL:downloadURLString destination:CUSTOM_PATH;

```

This will **create** the given path if needed and download the file in the `Path/` directory. **Remember that you should follow the [iOS Data Storage Guidelines](https://developer.apple.com/icloud/documentation/data-storage/)**.


### 3. Other things you should know
**1. This download manager is made using [NSURLSession](https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSURLSession_class/Introduction/Introduction.html) and [NSURLSessionDownloadTask](https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSURLSessionDownloadTask_class/Reference/Reference.html#//apple_ref/occ/cl/NSURLSessionDownloadTask)

**2. Use [EGOCache](https://github.com/enormego/EGOCache) to save resuming data. EGOCache is following a MIT license.


### 4. License
The MIT License (MIT)

Copyright (c) 2014 Moonbeom Kyle KWON

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


