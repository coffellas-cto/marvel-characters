//
//  GDBaseViewController.m
//  Marvel
//
//  Created by Alex G on 10.04.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

#import "GDBaseViewController.h"

@interface GDBaseViewController ()
{
	UIActivityIndicatorView *activityIndicator;
}

@end

@implementation GDBaseViewController

- (void)animateActivityIndicator:(BOOL)animate
{
	if (activityIndicator.hidden == !animate)
		return;

	activityIndicator.hidden = !animate;
	if (animate)
	{
		[self.view bringSubviewToFront:activityIndicator];
		[activityIndicator startAnimating];
	}
	else
		[activityIndicator stopAnimating];
}

#pragma Base Class Methods

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.

	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

	activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(self.tableView.frame))];
	activityIndicator.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
	activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	[self.view addSubview:activityIndicator];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
