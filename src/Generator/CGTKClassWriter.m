/*
 * CGTKClassWriter.m
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

#import "Generator/CGTKClassWriter.h"

@implementation CGTKClassWriter

+(void)generateFilesForClass:(CGTKClass *) cgtkClass inDir:(NSString *) outputDir
{
	NSError *error = nil;
	
	BOOL isDir;
	NSFileManager *fileManager= [NSFileManager defaultManager]; 
	if(![fileManager fileExistsAtPath:outputDir isDirectory:&isDir])
	{
		if(![fileManager createDirectoryAtPath:outputDir withIntermediateDirectories:YES attributes:nil error:NULL])
		{
		    NSLog(@"Error creating output directory: %@", outputDir);
		}
	}
	
	// Header
	NSString *hFilename = [[outputDir stringByAppendingPathComponent:[cgtkClass name]] stringByAppendingPathExtension:@"h"];
		
	[[CGTKClassWriter headerStringFor:cgtkClass] writeToFile:hFilename atomically:NO encoding:NSStringEncodingConversionAllowLossy error:&error];
	
	if(error != nil)
	{
		NSLog(@"Error writing header file: %@", error);
		error = nil;
	}
	
	// Source
	NSString *sFilename = [[outputDir stringByAppendingPathComponent:[cgtkClass name]] stringByAppendingPathExtension:@"m"];
		
	[[CGTKClassWriter sourceStringFor:cgtkClass] writeToFile:sFilename atomically:NO encoding:NSStringEncodingConversionAllowLossy error:&error];
	
	if(error != nil)
	{
		NSLog(@"Error writing source file: %@", error);
		error = nil;
	}
}

+(NSString *)headerStringFor:(CGTKClass *) cgtkClass
{
	NSMutableString *output = [[NSMutableString alloc] init];
	
	[output appendString:[CGTKClassWriter generateLicense:[NSString stringWithFormat:@"%@.h", [cgtkClass name]]]];
	
	// Imports
	[output appendString:@"\n/*\n * Objective-C imports\n */\n"];
	[output appendFormat:@"#import \"CoreGTK/%@.h\"\n", [CGTKUtil swapTypes:[cgtkClass cParentType]]];
	
	NSArray *extraImports = [CGTKUtil extraImports:[cgtkClass type]];
	
	if(extraImports != nil)
	{
		for(NSString *imp in extraImports)
		{
			NSLog(imp);
			[output appendFormat:@"#import %@\n", imp];
		}
	}
		
	[output appendString:@"\n"];
	
	// Interface declaration	
	[output appendFormat:@"@interface %@ : %@\n{\n\n}\n\n", [cgtkClass name], [CGTKUtil swapTypes:[cgtkClass cParentType]]];
	
	// Function declarations	
	if([cgtkClass hasFunctions])
	{
		[output appendString:@"/**\n * Functions\n */\n"];
		
		for(CGTKMethod *func in [cgtkClass functions])
		{
			[output appendFormat:@"+(%@)%@;\n", [func returnType], [func sig]];
		}
	}
	
	if([cgtkClass hasConstructors])
	{
		[output appendString:@"\n/**\n * Constructors\n */\n"];
		
		// Constructor declarations
		for(CGTKMethod *ctor in [cgtkClass constructors])
		{
			[output appendFormat:@"-(id)%@;\n", [CGTKUtil convertFunctionToInit:[ctor sig]]];
		}
	}
	
	[output appendString:@"\n/**\n * Methods\n */\n\n"];
	
	// Self type method declaration
	[output appendFormat:@"-(%@*)%@;\n", [cgtkClass cType], [[cgtkClass cName] uppercaseString]];
	
	for(CGTKMethod *meth in [cgtkClass methods])
	{
		[output appendFormat:@"\n%@\n", [CGTKClassWriter generateDocumentationForMethod:meth]];
		[output appendFormat:@"-(%@)%@;\n", [meth returnType], [meth sig]];
	}
	
	// End interface
	[output appendString:@"\n@end"];

	return [output autorelease];
}

+(NSString *)sourceStringFor:(CGTKClass *) cgtkClass
{	
	NSMutableString *output = [[NSMutableString alloc] init];
	
	[output appendString:[CGTKClassWriter generateLicense:[NSString stringWithFormat:@"%@.m", [cgtkClass name]]]];
	
	// Imports
	[output appendString:@"\n/*\n * Objective-C imports\n */\n"];
	[output appendFormat:@"#import \"CoreGTK/%@.h\"\n\n", [cgtkClass name]];
	
	// Implementation declaration	
	[output appendFormat:@"@implementation %@\n\n", [cgtkClass name]];
	
	// Function implementations
	for(CGTKMethod *func in [cgtkClass functions])
	{
		[output appendFormat:@"+(%@)%@", [func returnType], [func sig]];
				
		[output appendString:@"\n{\n"];
		
		if([func returnsVoid])
		{
			[output appendFormat:@"\t%@(%@);\n", [func cName], [CGTKClassWriter generateCParameterListString:[func parameters]]];
		}
		else
		{
			// Need to add "return ..."
			[output appendString:@"\treturn "];
			
			if([CGTKUtil isTypeSwappable:[func cReturnType]])
			{
				// Need to swap type on return
				[output appendString:[CGTKUtil convertType:[func cReturnType] withName:[NSString stringWithFormat:@"%@(%@)", [func cName], [CGTKClassWriter generateCParameterListString:[func parameters]]] toType:[func returnType]]];
			}
			else
			{
				[output appendFormat:@"%@(%@)", [func cName], [CGTKClassWriter generateCParameterListString:[func parameters]]];
			}
			
			[output appendString:@";\n"];
		}
		
		[output appendString:@"}\n\n"];
	}
	
	// Constructor implementations
	for(CGTKMethod *ctor in [cgtkClass constructors])
	{
		[output appendFormat:@"-(id)%@", [CGTKUtil convertFunctionToInit:[ctor sig]]];
		
		[output appendString:@"\n{\n"];
				
		[output appendFormat:@"\tself = %@;\n\n", [CGTKUtil getFunctionCallForConstructorOfType:[cgtkClass cType] withConstructor:[NSString stringWithFormat:@"%@(%@)", [ctor cName], [CGTKClassWriter generateCParameterListString:[ctor parameters]]]]];
		
		[output appendString:@"\tif(self)\n\t{\n\t\t//Do nothing\n\t}\n\n\treturn self;\n"];
		
		[output appendString:@"}\n\n"];
	}
	
	// Self type method implementation
	[output appendFormat:@"-(%@*)%@\n{\n\treturn %@;\n}\n\n", [cgtkClass cType], [[cgtkClass cName] uppercaseString], [CGTKUtil selfTypeMethodCall:[cgtkClass cType]]];
	
	for(CGTKMethod *meth in [cgtkClass methods])
	{		
		[output appendFormat:@"-(%@)%@", [meth returnType], [meth sig]];
				
		[output appendString:@"\n{\n"];
				
		if([meth returnsVoid])
		{
			[output appendFormat:@"\t%@(%@);\n", [meth cName], [CGTKClassWriter generateCParameterListWithInstanceString:[cgtkClass type] andParams:[meth parameters]]];
		}
		else
		{
			// Need to add "return ..."
			[output appendString:@"\treturn "];
			
			if([CGTKUtil isTypeSwappable:[meth cReturnType]])
			{
				// Need to swap type on return
				[output appendString:[CGTKUtil convertType:[meth cReturnType] withName:[NSString stringWithFormat:@"%@(%@)", [meth cName], [CGTKClassWriter generateCParameterListWithInstanceString:[cgtkClass type] andParams:[meth parameters]]] toType:[meth returnType]]];
			}
			else
			{			
				[output appendFormat:@"%@(%@)", [meth cName], [CGTKClassWriter generateCParameterListWithInstanceString:[cgtkClass type] andParams:[meth parameters]]];
			}
			
			[output appendString:@";\n"];
		}
		
		[output appendString:@"}\n\n"];
	}
	
	// End implementation
	[output appendString:@"\n@end"];

	return [output autorelease];
}

+(NSString *)generateCParameterListString:(NSArray *) params
{
	int i;
	NSMutableString *paramsOutput = [[NSMutableString alloc] init];
	
	if(params != nil && [params count] > 0)
	{
		CGTKParameter *p;
		for(i = 0; i < [params count]; i++)
		{
			p = [params objectAtIndex:i];
			[paramsOutput appendString: [CGTKUtil convertType:[p type] withName:[p name] toType:[p cType]]];
										
			if(i < [params count] -1)
			{
				[paramsOutput appendString:@", "];
			}				
		}
	}

	return [paramsOutput autorelease];
}

+(NSString *)generateCParameterListWithInstanceString:(NSString *)instanceType andParams:(NSArray *) params
{
	int i;
	NSMutableString *paramsOutput = [[NSMutableString alloc] init];
	
	[paramsOutput appendString:[CGTKUtil selfTypeMethodCall:instanceType]];
	
	if(params != nil && [params count] > 0)
	{
		[paramsOutput appendString:@", "];
			
		CGTKParameter *p;
		
		// Start at index 1
		for(i = 0; i < [params count]; i++)
		{
			p = [params objectAtIndex:i];
			[paramsOutput appendString: [CGTKUtil convertType:[p type] withName:[p name] toType:[p cType]]];
									
			if(i < [params count] -1)
			{
				[paramsOutput appendString:@", "];
			}				
		}
	}
	
	return [paramsOutput autorelease];
}

+(NSString *)generateLicense:(NSString *)fileName
{
	NSError *error = nil;
	NSString *licText = [NSString stringWithContentsOfFile:@"Config/license.txt" encoding:NSStringEncodingConversionAllowLossy error:&error];
	
	if(error == nil)
	{
		return [licText stringByReplacingOccurrencesOfString:@"@@@FILENAME@@@" withString:fileName];
	}
	else
	{
		NSLog(@"Error reading license file: %@", error);
		return nil;
	}
}

+(NSString *)generateDocumentationForMethod:(CGTKMethod *)meth
{
	int i;
	CGTKParameter *p = nil;
	
	NSMutableString *doc = [[NSMutableString alloc] init];
	
	[doc appendFormat:@"/**\n * -(%@*)%@;\n *\n", [meth returnType], [meth sig]];
	
	if([meth.parameters count] > 0)
	{		
		for(i = 0; i < [meth.parameters count]; i++)
		{
			p = [meth.parameters objectAtIndex:i];
		
			[doc appendFormat:@" * @param %@\n", [p name]];			
		}
	}
	
	if(![meth returnsVoid])
	{
		[doc appendFormat:@" * @returns %@\n", [meth returnType]];
	}
	
	[doc appendString:@" */"];
	
	return [doc autorelease];
}

@end
