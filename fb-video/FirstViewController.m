//
//  FirstViewController.m
//  fb-video
//
//  Created by Anthony Bernard Arias on 7/21/12.
//  Copyright (c) 2012 Chevron Holdings Inc. All rights reserved.
//

#import "FirstViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <AddressBook/AddressBook.h>

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    FBFriendPickerViewController *friendPicker = [[FBFriendPickerViewController alloc] init];
    
    // Set up the friend picker to sort and display names the same way as the
    // iOS Address Book does.
    
    // Need to call ABAddressBookCreate in order for the next two calls to do anything.
    ABAddressBookCreate();
    ABPersonSortOrdering sortOrdering = ABPersonGetSortOrdering();
    ABPersonCompositeNameFormat nameFormat = ABPersonGetCompositeNameFormat();
    
    friendPicker.sortOrdering = (sortOrdering == kABPersonSortByFirstName) ? FBFriendSortByFirstName : FBFriendSortByLastName;
    friendPicker.displayOrdering = (nameFormat == kABPersonCompositeNameFormatFirstNameFirst) ? FBFriendDisplayByFirstName : FBFriendDisplayByLastName;
    
    [friendPicker loadData];
    [friendPicker presentModallyFromViewController:self
                                          animated:YES
                                           handler:^(FBViewController *sender, BOOL donePressed) {
                                               if (donePressed) {
                                                   self.selectedFriends = friendPicker.selection;
                                                   [self updateSelections];
                                               }
                                           }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
