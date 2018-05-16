//
//  NSObject+KVO.h
//  HBKVODemo
//
//  Created by zhao on 2018/5/3.
//  Copyright © 2018年 zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (KVO)

- (void)hb_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

- (void)hb_removeObserver:(NSObject *)observer keyPath:(NSString *)keyPath;

-(void)hb_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context;

@end
