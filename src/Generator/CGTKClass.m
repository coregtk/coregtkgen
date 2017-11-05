/*
 * CGTKClass.m
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
#import "Generator/CGTKClass.h"

@implementation CGTKClass

-(id)init
{
	self = [super init];

	if(self)
	{
		constructors = [[NSMutableArray alloc] init];
		functions = [[NSMutableArray alloc] init];
		methods = [[NSMutableArray alloc] init];
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

-(void)setCType:(NSString *)type
{
	if(cType != nil)
	{
		[cType release];
	}
	
	if(type == nil)
	{
		cType = nil;
	}
	else
	{
		cType = [type retain];
	}
}

-(NSString *)cType
{
	return [[cType retain] autorelease];
}

-(NSString *)type
{
	return [CGTKUtil swapTypes:cType];
}

-(void)setCParentType:(NSString *)type
{
	if(cParentType != nil)
	{
		[cParentType release];
	}
	
	if(type == nil)
	{
		cParentType = nil;
	}
	else
	{
		cParentType = [type retain];
	}
}

-(NSString *)cParentType
{
	return [[cParentType retain] autorelease];
}

-(NSString *)name
{
	return [NSString stringWithFormat:@"CGTK%@", cName];
}

-(void)addConstructor:(CGTKMethod *)ctor
{
	if(ctor != nil)
	{
		[constructors addObject:ctor];
	}
}

-(NSArray *)constructors
{
	return constructors;
}

-(BOOL)hasConstructors
{
	return [constructors count] != 0;
}

-(void)addFunction:(CGTKMethod *)func
{
	if(func != nil)
	{
		[functions addObject:func];
	}
}

-(NSArray *)functions
{
	return functions;
}

-(BOOL)hasFunctions
{
	return [functions count] != 0;
}

-(void)addMethod:(CGTKMethod *)meth
{
	if(meth != nil)
	{
		[methods addObject:meth];
	}
}

-(NSArray *)methods
{
	return methods;
}

-(BOOL)hasMethods
{
	return [methods count] != 0;
}

-(void)dealloc
{
	[cName release];
	[cType release];
	[cParentType release];
	[constructors release];
	[functions release];
	[methods release];
	[super dealloc];
}

@end
