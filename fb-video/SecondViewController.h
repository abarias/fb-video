//
//  SecondViewController.h
//  fb-video
//
//  Created by Anthony Bernard Arias on 7/21/12.
//  Copyright (c) 2012 Chevron Holdings Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end
