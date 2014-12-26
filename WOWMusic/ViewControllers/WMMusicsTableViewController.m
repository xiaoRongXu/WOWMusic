//
//  WMMusicsTableViewController.m
//  WOWMusic
//
//  Created by wwwbbat on 14-12-18.
//  Copyright (c) 2014年 wwwbbat. All rights reserved.
//

#import "WMMusicsTableViewController.h"

@interface WMMusicsTableViewController ()
{
    
}
@property (nonatomic, strong) NSDictionary *wowInfo;
@end

@implementation WMMusicsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (Device_InterfaceIdiom == UIUserInterfaceIdiomPad){
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.tableFooterView = [UIView new];
    }
    
    _wowInfo = @{@"wow":@"经典旧世",
                 @"tbc":@"燃烧的远征",
                 @"wlk":@"巫妖王之怒",
                 @"ctm":@"大地的裂变",
                 @"mop":@"熊猫人之迷",
                 @"doc":@"德拉诺之王"};
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (Device_InterfaceIdiom == UIUserInterfaceIdiomPad){
        return _wowInfo.allKeys.count/2;
    }else
        return _wowInfo.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (Device_InterfaceIdiom == UIUserInterfaceIdiomPhone){
        cell = [tableView dequeueReusableCellWithIdentifier:WMMusicTableViewCellID_iPhone forIndexPath:indexPath];
        NSString *imageName = WOWKeywords[indexPath.row];
        NSString *title = _wowInfo[imageName];
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1];
        titleLabel.text = title;
        NSLog(@"w: %f h:%f",cell.bounds.size.width,cell.bounds.size.height);
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    }else{
        NSString *l = WOWKeywords[indexPath.row*2];
        NSString *r = WOWKeywords[indexPath.row*2+1];
        NSString *lText = _wowInfo[l];
        NSString *rText = _wowInfo[r];
        
        cell = [tableView dequeueReusableCellWithIdentifier:WMMusicTableViewCellID_iPad forIndexPath:indexPath];
        CGRect frame = cell.contentView.frame;
        UIImageView *lImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:l]];
        lImage.frame = CGRectMake(0, 0, frame.size.width/2, frame.size.height);
        UIImageView *rImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:r]];
        rImage.frame = CGRectMake(frame.size.width/2, 0, frame.size.width/2, frame.size.height);
        UILabel *lLabel = [[UILabel alloc] initWithFrame:lImage.frame];
        UILabel *rLabel = [[UILabel alloc] initWithFrame:rImage.frame];
        lLabel.tag = indexPath.row*2;
        rLabel.tag = indexPath.row*2+1;
        lLabel.text = lText;
        rLabel.text = rText;
        lLabel.font = rLabel.font = [UIFont systemFontOfSize:30];
        lLabel.textAlignment = rLabel.textAlignment = NSTextAlignmentCenter;
        lLabel.backgroundColor = rLabel.backgroundColor = [UIColor clearColor];
        lLabel.textColor = rLabel.textColor = [UIColor whiteColor];
        lLabel.userInteractionEnabled = rLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectRow:)];
        [lLabel addGestureRecognizer:tap];
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectRow:)];
        [rLabel addGestureRecognizer:tap2];
        
        
        [cell.contentView addSubview:lImage];
        [cell.contentView addSubview:rImage];
        [cell.contentView addSubview:lLabel];
        [cell.contentView addSubview:rLabel];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.f;
    if (Device_InterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if (Device_Width == 414) {
            height = 198.0f;
        }else if (Device_Width == 375){
            height = 179.0f;
        }else{
            height = 153.0f;
        }
    }else{
        height = 198.0f;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (Device_InterfaceIdiom == UIUserInterfaceIdiomPhone){
        NSString *tag = WOWKeywords[indexPath.row];
        [self performSegueWithIdentifier:Segue_MusicListDetain sender:tag];
    }
}

- (void)didSelectRow:(UITapGestureRecognizer *)tap
{
    UILabel *label = (UILabel *)tap.view;
    NSString *tag = WOWKeywords[label.tag];
    [self performSegueWithIdentifier:Segue_MusicListDetain sender:tag];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:Segue_MusicListDetain]) {
        UIViewController *vc = segue.destinationViewController;
        if ([vc respondsToSelector:@selector(setListTag:)]) {
            [vc setValue:sender forKey:@"listTag"];
        }
    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
