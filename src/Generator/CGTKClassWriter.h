/*
 * CGTKClassWriter.h
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

#import "Generator/CGTKUtil.h"
#import "Generator/CGTKClass.h"

/**
 * Functions to write in memory Class representation to file as CoreGTK source
 */
@interface CGTKClassWriter : NSObject
{

}

/**
 * Generate both header and source files based on class and save them in outputDir
 */
+(void)generateFilesForClass:(CGTKClass *) cgtkClass inDir:(NSString *) outputDir;

/**
 * Generate header file contents based on class
 */
+(NSString *)headerStringFor:(CGTKClass *) cgtkClass;

/**
 * Generate source file contents based on class
 */
+(NSString *)sourceStringFor:(CGTKClass *) cgtkClass;

/**
 * Generate list of paramters to pass to underlying C function
 */
+(NSString *)generateCParameterListString:(NSArray *) params;
+(NSString *)generateCParameterListWithInstanceString:(NSString *)instanceType andParams:(NSArray *) params;

/**
 * Reads the text from conf/license.txt and replaces "@@@FILENAME@@@" with fileName
 */
+(NSString *)generateLicense:(NSString *)fileName;

@end
