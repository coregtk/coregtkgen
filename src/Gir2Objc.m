/*
 * Gir2Objc.h
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
 
#import "Gir2Objc.h"

@implementation Gir2Objc

+(BOOL)parseGirFromFile:(NSString *) girFile intoDictionary:(NSDictionary **) girDict withError:(NSError **) parseError;
{
	*girDict = nil;
	*parseError = nil;
	
	NSString *girContents = [[NSString alloc] initWithContentsOfFile:girFile];

	if(girContents == nil)
	{
		NSLog(@"Could not load gir contents!");
		return NO;
	}
	
	// Parse the XML into a dictionary	
	*girDict = [XMLReader dictionaryForXMLString:girContents error:parseError];

	if(*parseError != nil)
	{
		// On error, if a dictionary was still created, clean it up before returning
		if(*girDict != nil)
		{
			[*girDict release];
		}
		
		return NO;
	}
	
	return YES;
}

+(GIRApi *)firstApiFromDictionary:(NSDictionary *) girDict
{
	if(girDict == nil)
	{
		return nil;
	}

	for (NSString *key in girDict)
	{
		id value = [girDict objectForKey:key];
		
		if([key isEqualToString:@"api"] || [key isEqualToString:@"repository"])
		{
			return [[[GIRApi alloc] initWithDictionary:value] autorelease];
		}
		else if([value isKindOfClass:[NSDictionary class]])
		{
			return [Gir2Objc firstApiFromDictionary:value];
		}
	}
	
	return nil;
}

+(GIRApi *)firstApiFromGirFile:(NSString *) girFile withError:(NSError **) parseError
{
	NSDictionary *girDict = nil;
	*parseError = nil;
	
	if(![Gir2Objc parseGirFromFile: girFile intoDictionary: &girDict withError: parseError])
	{
		return nil;
	}
	
	return [Gir2Objc firstApiFromDictionary: girDict];
}

+(BOOL)generateClassFilesFromApi:(GIRApi *) api
{
	@try
	{
		if(api == nil)
		{
			return NO;
		}
	
		NSArray *namespaces = api.namespaces;
		if(namespaces == nil)
		{
			return NO;
		}
		
		for(GIRNamespace *ns in namespaces)
		{
			if(![Gir2Objc generateClassFilesFromNamespace: ns])
			{
				return NO;
			}
		}
			
		return YES;
	}
	@catch (NSException *e)
	{
		NSLog(@"Exception: %@", e);
		return NO;
	}
}

+(BOOL)generateClassFilesFromNamespace:(GIRNamespace *) namespace
{
	int i = 0;
	@try
	{
		if(namespace == nil)
		{
			return NO;
		}
		
		NSArray *classesToGen = [CGTKUtil globalConfigValueFor:@"classesToGen"];
		
		// Pre-load arrTrimMethodName (in GTKUtil) from info in classesToGen
		// In order to do this we must convert from something like
		// ScaleButton to gtk_scale_button
		for(NSString *clazz in classesToGen)
		{
			NSMutableString *result = [[NSMutableString alloc] init];
	
			for(i = 0; i < [clazz length]; i++)
			{
				// Current character				
				NSString *currentChar = [clazz substringWithRange:NSMakeRange(i,1)];
		
				if(i != 0 && [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[currentChar characterAtIndex:0]])
				{
					[result appendFormat:@"_%@", [currentChar lowercaseString]];
				}
				else
				{
					[result appendString:[currentChar lowercaseString]];
				}
			}
			
			[CGTKUtil addToTrimMethodName:[NSString stringWithFormat:@"gtk_%@", result]];
		}
		
		for(GIRClass *clazz in namespace.classes)
		{		
			if(![classesToGen containsObject:clazz.name])
			{
				continue;
			}
			
			CGTKClass *cgtkClass = [[CGTKClass alloc] init];
	
			// Set basic class properties
			[cgtkClass setCName:clazz.name];
			[cgtkClass setCType:clazz.cType];
			[cgtkClass setCParentType:clazz.parent];
			
			// Set constructors				
			for(GIRConstructor *ctor in clazz.constructors)
			{
				BOOL foundVarArgs = NO;
				
				// First need to check for varargs in list of parameters
				for(GIRParameter *param in ctor.parameters)
				{
					if(param.varargs != nil)
					{
						foundVarArgs = YES;
						break;
					}
				}
				
				// Don't handle VarArgs constructors
				if(!foundVarArgs)
				{	
					CGTKMethod *objcCtor = [[CGTKMethod alloc] init];	
					[objcCtor setCName:ctor.cIdentifier];
					[objcCtor setCReturnType:ctor.returnValue.type.cType];	
					
					NSMutableArray *paramArray = [[NSMutableArray alloc] init];
					for(GIRParameter *param in ctor.parameters)
					{							
						CGTKParameter *objcParam = [[CGTKParameter alloc] init];
						
						if(param.type == nil && param.array != nil)
						{
							[objcParam setCType:param.array.cType];
						}
						else
						{
							[objcParam setCType:param.type.cType];
						}
						
						[objcParam setCName:param.name];
						[paramArray addObject:objcParam];			
						[objcParam release];				
					}
					[objcCtor setParameters:paramArray];
					[paramArray release];
					
					[cgtkClass addConstructor:objcCtor];
					[objcCtor release];
				}
			}
			
			// Set functions
			for(GIRFunction *func in clazz.functions)
			{
				BOOL foundVarArgs = NO;
				
				// First need to check for varargs in list of parameters
				for(GIRParameter *param in func.parameters)
				{
					if(param.varargs != nil)
					{
						foundVarArgs = YES;
						break;
					}
				}
				
				if(!foundVarArgs)
				{
					CGTKMethod *objcFunc = [[CGTKMethod alloc] init];
					[objcFunc setCName:func.cIdentifier];
					
					if(func.returnValue.type == nil && func.returnValue.array != nil)
					{
						[objcFunc setCReturnType:func.returnValue.array.cType];
					}
					else
					{
						[objcFunc setCReturnType:func.returnValue.type.cType];
					}
					
					NSMutableArray *paramArray = [[NSMutableArray alloc] init];
					for(GIRParameter *param in func.parameters)
					{							
						CGTKParameter *objcParam = [[CGTKParameter alloc] init];
						
						if(param.type == nil && param.array != nil)
						{
							[objcParam setCType:param.array.cType];
						}
						else
						{
							[objcParam setCType:param.type.cType];
						}						
						
						[objcParam setCName:param.name];
						[paramArray addObject:objcParam];	
						[objcParam release];							
					}
					[objcFunc setParameters:paramArray];
					[paramArray release];
					
					[cgtkClass addFunction:objcFunc];
					[objcFunc release];
				}
			}
			
			// Set methods
			for(GIRMethod *meth in clazz.methods)
			{
				BOOL foundVarArgs = NO;
				
				// First need to check for varargs in list of parameters
				for(GIRParameter *param in meth.parameters)
				{
					if(param.varargs != nil)
					{
						foundVarArgs = YES;
						break;
					}
				}
				
				if(!foundVarArgs)
				{
					CGTKMethod *objcMeth = [[CGTKMethod alloc] init];
					[objcMeth setCName:meth.cIdentifier];
					
					if(meth.returnValue.type == nil && meth.returnValue.array != nil)
					{
						[objcMeth setCReturnType:meth.returnValue.array.cType];
					}
					else
					{
						[objcMeth setCReturnType:meth.returnValue.type.cType];
					}
					
					NSMutableArray *paramArray = [[NSMutableArray alloc] init];
					for(GIRParameter *param in meth.parameters)
					{							
						CGTKParameter *objcParam = [[CGTKParameter alloc] init];
						
						if(param.type == nil && param.array != nil)
						{
							[objcParam setCType:param.array.cType];
						}
						else
						{
							[objcParam setCType:param.type.cType];
						}
						
						[objcParam setCName:param.name];
						[paramArray addObject:objcParam];	
						[objcParam release];							
					}
					[objcMeth setParameters:paramArray];
					[paramArray release];
					
					[cgtkClass addMethod:objcMeth];
					[objcMeth release];
				}
			}

			[CGTKClassWriter generateFilesForClass:cgtkClass inDir:[CGTKUtil globalConfigValueFor:@"outputDir"]];

			[cgtkClass release];
		}		
	
		return YES;
	}
	@catch (NSException *e)
	{
		NSLog(@"Exception: %@", e);
		return NO;		
	}
}

@end
