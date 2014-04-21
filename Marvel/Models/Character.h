//
//  Character.h
//  Marvel
//
//  Created by Alex G on 16.04.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Character : NSManagedObject
{
	NSDictionary *_thumbnailDictionary;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *charID;
@property (nonatomic, retain) NSNumber *innerID;
@property (nonatomic, retain) NSString *charDescription;
@property (nonatomic, retain) NSData *thumbnailImageData;
@property (nonatomic, retain) NSString *thumbnailURLString;

@property NSDictionary *thumbnailDictionary;

+ (NSInteger)allCharsCountWithContext:(NSManagedObjectContext *)managedObjectContext;
+ (Character *)charWithManagedObjectContext:(NSManagedObjectContext *)context andInnerID:(NSInteger)charInnerID;

@end
