//
//  Service.m
//  TicketProject
//
//  Created by sls002 on 13-8-16.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import "Service.h"

static Service *_Service = nil;

@implementation Service
+ (Service *)getDefaultService {
	@synchronized(self){
		if (_Service == nil) {
			_Service = [[self alloc] init];
		}
	}
	return _Service;
}



@end
