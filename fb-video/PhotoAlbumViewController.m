//
//  PhotoAlbumViewController.m
//  fb-video
//
//  Created by AB Arias on 9/2/12.
//  Copyright (c) 2012 Chevron Holdings Inc. All rights reserved.
//

#import "PhotoAlbumViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FacebookPhotoSource.h"
#import "FacebookPhoto.h"

@interface PhotoAlbumViewController ()

@property (strong, nonatomic) FBRequestConnection *requestConnection;

@end

@implementation PhotoAlbumViewController

@synthesize requestConnection = _requestConnection;
@synthesize album = _album;

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
    
    NSString *pageQuery = [NSString stringWithFormat:@"%@/photos",[self.album albumId],nil];
    
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
        NSDictionary *dictionary = (NSDictionary *)result;
        NSLog(@"JSON response: %@",[dictionary objectForKey:@"data"]);
        
        NSMutableArray *facebookPhotos = [NSMutableArray array];
        for (NSDictionary *photo in [dictionary objectForKey:@"data"]) {
            FacebookPhoto *fbPhoto = [[FacebookPhoto alloc] initWithCaption:[photo objectForKey:@"name"] urlLarge:[photo objectForKey:@"source"] urlSmall:nil urlThumb:[photo objectForKey:@"picture"] size:CGSizeMake(480, 720)];
            [facebookPhotos addObject:fbPhoto];
        }
        FacebookPhotoSource *photoSource = [[FacebookPhotoSource alloc] initWithTitle:[self.album name] photos:facebookPhotos];
        self.photoSource = photoSource;
        
        
      
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self sendRequests];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
