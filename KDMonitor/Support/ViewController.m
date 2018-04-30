//
//  ViewController.m
//  KDMonitor
//
//  Created by 一维 on 2018/4/17.
//  Copyright © 2018年 一维. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    self.tableView.frame = self.view.bounds;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor grayColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 46;
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1000;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.contentView.layer.cornerRadius = 5;
    cell.contentView.layer.masksToBounds = YES;
    cell.contentView.layer.shadowColor = [UIColor blueColor].CGColor;
    cell.contentView.layer.shadowOffset = CGSizeMake(5, 5);
    cell.contentView.layer.shadowRadius = 5;
    cell.contentView.layer.shadowOpacity = 0.5;
    cell.contentView.layer.borderColor = [UIColor greenColor].CGColor;
    
    UInt64  temp = 0;
    for (NSInteger i=0; i<100000000; i++) {
         temp += i * (i+1) * (i+2);
    }
    cell.contentView.layer.borderWidth = temp;
    return cell;
}
@end
