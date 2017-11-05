/*
 * CGTKMethod.m
 * This file is part of CoreGTKGen
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
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

/*
 * Modified by the CoreGTK Team, 2017. See the AUTHORS file for a
 * list of people on the CoreGTK Team.
 * See the ChangeLog files for a list of changes.
 *
 */

/*
 * Objective-C imports
 */
#import "Generator/CGTKMethod.h"

@implementation CGTKMethod

-(id)init
{
	self = [super init];

	if(self)
	{
		// Do nothing
	}

	return self;
}

-(void)setCName:(NSString *)name
{
	if(cName != nil)
	{
		[cName release];
	}

	if(name == nil)
	{
		cName = nil;
	}
	else
	{
		cName = [name retain];
	}
}

-(NSString *)cName
{
	return [[cName retain] autorelease];
}

-(NSString *)name
{
	return [CGTKUtil convertUSSToCamelCase:[CGTKUtil trimMethodName:cName]];
}

-(NSString *)sig
{
	int i;
	
	// C method with no parameters
	if(parameters == nil || [parameters count] == 0)
	{	
		return [NSString stringWithFormat:@"%@", [self name]];
	}
	// C method with only one parameter
	else if([parameters count] == 1)
	{
		CGTKParameter *p = [parameters objectAtIndex:0];
		
		return [NSString stringWithFormat:@"%@:(%@) %@", 
			 [self name],
			 [p type],
			 [p name]];
	}
	// C method with multiple parameters
	else
	{
		NSMutableString *output = [[NSMutableString alloc] init];
		
		[output appendString:[NSString stringWithFormat:@"%@With", [self name]]];
		
		for(i = 0; i < [parameters count]; i++)
		{
			CGTKParameter *p = [parameters objectAtIndex:i];
			
			if(i != 0)
			{
				[output appendString:@" and"];
			}
			
			[output appendFormat:@"%@:(%@) %@",
				[CGTKUtil convertUSSToCapCase:[p name]],
				[p type],
				[p name]];
		}
		
		return [output autorelease];
	}
}

-(void)setCReturnType:(NSString *)returnType
{
	if(cReturnType != nil)
	{
		[cReturnType release];
	}
	
	if(returnType == nil)
	{
		cReturnType = nil;
	}
	else
	{
		cReturnType = [returnType retain];
	}
}

-(NSString *)cReturnType
{
	return [[cReturnType retain] autorelease];
}

-(NSString *)returnType
{
	return [CGTKUtil swapTypes:cReturnType];
}

-(BOOL)returnsVoid
{
	return [cReturnType isEqualToString:@"void"];
}

-(void)setParameters:(NSArray *) params
{
	// Hacky fix to get around issue with missing GError parameter from GIR file
	if(	[[self cName] isEqualToString:@"gtk_window_set_icon_from_file"]
		|| [[self cName] isEqualToString:@"gtk_window_set_default_icon_from_file"]
		|| [[self cName] isEqualToString:@"gtk_builder_add_from_file"]
		|| [[self cName] isEqualToString:@"gtk_builder_add_from_resource"]
		|| [[self cName] isEqualToString:@"gtk_builder_add_from_string"]
		|| [[self cName] isEqualToString:@"gtk_builder_add_objects_from_file"]
		|| [[self cName] isEqualToString:@"gtk_builder_add_objects_from_resource"]
		|| [[self cName] isEqualToString:@"gtk_builder_add_objects_from_string"]
		|| [[self cName] isEqualToString:@"gtk_builder_extend_with_template"]
		|| [[self cName] isEqualToString:@"gtk_builder_value_from_string"]
		|| [[self cName] isEqualToString:@"gtk_builder_value_from_string_type"]
		)
	{		
		CGTKParameter *param = [[CGTKParameter alloc] init];
		[param setCType:@"GError**"];
		[param setCName:@"err"];
		
		NSMutableArray *hackyArray = [[[NSMutableArray alloc] init] autorelease];
		[hackyArray addObjectsFromArray:params];
		[hackyArray addObject:param];
		
		[param release];
		
		params = hackyArray;
	}

	parameters = [params retain];
}

-(NSArray *)parameters
{
	return [[parameters retain] autorelease];
}

-(void)dealloc
{
	[cName release];
	[cReturnType release];
	[parameters release];
	[super dealloc];
}

@end
