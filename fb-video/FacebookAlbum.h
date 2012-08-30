//
//  FacebookAlbum.h
//  fb-video
//
//  Created by AB Arias on 8/31/12.
//  Copyright (c) 2012 Chevron Holdings Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FacebookAlbum : NSObject

@property (nonatomic, retain) NSString *albumId;
@property (nonatomic, retain) NSString *coverImageUrl;
@property (nonatomic, retain) UIImage *coverImage;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *description;

@end
