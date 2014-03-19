//
//  InfoViewController.m
//  NNTest
//
//  Created by Samuel Wejéus on 22/07/2013.
//  Copyright (c) 2013 Samuel Wejéus. All rights reserved.
//

#import "InfoViewController.h"
#import "AttributionsViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController


- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.title = @"Info";
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Foo1" style:UIBarButtonItemStylePlain target:nil action:nil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AttributionsViewController *viewController = [AttributionsViewController new];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
