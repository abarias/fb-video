//
//  SecondViewController.m
//  fb-video
//
//  Created by Anthony Bernard Arias on 7/21/12.
//  Copyright (c) 2012 Chevron Holdings Inc. All rights reserved.
//

#import "SecondViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AsyncImageView.h"
#import "FacebookAlbum.h"

#define kCustomRowsPerPage     25

@interface SecondViewController ()

@property (strong, nonatomic) FBRequestConnection *requestConnection;
@property (nonatomic, strong) NSMutableArray *facebookAlbums;
@property int pageOffset;
@property int pageLimit;
@property int pageCounter;

@end

@implementation SecondViewController

@synthesize requestConnection = _requestConnection;
@synthesize myTableView = _myTableView;
@synthesize facebookAlbums = _facebookAlbums;
@synthesize pageOffset = _pageOffset;
@synthesize pageLimit = _pageLimit;
@synthesize pageCounter = _pageCounter;

- (void)sendRequests {
    // extract the id's for which we will request the profile
    
    // create the connection object
    FBRequestConnection *newConnection = [[FBRequestConnection alloc] init];
    
    // create a handler block to handle the results of the request for fbid's profile
    FBRequestHandler handler =
    ^(FBRequestConnection *connection, id result, NSError *error) {
        // output the results of the request
        [self requestCompleted:connection result:result error:error];
    };
    
    int limit = self.pageCounter * kCustomRowsPerPage;
    int offset = 0;
    if (self.pageCounter > 1) {
        offset = limit - kCustomRowsPerPage + 1;
    }
    
    NSString *pageQuery = [NSString stringWithFormat:@"me/albums?limit=%d&offset=%d",kCustomRowsPerPage,offset,nil];
        
        // create the request object, using the fbid as the graph path
        // as an alternative the request* static methods of the FBRequest class could
        // be used to fetch common requests, such as /me and /me/friends
        FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession
                                                      graphPath:pageQuery];
        
        // add the request to the connection object, if more than one request is added
        // the connection object will compose the requests as a batch request; whether or
        // not the request is a batch or a singleton, the handler behavior is the same,
        // allowing the application to be dynamic in regards to whether a single or multiple
        // requests are occuring
        [newConnection addRequest:request completionHandler:handler];
    
    
    // if there's an outstanding connection, just cancel
    [self.requestConnection cancel];
    
    // keep track of our connection, and start it
    self.requestConnection = newConnection;
    [newConnection start];
}

// FBSample logic
// Report any results.  Invoked once for each request we make.
- (void)requestCompleted:(FBRequestConnection *)connection
                  result:(id)result
                   error:(NSError *)error {
    // not the completion we were looking for...
    if (self.requestConnection &&
        connection != self.requestConnection) {
        return;
    }
    
    // clean this up, for posterity
    self.requestConnection = nil;
    
    //NSString *text;
    if (!error) {
        // result is the json response from a successful request
        if (self.facebookAlbums.count == 0) {
            self.facebookAlbums = [NSMutableArray array];
        }
        NSDictionary *dictionary = (NSDictionary *)result;
        NSLog(@"JSON response: %@",[dictionary objectForKey:@"data"]);
        for (NSDictionary *album in [dictionary objectForKey:@"data"]) {
            FacebookAlbum *facebookAlbum = [[FacebookAlbum alloc] init];
            facebookAlbum.name = (NSString *)[album objectForKey:@"name"];
            facebookAlbum.description = (NSString *)[album objectForKey:@"description"];
            facebookAlbum.albumId = (NSString *)[album objectForKey:@"id"];
            
            //request for image URL;
            NSString *coverPhotoId = (NSString *)[album objectForKey:@"cover_photo"];
            if (FBSession.activeSession.isOpen) {
                [[FBRequest requestForGraphPath:coverPhotoId] startWithCompletionHandler:
                 ^(FBRequestConnection *connection, id response, NSError *error) {
                     if (!error) {
                         facebookAlbum.coverImageUrl = (NSString *)[response objectForKey:@"picture"];
                     }
                 }];   
            }
            [self.facebookAlbums addObject:facebookAlbum];
        }
        
        
//        if (self.facebookAlbums.count == 0) {
//            self.facebookAlbums = [dictionary objectForKey:@"data"];
//        } else {
//            [self.facebookAlbums addObjectsFromArray:(NSArray*)[dictionary objectForKey:@"data"]];
//        }
//        NSLog(@"JSON response: %@",[dictionary objectForKey:@"data"]);
    }
    [self.myTableView reloadData];
    NSLog(@"page counter: %d", self.pageCounter);
    //NSLog(@"%@",text);
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pageCounter = 1;
	// Do any additional setup after loading the view, typically from a nib.
    [self sendRequests];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark -
#pragma mark Table view data source methods

/*
 The data source methods are handled primarily by the fetch results controller
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.facebookAlbums count] + 1;
}

// Customize the appearance of table view cells.

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell to show the book's title
//    NSDictionary *fbAlbum = [self.facebookAlbums objectAtIndex:[indexPath row]];
//    cell.textLabel.text = (NSString *)[fbAlbum objectForKey:@"name"];
//    cell.detailTextLabel.text = (NSString *)[fbAlbum objectForKey:@"location"];
    FacebookAlbum *album = (FacebookAlbum*)[self.facebookAlbums objectAtIndex:[indexPath row]];
    cell.textLabel.text = album.name;
    cell.detailTextLabel.text = album.coverImageUrl;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *MoreCellIdentifier = @"MoreCell";
    UITableViewCell *cell = nil;
    
    NSUInteger row = [indexPath row];
    NSUInteger count = [self.facebookAlbums count];
    
    if (row == count) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:MoreCellIdentifier];
        
        cell.textLabel.text = @"Load more items...";
        cell.textLabel.textColor = [UIColor blueColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        
    } else {
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [self configureCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.facebookAlbums.count) {
        self.pageCounter++;
        [self sendRequests];
    }
 
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
