//
//  GDMarvelRKObjectManager.h
//  Marvel
//
//  Created by Alex G on 14.04.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface GDMarvelRKObjectManager : NSObject

- (NSManagedObjectContext *)managedObjectContext;

- (void)getMarvelObjectsAtPath:(NSString *)path
                    parameters:(NSDictionary *)params
                       success:(void (^) (RKObjectRequestOperation * operation, RKMappingResult * mappingResult)) success
                       failure:(void (^) (RKObjectRequestOperation * operation, NSError * error))failure;

- (void)        addMappingForEntityForName:(NSString *)entityName
        andAttributeMappingsFromDictionary:(NSDictionary *)attributeMappings
               andIdentificationAttributes:(NSArray *)ids
                            andPathPattern:(NSString *)pathPattern;

- (void)configureWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel;
+ (GDMarvelRKObjectManager *)manager;

@end
