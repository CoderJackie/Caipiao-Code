//
//  InterfaceHelper.m
//  TicketProject
//
//  Created by sls002 on 13-5-31.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//接口帮助类

#import "InterfaceHelper.h"
#import <CommonCrypto/CommonCrypto.h>
#import "InterfaceHeader.h"
#import "UserInfo.h"
#import "OpenUDID.h"

@implementation InterfaceHelper

//MD5加密
+ (NSString *)MD5:(NSString *)str {
    const char *cStr = [str UTF8String];
    
    unsigned char result[16];
    CC_MD5(cStr,(CC_LONG)strlen(cStr),result);
    
    NSString *md5 = [[NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                    result[0],result[1],result[2],result[3],result[4],result[5],result[6],result[7],
                      result[8],result[9],result[10],result[11],result[12],result[13],result[14],result[15]] copy];
    
    return [md5 autorelease];
}

//修改这里需要的彩种信息就行   如果是新加入的在getLotteryMessageWithLotteryName:messageType:中没有id和图片的彩种信息，需要在该方法中也加入
+ (NSArray *)getDefaultLotteryNameArray {
    
    if ([[MyAppDelegate shareAppDelegate].whichProject isEqualToString:@"竞彩"]) {
        return [NSArray arrayWithObjects:@"竞彩足球",@"竞彩篮球",@"北京单场",@"双色球",@"大乐透",@"3D",@"胜负彩",@"任选九", nil];
    }
    return [NSArray array];
}

+ (NSArray *)getQuickLotteryArray { //高频彩
    if ([[MyAppDelegate shareAppDelegate].whichProject isEqualToString:@"竞彩"]) {
        return nil;//[NSArray arrayWithObjects:@"双色球",@"大乐透",@"3D",@"胜负彩",@"任选九", nil];
    }
    return [NSArray array];
}

+ (NSArray *)getTimeQuickLotteryArray {  //需要时间倒计时的高频彩
    if ([[MyAppDelegate shareAppDelegate].whichProject isEqualToString:@"竞彩"]) {
        return nil;//[NSArray arrayWithObjects:@"双色球",@"大乐透",@"3D",@"胜负彩",@"任选九", nil];
    }
    return [NSArray array];
}

+ (BOOL)isQuickLotteryWithLotteryID:(NSInteger)lotteryID {   //判断是否高频彩
    NSArray *nameArray = [self getQuickLotteryArray];
    NSMutableArray *idArray = [NSMutableArray array];
    [self getLotteryMessageArrayWithLotteryNameArray:nameArray messageType:0 lotteryMessageArray:idArray];
    for (NSString *strLotteryID in idArray) {
        if ([strLotteryID integerValue] == lotteryID) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isTimeQuickLotteryWithLotteryID:(NSInteger)lotteryID {   //判断是否时间倒计时的高频彩
    NSArray *nameArray = [self getTimeQuickLotteryArray];
    NSMutableArray *idArray = [NSMutableArray array];
    [self getLotteryMessageArrayWithLotteryNameArray:nameArray messageType:0 lotteryMessageArray:idArray];
    for (NSString *strLotteryID in idArray) {
        if ([strLotteryID integerValue] == lotteryID) {
            return YES;
        }
    }
    return NO;
}

//获得所有的彩种ID 字符串(除去竞彩)
+ (NSString *)getNotJCLotteryStr:(NSMutableArray *)nameArray {
//    NSArray *nameArray = [self getDefaultLotteryNameArray];
    NSMutableArray *idArray = [NSMutableArray array];
    [self getLotteryMessageArrayWithLotteryNameArray:nameArray messageType:0 lotteryMessageArray:idArray];
    
    NSString *lotteryStr = @"";
    
    for (NSString *str in idArray) {
        lotteryStr = [lotteryStr stringByAppendingFormat:@"%@,",str];
    }
    
    NSRange range = NSMakeRange(0, lotteryStr.length - 1);
    return [lotteryStr substringWithRange:range];
}

//获得所有的彩种ID 字符串
+ (NSString *)getAllLotteryString {
    
    NSArray *nameArray = [self getDefaultLotteryNameArray];
    NSMutableArray *idArray = [NSMutableArray array];
    [self getLotteryMessageArrayWithLotteryNameArray:nameArray messageType:0 lotteryMessageArray:idArray];
    
    NSString *lotteryStr = @"";
    
    for (NSString *str in idArray) {
        lotteryStr = [lotteryStr stringByAppendingFormat:@"%@,",str];
    }
    
    NSRange range = NSMakeRange(0, lotteryStr.length - 1);
    return [lotteryStr substringWithRange:range];
}

//获取各彩种名称、彩种ID和图片的字典
+ (NSDictionary *)getLotteryIDNameDic {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    NSArray *nameArray = nil;
    NSMutableArray *idArray = [NSMutableArray array];
    NSMutableArray *imageArray = [NSMutableArray array];
    
    
    nameArray = [self getDefaultLotteryNameArray];
        
    [self getLotteryMessageArrayWithLotteryNameArray:nameArray messageType:0 lotteryMessageArray:idArray];
        
    [self getLotteryMessageArrayWithLotteryNameArray:nameArray messageType:1 lotteryMessageArray:imageArray];
    
    
    [dic setObject:nameArray forKey:@"name"];
    [dic setObject:idArray forKey:@"id"];
    [dic setObject:imageArray forKey:@"image"];
    
    return dic;
}

+ (NSDictionary *)getWinLotteryIDNameDic {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    NSArray *nameArray = nil;
    NSMutableArray *idArray = [NSMutableArray array];
    
    nameArray = [self getDefaultLotteryNameArray];
        
    [self getLotteryMessageArrayWithLotteryNameArray:nameArray messageType:0 lotteryMessageArray:idArray];
    
    
    [dic setObject:nameArray forKey:@"name"];
    [dic setObject:idArray forKey:@"id"];
    
    return dic;
}

+ (NSDictionary *)getLotteryInfoWithID:(NSString *)_lotteryId{ //根据id号查到到彩种名和图片名
    NSMutableDictionary *dicRoot = [NSMutableDictionary dictionary];
    NSArray *nameArray = [self getDefaultLotteryNameArray];
    
    NSMutableArray *idArray = [NSMutableArray array];
    [self getLotteryMessageArrayWithLotteryNameArray:nameArray messageType:0 lotteryMessageArray:idArray];
    
    NSMutableArray *imageArray = [NSMutableArray array];
    [self getLotteryMessageArrayWithLotteryNameArray:nameArray messageType:1 lotteryMessageArray:imageArray];

    NSInteger count = [idArray count];
    for (int i = 0; i < count; i++) {
        NSString *lotteryId = [idArray objectAtIndex:i];
        NSString *name = [nameArray objectAtIndex:i];
        NSString *image = [imageArray objectAtIndex:i];
        NSDictionary *dicItem = [NSDictionary dictionaryWithObjectsAndKeys:name,@"name",image,@"image", nil];
        [dicRoot setObject:dicItem forKey:lotteryId];
    }
    return [dicRoot objectForKey:_lotteryId];
}

/** 根据一个彩种名获取该彩种的id或图片logo名
 @param lotteryNameArray  彩种名称的数组
 @param messageType  所要返回的类型 0为id 1为logo名
 @param lotteryMessageArray 传入的数组
 */
+ (void)getLotteryMessageArrayWithLotteryNameArray:(NSArray *)lotteryNameArray messageType:(NSInteger)messageType lotteryMessageArray:(NSMutableArray *)lotteryMessageArray {
    for (NSString *lotteryName in lotteryNameArray) {
        NSString *message = [self getLotteryMessageWithLotteryName:lotteryName messageType:messageType];
        [lotteryMessageArray addObject:message];
    }
}

/** 根据一个彩种名获取该彩种的id或图片logo名
 @param lotteryName  彩种名称
 @param messageType  所要返回的类型 0为id 1为logo名
 @return id 或 彩种logo名称
 */
+ (NSString *)getLotteryMessageWithLotteryName:(NSString *)lotteryName messageType:(NSInteger)messageType {
    if ([lotteryName isEqualToString:@"双色球"]) {
        return messageType == 0 ? @"5" : @"logo_ssq.png";
        
    } else if ([lotteryName isEqualToString:@"大乐透"]) {
        return messageType == 0 ? @"39" : @"logo_dlt.png";
        
    } else if ([lotteryName isEqualToString:@"胜负彩"]) {
        return messageType == 0 ? @"74" : @"logo_sfc.png";
        
    } else if ([lotteryName isEqualToString:@"3D"]) {
        return messageType == 0 ? @"6" : @"logo_sd.png";
      
    } else if ([lotteryName isEqualToString:@"任选九"]) {
        return messageType == 0 ? @"75" : @"logo_rxj.png";
        
    } else if ([lotteryName isEqualToString:@"竞彩足球"]) {
        return messageType == 0 ? @"72" : @"logo_jczq.png";
        
    } else if ([lotteryName isEqualToString:@"北京单场"]) {
        return messageType == 0 ? @"45" : @"logo_bjdc.png";
        
    } else if ([lotteryName isEqualToString:@"竞彩篮球"]) {
        return messageType == 0 ? @"73" : @"logo_jclq.png";

    }
    return @"";
}




//获取当前时间字符串
+ (NSString *)getCurrentDateString {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc]init] autorelease];
    [dateFormatter setDateFormat:@"yyyyMMddhhmmss"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

/** 得到 特定 key --- Crc */
//Crc验证的字符串
//imei 手机客户端的唯一标识
//time 时间戳格式yyyyMMddhhmmss
//key  软件身份key
//uid  用户ID
+(NSString *)getCrcWithInfo:(NSString *)info UID:(NSString *)uid TimeStamp:(NSString *)timeStamp {//未登陆情况下  uid为-1
    
    // crc = MD5(auth.time_stamp + auth.imei + auth.uid +MD5（password+key）+ Info, "utf-8")
    
    NSString *imei = [OpenUDID value];
    if (info == nil) {
        info = @"";
    }

    NSString *key = [InterfaceHelper MD5:kAppKey];
    
    NSString *str = [NSString stringWithFormat:@"%@%@%@%@%@",timeStamp,imei,uid,key,info];
    return [InterfaceHelper MD5:str];
}

+ (NSString *)getAuthStrWithCrc:(NSString *)crc UID:(NSString *)uid TimeStamp:(NSString *)timeStamp {
    NSString *imei = [OpenUDID value];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"1" forKey:kLoginType];
    [dic setObject:kAppKey forKey:kApp_Key];
    [dic setObject:imei forKey:kImei];
    [dic setObject:[UIDevice currentDevice].systemName forKey:kOS];
    [dic setObject:[UIDevice currentDevice].systemVersion forKey:kOS_Version];
    [dic setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey] forKey:kApp_Version];
    [dic setObject:@"Yek_test" forKey:kSource_id];
    [dic setObject:@"0.9" forKey:kVer];
    [dic setObject:uid forKey:kUid];
    [dic setObject:crc forKey:kCrc];
    [dic setObject:timeStamp forKey:kTime_stamp];
    
    return [dic JSONString];
}

//将字符串用指定字符 隐藏起来
+ (NSString *)replaceString:(NSString *)str InRange:(NSRange)range WithCharacter:(NSString *)character {
    NSString *firstStr = [str substringToIndex:range.location];
    NSString *secondStr = [str substringFromIndex:range.location + range.length];
    NSString *replacedStr = [NSString string];
    for (int i = 0; i < range.length; i++) {
        replacedStr = [replacedStr stringByAppendingString:character];
    }
    
    return [NSString stringWithFormat:@"%@%@%@",firstStr,replacedStr,secondStr];
}

@end
