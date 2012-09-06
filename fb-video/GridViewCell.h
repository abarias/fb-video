//
//  GridViewCell.h
//  fb-video
//
//  Created by AB Arias on 9/4/12.
//  Copyright (c) 2012 Chevron Holdings Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQGridViewCell.h"

@interface GridViewCell : AQGridViewCell
{
    UIImageView * _imageView;
}
@property (nonatomic, strong) UIImage * image;
@property (nonatomic, strong) NSURL * imageURL;

@end
