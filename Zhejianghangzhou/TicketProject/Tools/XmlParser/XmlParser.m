//
//  XmlParser.m
//  TicketProject
//
//  Created by sls002 on 13-6-19.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//XML解析

#import "XmlParser.h"

@implementation XmlParser

//获取银行名称
- (NSDictionary *)getBankNameDictionary {
    bankNameDic = [[NSMutableDictionary alloc]init];
    
    NSXMLParser *xmlParser = [[NSXMLParser alloc]initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bank" ofType:@"xml"]]];
    xmlParser.delegate = self;
    [xmlParser parse];
    [xmlParser release];

    return bankNameDic;
}

//获取省份名称
- (NSDictionary *)getProvinceNameDictionary {
    provinceNameDic = [[NSMutableDictionary alloc]init];
    
    NSXMLParser *xmlParser = [[NSXMLParser alloc]initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"province" ofType:@"xml"]]];
    xmlParser.delegate = self;
    
    [xmlParser parse];
    [xmlParser release];
    return provinceNameDic;
}

//获取城市名称
- (NSDictionary *)getCityNameDictionary {
    cityNameDic = [[NSMutableDictionary alloc]init];
    provinceNameDic = nil; // 取城市的时候把省份置空，否则省份也会增加
    cityArray = [[NSMutableArray alloc]init]; //在同一省份下的 城市 数组
    
    NSXMLParser *xmlParser = [[NSXMLParser alloc]initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"city" ofType:@"xml"]]];
    xmlParser.delegate = self;
    
    [xmlParser parse];
    [xmlParser release];
    
    return cityNameDic;
}

- (NSMutableDictionary *)getQuestionDictionary {
    if (!_questionDict) {
        _questionDict = [[NSMutableDictionary alloc] init];
    }
    
    NSXMLParser *xmlParser = [[NSXMLParser alloc]initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"question" ofType:@"xml"]]];
    [xmlParser setDelegate:self];
    [xmlParser parse];
    
    return _questionDict;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"question"]) {//安全问题
        if ([attributeDict count] > 0) {
            NSString *key = [attributeDict objectForKey:@"id"];
            NSString *value = [attributeDict objectForKey:@"question"];
            [_questionDict setObject:value forKey:key];
        }
    }
    
    if(bankNameDic) {
        if([elementName isEqualToString:@"row"]) {
            if(attributeDict) {
                NSString *key = [NSString stringWithFormat:@"%lu",(unsigned long)bankNameDic.count];
                [bankNameDic setObject:attributeDict forKey:key];
            }
        }
    }
    
    if(provinceNameDic) {
        if([elementName isEqualToString:@"row"]) {
            if(attributeDict) {
                NSString *key = [NSString stringWithFormat:@"%lu",(unsigned long)provinceNameDic.count];
                [provinceNameDic setObject:attributeDict forKey:key];
            }
        }
    }
    
    if(cityNameDic) {
        if([elementName isEqualToString:@"row"]) {
            if(attributeDict) {
                NSInteger currentProvinceID = [[attributeDict objectForKey:@"provinceid"] intValue];
                //判断上一个row的省份ID 是否 和当前row的省份id一样
                //如果一样 则表示 这两个城市是同一个省份的
                //如果不一样 表示 这两个城市是不同省份的
                if([cityNameDic objectForKey:[NSString stringWithFormat:@"%ld",(long)currentProvinceID]]) {
                    cityArray = [cityNameDic objectForKey:[NSString stringWithFormat:@"%ld",(long)currentProvinceID]];
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    [dic setObject:[attributeDict objectForKey:@"id"] forKey:@"cityId"];
                    [dic setObject:[attributeDict objectForKey:@"cityname"] forKey:@"cityName"];
                    [cityArray addObject:dic];
                    NSArray *array = [cityArray mutableCopy];
                    [cityNameDic setObject:array forKey:[NSString stringWithFormat:@"%ld",(long)currentProvinceID]];
                    [array release];
                } else {
                    NSMutableArray *array = [NSMutableArray array];
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    [dic setObject:[attributeDict objectForKey:@"id"] forKey:@"cityId"];
                    [dic setObject:[attributeDict objectForKey:@"cityname"] forKey:@"cityName"];
                    [array addObject:dic];
                    [cityNameDic setObject:array forKey:[NSString stringWithFormat:@"%ld",(long)currentProvinceID]];
                }
            }
        }
    }
}

- (void)dealloc {
    [bankNameDic release];
    [provinceNameDic release];
    [cityNameDic release];
    [_questionDict release];
    _questionDict = nil;
    
    [super dealloc];
}

@end
