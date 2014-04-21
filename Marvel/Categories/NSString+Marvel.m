//
//  NSString+Marvel.m
//  Marvel
//
//  Created by Alex G on 10.04.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

#import "NSString+Marvel.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Marvel)

- (NSString *)MD5String
{
	const char *str = [self UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(str, strlen(str), result);

	NSMutableString *retVal = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
	for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
		[retVal appendFormat:@"%02x", result[i]];

	return retVal;
}

@end
