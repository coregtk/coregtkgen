/*
 * GIRMethod.m
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
#import "GIRMethod.h"

@implementation GIRMethod

@synthesize name;
@synthesize cIdentifier;
@synthesize version;
@synthesize returnValue;
@synthesize doc;
@synthesize docDeprecated;
@synthesize deprecated;
@synthesize deprecatedVersion;
@synthesize invoker;
@synthesize throws;
@synthesize introspectable;
@synthesize shadowedBy;
@synthesize shadows;
@synthesize parameters;
@synthesize instanceParameters;

-(id)init
{
	self = [super init];
	
	if(self)
	{
		self.elementTypeName = @"GIRMethod";
		self.parameters = [[NSMutableArray alloc] init];
		self.instanceParameters = [[NSMutableArray alloc] init];
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
		
		if(![self tryParseWithKey:key andValue:value])
		{
			[self logUnknownElement:key];
		}
	}
}

-(BOOL)tryParseWithKey:(NSString *)key andValue:(id)value
{
	if([key isEqualToString:@"text"])
	{
		// Do nothing
	}	
	else if([key isEqualToString:@"name"])
	{
		self.name = value;
	}	
	else if([key isEqualToString:@"c:identifier"])
	{
		self.cIdentifier = value;
	}	
	else if([key isEqualToString:@"version"])
	{
		self.version = value;
	}
	else if([key isEqualToString:@"return-value"])
	{
		self.returnValue = [[GIRReturnValue alloc] initWithDictionary:value];
	}	
	else if([key isEqualToString:@"doc"])
	{
		self.doc = [[GIRDoc alloc] initWithDictionary:value];
	}	
	else if([key isEqualToString:@"doc-deprecated"])
	{
		self.docDeprecated = [[GIRDoc alloc] initWithDictionary:value];
	}
	else if([key isEqualToString:@"deprecated"])
	{
		self.deprecated = [value isEqualToString:@"1"];
	}
	else if([key isEqualToString:@"deprecated-version"])
	{
		self.deprecatedVersion = value;
	}
	else if([key isEqualToString:@"invoker"])
	{
		self.invoker = value;
	}	
	else if([key isEqualToString:@"throws"])
	{
		self.throws = [value isEqualToString:@"1"];
	}
	else if([key isEqualToString:@"introspectable"])
	{
		self.introspectable = [value isEqualToString:@"1"];
	}
	else if([key isEqualToString:@"shadowed-by"])
	{
		self.shadowedBy = [value isEqualToString:@"1"];
	}
	else if([key isEqualToString:@"shadows"])
	{
		self.shadows = [value isEqualToString:@"1"];
	}
	else if([key isEqualToString:@"parameters"])
	{
		for(NSString *paramKey in value)
		{			
			if([paramKey isEqualToString:@"parameter"])
			{
				[self processArrayOrDictionary:[value objectForKey:paramKey] withClass:[GIRParameter class] andArray:parameters];
			}
			else if([paramKey isEqualToString:@"instance-parameter"])
			{
				[self processArrayOrDictionary:[value objectForKey:paramKey] withClass:[GIRParameter class] andArray:instanceParameters];
			}
		}
	}
	else
	{
		return NO;
	}	
	
	return YES;
}

-(void)dealloc
{
	[name release];
	[cIdentifier release];
	[version release];
	[returnValue release];
	[deprecatedVersion release];
	[invoker release];
	[doc release];
	[docDeprecated release];
	[parameters release];
	[instanceParameters release];
	[super dealloc];
}

@end
