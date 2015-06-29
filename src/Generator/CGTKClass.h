/*
 * CGTKClass.h
 * This file is part of CoreGTKGen
 *
 * Copyright (C) 2015 - Tyler Burton
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
 * Modified by the CoreGTK Team, 2015. See the AUTHORS file for a
 * list of people on the CoreGTK Team.
 * See the ChangeLog files for a list of changes.
 *
 */

/*
 * Objective-C imports
 */
#import <Foundation/Foundation.h>

#import "Generator/CGTKMethod.h"

/**
 * Abstracts Class operations
 */
@interface CGTKClass : NSObject
{
	NSString *cName;
	NSString *cType;
	NSString *cParentType;
	NSMutableArray *constructors;
	NSMutableArray *functions;
	NSMutableArray *methods;
}

-(void)setCName:(NSString *)name;
-(NSString *)cName;

-(void)setCType:(NSString *)type;
-(NSString *)cType;

-(NSString *)type;

-(void)setCParentType:(NSString *)type;
-(NSString *)cParentType;

-(NSString *)name;

-(void)addConstructor:(CGTKMethod *)ctor;
-(NSArray *)constructors;
-(BOOL)hasConstructors;

-(void)addFunction:(CGTKMethod *)fun;
-(NSArray *)functions;
-(BOOL)hasFunctions;

-(void)addMethod:(CGTKMethod *)meth;
-(NSArray *)methods;
-(BOOL)hasMethods;

@end
