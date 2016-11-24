//
//  CalculateBetCount.h
//  TicketProject
//
//  Created by sls002 on 13-5-22.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//计算注数

#import <Foundation/Foundation.h>

@interface CalculateBetCount : NSObject

//计算排列 A m取n
+ (NSInteger)permutationWithM:(NSInteger)m N:(NSInteger)n;
//计算组合 C m取n
+ (NSInteger)combinationWithM:(NSInteger)m N:(NSInteger)n;

//根据红球 和篮球个数获取注数（ 双色球 (SSQ) 6+1大乐透(DLT)是 5+2）
-(long)getCountForSSQ_DLTWithRed:(NSInteger)redCount Blue:(NSInteger)blueCount RedNum:(NSInteger)redNumber BlueNum:(NSInteger)blueNumber;

-(NSInteger)getBetCountForSSQ_DTWithDan:(NSInteger)danCount Tuo:(NSInteger)tuoCount Blue:(NSInteger)blueCount RedNumber:(NSInteger)redNum BlueNumber:(NSInteger)blueNum;

-(long)getCountForDLT:(NSInteger)danCount Tuo:(NSInteger)tuoCount Blue:(NSInteger)blueCount RedNumber:(NSInteger)redNum BlueNumber:(NSInteger)blueNum;

-(NSString *)changeSSQWithRedArray:(NSArray *)red TuoArray:(NSArray *)tuoArray BlueArray:(NSArray *)blue Type:(NSInteger)type;

-(NSString *)changeDLTWithRedArray:(NSArray *)red TuoArray:(NSArray *)tuoArray BlueArray:(NSArray *)blue Type:(NSInteger)type;

-(NSArray *)convertToStringArrayWith:(NSArray *)ballsArray;

+(NSInteger)getLuckRacingCountWithOneArray:(NSArray *)one TwoArray:(NSArray *)two ThreeArray:(NSArray *)three Type:(NSInteger)type;

+ (NSInteger)calculateZhuShuWithDigit:(NSInteger)digit minNum:(NSInteger)minNum maxNum:(NSInteger)maxNum he:(NSInteger)he sum:(NSInteger)sum;

/** 有胆或者无胆n串m */
+ (NSInteger)getNG1WithN:(NSInteger)n m:(NSInteger)m matchArray:(NSArray *)matchArray danArray:(NSArray *)danArray;

/** 北京单场 */
+ (NSInteger)getBJDCNG1WithN:(NSInteger)n m:(NSInteger)m matchArray:(NSArray *)matchArray danArray:(NSArray *)danArray;

/** 奖金优化获取对阵信息算法(过关) */
+ (NSMutableArray *)getAgainstWithN:(NSInteger)n m:(NSInteger)m selectMatchArray:(NSMutableArray*)selectMatchArray arrayWithResult: (NSMutableArray *) resultArray ballType:(int)ballType;

/** 奖金优化获取对阵信息算法(单关) */
+ (NSMutableArray *)getOneMatchWithArray:(NSMutableArray *)selectMatchArray ballType:(int)ballType;

/**
 *  22选5注数计算
 */
+ (NSInteger)getCountForESEXWWithOneArray:(NSArray *)onearr
                                andPlayID:(NSInteger)playID;
/**
 *  幸运彩注数计算
 */
+ (NSInteger)getCountForXYCWithOneArray:(NSArray *)onearr
                                    two:(NSArray *)twoarr
                                  three:(NSArray *)threearr
                                   four:(NSArray *)fourarr
                                   five:(NSArray *)fivearr
                                    six:(NSArray *)sixarr
                              andPlayID:(NSInteger)playID
                      andPlayMethodName:(NSString *)name
                       andFirstViewName:(NSString *)name1
                      andSecondViewName:(NSString *)name2;
/**
 *  快赢481注数计算
 */
+ (NSInteger)getCountForKY481WithOneArray:(NSArray *)onearr
                                      two:(NSArray *)twoarr
                                    three:(NSArray *)threearr
                                     four:(NSArray *)fourarr
                                     five:(NSArray *)fivearr
                                andPlayID:(NSInteger)playID
                        andPlayMethodName:(NSString *)name;


+ (NSInteger)getOneMatchCountWithArray:(NSArray *)array andPlayID:(NSInteger)playID;

@end
