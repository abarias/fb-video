//
//  FirstViewController.h
//  fb-video
//
//  Created by Anthony Bernard Arias on 7/21/12.
//  Copyright (c) 2012 Chevron Holdings Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FirstViewController : UITableViewController<FBFriendPickerDelegate, NSFetchedResultsControllerDelegate>
- (IBAction)showFBFriendPicker:(id)sender;

@end
