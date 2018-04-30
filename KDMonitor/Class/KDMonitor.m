//
//  KDMonitor.m
//  KDMonitor
//
//  Created by 一维 on 2018/4/17.
//  Copyright © 2018年 一维. All rights reserved.
//

#import "KDMonitor.h"
#import "KDStrategyOperation.h"

@interface KDMonitor()
{
//    CFRunLoopActivity _runloopActivity;
    KDStrategyOperation *_strategyOperation;
    NSOperationQueue *_operationQueue;
}
@end

@implementation KDMonitor
+ (instancetype)sharedInstance
{
    static KDMonitor *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[KDMonitor alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self registerRunloopObserver];
        _operationQueue = [[NSOperationQueue alloc] init];
        _strategyOperation = [[KDStrategyOperation alloc] init];
        _strategyOperation.queuePriority = NSOperationQueuePriorityHigh;
        [_operationQueue addOperation:_strategyOperation];
    }
    return self;
}

+ (void)startMonitor
{
    [KDMonitor sharedInstance];
}

static void runloopObserverCallBack(CFRunLoopObserverRef observer,CFRunLoopActivity activity,void *info)
{
    KDMonitor *moniter = (__bridge KDMonitor *)info;
    moniter->_strategyOperation.mainThreadRunloopActivity = activity;
//    moniter->_runloopActivity = activity;
}

- (void)registerRunloopObserver
{
    CFRunLoopObserverContext context =  {
        0,
        (__bridge void*)self,
        NULL,
        NULL
    };
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, &runloopObserverCallBack, &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
}

@end
