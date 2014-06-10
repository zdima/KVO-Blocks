//
//  NSObject+KVOBlocks.m
//  kvo blocks sample
//
//  Created by Stephan Leroux on 2013-01-31.
//  Copyright (c) 2013 Stephan Leroux. All rights reserved.
//

#import "NSObject+KVOBlocks.h"
#import <objc/runtime.h>

@implementation NSObject (KVOBlocks)

- (void)addObserver:(NSObject*)observer
         forKeyPath:(NSString *)keyPath
            options:(NSKeyValueObservingOptions)options
            context:(void *)context
          withBlock:(KVOBlock)block
{
    void* key = (void*)[keyPath hash];
    NSMutableDictionary *blocks = objc_getAssociatedObject(self, key);
    if (!blocks) {
        blocks = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, key, blocks, OBJC_ASSOCIATION_RETAIN);
        [self addObserver:self forKeyPath:keyPath options:options context:context];
    }
    blocks[@([observer hash])] = [block copy];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    void* key = (void*)[keyPath hash];
    NSMutableDictionary *blocks = objc_getAssociatedObject(self, key);
    for (KVOBlock block in [blocks allValues]) {
        block(change, context);
    }
}

- (void)removeBlockObserver:(NSObject*)observer
                 ForKeyPath:(NSString *)keyPath
{
    void* key = (void*)[keyPath hash];
    NSMutableDictionary *blocks = objc_getAssociatedObject(self, key);
    [blocks removeObjectForKey: @([observer hash])];
    if (blocks && [blocks allKeys].count == 0) {
        objc_setAssociatedObject(self, key, nil, OBJC_ASSOCIATION_COPY);
        [self removeObserver:self forKeyPath:keyPath];
    }
}

@end
