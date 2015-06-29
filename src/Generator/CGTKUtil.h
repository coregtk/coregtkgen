/*
 * CGTKUtil.h
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

/**
 * Provides useful utility functions for CoreGTKGen
 */
@interface CGTKUtil : NSObject
{

}

/**
 * Returns the underscore_separated_string in camelCase 
 */
+(NSString *)convertUSSToCamelCase:(NSString *)input;

/**
 * Returns the underscore_separated_string in CapitalCase
 */
+(NSString *)convertUSSToCapCase:(NSString *)input;

/**
 * Returns YES if this type is configured as being swappable
 */
+(BOOL)isTypeSwappable:(NSString *) str;

/**
 * Attempts to swap the type or returns the input if it can't
 */
+(NSString *)swapTypes:(NSString *) str;

/**
 * Converts GTK style type_new_with_param style functions into CoreGTK initWithParam inits. If func doesn't contain "New" or "new" then it will return nil.
 */
+(NSString *)convertFunctionToInit:(NSString *)func;

/**
 * Returns a super constructor call for the given type. While it takes a cType it currently assumes everything is a GObject (FOR FUTURE USE).
 */
+(NSString *)getFunctionCallForConstructorOfType:(NSString *) cType withConstructor:(NSString *) cCtor;

/**
 * Converts the given fromType to the toType while maintaining the name
 */
+(NSString *)convertType:(NSString *) fromType withName:(NSString *)name toType:(NSString *) toType;

/**
 * Returns the appropriate self referencing call for the type (i.e. -(type)[self TYPE] or GTK_TYPE([self GOBJECT])
 */
+(NSString *)selfTypeMethodCall:(NSString *) type;

/**
 * Adds the prefix to the trimmed method name list
 */
+(void)addToTrimMethodName:(NSString *)val;

/**
 * Trims method name (i.e. removes things like GTK_)
 */
+(NSString *)trimMethodName:(NSString *)meth;

/**
 * Gets a list of extra imports for the class
 */
+(NSArray *)extraImports:(NSString *)clazz;

/**
 * Returns the configuration value for the provided key
 */
+(id)globalConfigValueFor:(NSString *)key;

@end
