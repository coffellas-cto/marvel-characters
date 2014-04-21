//
//  GDMarvelRKObjectManager.m
//  Marvel
//
//  Created by Alex G on 14.04.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

#import "GDMarvelRKObjectManager.h"

@implementation GDMarvelRKObjectManager
{
	RKObjectManager *objectManager;
	RKManagedObjectStore *managedObjectStore;
}

#pragma mark - Public Methods

- (NSManagedObjectContext *)managedObjectContext
{
	return managedObjectStore.mainQueueManagedObjectContext;
}

- (void)getMarvelObjectsAtPath:(NSString *)path
                    parameters:(NSDictionary *)params
                       success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                       failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure
{
	NSAssert(![MARVEL_PRIVATE_KEY isEqualToString:@""], @"MARVEL_PRIVATE_KEY can't be empty. Go to https://developer.marvel.com to get your key.");
	NSAssert(![MARVEL_PUBLIC_KEY isEqualToString:@""], @"MARVEL_PUBLIC_KEY can't be empty. Go to https://developer.marvel.com to get your key.");

	// Generate special parameters for authorization. Go to https://developer.marvel.com/documentation/authorization for details.
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyyMMddHHmmss"];
	NSString *timeStampString = [formatter stringFromDate:[NSDate date]];
	NSString *hash = [[NSString stringWithFormat:@"%@%@%@", timeStampString, MARVEL_PRIVATE_KEY, MARVEL_PUBLIC_KEY] MD5String];

	NSMutableDictionary *queryParams = [NSMutableDictionary dictionaryWithDictionary:@{@"apikey" : MARVEL_PUBLIC_KEY,
	                                                                                   @"ts" : timeStampString,
	                                                                                   @"hash" : hash}];
	if (params)
		[queryParams addEntriesFromDictionary:params];

	// Starts RKObjectRequestOperation with certain parameters.
	[objectManager getObjectsAtPath:[NSString stringWithFormat:@"%@%@", MARVEL_API_PATH_PATTERN, path]
	                     parameters:queryParams
	                        success:success
	                        failure:failure];
}

- (void)        addMappingForEntityForName:(NSString *)entityName
        andAttributeMappingsFromDictionary:(NSDictionary *)attributeMappings
               andIdentificationAttributes:(NSArray *)ids
                            andPathPattern:(NSString *)pathPattern
{
	if (!managedObjectStore)
		return;

	// Create mapping for the particular entity.
	RKEntityMapping *objectMapping = [RKEntityMapping mappingForEntityForName:entityName
	                                                     inManagedObjectStore:managedObjectStore];
	[objectMapping addAttributeMappingsFromDictionary:attributeMappings];
	objectMapping.identificationAttributes = ids;


	// Register mappings with the provider using a response descriptor.
	RKResponseDescriptor *characterResponseDescriptor =
	        [RKResponseDescriptor responseDescriptorWithMapping:objectMapping
	                                                     method:RKRequestMethodGET
	                                                pathPattern:[NSString stringWithFormat:@"%@%@", MARVEL_API_PATH_PATTERN, pathPattern]
	                                                    keyPath:@"data.results"
	                                                statusCodes:[NSIndexSet indexSetWithIndex:200]];

	[objectManager addResponseDescriptor:characterResponseDescriptor];
}

- (void)configureWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel
{
	NSAssert(managedObjectModel, @"managedObjectModel can't be nil");

	// Initialize CoreData store & contexts.
	managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
	NSError *error;
	if (!RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error))
		XLog(@"Failed to create Application Data Directory at path '%@': %@", RKApplicationDataDirectory(), error);

	NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"RKMarvel.sqlite"];
	if (![managedObjectStore addSQLitePersistentStoreAtPath:path
	                                 fromSeedDatabaseAtPath:nil
	                                      withConfiguration:nil options:nil error:&error])
		XLog(@"Failed adding persistent store at path '%@': %@", path, error);

	[managedObjectStore createManagedObjectContexts];

	// Link RestKit the generated object store with RestKit's object manager.
	objectManager.managedObjectStore = managedObjectStore;
}

#pragma mark - Singleton Accessor

+ (GDMarvelRKObjectManager *)manager
{
	static GDMarvelRKObjectManager *manager = nil;
	static dispatch_once_t predicate;
	dispatch_once(&predicate, ^{
	                      manager = [[GDMarvelRKObjectManager alloc] init];
		      });
	return manager;
}

#pragma mark - NSObject-derived

- (id)init
{
	self = [super init];
	if (self)
	{
		// Initialize AFNetworking HTTPClient.
		NSURL *baseURL = [NSURL URLWithString:MARVEL_API_BASEPOINT];
		AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];

		// Initialize RestKit's object manager.
		objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
	}

	return self;
}

@end
