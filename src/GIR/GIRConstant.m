/*
 * GIRConstant.m
 * This file is part of gir2objc
 *
 * Copyright (C) 2017 - Tyler Burton
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

/*
 * Modified by the gir2objc Team, 2017. See the AUTHORS file for a
 * list of people on the gir2objc Team.
 * See the ChangeLog files for a list of changes.
 *
 */

/*
 * Objective-C imports
 */
#import "GIRConstant.h"

@implementation GIRConstant

@synthesize cType;
@synthesize name;
@synthesize theValue;
@synthesize version;
@synthesize deprecatedVersion;
@synthesize deprecated;
@synthesize doc;
@synthesize docDeprecated;
@synthesize type;

-(id)init
{
	self = [super init];
	
	if(self)
	{
		self.elementTypeName = @"GIRConstant";
	}
	
	return self;
}

-(id)initWithDictionary:(NSDictionary *) dict
{
	self = [self init];
	
	if(self)
	{
		[self parseDictionary:dict];
	}
	
	return self;
}

-(void)parseDictionary:(NSDictionary *) dict
{
	for (NSString *key in dict)
	{	
		id value = [dict objectForKey:key];
	
		if([key isEqualToString:@"text"]
			|| [key isEqualToString:@"type"])
		{
			// Do nothing
		}	
		else if([key isEqualToString:@"c:type"])
		{
			self.cType = value;
		}
		else if([key isEqualToString:@"name"])
		{
			self.name = value;
		}	
		else if([key isEqualToString:@"value"])
		{
			self.theValue = value;
		}
		else if([key isEqualToString:@"version"])
		{
			self.version = value;
		}
		else if([key isEqualToString:@"deprecated-version"])
		{
			self.deprecatedVersion = value;
		}
		else if([key isEqualToString:@"deprecated"])
		{
			self.deprecated = [value isEqualToString:@"1"];
		}
		else if([key isEqualToString:@"doc"])
		{
			self.doc = [[GIRDoc alloc] initWithDictionary:value];
		}
		else if([key isEqualToString:@"doc-deprecated"])
		{
			self.docDeprecated = [[GIRDoc alloc] initWithDictionary:value];
		}
		else if([key isEqualToString:@"type"])
		{
			self.type = [[GIRType alloc] initWithDictionary:value];
		}			
		else
		{
			[self logUnknownElement:key];
		}
	}	
}

-(void)dealloc
{
	[cType release];
	[name release];
	[theValue release];
	[version release];
	[deprecatedVersion release];
	[doc release];
	[docDeprecated release];
	[type release];
	[super dealloc];
}

@end
