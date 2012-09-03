//
//  FacebookPhotoSource.m
//  fb-video
//
//  Created by AB Arias on 9/2/12.
//  Copyright (c) 2012 Chevron Holdings Inc. All rights reserved.
//

#import "FacebookPhotoSource.h"
#import "FacebookPhoto.h"

@implementation FacebookPhotoSource

@synthesize title = _title;
@synthesize photos = _photos;

- (id) initWithTitle:(NSString *)title photos:(NSArray *)photos {
    if ((self = [super init])) {
        self.title = title;
        self.photos = photos;
        for(int i = 0; i < _photos.count; ++i) {
            FacebookPhoto *photo = [_photos objectAtIndex:i];
            photo.photoSource = self;
            photo.index = i;
        }
    }
    return self;
}

- (void) dealloc {
    self.title = nil;
    self.photos = nil;
}

#pragma mark TTPhotoSource

- (NSInteger)numberOfPhotos {
    return _photos.count;
}

- (NSInteger)maxPhotoIndex {
    return _photos.count-1;
}

- (id)photoAtIndex:(NSInteger)photoIndex {
    if (photoIndex < _photos.count) {
        return [_photos objectAtIndex:photoIndex];
    } else {
        return nil;
    }
}

@end
