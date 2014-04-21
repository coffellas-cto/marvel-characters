//
//  GDCellThumbnailView.m
//  Marvel
//
//  Created by Alex G on 14.04.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

#import "GDCellThumbnailView.h"

@implementation GDCellThumbnailView
{
	UIActivityIndicatorView *activityIndicator;
	UIImageView *imageView;
	BOOL loaded;
}

- (void)setImage:(UIImage *)image
{
	if (!image)
		return;

	// This one uses UIImage category UIImage+Resize.
	UIImage *thumbnailedImage = [image thumbnailImage:120 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationMedium];
	// thumbnailImage:... can return nil on some gif files. If so, put old unmodified image instead.
	imageView.image = thumbnailedImage ? thumbnailedImage : image;
	[self animateActivity:NO];
	loaded = YES;
}

- (void)animateActivity:(BOOL)animate
{
	activityIndicator.hidden = !animate;
	if (animate)
		[activityIndicator startAnimating];
	else
		[activityIndicator stopAnimating];
}

+ (GDCellThumbnailView *)thumbnail
{
	return [[GDCellThumbnailView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code

		imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
		[self addSubview:imageView];
		activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
		activityIndicator.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
		[self addSubview:activityIndicator];
	}

	return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
	[super willMoveToSuperview:newSuperview];
	if (!loaded)
		[self animateActivity:YES];
}

/*
   // Only override drawRect: if you perform custom drawing.
   // An empty implementation adversely affects performance during animation.
   - (void)drawRect:(CGRect)rect
   {
    // Drawing code
   }
 */

@end
