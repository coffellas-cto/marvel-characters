//
//  GDMainViewController.m
//  Marvel
//
//  Created by Alex G on 10.04.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

#import "GDMainViewController.h"
#import "Character.h"
#import "GDMarvelRKObjectManager.h"
#import "GDCellThumbnailView.h"
#import "AllAroundPullView.h"

@interface GDMainViewController ()
{
	NSInteger numberOfCharacters;
	AllAroundPullView *bottomPullView;
	BOOL noRequestsMade;
}

@end

@implementation GDMainViewController

#pragma mark - Private Methods

- (void)showDetailsForCharacterID:(NSInteger)charInnerID
{
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MUST_SHOW_DETAILS object:@(charInnerID)];
}

- (void)saveToStore
{
	// Saving to persistent store for further usage.
	NSError *saveError;
	if (![[[GDMarvelRKObjectManager manager] managedObjectContext] saveToPersistentStore:&saveError])
		XLog(@"%@", [saveError localizedDescription]);
}

- (void)loadThumbnail:(GDCellThumbnailView *)view fromURLString:(NSString *)urlString forCharacter:(Character *)character
{
	// Download thumbnail image for selected character.
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
	         // Image downloaded successfully.
	         character.thumbnailImageData = responseObject;
	         [self saveToStore];
	         [view setImage:[UIImage imageWithData:responseObject]];
	 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
	         // Image download failure.
	         XLog(@"%@", [error localizedDescription]);
	 }];
	[operation start];
}

- (void)loadCharacters
{
	numberOfCharacters = [Character allCharsCountWithContext:[[GDMarvelRKObjectManager manager] managedObjectContext]];

	if (numberOfCharacters == 0)
		[self animateActivityIndicator:YES];
	else if (noRequestsMade && numberOfCharacters > 0) {
		noRequestsMade = NO;
		bottomPullView.hidden = NO;
		return;
	}

	noRequestsMade = NO;

	// Get an array of remote "character" objects. Specify the offset.
	[[GDMarvelRKObjectManager manager] getMarvelObjectsAtPath:MARVEL_API_CHARACTERS_PATH_PATTERN
	                                               parameters:@{@"offset" : @(numberOfCharacters)}
	                                                  success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
	         // Characters loaded successfully.
	         [self animateActivityIndicator:NO];

	         NSInteger newInnerID = numberOfCharacters;

	         for (Character * curCharacter in mappingResult.array)
	         {
	                 if ([curCharacter isKindOfClass:[Character class]])
	                 {
	                         curCharacter.innerID = @(newInnerID);
	                         newInnerID++;
	                         // Saving every character one by one (not after the loop) to prevent losing a bunch of characters if program terminates inside a loop.
	                         [self saveToStore];
			 }
		 }

	         numberOfCharacters = newInnerID;
	         [self.tableView reloadData];

	         bottomPullView.hidden = NO;
	         [bottomPullView finishedLoading];
	 }
	                                                  failure:^(RKObjectRequestOperation *operation, NSError *error) {
	         // Failed to load characters.
	         [self animateActivityIndicator:NO];
	         [bottomPullView finishedLoading];
	         [[[UIAlertView alloc] initWithTitle:@"Marvel API Error" message:operation.error.localizedDescription delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", nil] show];
	 }];
}

#pragma mark - UITableView Delegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = indexPath.row;
	NSString *reusableIdentifier = [NSString stringWithFormat:@"%d", row % 2];
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reusableIdentifier];
	if (!cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableIdentifier];
		cell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}

	[[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

	BOOL charHasDescription = NO;
	if (numberOfCharacters > row)
	{
		Character *curCharacter = [Character charWithManagedObjectContext:
		                           [[GDMarvelRKObjectManager manager] managedObjectContext]
		                                                       andInnerID:row];
		if (curCharacter)
		{
			charHasDescription = ![curCharacter.charDescription isEqualToString:@""];
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, CGRectGetWidth(cell.contentView.frame) - 70 - (charHasDescription ? 60 : 0), 60)];
			label.backgroundColor = [UIColor clearColor];
			label.text = curCharacter.name;
			label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			[cell.contentView addSubview:label];

			GDCellThumbnailView *thumbnail = [GDCellThumbnailView thumbnail];
			if (curCharacter.thumbnailImageData)
				[thumbnail setImage:[UIImage imageWithData:curCharacter.thumbnailImageData]];
			else
				[self loadThumbnail:thumbnail fromURLString:curCharacter.thumbnailURLString forCharacter:curCharacter];

			[cell.contentView addSubview:thumbnail];
		}
	}

	cell.accessoryType = charHasDescription ? UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellSelectionStyleNone;
	cell.userInteractionEnabled = charHasDescription;

	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return numberOfCharacters;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self showDetailsForCharacterID:indexPath.row];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	[self showDetailsForCharacterID:indexPath.row];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	cell.backgroundColor = [UIColor colorWithWhite:indexPath.row % 2 ? 0.9:0.95 alpha:1];
}

#pragma mark - UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
		[self loadCharacters];
}

#pragma mark - UIViewController-derived

- (id)init
{
	self = [super init];
	if (self)
		noRequestsMade = YES;

	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.title = @"Marvel Characters";

	bottomPullView = [[AllAroundPullView alloc] initWithScrollView:self.tableView position:AllAroundPullViewPositionBottom action:^(AllAroundPullView *view){
	                          [self loadCharacters];
			  }];
	bottomPullView.hidden = YES;
	[self.tableView addSubview:bottomPullView];

	// Configure CoreData managed object model.
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Marvel" withExtension:@"momd"];
	[[GDMarvelRKObjectManager manager] configureWithManagedObjectModel:[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL]];

	// Add mapping between the "Character" CoreData entity and the "Character" class. Specify the mapping between entity attributes and class properties.
	[[GDMarvelRKObjectManager manager] addMappingForEntityForName:@"Character"
	                           andAttributeMappingsFromDictionary:@{
	         @"name" : @"name",
	         @"id" : @"charID",
	         @"thumbnail" : @"thumbnailDictionary",
	         @"description" : @"charDescription"
	 }
	                                  andIdentificationAttributes:@[@"charID"]
	                                               andPathPattern:MARVEL_API_CHARACTERS_PATH_PATTERN];

	[self loadCharacters];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
