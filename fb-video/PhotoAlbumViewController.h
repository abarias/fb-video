//
//  PhotoAlbumViewController.h
//  fb-video
//
//  Created by AB Arias on 9/2/12.
//  Copyright (c) 2012 Chevron Holdings Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AQGridView.h"
//#import "Three20/Three20.h"
#import "FacebookAlbum.h"

@interface PhotoAlbumViewController : UIViewController<AQGridViewDataSource, AQGridViewDelegate>
{
    AQGridView * _gridView;
}

@property (strong, nonatomic) FacebookAlbum *album;
@property (strong, nonatomic) IBOutlet AQGridView *gridView;

@end
