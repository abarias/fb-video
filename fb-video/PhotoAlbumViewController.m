//
//  PhotoAlbumViewController.m
//  fb-video
//
//  Created by AB Arias on 9/2/12.
//  Copyright (c) 2012 Chevron Holdings Inc. All rights reserved.
//

#import "PhotoAlbumViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <AVFoundation/AVFoundation.h>
//#import "FacebookPhotoSource.h"
#import "FacebookPhoto.h"
#import "GridViewCell.h"
#import "AsyncImageView.h"

@interface PhotoAlbumViewController ()

@property (strong, nonatomic) FBRequestConnection *requestConnection;
@property (strong, nonatomic) NSMutableArray *albumPhotos;
@property (strong, nonatomic) NSMutableArray *imagesForMovie;

@end

@implementation PhotoAlbumViewController

@synthesize gridView = _gridView;
@synthesize requestConnection = _requestConnection;
@synthesize album = _album;
@synthesize albumPhotos = _albumPhotos;
@synthesize imagesForMovie = _imagesForMovie;

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
        
        self.albumPhotos = [NSMutableArray array];
        self.imagesForMovie = [NSMutableArray array];
        for (NSDictionary *photo in [dictionary objectForKey:@"data"]) {
            FacebookPhoto *fbPhoto = [[FacebookPhoto alloc] initWithCaption:[photo objectForKey:@"name"] urlLarge:[photo objectForKey:@"source"] urlSmall:nil urlThumb:[photo objectForKey:@"picture"] size:CGSizeMake(480, 720)];
            [self.albumPhotos addObject:fbPhoto];

            UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:fbPhoto.urlLarge]]];
            [self.imagesForMovie addObject:image];
//            UIImageView *imageView = [[UIImageView alloc] init];
//            imageView.imageURL = [NSURL URLWithString:fbPhoto.urlLarge];
//            if (imageView.image != nil) {
//                UIImage *imageForMovie = imageView.image;
//                [self.imagesForMovie addObject:imageForMovie];
//            }
        }
        
        
//        NSMutableArray *facebookPhotos = [NSMutableArray array];
//        for (NSDictionary *photo in [dictionary objectForKey:@"data"]) {
//            FacebookPhoto *fbPhoto = [[FacebookPhoto alloc] initWithCaption:[photo objectForKey:@"name"] urlLarge:[photo objectForKey:@"source"] urlSmall:nil urlThumb:[photo objectForKey:@"picture"] size:CGSizeMake(480, 720)];
//            [facebookPhotos addObject:fbPhoto];
//        }
//        FacebookPhotoSource *photoSource = [[FacebookPhotoSource alloc] initWithTitle:[self.album name] photos:facebookPhotos];
//        self.photoSource = photoSource;
        
        
        [self.gridView reloadData];
    }

}

- (CVPixelBufferRef) newPixelBufferFromCGImage: (CGImageRef) image andSize: (CGSize) frameSize
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CGAffineTransform frameTransform = CGAffineTransformRotate(frameTransform, 0);
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
                                          frameSize.height, kCVPixelFormatType_32ARGB, (CFDictionaryRef) CFBridgingRetain(options),
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width,
                                                 frameSize.height, 8, 4*frameSize.width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, frameTransform);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

-(void) writeImagesToMovieAtPath:(NSString *) path withSize:(CGSize) size{
    
    
    NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryPath error:nil];
    for (NSString *tString in dirContents) {
        if ([tString isEqualToString:@"test.mp4"])
        {
            [[NSFileManager defaultManager]removeItemAtPath:[NSString stringWithFormat:@"%@/%@",documentsDirectoryPath,tString] error:nil];
            
        }
    }
    
    NSLog(@"Write Started");
    
    NSError *error = nil;
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:
                                  [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/test.mp4",path]] fileType:AVFileTypeMPEG4
                                                              error:&error];
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey,
                                   nil];
    
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                             assetWriterInputWithMediaType:AVMediaTypeVideo
                                             outputSettings:videoSettings];
    
    
    
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
                                                     sourcePixelBufferAttributes:nil];
    
    
    
    
    
    NSParameterAssert(videoWriterInput);
    
    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
    videoWriterInput.expectsMediaDataInRealTime = YES;
    [videoWriter addInput:videoWriterInput];
    //Start a session:
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    
    //Video encoding
    
    CVPixelBufferRef buffer = NULL;
    
    //convert uiimage to CGImage.
    
    int frameCount = 0;
    
    for(int i = 0; i<[self.imagesForMovie count]; i++)
    {
        buffer = [self newPixelBufferFromCGImage:[[self.imagesForMovie objectAtIndex:i] CGImage] andSize:size];
        
        
        BOOL append_ok = NO;
        int j = 0;
        while (!append_ok && j < 50)
        {
            if (adaptor.assetWriterInput.readyForMoreMediaData)
            {
                printf("appending %d attemp %d\n", frameCount, j);
                
                CMTime frameTime = CMTimeMake(frameCount,(int32_t) 10);
                
                append_ok = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
                CVPixelBufferPoolRef bufferPool = adaptor.pixelBufferPool;
                NSParameterAssert(bufferPool != NULL);
                
                [NSThread sleepForTimeInterval:0.05];
            }
            else
            {
                printf("adaptor not ready %d, %d\n", frameCount, j);
                [NSThread sleepForTimeInterval:0.1];
            }
            j++;
        }
        if (!append_ok) {
            printf("error appending image %d times %d\n", frameCount, j);
        }
        frameCount++;
        CVBufferRelease(buffer);
    }
    
    
    [videoWriterInput markAsFinished];
    [videoWriter finishWriting];
    
    //[self.imagesForMovie removeAllObjects];
    
    NSLog(@"Write Ended");
}




-(IBAction)startClipifyProcess:(id)sender
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString* docDir = [paths objectAtIndex:0];
    [self writeImagesToMovieAtPath:docDir withSize:CGSizeMake(480, 720)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.album.name;
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(startClipifyProcess:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    self.gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	self.gridView.autoresizesSubviews = YES;
	self.gridView.delegate = self;
	self.gridView.dataSource = self;
    self.gridView.backgroundColor = [UIColor blackColor];
    //self.gridView.contentInset = UIEdgeInsetsMake(4, 4, 4, 4);
    //self.gridView.rightContentInset = 2;
    //self.gridView.leftContentInset = 2;
	//self.gridView.resizesCellWidthToFit = YES;

    [self sendRequests];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setGridView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark -
#pragma mark Grid View delegate


-(NSUInteger)numberOfItemsInGridView:(AQGridView *)aGridView {
    return [self.albumPhotos count];
}


-(AQGridViewCell *)gridView:(AQGridView *)aGridView cellForItemAtIndex:(NSUInteger)index {
	static NSString *CellIdentifier = @"CellIdentifier";
	GridViewCell *cell = (GridViewCell *)[aGridView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil )
    {
        cell = [[GridViewCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 80, 80)
                                                 reuseIdentifier: CellIdentifier];
        cell.selectionGlowColor = [UIColor blueColor];
    }
    //cell.image = [UIImage imageNamed:@"Placeholder.png"];
    FacebookPhoto *fbPhoto = (FacebookPhoto*)[self.albumPhotos objectAtIndex:index];
    cell.imageURL = [NSURL URLWithString:fbPhoto.urlThumb];
    return cell;
}


-(CGSize)portraitGridCellSizeForGridView:(AQGridView *)aGridView {
    return CGSizeMake(80, 80);
}


-(void)gridView:(AQGridView *)aGridView didSelectItemAtIndex:(NSUInteger)index {
//    GridViewCell *cell = (GridViewCell *)[gridView cellForItemAtIndex:index];
//    thumbRect = [self globalRectForCell:cell];
//	[self expandDetailView];
//    [expandedVC scrollToSpecificIndex:index];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
