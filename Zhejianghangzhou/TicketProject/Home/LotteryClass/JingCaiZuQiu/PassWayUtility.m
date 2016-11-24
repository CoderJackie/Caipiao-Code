//
//  PassWayUtility.m
//  TicketProject
//
//  Created by sls002 on 13-7-2.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import "PassWayUtility.h"

@implementation PassWayUtility

//获取自由过关
+ (NSArray *)getFreePassItemsWithMatchCount:(NSInteger)count {
    if (count>8) {
        count=8;
    }
    
    NSMutableArray *freePassArray = [NSMutableArray array];
    for (int i = 2; i <= count; i++) {
        NSString *str = [NSString stringWithFormat:@"%d串1",i];
        [freePassArray addObject:str];
    }
    return freePassArray;
}

//获取多串过关
+ (NSArray *)getMixPassItemsWithMatchCount:(NSInteger)count {
    NSMutableArray *mixPassArray = [NSMutableArray array];
    
    for (int i = 3; i <= count; i++) {
        switch (i) {
            case 3:
                [mixPassArray addObject:@"3串3"];
                [mixPassArray addObject:@"3串4"];
                break;
            case 4:
                [mixPassArray addObject:@"4串4"];
                [mixPassArray addObject:@"4串5"];
                [mixPassArray addObject:@"4串6"];
                [mixPassArray addObject:@"4串11"];
                break;
            case 5:
                [mixPassArray addObject:@"5串5"];
                [mixPassArray addObject:@"5串6"];
                [mixPassArray addObject:@"5串10"];
                [mixPassArray addObject:@"5串16"];
                [mixPassArray addObject:@"5串20"];
                [mixPassArray addObject:@"5串26"];
                break;
            case 6:
                [mixPassArray addObject:@"6串6"];
                [mixPassArray addObject:@"6串7"];
                [mixPassArray addObject:@"6串15"];
                [mixPassArray addObject:@"6串20"];
                [mixPassArray addObject:@"6串22"];
                [mixPassArray addObject:@"6串35"];
                [mixPassArray addObject:@"6串42"];
                [mixPassArray addObject:@"6串50"];
                [mixPassArray addObject:@"6串57"];
                break;
            case 7:
                [mixPassArray addObject:@"7串7"];
                [mixPassArray addObject:@"7串8"];
                [mixPassArray addObject:@"7串21"];
                [mixPassArray addObject:@"7串35"];
                [mixPassArray addObject:@"7串120"];
                break;
            case 8:
                [mixPassArray addObject:@"8串8"];
                [mixPassArray addObject:@"8串9"];
                [mixPassArray addObject:@"8串28"];
                [mixPassArray addObject:@"8串56"];
                [mixPassArray addObject:@"8串70"];
                [mixPassArray addObject:@"8串247"];
                break;
            default:
                break;
        }
    }
    return mixPassArray;
}

+ (NSArray *)getFreePassItemsWithMatchCount:(NSInteger)count danCount:(NSInteger)danCount playID:(NSInteger)playID playType:(NSInteger)playType {
    if (playType == 4501 || playType == 4506) {
        if (count > 15) {
            count = 15;
        }
    } else if (playType == 4502 || playType == 4503 || playType == 4505) {
        if (count > 6) {
            count = 6;
        }
    } else if (playType == 4504) {
        if (count > 3) {
            count = 3;
        }
    } else if (playID != 45) {
        if (count > 8) {
            count = 8;
        }
    }
    
    NSInteger begin = danCount+1;
    
    NSMutableArray *freePassArray = [NSMutableArray array];
    
    if (playType != 4506) {
        if (begin < 2) {
            [freePassArray addObject:@"单关"];
        }
        
        if (begin<2) {
            begin=2;
        }
        for (NSInteger i = begin; i <= count; i++) {
            NSString *str = [NSString stringWithFormat:@"%ld串1",(long)i];
            [freePassArray addObject:str];
        }
    } else {
        
        if (begin<2) {
            begin=2;
        }
        for (NSInteger i = begin + 1; i < count + 1; i++) {
            NSString *str = [NSString stringWithFormat:@"%ld串1",(long)i];
            [freePassArray addObject:str];
        }
    }
    
    return freePassArray;
}

+ (NSArray *)getFreePassItemsWithMatchCount:(NSInteger)count danCount:(NSInteger)danCount {
    if (count>8) {
        count=8;
    }
    
    NSInteger begin = danCount + 1;
    if (begin<2) {
        begin=2;
    }
    
    NSMutableArray *freePassArray = [NSMutableArray array];
    for (NSInteger i = begin; i <= count; i++) {
        NSString *str = [NSString stringWithFormat:@"%ld串1",(long)i];
        [freePassArray addObject:str];
    }
    return freePassArray;
}

+ (NSArray *)getMixPassItemsWithMatchCount:(NSInteger)count danCount:(NSInteger)danCount {
    NSMutableArray *mixPassArray = [NSMutableArray array];
    NSInteger begin = danCount + 1;
    if (begin < 3) {
        begin = 3;
    }
    for (NSInteger i = begin; i <= count; i++) {
        switch (i) {
            case 3:
                [mixPassArray addObject:@"3串3"];
                [mixPassArray addObject:@"3串4"];
                break;
            case 4:
                [mixPassArray addObject:@"4串4"];
                [mixPassArray addObject:@"4串5"];
                [mixPassArray addObject:@"4串6"];
                [mixPassArray addObject:@"4串11"];
                break;
            case 5:
                [mixPassArray addObject:@"5串5"];
                [mixPassArray addObject:@"5串6"];
                [mixPassArray addObject:@"5串10"];
                [mixPassArray addObject:@"5串16"];
                [mixPassArray addObject:@"5串20"];
                [mixPassArray addObject:@"5串26"];
                break;
            case 6:
                [mixPassArray addObject:@"6串6"];
                [mixPassArray addObject:@"6串7"];
                [mixPassArray addObject:@"6串15"];
                [mixPassArray addObject:@"6串20"];
                [mixPassArray addObject:@"6串22"];
                [mixPassArray addObject:@"6串35"];
                [mixPassArray addObject:@"6串42"];
                [mixPassArray addObject:@"6串50"];
                [mixPassArray addObject:@"6串57"];
                break;
            case 7:
                [mixPassArray addObject:@"7串7"];
                [mixPassArray addObject:@"7串8"];
                [mixPassArray addObject:@"7串21"];
                [mixPassArray addObject:@"7串35"];
                [mixPassArray addObject:@"7串120"];
                break;
            case 8:
                [mixPassArray addObject:@"8串8"];
                [mixPassArray addObject:@"8串9"];
                [mixPassArray addObject:@"8串28"];
                [mixPassArray addObject:@"8串56"];
                [mixPassArray addObject:@"8串70"];
                [mixPassArray addObject:@"8串247"];
                break;
            default:
                break;
        }
    }
    return mixPassArray;
}

+(NSArray *)getMixPassItemsWithMatchCount:(NSInteger)count danCount:(NSInteger)danCount playType:(NSInteger)playType {
    NSMutableArray *mixPassArray = [NSMutableArray array];
    NSInteger begin = danCount + 1;
    if (begin < 3) {
        begin = 2;
    }
    for (NSInteger i = begin; i <= count; i++) {
        switch (i) {
            case 2:
                [mixPassArray addObject:@"2串3"];
                break;
            case 3:
                [mixPassArray addObject:@"3串4"];
                [mixPassArray addObject:@"3串7"];
                break;
            case 4:
                [mixPassArray addObject:@"4串5"];
                [mixPassArray addObject:@"4串11"];
                [mixPassArray addObject:@"4串15"];
                break;
            case 5:
                [mixPassArray addObject:@"5串6"];
                [mixPassArray addObject:@"5串16"];
                [mixPassArray addObject:@"5串26"];
                [mixPassArray addObject:@"5串31"];
                break;
            case 6:
                [mixPassArray addObject:@"6串7"];
                [mixPassArray addObject:@"6串22"];
                [mixPassArray addObject:@"6串42"];
                [mixPassArray addObject:@"6串57"];
                [mixPassArray addObject:@"6串63"];
                break;
            default:
                break;
        }
    }
    return mixPassArray;
}

//过关方式的代号
+ (NSString *)getPassWayCodeWithString:(NSString *)string {
    NSString *result = [NSString string];
    if([string isEqualToString:@"单关"]) {
        result = @"A0";
    } else if ([string isEqualToString:@"2串1"]) {
        result = @"AA";
    } else if ([string isEqualToString:@"3串1"]) {
        result = @"AB";
    } else if ([string isEqualToString:@"3串3"]) {
        result = @"AC";
    } else if ([string isEqualToString:@"3串4"]) {
        result = @"AD";
    } else if ([string isEqualToString:@"4串1"]) {
        result = @"AE";
    } else if ([string isEqualToString:@"4串4"]) {
        result = @"AF";
    } else if ([string isEqualToString:@"4串5"]) {
        result = @"AG";
    } else if ([string isEqualToString:@"4串6"]) {
        result = @"AH";
    } else if ([string isEqualToString:@"4串11"]) {
        result = @"AI";
    } else if ([string isEqualToString:@"5串1"]) {
        result = @"AJ";
    } else if ([string isEqualToString:@"5串5"]) {
        result = @"AK";
    } else if ([string isEqualToString:@"5串6"]) {
        result = @"AL";
    } else if ([string isEqualToString:@"5串10"]) {
        result = @"AM";
    } else if ([string isEqualToString:@"5串16"]) {
        result = @"AN";
    } else if ([string isEqualToString:@"5串20"]) {
        result = @"AO";
    } else if ([string isEqualToString:@"5串26"]) {
        result = @"AP";
    } else if ([string isEqualToString:@"6串1"]) {
        result = @"AQ";
    } else if ([string isEqualToString:@"6串6"]) {
        result = @"AR";
    } else if ([string isEqualToString:@"6串7"]) {
        result = @"AS";
    } else if ([string isEqualToString:@"6串15"]) {
        result = @"AT";
    } else if ([string isEqualToString:@"6串20"]) {
        result = @"AU";
    } else if ([string isEqualToString:@"6串22"]) {
        result = @"AV";
    } else if ([string isEqualToString:@"6串35"]) {
        result = @"AW";
    } else if ([string isEqualToString:@"6串42"]) {
        result = @"AX";
    } else if ([string isEqualToString:@"6串50"]) {
        result = @"AY";
    } else if ([string isEqualToString:@"6串57"]) {
        result = @"AZ";
    } else if ([string isEqualToString:@"7串1"]) {
        result = @"BA";
    } else if ([string isEqualToString:@"7串7"]) {
        result = @"BB";
    } else if ([string isEqualToString:@"7串8"]) {
        result = @"BC";
    } else if ([string isEqualToString:@"7串21"]) {
        result = @"BD";
    } else if ([string isEqualToString:@"7串35"]) {
        result = @"BE";
    } else if ([string isEqualToString:@"7串120"]) {
        result = @"BF";
    } else if ([string isEqualToString:@"8串1"]) {
        result = @"BG";
    } else if ([string isEqualToString:@"8串8"]) {
        result = @"BH";
    } else if ([string isEqualToString:@"8串9"]) {
        result = @"BI";
    } else if ([string isEqualToString:@"8串28"]) {
        result = @"BJ";
    } else if ([string isEqualToString:@"8串56"]) {
        result = @"BK";
    } else if ([string isEqualToString:@"8串70"]) {
        result = @"BL";
    } else if ([string isEqualToString:@"8串247"]) {
        result = @"BM";
    } else if ([string isEqualToString:@"单关"]) {
        result = @"A0";
    }
    
    return result;
}

+(NSString *)getPassWayBJDCCodeWithString:(NSString *)string {
    NSString *result = [NSString string];
    if([string isEqualToString:@"单关"]) {
        result = @"A0";
    } else if ([string isEqualToString:@"2串1"]) {
        result = @"AA";
    } else if ([string isEqualToString:@"2串3"]) {
        result = @"AB";
    } else if ([string isEqualToString:@"3串1"]) {
        result = @"AC";
    } else if ([string isEqualToString:@"3串4"]) {
        result = @"AD";
    } else if ([string isEqualToString:@"3串7"]) {
        result = @"AE";
    } else if ([string isEqualToString:@"4串1"]) {
        result = @"AF";
    } else if ([string isEqualToString:@"4串5"]) {
        result = @"AG";
    } else if ([string isEqualToString:@"4串11"]) {
        result = @"AH";
    } else if ([string isEqualToString:@"4串15"]) {
        result = @"AI";
    } else if ([string isEqualToString:@"5串1"]) {
        result = @"AJ";
    } else if ([string isEqualToString:@"5串6"]) {
        result = @"AK";
    } else if ([string isEqualToString:@"5串16"]) {
        result = @"AL";
    } else if ([string isEqualToString:@"5串26"]) {
        result = @"AM";
    } else if ([string isEqualToString:@"5串31"]) {
        result = @"AN";
    } else if ([string isEqualToString:@"6串1"]) {
        result = @"AO";
    } else if ([string isEqualToString:@"6串7"]) {
        result = @"AP";
    } else if ([string isEqualToString:@"6串22"]) {
        result = @"AQ";
    } else if ([string isEqualToString:@"6串42"]) {
        result = @"AR";
    } else if ([string isEqualToString:@"6串57"]) {
        result = @"AS";
    } else if ([string isEqualToString:@"6串63"]) {
        result = @"AT";
    } else if ([string isEqualToString:@"7串1"]) {
        result = @"AU";
    } else if ([string isEqualToString:@"8串1"]) {
        result = @"AV";
    } else if ([string isEqualToString:@"9串1"]) {
        result = @"AW";
    } else if ([string isEqualToString:@"10串1"]) {
        result = @"AX";
    } else if ([string isEqualToString:@"11串1"]) {
        result = @"AY";
    } else if ([string isEqualToString:@"12串1"]) {
        result = @"AZ";
    } else if ([string isEqualToString:@"13串1"]) {
        result = @"BA";
    } else if ([string isEqualToString:@"14串1"]) {
        result = @"BB";
    } else if ([string isEqualToString:@"15串1"]) {
        result = @"BC";
    }
    
    return result;
}

@end
