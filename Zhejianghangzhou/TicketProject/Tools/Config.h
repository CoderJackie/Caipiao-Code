//
//  Header.h
//  TicketProject
//
//  Created by md005 on 13-9-2.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#ifndef TicketProject_Header_h
#define TicketProject_Header_h

#define SafeClearRequest(request)\
if(request!=nil)\
{\
[request clearDelegatesAndCancel];\
[request release];\
request=nil;\
}\

#define SafeRelease(obj)\
if(obj)\
{\
[obj release];\
obj = nil;\
}\

typedef enum
{
    Red,
    Blue
}BallsType;

#endif
