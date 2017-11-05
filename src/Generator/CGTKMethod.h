/*
 * CGTKMethod.h
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
#import <Foundation/Foundation.h>

#import "Generator/CGTKUtil.h"
#import "Generator/CGTKParameter.h"

/**
 * Abstracts Method operations
 */
@interface CGTKMethod : NSObject
{
	NSString *cName;
	NSString *cReturnType;
	NSArray *parameters;
}

-(void)setCName:(NSString *)name;
-(NSString *)cName;

-(NSString *)name;
-(NSString *)sig;

-(void)setCReturnType:(NSString *)returnType;
-(NSString *)cReturnType;

-(NSString *)returnType;
-(BOOL)returnsVoid;

-(void)setParameters:(NSArray *) params;
-(NSArray *)parameters;

@end
