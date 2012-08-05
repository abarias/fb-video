//
//  DefaultViewController.m
//  fb-video
//
//  Created by AB Arias on 8/5/12.
//  Copyright (c) 2012 Chevron Holdings Inc. All rights reserved.
//

#import "DefaultViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface DefaultViewController ()
- (IBAction)login:(id)sender;
@end

@implementation DefaultViewController
@synthesize login;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setLogin:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)login:(id)sender {
    [FBSession sessionOpenWithPermissions:nil completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        if (session.isOpen) {
            FBRequest *me = [FBRequest requestForMe];
            [me startWithCompletionHandler: ^(FBRequestConnection *connection,
                                              NSDictionary<FBGraphUser> *my,
                                              NSError *error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hello"
                                                                    message:my.first_name
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
            }];
        }
    }];
}
@end
