//
//  FirstViewController.h
//  fb-video
//
//  Created by Anthony Bernard Arias on 7/21/12.
//  Copyright (c) 2012 Chevron Holdings Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FirstViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, FBFriendPickerDelegate, NSFetchedResultsControllerDelegate>
- (IBAction)showFBFriendPicker:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;

@end
