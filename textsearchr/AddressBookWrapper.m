//
//  AddressBookWrapper.m
//  textsearchr
//
//  Created by Jeroen Arnoldus on 14-01-15.
//  Copyright (c) 2015 Repleo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AddressBookWrapper.h"

@implementation AddressBookWrapper

- (NSString *) anyObjectToString:(id) object {
    if (object != nil && [object isKindOfClass:[NSString class]]) {
      NSString *result = [NSString stringWithFormat:@"%@", object];
      return result;
    } else {
      return @"";
    }
}

@end
