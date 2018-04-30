//
//  KDStrategyOperation.m
//  KDMonitor
//
//  Created by 一维 on 2018/4/17.
//  Copyright © 2018年 一维. All rights reserved.
//

#import "KDStrategyOperation.h"

#import <PLCrashReporter/CrashReporter/CrashReporter.h>
@interface KDStrategyOperation()
{
    dispatch_semaphore_t _semaphore;
    NSInteger _kdCount;
    dispatch_queue_t _propertyModifyQueue;
}
@end

@implementation KDStrategyOperation
- (instancetype)init
{
    self = [super init];
    if (self) {
        _semaphore = dispatch_semaphore_create(0);
        _propertyModifyQueue = dispatch_queue_create("KDStrategyOperation.propertyModifyQueue", 0);
    }
    return self;
}

@synthesize mainThreadRunloopActivity = _mainThreadRunloopActivity;

- (void)setMainThreadRunloopActivity:(CFRunLoopActivity)mainThreadRunloopActivity
{
    dispatch_barrier_async(_propertyModifyQueue, ^{
        self->_mainThreadRunloopActivity = mainThreadRunloopActivity;
        dispatch_semaphore_signal(self->_semaphore);
    });
}

- (CFRunLoopActivity)mainThreadRunloopActivity
{
    __block CFRunLoopActivity activity ;
    dispatch_sync(_propertyModifyQueue, ^{
        activity = self->_mainThreadRunloopActivity;
    });
    return activity;
}

- (BOOL)isAsynchronous
{
    return YES;
}

- (void)main
{
    @autoreleasepool {
//        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
//
//        CFRunLoopSourceContext sourceCtx = {
//            .version = 0,
//            .info = NULL,
//            .retain = NULL,
//            .release = NULL,
//            .copyDescription = NULL,
//            .equal = NULL,
//            .hash = NULL,
//            .schedule = NULL,
//            .cancel = NULL,
//            .perform = NULL
//        };
//        CFRunLoopSourceRef source = CFRunLoopSourceCreate(NULL, 0, &sourceCtx);
//        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
//        CFRelease(source);
        
        while (YES/*[runloop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]*/) {
            BOOL timeout = dispatch_semaphore_wait(_semaphore, dispatch_time(DISPATCH_TIME_NOW, 20*NSEC_PER_MSEC));
            if (timeout) {
                if (self.mainThreadRunloopActivity == kCFRunLoopBeforeSources
                    || self.mainThreadRunloopActivity == kCFRunLoopAfterWaiting) {
                    self->_kdCount++;
                    if (self->_kdCount > 5) {
                        self->_kdCount = 0;
                        [self getCallStackSymbolsReport];
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            NSArray *callBacks = NSThread.callStackSymbols;
//                            NSLog(@"%@",callBacks);
//                        });
                    }
                }
            }
        }
    }
}

- (void)getCallStackSymbolsReport
{
    PLCrashReporterConfig *config = [[PLCrashReporterConfig alloc] initWithSignalHandlerType:PLCrashReporterSignalHandlerTypeBSD
                                                                       symbolicationStrategy:PLCrashReporterSymbolicationStrategyAll];
    PLCrashReporter *crashReporter = [[PLCrashReporter alloc] initWithConfiguration:config];
    
    NSData *data = [crashReporter generateLiveReport];
    PLCrashReport *reporter = [[PLCrashReport alloc] initWithData:data error:NULL];
    NSString *report = [PLCrashReportTextFormatter stringValueForCrashReport:reporter
                                                              withTextFormat:PLCrashReportTextFormatiOS];
    
    NSLog(@"------------n%@n------------", report);
}
@end
