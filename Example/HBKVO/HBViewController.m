//
//  HBViewController.m
//  HBKVO
//
//  Created by wutianyukkk@sina.com on 05/16/2018.
//  Copyright (c) 2018 wutianyukkk@sina.com. All rights reserved.
//

#import "HBViewController.h"
#import "HBPerson.h"
#import "NSObject+KVO.h"

@interface HBViewController ()

@end

@implementation HBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    HBPerson *person = [[HBPerson alloc] init];
    
    [person hb_addObserver:self forKeyPath:@"name"];
    
    person.name = @"nihao";
}

-(void)hb_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"%@",change);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
