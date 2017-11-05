/*
 * CGTKUtil.m
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
#import "Generator/CGTKUtil.h"

@implementation CGTKUtil

static NSMutableArray *arrTrimMethodName;
static NSMutableDictionary *dictConvertType;
static NSMutableDictionary *dictGlobalConf;
static NSMutableDictionary *dictSwapTypes;
static NSMutableDictionary *dictExtraImports;
static NSMutableDictionary *dictExtraMethods;

+(NSString *)convertUSSToCamelCase:(NSString *)input
{
	NSString *output = [self convertUSSToCapCase:input];
	
	if([output length] > 1)
	{	
		return [NSString stringWithFormat:@"%@%@",[[output substringToIndex:1] lowercaseString],[output substringFromIndex:1]];
	}
	else
	{
		return [output lowercaseString];
	}
}

+(NSString *)convertUSSToCapCase:(NSString *)input
{
	NSMutableString *output = [[[NSMutableString alloc] init] autorelease];
	NSArray *inputItems = [input componentsSeparatedByString:@"_"];
	
	BOOL previousItemWasSingleChar = NO;
	
	for(NSString *item in inputItems)
	{
		if([item length] > 1)
		{
			// Special case where we don't strand single characters
			if(previousItemWasSingleChar)
			{
				[output appendString:item];
			}
			else
			{
				[output appendFormat:@"%@%@",[[item substringToIndex:1] uppercaseString], [item substringFromIndex:1]];
			}
			previousItemWasSingleChar = NO;
		}
		else
		{
			[output appendString:[item uppercaseString]];
			previousItemWasSingleChar = YES;
		}
	}

	return output;
}

+(BOOL)isTypeSwappable:(NSString *) str
{
	return [str isEqualToString:@"NSArray*"] || ![[CGTKUtil swapTypes:str] isEqualToString:str];
}

+(NSString *)convertFunctionToInit:(NSString *)func
{
	NSRange range = [func rangeOfString:@"New"];
	if (range.location == NSNotFound)
	{
		range = [func rangeOfString:@"new"];
	}
	
	if (range.location == NSNotFound) 
	{
		return nil;
	}
	else
	{
		return [NSString stringWithFormat:@"init%@", [func substringFromIndex:range.location + 3]];
	}
}

+(void)addToTrimMethodName:(NSString *)val
{
	if(arrTrimMethodName == nil)
	{
		arrTrimMethodName = [[NSMutableArray alloc] init];
	}
	
	if([arrTrimMethodName indexOfObject:val] == NSNotFound)
	{
		[arrTrimMethodName addObject:val];
	}
}

+(NSString *)trimMethodName:(NSString *)meth
{
	if(arrTrimMethodName == nil)
	{
		arrTrimMethodName = [[NSMutableArray alloc] init];
	}
	
	NSString *longestMatch = nil;
	
	for (NSString *el in arrTrimMethodName)
	{
		if([meth hasPrefix:el])
		{
			if(longestMatch == nil)
			{
				longestMatch = el;
			}
			else if(longestMatch.length < el.length)
			{
				// Found longer match
				longestMatch = el;
			}
		}
	}
	
	if(longestMatch != nil)
	{
		return [meth substringFromIndex:[longestMatch length]];
	}
	
	return meth;
}

+(NSString *)getFunctionCallForConstructorOfType:(NSString *) cType withConstructor:(NSString *) cCtor
{	
	return [NSString stringWithFormat:@"[super initWithGObject:(GObject *)%@]", cCtor];
}

+(NSString *)selfTypeMethodCall:(NSString *) type;
{
	int i=0;
	
	// Convert CGTKFooBar into [self FOOBAR]
	if([type hasPrefix:@"CGTK"])
	{
		type = [CGTKUtil swapTypes:type];
		
		return [NSString stringWithFormat:@"[self %@]", [[type substringWithRange:NSMakeRange(3,[type length] - 3)] uppercaseString]];
	}		
	// Convert GtkFooBar into GTK_FOO_BAR([self GOBJECT])
	else if([type hasPrefix:@"Gtk"])
	{
		NSMutableString *result = [[NSMutableString alloc] init];
		
		// Special logic for GTK_GL_AREA
		if([type isEqualToString:@"GtkGLArea"])
		{
			[result appendString:@"GTK_GL_AREA"];
		}
		else
		{
			// Special logic for things like GtkHSV
			int countBetweenUnderscores = 0;
		
			for(i = 0; i < [type length]; i++)
			{
				// Current character				
				NSString *currentChar = [type substringWithRange:NSMakeRange(i,1)];
			
				if(i != 0 && [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[currentChar characterAtIndex:0]] && countBetweenUnderscores > 1)
				{
					[result appendFormat:@"_%@", [currentChar uppercaseString]];
					countBetweenUnderscores = 0;
				}
				else
				{
					[result appendString:[currentChar uppercaseString]];
					countBetweenUnderscores++;
				}
			}
		}
		
		[result appendString:@"([self GOBJECT])"];
		
		return result;
	}
	else
	{
		return type;
	}
}

+(NSString *)swapTypes:(NSString *) str
{
	if(dictSwapTypes == nil)
	{
		dictSwapTypes = [[NSMutableDictionary alloc] initWithContentsOfFile:@"Config/swap_types.map"];
	}

	NSString *val = [dictSwapTypes objectForKey:str];
	
	return (val == nil) ? str : val;
}

+(NSString *)convertType:(NSString *) fromType withName:(NSString *)name toType:(NSString *) toType
{
	if(dictConvertType == nil)
	{
		dictConvertType = [[NSMutableDictionary alloc] initWithContentsOfFile:@"Config/convert_type.map"];
	}
	
	NSMutableDictionary *outerDict = [dictConvertType objectForKey:fromType];	
	
	if(outerDict == nil)
	{
		if([fromType hasPrefix:@"Gtk"] && [toType hasPrefix:@"CGTK"])
		{
			// Converting from Gtk -> CGTK			
			return [NSString stringWithFormat:@"[[%@ alloc] initWithGObject:(GObject *)%@]", [toType substringWithRange:NSMakeRange(0, [toType length] - 1)], name];
		}
		else if([fromType hasPrefix:@"CGTK"] && [toType hasPrefix:@"Gtk"])
		{
			// Converting from CGTK -> Gtk
			return [NSString stringWithFormat:@"[%@ %@]", name, [[toType substringWithRange:NSMakeRange(3, [toType length] - 4)] uppercaseString]];
		}
		else
		{
			return name;
		}
	}
	
	NSString *val = [outerDict objectForKey:toType];
	
	if(val == nil)
	{
		return name;
	}
	else
	{
		return [NSString stringWithFormat:val, name];
	}
}

+(id)globalConfigValueFor:(NSString *)key
{
	if(dictGlobalConf == nil)
	{
		dictGlobalConf = [[NSMutableDictionary alloc] initWithContentsOfFile:@"Config/global_conf.map"];
	}
	
	return [dictGlobalConf objectForKey:key];
}

+(NSArray *)extraImports:(NSString *)clazz
{
	if(dictExtraImports == nil)
	{
		dictExtraImports = [[NSMutableDictionary alloc] initWithContentsOfFile:@"Config/extra_imports.map"];
	}
	
	return [dictExtraImports objectForKey:clazz];
}

+(NSDictionary *)extraMethods:(NSString *)clazz
{
	if(dictExtraMethods == nil)
	{
		dictExtraMethods = [[NSMutableDictionary alloc] initWithContentsOfFile:@"Config/extra_methods.map"];
	}
	
	return [dictExtraMethods objectForKey:clazz];
}

@end
