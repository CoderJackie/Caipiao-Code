
//
//  CustomParserNumber.h
//  TicketProject
//
//  Created by KAI on 14-10-16.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

#define redTextColor @"e3393c"
#define blueTextColor @"2f85e6"
#define grayTextColor @"999999"

typedef enum {
    EnterTypeNO,
    EnterTypeLeft,
    EnterTypeBothSides,
    EnterTypeRight,
} EnterType ;

typedef enum {
    BallNumArrayKeyTypeOfName,
    BallNumArrayKeyTypeOfNum,
} BallNumArrayKeyType;


@interface CustomParserNumber : NSObject



+ (BOOL)isNumText:(NSString *)str;

+ (NSString *)numberBallViewName:(NSInteger)num;

+ (BOOL)splitBallViewNumber_1_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString;

+ (BOOL)splitBallViewNumber_2_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString;

+ (BOOL)splitBallViewNumber_3_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString;

+ (BOOL)splitBallViewNumber_4_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString;
+ (BOOL)splitBallViewNumber_44_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString;

+ (BOOL)splitBallViewNumber_5_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString ballNumArrayKeyNameType:(BallNumArrayKeyType)ballNumArrayKeyNameType deleteLine:(BOOL)deleteLine;

+ (BOOL)splitBallViewNumber_6_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString playTypeName:(NSString *)playTypeName;

+ (BOOL)splitBallViewNumber_7_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString;

+ (BOOL)splitBallViewNumber_8_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString;

+ (BOOL)splitBallViewNumber_9_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString;

+ (BOOL)splitBallViewNumber_10_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString;
+ (BOOL)splitBallViewNumber_101_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString;

+ (BOOL)splitBallViewNumber_11_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString;

+ (BOOL)splitBallViewNumber_12_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString;

+ (void)parserWinNumer_1:(NSString *)winNumber lotteryID:(NSInteger)lotteryID winParserDict:(NSMutableDictionary *)winParserDict;

+ (void)parserWinNumer_2:(NSString *)winNumber lotteryID:(NSInteger)lotteryID winParserDict:(NSMutableDictionary *)winParserDict;

+ (void)parserWinNumer_3:(NSString *)winNumber lotteryID:(NSInteger)lotteryID winParserDict:(NSMutableDictionary *)winParserDict;

+ (NSString *)comparisonWinArray:(NSArray *)winArray
                     selectArray:(NSArray *)selectArray
                       textColor:(NSString *)textColor
                   enterCharType:(EnterType)enterCharType
                       enterChar:(NSString *)enterChar
                     spaceString:(NSString *)spaceString
                 singleIsAddChar:(BOOL)singleIsAddChar
                      numHasZero:(BOOL)numHasZero
                      isLastPart:(BOOL)isLastPart;

+ (NSString *)comparisonWinArray_2:(NSArray *)winArray
                       selectArray:(NSArray *)selectArray
                         textColor:(NSString *)textColor;

+ (NSString *)comparisonWinArray_3:(NSArray *)winArray
                       selectArray:(NSArray *)selectArray
                         textColor:(NSString *)textColor;

+ (NSString *)comparisonWinArray_4:(NSArray *)winArray
                       selectArray:(NSArray *)selectArray
                         textColor:(NSString *)textColor;

+ (NSString *)comparisonWinArray_5:(NSArray *)winArray
                       selectArray:(NSArray *)selectArray
                         textColor:(NSString *)textColor
                       spaceString:(NSString *)spaceString;

+ (NSString *)comparisonWinArray_6:(NSArray *)winArray
                       selectArray:(NSArray *)selectArray
                         textColor:(NSString *)textColor
                       spaceString:(NSString *)spaceString;

+ (NSString *)comparisonWinArray_7:(NSArray *)winArray
                        selectDict:(NSDictionary *)selectDict
                         textColor:(NSString *)textColor
                     enterCharType:(EnterType)enterCharType
                         enterChar:(NSString *)enterChar;

+ (NSString *)comparisonWinArray_8:(NSArray *)winArray
                       selectArray:(NSArray *)selectArray
                         textColor:(NSString *)textColor;

+ (NSString *)comparisonWinArray_9:(NSArray *)winArray
                        selectDict:(NSDictionary *)selectDict
                         textColor:(NSString *)textColor
                    winNumberCount:(NSInteger)winNumberCount;

+ (NSString *)comparisonWinArray_10:(NSArray *)winArray
                        selectArray:(NSArray *)selectArray
                          textColor:(NSString *)textColor;

+ (NSString *)comparisonWinArray_11:(NSArray *)winArray
                        selectArray:(NSArray *)selectArray
                          textColor:(NSString *)textColor;

+ (NSString *)comparisonWinArray_12:(NSArray *)winArray
                        selectArray:(NSArray *)selectArray
                          textColor:(NSString *)textColor
                               text:(NSString *)text;

+ (NSString *)comparisonWinArray_13:(NSArray *)winArray
                        selectArray:(NSArray *)selectArray
                          textColor:(NSString *)textColor
                               text:(NSString *)text
                           sortType:(NSInteger)sortType;

+ (NSString *)comparisonWinArray_14:(NSArray *)winArray
                        selectArray:(NSArray *)selectArray
                          textColor:(NSString *)textColor
                        spaceString:(NSString *)spaceString;

+ (NSString *)comparisonWinArray_15:(NSArray *)winArray
                        selectArray:(NSArray *)selectArray
                          textColor:(NSString *)textColor
                        spaceString:(NSString *)spaceString
                          enterChar:(NSString *)enterChar;

+ (NSString *)comparisonWinRedArray_16:(NSArray *)winRedArray
                          winBlueArray:(NSArray *)winBlueArray
                           selectArray:(NSArray *)selectArray
                          textRedColor:(NSString *)textRedColor
                         textBlueColor:(NSString *)textBlueColor
                         enterCharType:(EnterType)enterCharType
                             enterChar:(NSString *)enterChar
                           spaceString:(NSString *)spaceString
                       singleIsAddChar:(BOOL)singleIsAddChar
                            numHasZero:(BOOL)numHasZero
                            isLastPart:(BOOL)isLastPart;

+ (NSString *)comparisonWinArray_17:(NSArray *)winArray
                        selectArray:(NSArray *)selectArray
                          textColor:(NSString *)textColor
                        spaceString:(NSString *)spaceString
                      enterCharType:(EnterType)enterCharType
                          enterChar:(NSString *)enterChar;

+ (NSString *)comparisonWinArray_18:(NSArray *)winArray
                        minFirstNum:(NSInteger)minFirstNum
                         minLastNum:(NSInteger)minLastLastNum
                            minText:(NSString *)minText
                        maxFirstNum:(NSInteger)maxFirstNum
                         maxLastNum:(NSInteger)maxLastLastNum
                            maxText:(NSString *)maxText
                        selectArray:(NSArray *)selectArray
                          textColor:(NSString *)textColor;

+ (NSMutableArray *)takeAllNumberInOneArrayWithDict:(NSDictionary *)dict count:(NSInteger)count;

+ (NSMutableArray *)takeAllLastNumberInOneArrayWithDict:(NSDictionary *)dict count:(NSInteger)count;

+ (NSMutableArray *)statisticsNumCountWithWinArray:(NSArray *)winArray occurrencesCount:(NSInteger)occurrencesCount;

+ (NSString *)joinLeftText:(NSString *)leftText
                 rightText:(NSString *)rightText
                  winArray:(NSArray *)winArray
                spaceColor:(NSString *)spaceColor
               spaceString:(NSString *)spaceString;

+ (NSString *)joinText:(NSString *)text
              winArray:(NSArray *)winArray
        enterCharColor:(NSString *)enterCharColor
             enterChar:(NSString *)enterChar
         enterCharType:(EnterType)enterCharType;

@end
