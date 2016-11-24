//
//  XmlParser.h
//  TicketProject
//
//  Created by sls002 on 13-6-19.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XmlParser : NSObject<NSXMLParserDelegate> {
    NSMutableDictionary *bankNameDic;
    NSMutableDictionary *provinceNameDic;
    NSMutableDictionary *cityNameDic;
    NSMutableDictionary *_questionDict;
    
    NSMutableArray *cityArray;//属于一个省份的城市 数组
}

- (NSDictionary *)getBankNameDictionary;

- (NSDictionary *)getProvinceNameDictionary;

- (NSDictionary *)getCityNameDictionary;

- (NSMutableDictionary *)getQuestionDictionary;

@end
