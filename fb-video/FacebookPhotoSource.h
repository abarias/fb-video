//
//  FacebookPhotoSource.h
//  fb-video
//
//  Created by AB Arias on 9/2/12.
//  Copyright (c) 2012 Chevron Holdings Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"

@interface FacebookPhotoSource : TTURLRequestModel<TTPhotoSource>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSArray *photos;

- (id) initWithTitle:(NSString *)title photos:(NSArray *)photos;

@end
