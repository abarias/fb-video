//
//  FavoriteFriends.h
//  fb-video
//
//  Created by AB Arias on 8/22/12.
//  Copyright (c) 2012 Chevron Holdings Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FavoriteFriends : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * first_name;
@property (nonatomic, retain) NSString * last_name;

@end
