//
//  NSObject+KVO.m
//  HBKVODemo
//
//  Created by zhao on 2018/5/3.
//  Copyright © 2018年 zhao. All rights reserved.
//

#import "NSObject+KVO.h"
#import <objc/message.h>

static NSString *const kHBKVOPrefix = @"HBKVO";
static NSString *const kHBKVOAssiociate = @"kHBKVOAssiocate";

@interface KVOInfo : NSObject

@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, strong) NSString *keyPath;

@end

@implementation KVOInfo

- (instancetype)initWithObserver:(NSObject *)observer keyPath:(NSString *)keypath {
    if(self = [super init]){
        self.observer = observer;
        self.keyPath = keypath;
    }
    return self;
}
@end


#pragma mark - 从getter方法获得setter方法名称
static NSString * setterForGetter(NSString *getter) {
    if(getter.length <= 0){
        return nil;
    }
    
    NSString *firstString = [[getter substringToIndex:1] uppercaseString];
    NSString *leaveString = [getter substringFromIndex:1];
    return [NSString stringWithFormat:@"set%@%@:",firstString,leaveString];
}

#pragma mark - 从setter方法获取getter方法名车个
static NSString * getterForSetter(NSString *setter) {
    if(setter.length <= 0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]){
        return nil;
    }
    NSRange range = NSMakeRange(3, setter.length-4);
    NSString *getter = [setter substringWithRange:range];
    NSString *firstString = [[getter substringToIndex:1] lowercaseString];
    getter = [getter stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstString];
    return getter;
}

static void kvo_setter (id self, SEL _cmd,id newValue) {
    NSString *setterName = NSStringFromSelector(_cmd);
    NSString *getterName = getterForSetter(setterName);
    if(!getterName) {
        // throw invalid argument exception
        return;
    }
    
    id oldValue = [self valueForKey:getterName];
    
    struct objc_super superClass = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    
    void (*objc_msgSendSuperCasted)(void *,SEL,id) = (void *)objc_msgSendSuper;
    
    objc_msgSendSuperCasted(&superClass,_cmd,newValue);
    
    NSMutableArray *observers = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(kHBKVOAssiociate));
    for(KVOInfo *info in observers){
        if([info.keyPath isEqualToString:getterName]){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //diaoyong 监听改变更新
                NSDictionary *dict = @{@"new":newValue?:@"",@"old":oldValue?:@""};
                [info.observer hb_observeValueForKeyPath:info.keyPath ofObject:self change:dict context:nil];
            });
        }
    }
}

#pragma mark - 新类Class所指向的函数实现
static Class HBKVO_Class(id self){
    return class_getSuperclass(object_getClass(self));
}



@implementation NSObject (KVO)

- (void)hb_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    //判断是否存在与keyPath 是否存在， 利用setter方法验证
    SEL setterSelector = NSSelectorFromString(setterForGetter(keyPath));
    Class superClass = object_getClass(self);
    Method setterMethod = class_getInstanceMethod(superClass, setterSelector);
    if(!setterMethod){
        // throw invalid argument exception
        return;
    }
    
    NSString *superClassName = NSStringFromClass(superClass);
    Class newClass;
    if(![superClassName hasPrefix:kHBKVOPrefix]){
        //创建类并替换父类
        newClass = [self createClassFromSuperName:superClassName];
        object_setClass(self, newClass);
    }
    
    //添加setter方法 注意这个时候self 的子类
    if(![self hasSelector:setterSelector]){
        const char *types = method_getTypeEncoding(setterMethod);
        class_addMethod(newClass, setterSelector, (IMP)kvo_setter, types);
    }
    
    KVOInfo *info = [[KVOInfo alloc] initWithObserver:observer keyPath:keyPath];
    
    NSMutableArray *observers = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(kHBKVOAssiociate));
    if(!observers){
        observers = [NSMutableArray array];
        objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(kHBKVOAssiociate), observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [observers addObject:info];
}

- (Class)createClassFromSuperName:(NSString *)superClassName {
    NSString *newClassName = [kHBKVOPrefix stringByAppendingString:superClassName];
    Class newClass = NSClassFromString(newClassName);
    if(newClass){
        return newClass;
    }
    
    Class superClass = object_getClass(self);
    newClass = objc_allocateClassPair(superClass, newClassName.UTF8String, 0);
    Method classMethod = class_getInstanceMethod(superClass, @selector(class));
    const char *types = method_getTypeEncoding(classMethod);
    class_addMethod(newClass, @selector(class), (IMP)HBKVO_Class, types);
    objc_registerClassPair(newClass);
    return newClass;
}

- (BOOL)hasSelector:(SEL)selector {
    
    Class observerClass = object_getClass(self);
    unsigned int methodCount = 0;
    
    //得到一个方法的名字列表 class_copyIvarList 变量列表 class_copyPropertyList 属性列表
    Method *methodList = class_copyMethodList(observerClass, &methodCount);
    for(int i = 0 ; i < methodCount ; i++ ){
        SEL sel = method_getName(methodList[i]);
        if(sel == selector){
            free(methodList);
            return YES;
        }
    }
    free(methodList);
    return NO;
}


- (void)hb_removeObserver:(NSObject *)observer keyPath:(NSString *)keyPath {
    NSMutableArray* observers = objc_getAssociatedObject(self, (__bridge const void *)(kHBKVOAssiociate));
    
    KVOInfo *info;
    for (KVOInfo* tempInfo in observers) {
        if (tempInfo.observer == observer && [tempInfo.keyPath isEqual:keyPath]) {
            info = tempInfo;
            break;
        }
    }
    
    [observers removeObject:info];
}

@end
