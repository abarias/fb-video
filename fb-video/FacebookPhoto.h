//
//  FacebookPhoto.h
//  fb-video
//
//  Created by AB Arias on 9/2/12.
//  Copyright (c) 2012 Chevron Holdings Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "Three20/Three20.h"

//@interface FacebookPhoto : NSObject <TTPhoto>
@interface FacebookPhoto : NSObject

@property (nonatomic, copy) NSString *caption;
@property (nonatomic, copy) NSString *urlLarge;
@property (nonatomic, copy) NSString *urlSmall;
@property (nonatomic, copy) NSString *urlThumb;
@property (nonatomic) CGSize size;
@property (nonatomic) NSInteger index;

- (id)initWithCaption:(NSString *)caption urlLarge:(NSString *)urlLarge
             urlSmall:(NSString *)urlSmall urlThumb:(NSString *)urlThumb size:(CGSize)size;

@end
