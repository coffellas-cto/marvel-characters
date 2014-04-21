//
//  GDDetailedViewController.m
//  Marvel
//
//  Created by Alex G on 19.04.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

#import "GDDetailedViewController.h"
#import "Character.h"
#import "GDMarvelRKObjectManager.h"

@interface GDDetailedViewController ()
{
	Character *character;
	UIImageView *imageView;
}

@end

@implementation GDDetailedViewController

@synthesize selectedCharInnerID;

#pragma mark - UITableView Delegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = indexPath.row;
	CGFloat commonWidth = 320;

	NSString *reuseIdentifier = [NSString stringWithFormat:@"%d", row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (!cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.backgroundColor = [UIColor blackColor];
		switch (row) {
		    case 0:
		    {
			    if (!imageView)
			    {
				    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, commonWidth, commonWidth)];
				    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
			    }

			    [cell.contentView addSubview:imageView];
		    }
		    break;
		    case 1:
		    {
			    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
			    cell.textLabel.numberOfLines = 0;
			    cell.textLabel.backgroundColor = [UIColor clearColor];
			    cell.textLabel.textColor = [UIColor whiteColor];
			    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:18];
		    }
		    break;

		    default:
			    break;
		}
	}

	switch (row) {
	    case 0:
	    {
		    // TODO: It's a little too naive to think the image is already downloaded in the previous view-controller. Need to add a check and download if not already loaded.
		    UIImage *image = [UIImage imageWithData:character.thumbnailImageData];
		    UIImage *thumbnailedImage = [image thumbnailImage:commonWidth * 2 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationMedium];

		    // thumbnailImage:... can return nil on some gif files. Put old unmodified image instead.
		    imageView.image = thumbnailedImage ? thumbnailedImage : image;
	    }
	    break;
	    case 1:
		    cell.textLabel.text = character.charDescription;
		    break;

	    default:
		    break;
	}

	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat retVal = 0;
	switch (indexPath.row) {
	    case 0:
		    retVal = 320;
		    break;
	    case 1:
	    {
		    CGSize labelSize = [character.charDescription sizeWithFont:[UIFont fontWithName:@"Avenir-Heavy" size:18] constrainedToSize:CGSizeMake(CGRectGetWidth(self.tableView.frame) - 20, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
		    retVal = labelSize.height + 20;
	    }
	    break;

	    default:
		    break;
	}

	return retVal;
}

#pragma mark - UIViewController-derived

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.

	self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	self.tableView.backgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	character = [Character charWithManagedObjectContext:[[GDMarvelRKObjectManager manager] managedObjectContext] andInnerID:[selectedCharInnerID integerValue]];
	if (!character)
	{
		[[[UIAlertView alloc] initWithTitle:@"Database Error" message:@"Can't read info about selected character" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
		return;
	}

	self.title = character.name;

	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:(UITableViewScrollPositionTop) animated:NO];
	[self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if (!character)
		[self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
