//
//  AFHTTPSessionManager+DataTask.h
//  OperationSample
//
//  Created by Vincent on 02/02/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface AFHTTPSessionManager (DataTask)

// this method is not publicly defined in @interface in .h, so we need to define our own interface for it

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;
@end
