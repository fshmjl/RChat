//
//  KNetworkDetection.m
//  KXiniuCloud
//
//  Created by RPK on 2018/7/3.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KNetworkDetection.h"

static NSString *kAppleUrlToCheckNetStatus = @"https://www.baidu.com";
static KNetworkDetection *networkDetection = nil;

@implementation KNetworkDetection

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkDetection = [[super allocWithZone:NULL] init];
    });
    return networkDetection;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [KNetworkDetection shareInstance];
}

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}



- (BOOL)checkNetCanUse {
    
    __block BOOL canUse = NO;

    // 使用信号量实现NSURLSession同步请求**
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:kAppleUrlToCheckNetStatus] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (data != nil && response != nil && error == nil) {
                canUse = YES;
            }
            else {
                canUse = NO;
            }
            dispatch_semaphore_signal(semaphore);
        }] resume];
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    return canUse;
}

- (NSString *)filterHTML:(NSString *)html {
    
    NSScanner *theScanner;
    NSString *text = nil;
    
    theScanner = [NSScanner scannerWithString:html];
    
    while ([theScanner isAtEnd] == NO) {
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
                [NSString stringWithFormat:@"%@>", text]
                                               withString:@""];
    }
    return html;
}

@end
