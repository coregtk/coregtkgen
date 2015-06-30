/*
 * main.h
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
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSString.h>

#import "Generator/CGTKClassWriter.h"
#import "Gir2Objc.h"

int main(int argc, char *argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	/*
	 * Step 1: parse GIR file
	 */
	
	NSString *girFile = [CGTKUtil globalConfigValueFor:@"girFile"];
	NSError *parseError = nil;
	
	NSLog(@"Attempting to parse GIR file...");
	GIRApi *api = [Gir2Objc firstApiFromGirFile: girFile withError: &parseError];
	
	if(api == nil)
	{
		// Check if it failed due to a parsing error
		if(parseError != nil)
		{
			NSLog(@"Failed to parse GIR file!");
			NSLog(@"%@", parseError);
		}
		// If there wasn't a file parsing error then it failed turning the NSDictionary into the GIRApi
		else
		{
			NSLog(@"Failed to convert dictionary into GIRApi!");
		}
	}
	else
	{
		NSLog(@"Finished converting dictionary into GIRApi.");
	}
		
	if(api != nil)
	{
		/*
		 * Step 2: generate CoreGTK source files
		 */
	
		NSLog(@"Attempting to generate CoreGTK...");
		[Gir2Objc generateClassFilesFromApi:api];
		NSLog(@"Process complete");
		
		/*
		 * Step 3: copy CoreGTK base files
		 */
		
		NSString *baseClassPath = [CGTKUtil globalConfigValueFor:@"baseClassDir"];
		NSString *outputDir = [CGTKUtil globalConfigValueFor:@"outputDir"];
	
		if(baseClassPath != nil && outputDir != nil)
		{
			NSLog(@"Attempting to copy CoreGTK base class files...");
			NSFileManager *fileMgr = [NSFileManager defaultManager];
	
			if ([fileMgr isReadableFileAtPath:baseClassPath] && [fileMgr isWritableFileAtPath:outputDir])
			{			
				NSError *error = nil;
				NSArray *srcDirContents = [fileMgr contentsOfDirectoryAtPath:baseClassPath error:&error];
			
				if(error != nil)
				{
					NSLog(@"Error: %@", error);
				}
				else
				{
					for(NSString *srcFile in srcDirContents)
					{
						NSString *src = [baseClassPath stringByAppendingPathComponent:[srcFile lastPathComponent]];
						NSString *dest = [outputDir stringByAppendingPathComponent:
										  [srcFile lastPathComponent]];

						if([fileMgr fileExistsAtPath:dest])
						{
							NSLog(@"File [%@] already exists in destination [%@]. Removing existing file...", src, dest);
							if(![fileMgr removeItemAtPath:dest error:&error])
							{
								NSLog(@"Error removing file [%@]: %@. Skipping file.", dest, error);
								continue;
							}
						}
						
						NSLog(@"Copying file [%@] to [%@]...", src, dest);
						if(![fileMgr copyItemAtPath:src
											    toPath:dest
											     error:&error])
						{
							NSLog(@"Error: %@", error);
						}
					}
				}
			}
			else
			{
				NSLog(@"Cannot read/write from directories!");
			}
			NSLog(@"Process complete");
		}
		
		// Release memory
	    [baseClassPath release];
    	[outputDir release];
    }
    	
	/*
	 * Release allocated memory
	 */
	[pool release];
	
	// Return success
	return 0;
}
