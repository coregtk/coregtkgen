/*
 * CGTKBase.m
 * This file is part of CoreGTK
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
#import "CoreGTK/CGTKBase.h"

@implementation CGTKBase

+(CGTKBase *)withGtkWidget:(GtkWidget *)obj
{
	CGTKBase *retVal = [[CGTKBase alloc] initWithGObject:(GObject *)obj];
	return [retVal autorelease];
}

+(CGTKBase *)withGObject:(GObject *)obj
{
	CGTKBase *retVal = [[CGTKBase alloc] initWithGObject:obj];
	return [retVal autorelease];
}

-(id)initWithGObject:(GObject *)obj
{
	self = [super init];
	
	if(self)
	{
		[self setGObject:obj];
	}
	
	return self;
}

-(GtkWidget *)WIDGET
{
	return GTK_WIDGET(__gObject);
}

-(void)setGObject:(GObject *)obj
{
	if(__gObject != NULL)
	{
		// Decrease the reference count on the previously stored GObject
		g_object_unref(__gObject);
	}
	
	__gObject = obj;
	
	if(__gObject != NULL)
	{
		// Increase the reference count on the new GObject
		g_object_ref(__gObject);
	}
}

-(GObject *)GOBJECT
{
	return __gObject;
}

-(void)dealloc
{
	if(__gObject != NULL)
	{
		// Decrease the reference count on the previously stored GObject
		g_object_unref(__gObject);
		__gObject = NULL;
	}
	[super dealloc];
}

@end
