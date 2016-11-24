//
//  CalculateBetCount.m
//  TicketProject
//
//  Created by sls002 on 13-5-22.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import "CalculateBetCount.h"

#import "Globals.h"

@implementation CalculateBetCount

//计算排列 A m取n
+ (NSInteger)permutationWithM:(NSInteger)m N:(NSInteger)n {
    if (m < n) {
        return 0;
    }
    NSInteger count = 1;
    for (NSInteger i = 0; i < n; i++) {
        count *= m - i;
    }
    return count;
}

//计算组合 C m取n
+ (NSInteger)combinationWithM:(NSInteger)m N:(NSInteger)n {
    if (m < n) {
        return 0;
    }
    NSInteger count = 1;
    if (m / 2 < n) {
        n = m - n;
    }
    for (NSInteger i = 0; i < n; i ++) {
        count *= (m - i);
        count /= (i + 1);
    }
    return count;
}

/* 根据红球 和篮球个数获取注数（ 双色球 (SSQ) 6+1大乐透(DLT)是 5+2）
    RedCount    所选的红球个数
    BlueCount   所选的蓝球个数
    RedNumber   标准的红球个数
    BlueNumber  标准的蓝球个数
*/
-(long)getCountForSSQ_DLTWithRed:(NSInteger)redCount Blue:(NSInteger)blueCount RedNum:(NSInteger)redNumber BlueNum:(NSInteger)blueNumber
{
    // 如果没有选满数字 则返回 0
    if ((redCount < redNumber) || (blueCount < blueNumber)) {
        return 0;
    }
    // 如果选择的红球和篮球 数量 等于 应该选的数量
    else if (redCount == redNumber && blueCount == blueNumber) {
        return 1;
    }
    else
    {
        // 红球的排列总数 变量 (所选的红球的个数的排列组合的种类)
        long RedInvestNum = 1;
        
        for (int i = 0; i < redNumber; i++) {
            RedInvestNum = RedInvestNum * redCount;
            redCount--;
        }
        
        // 默认的6个红球的排列组合种类
        long temp = 1;
        for (NSInteger i = redNumber; i > 0; i--) {
            temp *= i;
        }
        RedInvestNum = RedInvestNum / temp;
        
        // 蓝球的排列总数 变量
        long BlueInvestNum = 1;
        // 如果篮球应该选的数量大于1 （也就是大乐透 5+2 形式的）
        if (blueNumber > 1) {
            if (blueCount > 2) {
                for (int i = 3; i <= blueCount; i++)
                    BlueInvestNum *= i;
                for (int i = 2; i <= (blueCount - 2); i++)
                    BlueInvestNum = round(BlueInvestNum / i);
            }
            // 如果篮球应该选的数量==1 （也就是双色球 6+1 形式的）
        } else {
            BlueInvestNum = blueCount;
        }
        
        return (RedInvestNum * BlueInvestNum);
    }
}


//双色球,大乐透胆拖注数算法(胆拖投注)
//danCount  胆球个数
//tuoCount  拖球个数
//blueCount 蓝球个数
//redNum    标准红球红球个数   双色球6个  大乐透5个
//blueNum   标准红球蓝球个数   双色球1个  大乐透2个
-(NSInteger)getBetCountForSSQ_DTWithDan:(NSInteger)danCount Tuo:(NSInteger)tuoCount Blue:(NSInteger)blueCount RedNumber:(NSInteger)redNum BlueNumber:(NSInteger)blueNum
{
    // 不满足基本条件
    if (danCount < 1 || tuoCount < 1)
        return 0;
    if (danCount + tuoCount < redNum || blueCount < blueNum) 
        return 0;
    
    return [CalculateBetCount combinationWithM:tuoCount N:redNum - danCount] * [CalculateBetCount combinationWithM:blueCount N:blueNum];
}

//大乐透算法
-(long)getCountForDLT:(NSInteger)danCount Tuo:(NSInteger)tuoCount Blue:(NSInteger)blueCount RedNumber:(NSInteger)redNum BlueNumber:(NSInteger)blueNum
{
    
    if(danCount+tuoCount<5 || danCount<1 || tuoCount<1 || blueNum < 2){
        return 0;
    }
    
    int RedInvestNum = 1;
    for (int i = 1; i <= (redNum - danCount); i++) {
        RedInvestNum *= tuoCount;
        tuoCount --;
    }
    
    int RedInvestNum2 = 1;
    for (int i = 2; i <= (redNum - danCount); i++) {
        RedInvestNum2 *= i;
    }
    
    RedInvestNum = RedInvestNum / RedInvestNum2;
    
    int BlueInvestNum = 1;
    for (int i = 1; i < blueNum+1; i++) {
        BlueInvestNum *= blueCount;
        blueCount--;
    }
    
    int BlueInvestNum2 = 2;
    for (int i = 1; i < blueNum+1; i++) {
        BlueInvestNum2 *= i;
    }
    BlueInvestNum = BlueInvestNum / BlueInvestNum2;
    
    return RedInvestNum * BlueInvestNum;
}

//格式化 双色球
-(NSString *)changeSSQWithRedArray:(NSArray *)red TuoArray:(NSArray *)tuoArray BlueArray:(NSArray *)blue Type:(NSInteger)type
{
    NSString *num = [NSString string];
    NSString *tuoNum = [NSString string];
    NSString *blueNum = [NSString string];
    
    for (NSString *str in red) {
        num = [num stringByAppendingString:[NSString stringWithFormat:@"%@ ",str]];
    }
    
    if(tuoArray != nil)
    {
        for (NSString *str in tuoArray) {
            tuoNum = [tuoNum stringByAppendingString:[NSString stringWithFormat:@"%@ ",str]];
        }
    }
    
    for (NSString *str in blue  ) {
        blueNum = [blueNum stringByAppendingString:[NSString stringWithFormat:@"%@ ",str]];
    }
    
    if(type == 501)
    {
        //去掉最后一个空格
        NSRange range = NSMakeRange(0, num.length - 1);
        num = [num substringWithRange:range];
        
        num = [num stringByAppendingFormat:@"-%@",blueNum];
    }
    else if (type == 502)
    {
        NSRange range = NSMakeRange(0, tuoNum.length - 1);
        tuoNum = [tuoNum substringWithRange:range];
        
        NSRange range1 = NSMakeRange(0, blueNum.length - 1);
        blueNum = [blueNum substringWithRange:range1];
        
        num = [num stringByAppendingFormat:@", %@-%@",tuoNum,blueNum];
    }
    
    return num;
}

//格式化 大乐透
- (NSString *)changeDLTWithRedArray:(NSArray *)red TuoArray:(NSArray *)tuoArray BlueArray:(NSArray *)blue Type:(NSInteger)type
{
    NSString *num = [NSString string];
    NSString *tuoNum = [NSString string];
    NSString *blueNum = [NSString string];
    
    for (NSString *str in red) {
        num = [num stringByAppendingString:[NSString stringWithFormat:@"%@ ",str]];
    }
    
    if(tuoArray != nil)
    {
        for (NSString *str in tuoArray) {
            tuoNum = [tuoNum stringByAppendingString:[NSString stringWithFormat:@"%@ ",str ]];
        }
    }
    
    for (NSString *str in blue  ) {
        blueNum = [blueNum stringByAppendingString:[NSString stringWithFormat:@"%@ ",str]];
    }
    
    if(type == 3901)
    {
        //去掉最后一个空格
        NSRange range = NSMakeRange(0, num.length - 1);
        num = [num substringWithRange:range];
        
        num = [num stringByAppendingFormat:@"-%@",blueNum];
    }
    else if (type == 3903||type == 3902)
    {
        NSRange range = NSMakeRange(0, tuoNum.length - 1);
        tuoNum = [tuoNum substringWithRange:range];
        
        num = [num stringByAppendingFormat:@", %@-%@",tuoNum,blueNum];
    }
    
    return num;
}

//选球(数字)数组排序
- (NSArray *)sortArrayWith:(NSArray *)ballsArray {
    NSComparator comparator = ^(id obj1,id obj2){
        if([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        } else if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        } else {
            return (NSComparisonResult)NSOrderedSame;
        }
    };
    
    return [ballsArray sortedArrayUsingComparator:comparator];
}

//将数字数组转换成字符串数组
- (NSArray *)convertToStringArrayWith:(NSArray *)ballsArray {
    ballsArray = [self sortArrayWith:ballsArray];
    NSMutableArray *strArray = [NSMutableArray arrayWithCapacity:ballsArray.count];
    for (NSNumber *ballNum in ballsArray) {
        if([ballNum integerValue] < 10) {
            [strArray addObject:[NSString stringWithFormat:@"0%@",ballNum]];
        } else {
            [strArray addObject:[NSString stringWithFormat:@"%@",ballNum]];
        }
    }
    return strArray;
}
/** 直选和值算法
 @param  digit   需要计算的位数
 @param  minNum  计算的位的最小数值
 @param  maxNum  计算的位的最大数值
 @param  he      需要计算的和
 @param  sum     已经计算的目前的和，调用传入为0
 @return 计算的注数 */
+ (NSInteger)calculateZhuShuWithDigit:(NSInteger)digit minNum:(NSInteger)minNum maxNum:(NSInteger)maxNum he:(NSInteger)he sum:(NSInteger)sum {
    if (digit <= 1) {
        for (NSInteger i = minNum; i <= maxNum; i++) {
            if (sum + i == he) {
                return 1;
            }
        }
        return 0;
    }
    NSInteger count = 0;
    for (NSInteger i = minNum; i <= maxNum; i++) {
        if(sum + i > he)
            return count;
        count += [self calculateZhuShuWithDigit:digit - 1 minNum:minNum maxNum:maxNum he:he sum:sum + i];
    }
    return count;
}

/*********竞彩部分的算法**************/
/** n串m 洪晓彬写 该方法暂不兼容混合投注的胆算法*/

+ (NSInteger)getNG1WithN:(NSInteger)n m:(NSInteger)m matchArray:(NSArray *)matchArray danArray:(NSArray *)danArray {//传入的只能是选号的数组
    NSInteger mul = 1;
    if ([danArray count] > n) {
        return 0;
    }
    NSInteger danCount = 0;
    NSMutableArray *danCountArray = [[NSMutableArray alloc] init];
    [CalculateBetCount disposeSelectMatchNumberCountArrayWithMatchArray:danArray countArray:danCountArray];
    if (danCountArray) { //胆的无考虑混合投注方法
        for (NSArray *dArray in danCountArray) {
            for(NSInteger i = 0; i < [dArray count]; i++) {
                mul *= [[dArray objectAtIndex:i] integerValue];
            }
            danCount++;
        }
    }
    
    NSInteger wantSelectMatchCount = n - danCount;
    NSMutableArray *countArray = [[NSMutableArray alloc] init];
    [CalculateBetCount disposeSelectMatchNumberCountArrayWithMatchArray:matchArray countArray:countArray];
    NSInteger arrayCount = [countArray count];
    NSInteger sumCount = 0;
    if (m == 1) {
        sumCount = [CalculateBetCount getNG1WithN:wantSelectMatchCount onIndex:0 maxCount:arrayCount - wantSelectMatchCount + 1 countArray:countArray sumBetCount:sumCount multiplicationCount:mul];
    } else {
        NSMutableArray *gSelectMatchCountArray = [NSMutableArray array];
        [CalculateBetCount getNGMWithN:n m:m gSelectMatchCountArray:gSelectMatchCountArray];
        
        NSMutableArray *selectMatchArray = [NSMutableArray array];
        [selectMatchArray addObjectsFromArray:danCountArray];
        sumCount = [CalculateBetCount getNGMWithWantSelectMatchCount:wantSelectMatchCount onIndex:0 maxCount:arrayCount - wantSelectMatchCount + 1 countArray:countArray selectMatchArray:selectMatchArray gSelectMatchCountArray:gSelectMatchCountArray danNumberCount:danCount sumBetCount:sumCount multiplicationCount:1];
    }
    [danCountArray release];
    [countArray release];
    return sumCount;
}

//北京单场
+ (NSInteger)getBJDCNG1WithN:(NSInteger)n m:(NSInteger)m matchArray:(NSArray *)matchArray danArray:(NSArray *)danArray {//传入的只能是选号的数组
    NSInteger mul = 1;
    if ([danArray count] > n) {
        return 0;
    }
    NSInteger danCount = 0;
    NSMutableArray *danCountArray = [[NSMutableArray alloc] init];
    [CalculateBetCount disposeSelectMatchNumberCountArrayWithMatchArray:danArray countArray:danCountArray];
    if (danCountArray) { //胆的无考虑混合投注方法
        for (NSArray *dArray in danCountArray) {
            for(NSInteger i = 0; i < [dArray count]; i++) {
                mul *= [[dArray objectAtIndex:i] integerValue];
            }
            danCount++;
        }
    }
    
    NSInteger wantSelectMatchCount = n - danCount;
    NSMutableArray *countArray = [[NSMutableArray alloc] init];
    [CalculateBetCount disposeSelectMatchNumberCountArrayWithMatchArray:matchArray countArray:countArray];
    NSInteger arrayCount = [countArray count];
    NSInteger sumCount = 0;
    if (m == 1) {
        sumCount = [CalculateBetCount getNG1WithN:wantSelectMatchCount onIndex:0 maxCount:arrayCount - wantSelectMatchCount + 1 countArray:countArray sumBetCount:sumCount multiplicationCount:mul];
    } else {
        NSMutableArray *gSelectMatchCountArray = [NSMutableArray array];
        [CalculateBetCount getBJDCNGMWithN:n m:m gSelectMatchCountArray:gSelectMatchCountArray];
        
        NSMutableArray *selectMatchArray = [NSMutableArray array];
        [selectMatchArray addObjectsFromArray:danCountArray];
        sumCount = [CalculateBetCount getNGMWithWantSelectMatchCount:wantSelectMatchCount onIndex:0 maxCount:arrayCount - wantSelectMatchCount + 1 countArray:countArray selectMatchArray:selectMatchArray gSelectMatchCountArray:gSelectMatchCountArray danNumberCount:danCount sumBetCount:sumCount multiplicationCount:1];
    }
    [danCountArray release];
    [countArray release];
    return sumCount;
}

/**  洪晓彬写  */
+ (void)disposeSelectMatchNumberCountArrayWithMatchArray:(NSArray *)matchArray countArray:(NSMutableArray *)countArray {
    for (NSArray *array in matchArray) { //先进行统计
        if ([array count] == 0) {
            continue;
        } else {
            NSMutableArray *oneMatchTypeCountArray = [NSMutableArray array];
            for (NSInteger signIndex = 0; signIndex <= 5; signIndex++) {//目前竞彩投注号码只有0到599这个区间
                NSInteger signIndexCount = 0;
                for (NSInteger i = 0; i < [array count]; i++) {
                    if ([[array objectAtIndex:i] integerValue] / 100 == signIndex) {
                        signIndexCount++;
                    }
                }
                if (signIndexCount != 0) {
                    [oneMatchTypeCountArray addObject:[NSNumber numberWithInteger:signIndexCount]];
                }
            }
            [countArray addObject:oneMatchTypeCountArray];
        }
    }
}

/**  洪晓彬写  */
+ (void)getNGMWithN:(NSInteger)n m:(NSInteger)m gSelectMatchCountArray:(NSMutableArray *)gSelectMatchCountArray {
    switch (n) {
        case 3: {
            switch (m) {
                case 3: {
                    [gSelectMatchCountArray addObject:@"2"];
                }
                    break;
                case 4: {
                    [gSelectMatchCountArray addObject:@"2"];
                    [gSelectMatchCountArray addObject:@"3"];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 4: {
            switch (m) {
                case 4: {
                    [gSelectMatchCountArray addObject:@"3"];
                }
                    break;
                case 5: {
                    [gSelectMatchCountArray addObject:@"3"];
                    [gSelectMatchCountArray addObject:@"4"];
                }
                    break;
                case 6: {
                    [gSelectMatchCountArray addObject:@"2"];
                }
                    break;
                case 11: {
                    [gSelectMatchCountArray addObject:@"2"];
                    [gSelectMatchCountArray addObject:@"3"];
                    [gSelectMatchCountArray addObject:@"4"];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 5: {
            switch (m) {
                case 5: {
                    [gSelectMatchCountArray addObject:@"4"];
                }
                    break;
                case 6: {
                    [gSelectMatchCountArray addObject:@"4"];
                    [gSelectMatchCountArray addObject:@"5"];
                }
                    break;
                case 10: {
                    [gSelectMatchCountArray addObject:@"2"];
                }
                    break;
                case 16: {
                    [gSelectMatchCountArray addObject:@"3"];
                    [gSelectMatchCountArray addObject:@"4"];
                    [gSelectMatchCountArray addObject:@"5"];
                }
                    break;
                case 20: {
                    [gSelectMatchCountArray addObject:@"2"];
                    [gSelectMatchCountArray addObject:@"3"];
                }
                    break;
                case 26: {
                    [gSelectMatchCountArray addObject:@"2"];
                    [gSelectMatchCountArray addObject:@"3"];
                    [gSelectMatchCountArray addObject:@"4"];
                    [gSelectMatchCountArray addObject:@"5"];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 6: {
            switch (m) {
                case 6: {
                    [gSelectMatchCountArray addObject:@"5"];
                }
                    break;
                case 7: {
                    [gSelectMatchCountArray addObject:@"5"];
                    [gSelectMatchCountArray addObject:@"6"];
                }
                    break;
                case 15: {
                    [gSelectMatchCountArray addObject:@"2"];
                }
                    break;
                case 20: {
                    [gSelectMatchCountArray addObject:@"3"];
                }
                    break;
                case 22: {
                    [gSelectMatchCountArray addObject:@"4"];
                    [gSelectMatchCountArray addObject:@"5"];
                    [gSelectMatchCountArray addObject:@"6"];
                }
                    break;
                case 35: {
                    [gSelectMatchCountArray addObject:@"2"];
                    [gSelectMatchCountArray addObject:@"3"];
                }
                    break;
                case 42: {
                    [gSelectMatchCountArray addObject:@"3"];
                    [gSelectMatchCountArray addObject:@"4"];
                    [gSelectMatchCountArray addObject:@"5"];
                    [gSelectMatchCountArray addObject:@"6"];
                }
                    break;
                case 50: {
                    [gSelectMatchCountArray addObject:@"2"];
                    [gSelectMatchCountArray addObject:@"3"];
                    [gSelectMatchCountArray addObject:@"4"];
                }
                    break;
                case 57: {
                    [gSelectMatchCountArray addObject:@"2"];
                    [gSelectMatchCountArray addObject:@"3"];
                    [gSelectMatchCountArray addObject:@"4"];
                    [gSelectMatchCountArray addObject:@"5"];
                    [gSelectMatchCountArray addObject:@"6"];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 7: {
            switch (m) {
                case 7: {
                    [gSelectMatchCountArray addObject:@"6"];
                }
                    break;
                case 8: {
                    [gSelectMatchCountArray addObject:@"6"];
                    [gSelectMatchCountArray addObject:@"7"];
                }
                    break;
                case 21: {
                    [gSelectMatchCountArray addObject:@"5"];
                }
                    break;
                case 35: {
                    [gSelectMatchCountArray addObject:@"4"];
                }
                    break;
                case 120: {
                    [gSelectMatchCountArray addObject:@"2"];
                    [gSelectMatchCountArray addObject:@"3"];
                    [gSelectMatchCountArray addObject:@"4"];
                    [gSelectMatchCountArray addObject:@"5"];
                    [gSelectMatchCountArray addObject:@"6"];
                    [gSelectMatchCountArray addObject:@"7"];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 8: {
            switch (m) {
                case 8: {
                    [gSelectMatchCountArray addObject:@"7"];
                }
                    break;
                case 9: {
                    [gSelectMatchCountArray addObject:@"7"];
                    [gSelectMatchCountArray addObject:@"8"];
                }
                    break;
                case 28: {
                    [gSelectMatchCountArray addObject:@"6"];
                }
                    break;
                case 56: {
                    [gSelectMatchCountArray addObject:@"5"];
                }
                    break;
                case 70: {
                    [gSelectMatchCountArray addObject:@"4"];
                }
                    break;
                case 247: {
                    [gSelectMatchCountArray addObject:@"2"];
                    [gSelectMatchCountArray addObject:@"3"];
                    [gSelectMatchCountArray addObject:@"4"];
                    [gSelectMatchCountArray addObject:@"5"];
                    [gSelectMatchCountArray addObject:@"6"];
                    [gSelectMatchCountArray addObject:@"7"];
                    [gSelectMatchCountArray addObject:@"8"];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    
}


+ (void)getBJDCNGMWithN:(NSInteger)n m:(NSInteger)m gSelectMatchCountArray:(NSMutableArray *)gSelectMatchCountArray {
    switch (n) {
        case 2:
        {
            switch (m) {
                case 3:
                {
                    [gSelectMatchCountArray addObject:@"1"];
                    [gSelectMatchCountArray addObject:@"2"];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 3:
        {
            switch (m) {
                case 4:
                {
                    [gSelectMatchCountArray addObject:@"2"];
                    [gSelectMatchCountArray addObject:@"3"];
                }
                    break;
                case 7:
                {
                    [gSelectMatchCountArray addObject:@"1"];
                    [gSelectMatchCountArray addObject:@"2"];
                    [gSelectMatchCountArray addObject:@"3"];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 4:
        {
            switch (m) {
                case 5:
                {
                    [gSelectMatchCountArray addObject:@"3"];
                    [gSelectMatchCountArray addObject:@"4"];
                }
                    break;
                case 11:
                {
                    [gSelectMatchCountArray addObject:@"2"];
                    [gSelectMatchCountArray addObject:@"3"];
                    [gSelectMatchCountArray addObject:@"4"];
                }
                    break;
                case 15:
                {
                    [gSelectMatchCountArray addObject:@"1"];
                    [gSelectMatchCountArray addObject:@"2"];
                    [gSelectMatchCountArray addObject:@"3"];
                    [gSelectMatchCountArray addObject:@"4"];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 5:
        {
            switch (m) {
                case 6:
                {
                    [gSelectMatchCountArray addObject:@"4"];
                    [gSelectMatchCountArray addObject:@"5"];
                }
                    break;
                case 16:
                {
                    [gSelectMatchCountArray addObject:@"3"];
                    [gSelectMatchCountArray addObject:@"4"];
                    [gSelectMatchCountArray addObject:@"5"];
                }
                    break;
                case 26:
                {
                    [gSelectMatchCountArray addObject:@"2"];
                    [gSelectMatchCountArray addObject:@"3"];
                    [gSelectMatchCountArray addObject:@"4"];
                    [gSelectMatchCountArray addObject:@"5"];
                }
                    break;
                case 31:
                {
                    [gSelectMatchCountArray addObject:@"1"];
                    [gSelectMatchCountArray addObject:@"2"];
                    [gSelectMatchCountArray addObject:@"3"];
                    [gSelectMatchCountArray addObject:@"4"];
                    [gSelectMatchCountArray addObject:@"5"];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 6:
        {
            switch (m) {
                case 7:
                {
                    [gSelectMatchCountArray addObject:@"5"];
                    [gSelectMatchCountArray addObject:@"6"];
                }
                    break;
                case 22:
                {
                    [gSelectMatchCountArray addObject:@"4"];
                    [gSelectMatchCountArray addObject:@"5"];
                    [gSelectMatchCountArray addObject:@"6"];
                }
                    break;
                case 35:
                {
                    [gSelectMatchCountArray addObject:@"2"];
                    [gSelectMatchCountArray addObject:@"3"];
                }
                    break;
                case 42:
                {
                    [gSelectMatchCountArray addObject:@"3"];
                    [gSelectMatchCountArray addObject:@"4"];
                    [gSelectMatchCountArray addObject:@"5"];
                    [gSelectMatchCountArray addObject:@"6"];
                }
                    break;
                case 57:
                {
                    [gSelectMatchCountArray addObject:@"2"];
                    [gSelectMatchCountArray addObject:@"3"];
                    [gSelectMatchCountArray addObject:@"4"];
                    [gSelectMatchCountArray addObject:@"5"];
                    [gSelectMatchCountArray addObject:@"6"];
                }
                    break;
                case 63:
                {
                    [gSelectMatchCountArray addObject:@"1"];
                    [gSelectMatchCountArray addObject:@"2"];
                    [gSelectMatchCountArray addObject:@"3"];
                    [gSelectMatchCountArray addObject:@"4"];
                    [gSelectMatchCountArray addObject:@"5"];
                    [gSelectMatchCountArray addObject:@"6"];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

/**  洪晓彬写  */
+ (NSInteger)getNGMWithWantSelectMatchCount:(NSInteger)wantSelectMatchCount onIndex:(NSInteger)onIndex maxCount:(NSInteger)maxCount countArray:(NSMutableArray *)countArray selectMatchArray:(NSMutableArray *)selectMatchArray gSelectMatchCountArray:(NSMutableArray *)gSelectMatchCountArray danNumberCount:(NSInteger)danNumberCount sumBetCount:(NSInteger)sumBetCount multiplicationCount:(NSInteger)multiplicationCount {
    if (wantSelectMatchCount <= 1) {
        
        for (NSInteger index = onIndex; index < maxCount; index++) {
            
            for (NSInteger i = 0; i < [[countArray objectAtIndex:index] count]; i++) {
                NSMutableArray *selectMatch2Array = [NSMutableArray array];
                [selectMatch2Array addObjectsFromArray:selectMatchArray];
                NSMutableArray *oneArray = [NSMutableArray array];
                [oneArray addObject:[[countArray objectAtIndex:index] objectAtIndex:i]];
                [selectMatch2Array addObject:oneArray];
                
                for (NSInteger i = 0; i < [gSelectMatchCountArray count]; i++) {
                    NSInteger n = [[gSelectMatchCountArray objectAtIndex:i] integerValue];//n 指n串几中的n
                    sumBetCount += [CalculateBetCount getNG1WithN:n  onIndex:0 maxCount:[selectMatch2Array count] - n + 1 countArray:selectMatch2Array sumBetCount:0 multiplicationCount:multiplicationCount];
                }
            }
        }
        
        return sumBetCount;
    } else {
        NSInteger count = 0;
        for (NSInteger index = onIndex; index < maxCount; index++) {
            
            for (NSInteger i = 0; i < [[countArray objectAtIndex:index] count]; i++) {
                NSMutableArray *selectMatch2Array = [NSMutableArray array];
                [selectMatch2Array addObjectsFromArray:selectMatchArray];
                NSMutableArray *oneArray = [NSMutableArray array];
                [oneArray addObject:[[countArray objectAtIndex:index] objectAtIndex:i]];
                [selectMatch2Array addObject:oneArray];
                
                count += [CalculateBetCount getNGMWithWantSelectMatchCount:wantSelectMatchCount - 1 onIndex:index + 1 maxCount:maxCount + 1 countArray:countArray selectMatchArray:selectMatch2Array gSelectMatchCountArray:gSelectMatchCountArray danNumberCount:danNumberCount sumBetCount:0 multiplicationCount:multiplicationCount];
            }
            
            
        }
        return count;
    }
    return 0;
}

/**  洪晓彬写  */
+ (NSInteger)getNG1WithN:(NSInteger)n onIndex:(NSInteger)onIndex maxCount:(NSInteger)maxCount countArray:(NSMutableArray *)countArray sumBetCount:(NSInteger)sumBetCount multiplicationCount:(NSInteger)multiplicationCount {
    if(n <= 1) {
        for (NSInteger index = onIndex; index < maxCount; index++) {
            for (NSInteger i = 0; i < [[countArray objectAtIndex:index] count]; i++) {
                sumBetCount += multiplicationCount * [[[countArray objectAtIndex:index] objectAtIndex:i] integerValue];
            }
        }
        
        return sumBetCount;
    } else {
        
        NSInteger count = 0;
        for (NSInteger index = onIndex; index < maxCount; index++) {
            
            for (NSInteger i = 0; i < [[countArray objectAtIndex:index] count]; i++) {
                count += (sumBetCount + [CalculateBetCount getNG1WithN:n - 1 onIndex:index + 1 maxCount:maxCount + 1 countArray:countArray sumBetCount:sumBetCount multiplicationCount:(multiplicationCount * [[[countArray objectAtIndex:index] objectAtIndex:i] integerValue])]);
            }
        }
        return count;
    }
    return 0;
}

/********幸运赛车**********/
+(NSInteger)getLuckRacingCountWithOneArray:(NSArray *)one TwoArray:(NSArray *)two ThreeArray:(NSArray *)three Type:(NSInteger)type
{
    NSInteger total = 0;
    switch (type)
    {
        case 8701:
        case 8708:
        case 8713:
            total = one.count;
            break;
            //前二
        case 8702:
            ;
            int r = 0;
            for (NSString *str in one)
            {
                for(NSString *str2 in two)
                {
                    if([str isEqualToString:str2])
                    {
                        r++;
                    }
                }
            }
            total = r * (one.count - 1) + (two.count - r) * one.count;
            break;
        case 8709:
        case 8715:
            total = one.count * two.count;
            break;
        case 8703:
            total = one.count *(one.count -1);
            break;
        case 8704:
            if(two.count == 1)
            {
                return 0;
            }
            total = one.count * two.count * 2;
            break;
        case 8705:
            total = 0;
            for(NSString *str in one)
            {
                for(NSString *str2 in two)
                {
                    if(![str isEqualToString:str2])
                    {
                        for(NSString *str3 in three)
                        {
                            if(![str3 isEqualToString:str] && ![str3 isEqualToString:str2])
                                total ++;
                        }
                    }
                }
            }
            break;
        case 8706:
            ;
            NSInteger o = one.count;
            total = o * (o - 1) * (o - 2);
            break;
        case 8711:
            total = one.count * two.count * three.count;
            break;
        case 8712:
            ;
            int a = 1;
            NSInteger s = two.count;
            for(int i = 0;i < (3 - one.count);i++)
            {
                a *= s;
                s--;
            }
            int b = 1;
            for(NSInteger j = (3 - one.count); j > 0; j--)
            {
                b *= j;
            }
            total = a / b * 6;
            break;
        case 8707:
            if(two.count + one.count < 4)
                return 0;
            if(one.count == 2)
                total = two.count * 6;
            else if(one.count == 1)
                total = two.count * (two.count -1) /2 * 6;
            break;
        case 8710:
            total = two.count * 2;
            break;
        case 8714:
            total = (one.count *(one.count - 1)) / 2;
            break;
        case 8716:
            total = (one.count * (one.count - 1) * (one.count - 2)) / 6;
            break;
        case 8717:
            ;
            int c = 1;
            NSInteger t= two.count;
            for(int i=0;i< (3 - one.count);i++)
            {
                c *= t;
                t --;
            }
            int d = 1;
            for(NSInteger j = (3 - one.count);j>0;j--)
            {
                d *= j;
            }
            total = c / d;
            break;
        default:
            total = 0;
            break;
    }
    return total;
}

+ (NSInteger)getCountForESEXWWithOneArray:(NSArray *)onearr andPlayID:(NSInteger)playID
{
    NSInteger count = 0;
    switch (playID) {
        case 6901:
        {
            if (onearr.count >= 5) {
                count = [CalculateBetCount combinationWithM:onearr.count N:5];
            }
        }
            break;
        case 6902:
        {
            if (onearr.count >= 2) {
                count = [CalculateBetCount combinationWithM:onearr.count N:2];
            }
        }
            break;
        case 6903:
        {
            if (onearr.count >= 3) {
                count = [CalculateBetCount combinationWithM:onearr.count N:3];
            }
        }
            break;
        case 6904:
        {
            if (onearr.count >= 4) {
                count = [CalculateBetCount combinationWithM:onearr.count N:4];
            }
        }
            break;
            
        default:
            break;
    }
    return count;
}

+ (NSInteger)getCountForXYCWithOneArray:(NSArray *)onearr two:(NSArray *)twoarr three:(NSArray *)threearr four:(NSArray *)fourarr five:(NSArray *)fivearr six:(NSArray *)sixarr andPlayID:(NSInteger)playID andPlayMethodName:(NSString *)name andFirstViewName:(NSString *)name1 andSecondViewName:(NSString *)name2
{
    NSInteger count = 0;
    switch (playID) {
        case 8201:
        {
            if ([name1 isEqualToString:@"选一场"]) {
                if (onearr.count > 0)
                    count = onearr.count;
                if (twoarr.count > 0)
                    count = twoarr.count;
                if (threearr.count > 0)
                    count = threearr.count;
            }
            
            if ([name1 isEqualToString:@"选二场"]) {
                if (onearr.count == 0 && twoarr.count > 0 && threearr.count > 0) {
                    count = twoarr.count * threearr.count;
                }
                
                if (onearr.count > 0 && twoarr.count > 0 && threearr.count == 0) {
                    count = onearr.count * twoarr.count;
                }
                
                if (onearr.count > 0 && twoarr.count == 0 && threearr.count > 0) {
                    count = onearr.count * threearr.count;
                }
            }
            
            if ([name1 isEqualToString:@"选三场"]) {
                count = onearr.count * twoarr.count * threearr.count;
            }
        }
            break;
        case 8202:
        {
            if ([name2 isEqualToString:@"任一"]) {
                count = fourarr.count;
            } else if ([name2 isEqualToString:@"任二"]) {
                if (fourarr.count >= 2)
                    count = [CalculateBetCount combinationWithM:fourarr.count N:2];
            } else if ([name2 isEqualToString:@"任三"]) {
                if (fourarr.count >= 3)
                    count = [CalculateBetCount combinationWithM:fourarr.count N:3];
            } else if ([name2 isEqualToString:@"任四"]) {
                if (fourarr.count >= 4)
                    count = [CalculateBetCount combinationWithM:fourarr.count N:4];
            } else if ([name2 isEqualToString:@"任五"]) {
                if (fourarr.count >= 5)
                    count = [CalculateBetCount combinationWithM:fourarr.count N:5];
            } else if ([name2 isEqualToString:@"任六"]) {
                if (fourarr.count >= 6)
                    count = [CalculateBetCount combinationWithM:fourarr.count N:6];
            } else if ([name2 isEqualToString:@"任七"]) {
                if (fourarr.count >= 7)
                    count = [CalculateBetCount combinationWithM:fourarr.count N:7];
            } else if ([name2 isEqualToString:@"顺一"]) {
                count = fourarr.count;
            } else if ([name2 isEqualToString:@"顺二"]) {
                for (int i = 0; i < fourarr.count; i++) {
                    for (int j = 0; j < fivearr.count; j++) {
                        if ([fourarr objectAtIndex:i] != [fivearr objectAtIndex:j])
                            count += 1;
                    }
                }
            } else if ([name2 isEqualToString:@"顺三"]) {
                for (int i = 0; i < fourarr.count; i++){
                    for (int j = 0; j < fivearr.count; j++) {
                        for (int k = 0; k < sixarr.count; k++) {
                            if ([fourarr objectAtIndex:i] != [fivearr objectAtIndex:j]
                                && [fourarr objectAtIndex:i] != [sixarr objectAtIndex:k]
                                && [fivearr objectAtIndex:j] != [sixarr objectAtIndex:k])
                            {
                                count += 1;
                            }
                        }
                    }
                }
            }
        }
            break;
        case 8203:
        {
            // 
            NSInteger count1 = 0;
            if ([name1 isEqualToString:@"选一场"]) {
                if (onearr.count > 0)
                    count1 = onearr.count;
                if (twoarr.count > 0)
                    count1 = twoarr.count;
                if (threearr.count > 0)
                    count1 = threearr.count;
            }
            if ([name1 isEqualToString:@"选二场"]) {
                if (onearr.count == 0 && twoarr.count > 0 && threearr.count > 0) {
                    count1 = twoarr.count * threearr.count;
                }
                
                if (onearr.count > 0 && twoarr.count > 0 && threearr.count == 0) {
                    count1 = onearr.count * twoarr.count;
                }
                
                if (onearr.count > 0 && twoarr.count == 0 && threearr.count > 0) {
                    count1 = onearr.count * threearr.count;
                }
            }
            if ([name1 isEqualToString:@"选三场"]) {
                count1 = onearr.count * twoarr.count * threearr.count;
            }
            
            //
            NSInteger count2 = 0;
            if ([name2 isEqualToString:@"任一"]) {
                count2 = fourarr.count;
            } else if ([name2 isEqualToString:@"任二"]) {
                if (fourarr.count >= 2)
                    count2 = [CalculateBetCount combinationWithM:fourarr.count N:2];
            } else if ([name2 isEqualToString:@"任三"]) {
                if (fourarr.count >= 3)
                    count2 = [CalculateBetCount combinationWithM:fourarr.count N:3];
            } else if ([name2 isEqualToString:@"任四"]) {
                if (fourarr.count >= 4)
                    count2 = [CalculateBetCount combinationWithM:fourarr.count N:4];
            } else if ([name2 isEqualToString:@"任五"]) {
                if (fourarr.count >= 5)
                    count2 = [CalculateBetCount combinationWithM:fourarr.count N:5];
            } else if ([name2 isEqualToString:@"任六"]) {
                if (fourarr.count >= 6)
                    count2 = [CalculateBetCount combinationWithM:fourarr.count N:6];
            } else if ([name2 isEqualToString:@"任七"]) {
                if (fourarr.count >= 7)
                    count2 = [CalculateBetCount combinationWithM:fourarr.count N:7];
            } else if ([name2 isEqualToString:@"顺一"]) {
                count2 = fourarr.count;
            } else if ([name2 isEqualToString:@"顺二"]) {
                for (int i = 0; i < fourarr.count; i++) {
                    for (int j = 0; j < fivearr.count; j++) {
                        if ([fourarr objectAtIndex:i] != [fivearr objectAtIndex:j])
                            count2 += 1;
                    }
                }
            } else if ([name2 isEqualToString:@"顺三"]) {
                for (int i = 0; i < fourarr.count; i++){
                    for (int j = 0; j < fivearr.count; j++) {
                        for (int k = 0; k < sixarr.count; k++) {
                            if ([fourarr objectAtIndex:i] != [fivearr objectAtIndex:j]
                                && [fourarr objectAtIndex:i] != [sixarr objectAtIndex:k]
                                && [fivearr objectAtIndex:j] != [sixarr objectAtIndex:k])
                            {
                                count2 += 1;
                            }
                        }
                    }
                }
            }
            
            //
            count = count1 * count2;
        }
            break;
            
        default:
            break;
    }
    return count;
}

+ (NSInteger)getCountForKY481WithOneArray:(NSArray *)onearr two:(NSArray *)twoarr three:(NSArray *)threearr four:(NSArray *)fourarr five:(NSArray *)fivearr andPlayID:(NSInteger)playID andPlayMethodName:(NSString *)name
{
    NSInteger count = 0;
    switch (playID) {
        case 6801:  // 任选一
            count = onearr.count + twoarr.count + threearr.count + fourarr.count;
            break;
        case 6802:  // 任选二
            count = onearr.count * (twoarr.count + threearr.count + fourarr.count) + twoarr.count * (threearr.count + fourarr.count) + threearr.count * fourarr.count;
            break;
        case 6803:  // 任选二全包
        {
            if (onearr.count > 0 && twoarr.count > 0) {
                count = [CalculateBetCount combinationWithM:4 N:2] * [CalculateBetCount combinationWithM:onearr.count N:1] * [CalculateBetCount combinationWithM:twoarr.count N:1] * 2 - (getRepeatCount(onearr,twoarr,NULL) * [CalculateBetCount combinationWithM:4 N:2]);
            }
        }
            break;
        case 6804:  // 任选三
            count = onearr.count * twoarr.count * threearr.count + onearr.count * twoarr.count * fourarr.count + twoarr.count * threearr.count * fourarr.count;
            break;
        case 6805:  // 任选三全包
        {
            // 遍历三个数组
            int noRepeat = 0;       // 2 3 4                    (三个数都不相同的次数)
            int twoRepeat = 0;      // 2 2 4 、3 3 3、2 7 7      (三个数中，有两个相同的次数)
            int threeTepeat = 0;    // 3 3 3                     (三个数全部相同的次数)
            for (int i = 0; i < onearr.count; i++) {
                int one = [[onearr objectAtIndex:i] intValue];
                for (int j = 0; j < twoarr.count; j++) {
                    int two = [[twoarr objectAtIndex:j] intValue];
                    for (int k = 0; k < threearr.count; k++) {
                        int three = [[threearr objectAtIndex:k] intValue];
                        
                        if (one != two && one != three && two != three)
                            noRepeat++;
                        if (one == two && one == three && two == three)
                            threeTepeat++;
                        if (one == two || one == three || two == three)
                            twoRepeat++;
                    }
                }
            }
            count = 24 * noRepeat + 12 * twoRepeat - 8 * threeTepeat;
        }
            break;
        case 6806:
        {
            if (onearr.count > 0 && twoarr.count > 0 && threearr.count > 0 && fourarr.count > 0) {
                if ([name isEqualToString:@"单 式"]) {
                    if (onearr.count == 1 && twoarr.count == 1 && threearr.count == 1 && fourarr.count == 1)
                        count = 1;
                } else if ([name isEqualToString:@"复 式"]) {
                    count = onearr.count * twoarr.count * threearr.count * fourarr.count;
                }
            }
        }
            break;
        case 6807:      // 组24(单式和复式)
        {
            if ([name isEqualToString:@"单 式"]) {    // 每个球都不能相同，此玩法只有一注
                if (onearr.count == 1 && twoarr.count == 1 && threearr.count == 1 && fourarr.count == 1) {
                    if ([onearr objectAtIndex:0] != [twoarr objectAtIndex:0] && [onearr objectAtIndex:0] != [threearr objectAtIndex:0]
                        && [onearr objectAtIndex:0] != [fourarr objectAtIndex:0] && [twoarr objectAtIndex:0] != [threearr objectAtIndex:0]
                        && [twoarr objectAtIndex:0] != [fourarr objectAtIndex:0] && [threearr objectAtIndex:0] != [fourarr objectAtIndex:0]) {
                         count = 1;
                    }
                }
            } else if ([name isEqualToString:@"复 式"]) {
                if (onearr.count >= 4) {
                    count = [CalculateBetCount combinationWithM:onearr.count N:4];
                }
            }
        }
            break;
        case 6808:      // 组24胆拖
        {
            if (onearr.count > 0)
                count = [CalculateBetCount combinationWithM:twoarr.count N:4 - onearr.count];
            if (count == 1)
                count = 0;
        }
            break;
        case 6809:  // 组12（单式和复式）(2个不同，2个相同)
        {
            if ([name isEqualToString:@"单 式"]) {
                if (onearr.count > 0 && twoarr.count > 0 && threearr.count > 0 && fourarr.count > 0) {
                    if (repeatCounts(onearr, twoarr, threearr, fourarr, NULL) == 1) {
                        count = 1;
                    }
                }
            } else if ([name isEqualToString:@"复 式"]) {
                if (onearr.count >= 3) {
                    count = [CalculateBetCount permutationWithM:onearr.count N:3] / 2;
                }
            }
        }
            break;
        case 6810:      // 组12胆拖
        {
            if (onearr.count == 1) {
                if (twoarr.count >= 2)
                    count = 3 * [CalculateBetCount combinationWithM:twoarr.count N:2];
            }
            if (onearr.count == 2) {
                count = twoarr.count * 3;
            }
        }
            break;
        case 6811:      // 组12重胆拖
        {
            if (onearr.count == 1 && twoarr.count >= 3)
                count = [CalculateBetCount combinationWithM:twoarr.count N:2];
        }
            break;
        case 6812:  // 组6（单式和复式）(两两相同)
        {
            if ([name isEqualToString:@"单 式"]) {
                if (onearr.count > 0 && twoarr.count > 0 && threearr.count > 0 && fourarr.count > 0) {
                    if (getRepeatCount(onearr, twoarr, threearr, fourarr, NULL) == 2) {
                        count = 1;
                    }
                }
            } else if ([name isEqualToString:@"复 式"]) {
                if (onearr.count >= 2) {
                    count = [CalculateBetCount combinationWithM:onearr.count N:2];
                }
            }
        }
            break;
        case 6813:      // 组6胆拖
        {
            if (onearr.count == 1 && twoarr.count >= 2)
                count = twoarr.count;
        }
            break;
        case 6814:  // 组4（单式和复式）(3个相同，1个不同)
        {
            if ([name isEqualToString:@"单 式"]) {
                if (onearr.count > 0 && twoarr.count > 0 && threearr.count > 0 && fourarr.count > 0) {
                    if (repeatCounts(onearr, twoarr, threearr, fourarr, NULL) == 3) {
                        count = 1;
                    }
                }
            } else if ([name isEqualToString:@"复 式"]) {
                if (onearr.count >= 2) {
                    count = [CalculateBetCount permutationWithM:onearr.count N:2];
                }
            }
        }
            break;
        case 6815:      // 组4胆拖
        {
            if (onearr.count == 1)
                count = twoarr.count * 2;
        }
            break;
        case 6816:      // 组4重胆拖
        {
            if (onearr.count == 1 && twoarr.count >= 2)
                count = twoarr.count;
        }
            break;
        default:
            break;
    }
    return count;
}

// A(m,n)   m >= n
int A(int m, int n)
{
    int a = 1;
    for (int i = 0; i < n; i++) {
        a *= m - i;
    }
    return a;
}

NSInteger getRepeatCount(id parameter,...)
{
    va_list args;
    va_start(args,parameter);
    va_end(args);
    
    NSMutableArray *m_arr = [NSMutableArray arrayWithObjects:parameter, nil];
    
    if (parameter)
    {
        while (YES) {
            id obj = nil;
            obj = va_arg(args, id);
            if (!obj)
                break;
            NSArray *array = (NSArray *)obj;
            [m_arr addObject:array];
        }
    }
    
    NSMutableArray *repeatNumArr = [NSMutableArray array];
    for (int i = 0; i < m_arr.count; i++) {
        NSArray *arr1 = [m_arr objectAtIndex:i];
        for (int j = i + 1; j < m_arr.count; j++) {
            NSArray *arr2 = [m_arr objectAtIndex:j];
            for (NSNumber *number1 in arr1) {
                for (NSNumber *number2 in arr2) {
                    if ([number1 isEqualToNumber:number2]) {
                        if (![repeatNumArr containsObject:number1])
                            [repeatNumArr addObject:number1];
                    }
                }
            }
        }
    }
    
    return repeatNumArr.count;
}

int repeatCounts(id parameter,...)
{
    va_list args;
    va_start(args,parameter);
    va_end(args);
    
    NSMutableArray *m_arr = [NSMutableArray arrayWithObjects:parameter, nil];
    
    if (parameter)
    {
        while (YES) {
            id obj = nil;
            obj = va_arg(args, id);
            if (!obj)
                break;
            NSArray *array = (NSArray *)obj;
            [m_arr addObject:array];
        }
    }
    int counts = 0;
    for (int i = 0; i < m_arr.count; i++) {
        NSArray *arr1 = [m_arr objectAtIndex:i];
        for (int j = i + 1; j < m_arr.count; j++) {
            NSArray *arr2 = [m_arr objectAtIndex:j];
            for (NSNumber *number1 in arr1) {
                for (NSNumber *number2 in arr2) {
                    if ([number1 isEqualToNumber:number2]) {
                        counts += 1;
                    }
                }
            }
        }
    }
    
    return counts;
}

+ (NSInteger)getOneMatchCountWithArray:(NSArray *)array andPlayID:(NSInteger)playID {
    NSInteger count = 0;
    for (NSArray * selectOneMatch in array) {
        count += [selectOneMatch count];
    }
    return count;
}

#pragma mark - 奖金优化算法 (获取对阵消息)
/** n串1 该方法暂不兼容混合投注的胆算法 (刘科)*/
/** 奖金优化算法
 @param  n   串数 （如: 8串1 的 8）
 @param  m   串数 （如: 8串1 的 1）
 @param  matchArray     投注信息
 @param  danArray       胆
 @return resultArray 奖金优化对阵信息 */
+ (NSMutableArray *)getAgainstWithN:(NSInteger)n m:(NSInteger)m selectMatchArray:(NSMutableArray*)selectMatchArray arrayWithResult: (NSMutableArray *) resultArray ballType:(int)ballType{//传入的只能是选号的数组
    
    if (m == 1) {
        switch (n) {
            case 2:
            {
                resultArray = [CalculateBetCount twoBunch:selectMatchArray arrayWithResult:resultArray ballType:ballType];
            }
                break;
            case 3:
            {
                resultArray = [CalculateBetCount threeBunch:selectMatchArray arrayWithResult:resultArray ballType:ballType];
            }
                break;
            case 4:
            {
                resultArray = [CalculateBetCount fourBunch:selectMatchArray arrayWithResult:resultArray ballType:ballType];
            }
                break;
            case 5:
            {
                resultArray = [CalculateBetCount fiveBunch:selectMatchArray arrayWithResult:resultArray ballType:ballType];
            }
                break;
            case 6:
            {
                resultArray = [CalculateBetCount sixBunch:selectMatchArray arrayWithResult:resultArray ballType:ballType];
            }
                break;
            case 7:
            {
                resultArray = [CalculateBetCount sevenBunch:selectMatchArray arrayWithResult:resultArray ballType:ballType];
            }
                break;
            case 8:
            {
                resultArray = [CalculateBetCount eightBunch:selectMatchArray arrayWithResult:resultArray ballType:ballType];
            }
                break;
            default:
                break;
        }
    }
    
    
    return resultArray;
}

// 奖金优化 2串1 玩法
// 获取优化后对阵信息
+ (NSMutableArray *)twoBunch: (NSMutableArray *)selectMatchArray arrayWithResult:(NSMutableArray *)resultArray ballType:(int)ballType {
    
    for (int i = 0; i < [selectMatchArray count] - 1; i++) {
        NSDictionary *dic = selectMatchArray[i];
        
        for (int i1 = 0; i1 < [[dic objectForKey:@"selectArray"] count]; i1++) {
            
            for (int j = i + 1; j < [selectMatchArray count]; j++) {
                NSDictionary *dic1 = selectMatchArray[j];
                
                for (int j1 = 0; j1 < [[dic1 objectForKey:@"selectArray"] count]; j1++) {
                    
                    NSMutableArray *tempArr = [NSMutableArray array];
                    
                    if (ballType == 0) {    // 竞彩足球
                        [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:i two:i1 selectMatchArray:selectMatchArray]];
                        [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:j two:j1 selectMatchArray:selectMatchArray]];
                    }else {     // 竞彩篮球
                        [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:i two:i1 selectMatchArray:selectMatchArray]];
                        [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:j two:j1 selectMatchArray:selectMatchArray]];
                    }
                    
                    
                    // 预测奖金
                    float odds = 2;
                    for (int temp = 0; temp < tempArr.count; temp++) {
                        odds = odds * [[[tempArr objectAtIndex:temp] objectForKey:@"odds"] floatValue];
                    }
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                    [dict setObject:tempArr forKey:@"team"];    // 单注组合
                    [dict setObject:[NSString stringWithFormat:@"%.2f", odds] forKey:@"castMoney"];     // 预测奖金
                    [dict setObject:[NSString stringWithFormat:@"2"] forKey:@"passNumber"];             // 过关
                    [dict setObject:[NSString stringWithFormat:@"1"] forKey:@"playCount"];              // 注数
                    [dict setObject:[NSString stringWithFormat:@"2串1"] forKey:@"GGWay"];               // 串数
                    
                    [resultArray addObject:dict];
                    [dict release];
                    
                }
            }
        }
    }

    return resultArray;
}

// 奖金优化 3串1 玩法
// 获取优化后对阵信息
+ (NSMutableArray *)threeBunch: (NSMutableArray *)selectMatchArray arrayWithResult:(NSMutableArray *)resultArray ballType:(int)ballType {
    
    for (int one1 = 0; one1 < [selectMatchArray count] - 1; one1++) {
        NSDictionary *dic1 = selectMatchArray[one1];
        
        for (int two1 = 0; two1 < [[dic1 objectForKey:@"selectArray"] count]; two1++) {
            
            for (int one2 = one1 + 1; one2 < [selectMatchArray count]; one2++) {
                NSDictionary *dic2 = selectMatchArray[one2];
                
                for (int two2 = 0; two2 < [[dic2 objectForKey:@"selectArray"] count]; two2++) {
                    
                    for (int one3 = one2 + 1; one3 < [selectMatchArray count]; one3++) {
                        NSDictionary *dic3 = selectMatchArray[one3];
                        
                        for (int two3 = 0; two3 < [[dic3 objectForKey:@"selectArray"] count]; two3++) {
                            
                            NSMutableArray *tempArr = [NSMutableArray array];
                            if (ballType == 0) {    // 竞彩足球
                                [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one1 two:two1 selectMatchArray:selectMatchArray]];
                                [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one2 two:two2 selectMatchArray:selectMatchArray]];
                                [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one3 two:two3 selectMatchArray:selectMatchArray]];
                            }else {
                                [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one1 two:two1 selectMatchArray:selectMatchArray]];
                                [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one2 two:two2 selectMatchArray:selectMatchArray]];
                                [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one3 two:two3 selectMatchArray:selectMatchArray]];
                            }
                            
                            // 预测奖金
                            float odds = 3;
                            for (int temp = 0; temp < tempArr.count; temp++) {
                                odds = odds * [[[tempArr objectAtIndex:temp] objectForKey:@"odds"] floatValue];
                            }
                            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                            [dict setObject:tempArr forKey:@"team"];    // 单注组合
                            [dict setObject:[NSString stringWithFormat:@"%.2f", odds] forKey:@"castMoney"];     // 预测奖金
                            [dict setObject:[NSString stringWithFormat:@"3"] forKey:@"passNumber"];             // 过关
                            [dict setObject:[NSString stringWithFormat:@"1"] forKey:@"playCount"];              // 注数
                            [dict setObject:[NSString stringWithFormat:@"3串1"] forKey:@"GGWay"];               // 串数
                            
                            [resultArray addObject:dict];
                            [dict release];
                            
                        }
                    }
                }
            }
        }
    }
    
    return resultArray;
}

// 奖金优化 4串1 玩法
// 获取优化后对阵信息
+ (NSMutableArray *)fourBunch: (NSMutableArray *)selectMatchArray arrayWithResult:(NSMutableArray *)resultArray ballType:(int)ballType {
    
    for (int one1 = 0; one1 < [selectMatchArray count] - 1; one1++) {
        NSDictionary *dic1 = selectMatchArray[one1];
        
        for (int two1 = 0; two1 < [[dic1 objectForKey:@"selectArray"] count]; two1++) {
            
            for (int one2 = one1 + 1; one2 < [selectMatchArray count]; one2++) {
                NSDictionary *dic2 = selectMatchArray[one2];
                
                for (int two2 = 0; two2 < [[dic2 objectForKey:@"selectArray"] count]; two2++) {
                    
                    for (int one3 = one2 + 1; one3 < [selectMatchArray count]; one3++) {
                        NSDictionary *dic3 = selectMatchArray[one3];
                        
                        for (int two3 = 0; two3 < [[dic3 objectForKey:@"selectArray"] count]; two3++) {
                            
                            for (int one4 = one3 + 1; one4 < [selectMatchArray count]; one4++) {
                                NSDictionary *dic4 = selectMatchArray[one4];
                                
                                for (int two4 = 0; two4 < [[dic4 objectForKey:@"selectArray"] count]; two4++) {
                                    
                                    NSMutableArray *tempArr = [NSMutableArray array];
                                    if (ballType == 0) {    // 竞彩足球
                                        [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one1 two:two1 selectMatchArray:selectMatchArray]];
                                        [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one2 two:two2 selectMatchArray:selectMatchArray]];
                                        [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one3 two:two3 selectMatchArray:selectMatchArray]];
                                        [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one4 two:two4 selectMatchArray:selectMatchArray]];
                                    }else {
                                        [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one1 two:two1 selectMatchArray:selectMatchArray]];
                                        [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one2 two:two2 selectMatchArray:selectMatchArray]];
                                        [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one3 two:two3 selectMatchArray:selectMatchArray]];
                                        [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one4 two:two4 selectMatchArray:selectMatchArray]];
                                    }
                                    
                                    // 预测奖金
                                    float odds = 4;
                                    for (int temp = 0; temp < tempArr.count; temp++) {
                                        odds = odds * [[[tempArr objectAtIndex:temp] objectForKey:@"odds"] floatValue];
                                    }
                                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                                    [dict setObject:tempArr forKey:@"team"];    // 单注组合
                                    [dict setObject:[NSString stringWithFormat:@"%.2f", odds] forKey:@"castMoney"];     // 预测奖金
                                    [dict setObject:[NSString stringWithFormat:@"4"] forKey:@"passNumber"];             // 过关
                                    [dict setObject:[NSString stringWithFormat:@"1"] forKey:@"playCount"];              // 注数
                                    [dict setObject:[NSString stringWithFormat:@"4串1"] forKey:@"GGWay"];               // 串数
                                    
                                    [resultArray addObject:dict];
                                    [dict release];
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    return resultArray;
}

// 奖金优化 5串1 玩法
// 获取优化后对阵信息
+ (NSMutableArray *)fiveBunch: (NSMutableArray *)selectMatchArray arrayWithResult:(NSMutableArray *)resultArray ballType:(int)ballType {
    
    for (int one1 = 0; one1 < [selectMatchArray count] - 1; one1++) {
        NSDictionary *dic1 = selectMatchArray[one1];
        
        for (int two1 = 0; two1 < [[dic1 objectForKey:@"selectArray"] count]; two1++) {
            
            for (int one2 = one1 + 1; one2 < [selectMatchArray count]; one2++) {
                NSDictionary *dic2 = selectMatchArray[one2];
                
                for (int two2 = 0; two2 < [[dic2 objectForKey:@"selectArray"] count]; two2++) {
                    
                    for (int one3 = one2 + 1; one3 < [selectMatchArray count]; one3++) {
                        NSDictionary *dic3 = selectMatchArray[one3];
                        
                        for (int two3 = 0; two3 < [[dic3 objectForKey:@"selectArray"] count]; two3++) {
                            
                            for (int one4 = one3 + 1; one4 < [selectMatchArray count]; one4++) {
                                NSDictionary *dic4 = selectMatchArray[one4];
                                
                                for (int two4 = 0; two4 < [[dic4 objectForKey:@"selectArray"] count]; two4++) {
                                    
                                    for (int one5 = one4 + 1; one5 < [selectMatchArray count]; one5++) {
                                        NSDictionary *dic5 = selectMatchArray[one5];
                                        
                                        for (int two5 = 0; two5 < [[dic5 objectForKey:@"selectArray"] count]; two5++) {
                                            
                                            NSMutableArray *tempArr = [NSMutableArray array];
                                            if (ballType == 0) {    // 竞彩足球
                                                [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one1 two:two1 selectMatchArray:selectMatchArray]];
                                                [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one2 two:two2 selectMatchArray:selectMatchArray]];
                                                [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one3 two:two3 selectMatchArray:selectMatchArray]];
                                                [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one4 two:two4 selectMatchArray:selectMatchArray]];
                                                [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one5 two:two5 selectMatchArray:selectMatchArray]];
                                            }else {
                                                [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one1 two:two1 selectMatchArray:selectMatchArray]];
                                                [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one2 two:two2 selectMatchArray:selectMatchArray]];
                                                [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one3 two:two3 selectMatchArray:selectMatchArray]];
                                                [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one4 two:two4 selectMatchArray:selectMatchArray]];
                                                [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one5 two:two5 selectMatchArray:selectMatchArray]];
                                            }
                                            
                                            // 预测奖金
                                            float odds = 5;
                                            for (int temp = 0; temp < tempArr.count; temp++) {
                                                odds = odds * [[[tempArr objectAtIndex:temp] objectForKey:@"odds"] floatValue];
                                            }
                                            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                                            [dict setObject:tempArr forKey:@"team"];    // 单注组合
                                            [dict setObject:[NSString stringWithFormat:@"%.2f", odds] forKey:@"castMoney"];     // 预测奖金
                                            [dict setObject:[NSString stringWithFormat:@"5"] forKey:@"passNumber"];             // 过关
                                            [dict setObject:[NSString stringWithFormat:@"1"] forKey:@"playCount"];              // 注数
                                            [dict setObject:[NSString stringWithFormat:@"5串1"] forKey:@"GGWay"];               // 串数
                                            
                                            [resultArray addObject:dict];
                                            [dict release];
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    return resultArray;
}

// 奖金优化 6串1 玩法
// 获取优化后对阵信息
+ (NSMutableArray *)sixBunch: (NSMutableArray *)selectMatchArray arrayWithResult:(NSMutableArray *)resultArray ballType:(int)ballType {
    
    for (int one1 = 0; one1 < [selectMatchArray count] - 1; one1++) {
        NSDictionary *dic1 = selectMatchArray[one1];
        
        for (int two1 = 0; two1 < [[dic1 objectForKey:@"selectArray"] count]; two1++) {
            
            for (int one2 = one1 + 1; one2 < [selectMatchArray count]; one2++) {
                NSDictionary *dic2 = selectMatchArray[one2];
                
                for (int two2 = 0; two2 < [[dic2 objectForKey:@"selectArray"] count]; two2++) {
                    
                    for (int one3 = one2 + 1; one3 < [selectMatchArray count]; one3++) {
                        NSDictionary *dic3 = selectMatchArray[one3];
                        
                        for (int two3 = 0; two3 < [[dic3 objectForKey:@"selectArray"] count]; two3++) {
                            
                            for (int one4 = one3 + 1; one4 < [selectMatchArray count]; one4++) {
                                NSDictionary *dic4 = selectMatchArray[one4];
                                
                                for (int two4 = 0; two4 < [[dic4 objectForKey:@"selectArray"] count]; two4++) {
                                    
                                    for (int one5 = one4 + 1; one5 < [selectMatchArray count]; one5++) {
                                        NSDictionary *dic5 = selectMatchArray[one5];
                                        
                                        for (int two5 = 0; two5 < [[dic5 objectForKey:@"selectArray"] count]; two5++) {
                                            
                                            for (int one6 = one5 + 1; one6 < [selectMatchArray count]; one6++) {
                                                NSDictionary *dic6 = selectMatchArray[one6];
                                                
                                                for (int two6 = 0; two6 < [[dic6 objectForKey:@"selectArray"] count]; two6++) {
                                                    
                                                    NSMutableArray *tempArr = [NSMutableArray array];
                                                    if (ballType == 0) {    // 竞彩足球
                                                        [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one1 two:two1 selectMatchArray:selectMatchArray]];
                                                        [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one2 two:two2 selectMatchArray:selectMatchArray]];
                                                        [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one3 two:two3 selectMatchArray:selectMatchArray]];
                                                        [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one4 two:two4 selectMatchArray:selectMatchArray]];
                                                        [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one5 two:two5 selectMatchArray:selectMatchArray]];
                                                        [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one6 two:two6 selectMatchArray:selectMatchArray]];
                                                    }else {
                                                        [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one1 two:two1 selectMatchArray:selectMatchArray]];
                                                        [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one2 two:two2 selectMatchArray:selectMatchArray]];
                                                        [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one3 two:two3 selectMatchArray:selectMatchArray]];
                                                        [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one4 two:two4 selectMatchArray:selectMatchArray]];
                                                        [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one5 two:two5 selectMatchArray:selectMatchArray]];
                                                        [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one6 two:two6 selectMatchArray:selectMatchArray]];
                                                    }
                                                    
                                                    // 预测奖金
                                                    float odds = 6;
                                                    for (int temp = 0; temp < tempArr.count; temp++) {
                                                        odds = odds * [[[tempArr objectAtIndex:temp] objectForKey:@"odds"] floatValue];
                                                    }
                                                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                                                    [dict setObject:tempArr forKey:@"team"];    // 单注组合
                                                    [dict setObject:[NSString stringWithFormat:@"%.2f", odds] forKey:@"castMoney"];     // 预测奖金
                                                    [dict setObject:[NSString stringWithFormat:@"6"] forKey:@"passNumber"];             // 过关
                                                    [dict setObject:[NSString stringWithFormat:@"1"] forKey:@"playCount"];              // 注数
                                                    [dict setObject:[NSString stringWithFormat:@"6串1"] forKey:@"GGWay"];               // 串数
                                                    
                                                    [resultArray addObject:dict];
                                                    [dict release];
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    return resultArray;
}

// 奖金优化 7串1 玩法
// 获取优化后对阵信息
+ (NSMutableArray *)sevenBunch: (NSMutableArray *)selectMatchArray arrayWithResult:(NSMutableArray *)resultArray ballType:(int)ballType {
    
    for (int one1 = 0; one1 < [selectMatchArray count] - 1; one1++) {
        NSDictionary *dic1 = selectMatchArray[one1];
        
        for (int two1 = 0; two1 < [[dic1 objectForKey:@"selectArray"] count]; two1++) {
            
            for (int one2 = one1 + 1; one2 < [selectMatchArray count]; one2++) {
                NSDictionary *dic2 = selectMatchArray[one2];
                
                for (int two2 = 0; two2 < [[dic2 objectForKey:@"selectArray"] count]; two2++) {
                    
                    for (int one3 = one2 + 1; one3 < [selectMatchArray count]; one3++) {
                        NSDictionary *dic3 = selectMatchArray[one3];
                        
                        for (int two3 = 0; two3 < [[dic3 objectForKey:@"selectArray"] count]; two3++) {
                            
                            for (int one4 = one3 + 1; one4 < [selectMatchArray count]; one4++) {
                                NSDictionary *dic4 = selectMatchArray[one4];
                                
                                for (int two4 = 0; two4 < [[dic4 objectForKey:@"selectArray"] count]; two4++) {
                                    
                                    for (int one5 = one4 + 1; one5 < [selectMatchArray count]; one5++) {
                                        NSDictionary *dic5 = selectMatchArray[one5];
                                        
                                        for (int two5 = 0; two5 < [[dic5 objectForKey:@"selectArray"] count]; two5++) {
                                            
                                            for (int one6 = one5 + 1; one6 < [selectMatchArray count]; one6++) {
                                                NSDictionary *dic6 = selectMatchArray[one6];
                                                
                                                for (int two6 = 0; two6 < [[dic6 objectForKey:@"selectArray"] count]; two6++) {
                                                    
                                                    for (int one7 = one6 + 1; one7 < [selectMatchArray count]; one7++) {
                                                        NSDictionary *dic7 = selectMatchArray[one7];
                                                        
                                                        for (int two7 = 0; two7 < [[dic7 objectForKey:@"selectArray"] count]; two7++) {
                                                            
                                                            NSMutableArray *tempArr = [NSMutableArray array];
                                                            if (ballType == 0) {    // 竞彩足球
                                                                [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one1 two:two1 selectMatchArray:selectMatchArray]];
                                                                [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one2 two:two2 selectMatchArray:selectMatchArray]];
                                                                [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one3 two:two3 selectMatchArray:selectMatchArray]];
                                                                [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one4 two:two4 selectMatchArray:selectMatchArray]];
                                                                [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one5 two:two5 selectMatchArray:selectMatchArray]];
                                                                [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one6 two:two6 selectMatchArray:selectMatchArray]];
                                                                [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one7 two:two7 selectMatchArray:selectMatchArray]];
                                                            }else {
                                                                [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one1 two:two1 selectMatchArray:selectMatchArray]];
                                                                [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one2 two:two2 selectMatchArray:selectMatchArray]];
                                                                [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one3 two:two3 selectMatchArray:selectMatchArray]];
                                                                [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one4 two:two4 selectMatchArray:selectMatchArray]];
                                                                [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one5 two:two5 selectMatchArray:selectMatchArray]];
                                                                [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one6 two:two6 selectMatchArray:selectMatchArray]];
                                                                [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one7 two:two7 selectMatchArray:selectMatchArray]];
                                                            }
                                                            
                                                            // 预测奖金
                                                            float odds = 7;
                                                            for (int temp = 0; temp < tempArr.count; temp++) {
                                                                odds = odds * [[[tempArr objectAtIndex:temp] objectForKey:@"odds"] floatValue];
                                                            }
                                                            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                                                            [dict setObject:tempArr forKey:@"team"];    // 单注组合
                                                            [dict setObject:[NSString stringWithFormat:@"%.2f", odds] forKey:@"castMoney"];     // 预测奖金
                                                            [dict setObject:[NSString stringWithFormat:@"7"] forKey:@"passNumber"];             // 过关
                                                            [dict setObject:[NSString stringWithFormat:@"1"] forKey:@"playCount"];              // 注数
                                                            [dict setObject:[NSString stringWithFormat:@"7串1"] forKey:@"GGWay"];               // 串数
                                                            
                                                            [resultArray addObject:dict];
                                                            [dict release];
                                                            
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    return resultArray;
}

// 奖金优化 8串1 玩法
// 获取优化后对阵信息
+ (NSMutableArray *)eightBunch: (NSMutableArray *)selectMatchArray arrayWithResult:(NSMutableArray *)resultArray ballType:(int)ballType {
    
    for (int one1 = 0; one1 < [selectMatchArray count] - 1; one1++) {
        NSDictionary *dic1 = selectMatchArray[one1];
        
        for (int two1 = 0; two1 < [[dic1 objectForKey:@"selectArray"] count]; two1++) {
            
            for (int one2 = one1 + 1; one2 < [selectMatchArray count]; one2++) {
                NSDictionary *dic2 = selectMatchArray[one2];
                
                for (int two2 = 0; two2 < [[dic2 objectForKey:@"selectArray"] count]; two2++) {
                    
                    for (int one3 = one2 + 1; one3 < [selectMatchArray count]; one3++) {
                        NSDictionary *dic3 = selectMatchArray[one3];
                        
                        for (int two3 = 0; two3 < [[dic3 objectForKey:@"selectArray"] count]; two3++) {
                            
                            for (int one4 = one3 + 1; one4 < [selectMatchArray count]; one4++) {
                                NSDictionary *dic4 = selectMatchArray[one4];
                                
                                for (int two4 = 0; two4 < [[dic4 objectForKey:@"selectArray"] count]; two4++) {
                                    
                                    for (int one5 = one4 + 1; one5 < [selectMatchArray count]; one5++) {
                                        NSDictionary *dic5 = selectMatchArray[one5];
                                        
                                        for (int two5 = 0; two5 < [[dic5 objectForKey:@"selectArray"] count]; two5++) {
                                            
                                            for (int one6 = one5 + 1; one6 < [selectMatchArray count]; one6++) {
                                                NSDictionary *dic6 = selectMatchArray[one6];
                                                
                                                for (int two6 = 0; two6 < [[dic6 objectForKey:@"selectArray"] count]; two6++) {
                                                    
                                                    for (int one7 = one6 + 1; one7 < [selectMatchArray count]; one7++) {
                                                        NSDictionary *dic7 = selectMatchArray[one7];
                                                        
                                                        for (int two7 = 0; two7 < [[dic7 objectForKey:@"selectArray"] count]; two7++) {
                                                            
                                                            for (int one8 = one7 + 1; one8 < [selectMatchArray count]; one8++) {
                                                                NSDictionary *dic8 = selectMatchArray[one8];
                                                                
                                                                for (int two8 = 0; two8 < [[dic8 objectForKey:@"selectArray"] count]; two8++) {
                                                                    
                                                                    NSMutableArray *tempArr = [NSMutableArray array];
                                                                    if (ballType == 0) {    // 竞彩足球
                                                                        [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one1 two:two1 selectMatchArray:selectMatchArray]];
                                                                        [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one2 two:two2 selectMatchArray:selectMatchArray]];
                                                                        [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one3 two:two3 selectMatchArray:selectMatchArray]];
                                                                        [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one4 two:two4 selectMatchArray:selectMatchArray]];
                                                                        [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one5 two:two5 selectMatchArray:selectMatchArray]];
                                                                        [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one6 two:two6 selectMatchArray:selectMatchArray]];
                                                                        [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one7 two:two7 selectMatchArray:selectMatchArray]];
                                                                        [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one8 two:two8 selectMatchArray:selectMatchArray]];
                                                                    }else {
                                                                        [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one1 two:two1 selectMatchArray:selectMatchArray]];
                                                                        [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one2 two:two2 selectMatchArray:selectMatchArray]];
                                                                        [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one3 two:two3 selectMatchArray:selectMatchArray]];
                                                                        [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one4 two:two4 selectMatchArray:selectMatchArray]];
                                                                        [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:one5 two:two5 selectMatchArray:selectMatchArray]];
                                                                        [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one6 two:two6 selectMatchArray:selectMatchArray]];
                                                                        [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one7 two:two7 selectMatchArray:selectMatchArray]];
                                                                        [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:one8 two:two8 selectMatchArray:selectMatchArray]];
                                                                    }
                                                                    
                                                                    // 预测奖金
                                                                    float odds = 8;
                                                                    for (int temp = 0; temp < tempArr.count; temp++) {
                                                                        odds = odds * [[[tempArr objectAtIndex:temp] objectForKey:@"odds"] floatValue];
                                                                    }
                                                                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                                                                    [dict setObject:tempArr forKey:@"team"];    // 单注组合
                                                                    [dict setObject:[NSString stringWithFormat:@"%.2f", odds] forKey:@"castMoney"];     // 预测奖金
                                                                    [dict setObject:[NSString stringWithFormat:@"8"] forKey:@"passNumber"];             // 过关
                                                                    [dict setObject:[NSString stringWithFormat:@"1"] forKey:@"playCount"];              // 注数
                                                                    [dict setObject:[NSString stringWithFormat:@"8串1"] forKey:@"GGWay"];               // 串数
                                                                    
                                                                    [resultArray addObject:dict];
                                                                    [dict release];
                                                                    
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    return resultArray;
}

// 获取优化后对阵信息
+ (NSMutableDictionary *)getFootBallTeamWithOne:(int)one two:(int)two selectMatchArray:(NSMutableArray *)selectMatchArray {
    
    NSString *results = nil;        // 赛果
    NSString * odds = nil;          // 赔率
    NSString *resultsKey = nil;     // 赛果代号
    NSDictionary *dic = selectMatchArray[one];
    
    NSArray *arr = [dic objectForKey:@"selectArray"];
    NSInteger temp = [[NSString stringWithFormat:@"%@", arr[two]] integerValue];
    resultsKey = [NSString stringWithFormat:@"%ld", (long)temp];
    
    // 竞彩足球赛果对应的代码, 算出赛果
    switch ([[dic objectForKey:@"selectType"] intValue]) {
        case 0:     // 让球胜平负
        {
            if (temp == 1) {
                results = @"主胜";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"win"];
            }else if (temp == 2) {
                results = @"平";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"flat"];
            }else if (temp == 3) {
                results = @"主负";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"lose"];
            }
        }
            break;
        case 1:     // 胜平负
        {
            if (temp == 1) {
                results = @"主胜";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"spfwin"];
            }else if (temp == 2) {
                results = @"平";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"spfflat"];
            }else if (temp == 3) {
                results = @"主负";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"spflose"];
            }
        }
            break;
        case 2:     // 比分
        {
            if (temp == 1) { // 1:0 (主胜)
                results = @"1:0";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"s10"];
            }else if (temp == 2) {  // 2:0 (主胜)
                results = @"2:0";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"s20"];
            }else if (temp == 3) {  // 2:1 (主胜)
                results = @"2:1";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"s21"];
            }else if (temp == 4) {  // 3:0 (主胜)
                results = @"3:0";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"s30"];
            }else if (temp == 5) {  // 3:1 (主胜)
                results = @"3:1";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"s31"];
            }else if (temp == 6) {  // 3:2 (主胜)
                results = @"3:2";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"s32"];
            }else if (temp == 7) {  // 4:0 (主胜)
                results = @"4:0";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"s40"];
            }else if (temp == 8) {  // 4:1 (主胜)
                results = @"4:1";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"s41"];
            }else if (temp == 9) {  // 4:2 (主胜)
                results = @"4:2";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"s42"];
            }else if (temp == 10) { // 5:0 (主胜)
                results = @"5:0";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"s50"];
            }else if (temp == 11) { // 5:1 (主胜)
                results = @"5:1";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"s51"];
            }else if (temp == 12) { // 5:2 (主胜)
                results = @"5:2";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"s52"];
            }else if (temp == 13) { // 胜其他 (主胜)
                results = @"胜其他";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"sother"];
            }else if (temp == 14) { // 0:0 (平)
                results = @"0:0";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"p00"];
            }else if (temp == 15) { // 1:1 (平)
                results = @"1:1";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"p11"];
            }else if (temp == 16) { // 2:2 (平)
                results = @"2:2";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"p22"];
            }else if (temp == 17) { // 3:3 (平)
                results = @"3:3";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"p33"];
            }else if (temp == 18) { // 平其他 (平)
                results = @"平其他";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"pother"];
            }else if (temp == 19) { // 0:1 (主负)
                results = @"0:1";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"f01"];
            }else if (temp == 20) { // 0:2 (主负)
                results = @"0:2";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"f02"];
            }else if (temp == 21) { // 1:2 (主负)
                results = @"1:2";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"f12"];
            }else if (temp == 22) { // 0:3 (主负)
                results = @"0:3";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"f03"];
            }else if (temp == 23) { // 1:3 (主负)
                results = @"1:3";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"f13"];
            }else if (temp == 24) { // 2:3 (主负)
                results = @"2:3";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"f23"];
            }else if (temp == 25) { // 0:4 (主负)
                results = @"0:4";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"f04"];
            }else if (temp == 26) { // 1:4 (主负)
                results = @"1:4";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"f14"];
            }else if (temp == 27) { // 2:4 (主负)
                results = @"2:4";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"f24"];
            }else if (temp == 28) { // 0:5 (主负)
                results = @"0:5";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"f05"];
            }else if (temp == 29) { // 1:5 (主负)
                results = @"1:5";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"f15"];
            }else if (temp == 30) { // 2:5 (主负)
                results = @"2:5";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"f25"];
            }else if (temp == 31) { // 负其他 (主负)
                results = @"负其他";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"fother"];
            }
        }
            break;
        case 3:     // 总进球
        {
            results = [NSString stringWithFormat:@"%ld球", (long)temp - 1];
            
            NSString *cur = [NSString stringWithFormat:@"in%d", two];
            odds = [[dic objectForKey:@"selectRowDic"] objectForKey:cur];
        }
            break;
        case 4:     // 半全场
        {
            if (temp == 1) { // 胜胜
                results = @"胜胜";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"ss"];
            }else if (temp == 2) {  // 胜平
                results = @"胜平";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"sp"];
            }else if (temp == 3) {  // 胜负
                results = @"胜负";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"sf"];
            }else if (temp == 4) {  // 平胜
                results = @"平胜";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"ps"];
            }else if (temp == 5) {  // 平平
                results = @"平平";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"pp"];
            }else if (temp == 6) {  // 平负
                results = @"平负";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"pf"];
            }else if (temp == 7) {  // 负胜
                results = @"负胜";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"fs"];
            }else if (temp == 8) {  // 负平
                results = @"负平";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"fp"];
            }else if (temp == 9) {  // 负负
                results = @"负负";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"ff"];
            }
        }
            break;
            
        default:
            break;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:results == nil ? @"" : results forKey:@"results"];
    [dict setObject:odds == nil ? @"" : odds forKey:@"odds"];
    [dict setObject:resultsKey == nil ? @"" : resultsKey forKey:@"resultsKey"];
    [dict setObject:[[dic objectForKey:@"selectRowDic"] objectForKey:@"mainTeam"] forKey:@"teamName"];
    [dict setObject:[[dic objectForKey:@"selectRowDic"] objectForKey:@"matchId"] forKey:@"matchId"];              // 赛事ID
    
    return dict;
}

#pragma mark - 获取竞彩篮球优化后对阵信息
+ (NSMutableDictionary *)getBasketBallTeamWithOne:(int)one two:(int)two selectMatchArray:(NSMutableArray *)selectMatchArray {
    
    NSString *results = nil;        // 赛果
    NSString * odds = nil;          // 赔率
    NSString *resultsKey = nil;     // 赛果代号
    NSDictionary *dic = selectMatchArray[one];
    
    NSArray *arr = [dic objectForKey:@"selectArray"];
    NSInteger temp = [[NSString stringWithFormat:@"%@", arr[two]] integerValue];
    resultsKey = [NSString stringWithFormat:@"%ld", (long)temp];
    
    // 竞彩足球赛果对应的代码, 算出赛果
    switch ([[dic objectForKey:@"selectType"] intValue]) {
        case 0:     // 胜负
        {
            if (temp == 1) {
                results = @"主负";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"mainLose"];
            }else if (temp == 2) {
                results = @"主胜";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"mainWin"];
            }
        }
            break;
        case 1:     // 让分胜负
        {
            if (temp == 1) {
                results = @"主负";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"letMainLose"];
            }else if (temp == 2) {
                results = @"主胜";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"letMainWin"];
            }
        }
            break;
        case 2:     // 胜负差
        {
            if (temp == 1) { // 客胜1-5
                results = @"客胜1-5";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"differGuest1_5"];
            }else if (temp == 2) {  // 主胜1-5
                results = @"主胜1-5";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"differMain1_5"];
            }else if (temp == 3) {  // 客胜6-10
                results = @"客胜6-10";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"differGuest6_10"];
            }else if (temp == 4) {  // 主胜6-10
                results = @"主胜6-10";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"differMain6_10"];
            }else if (temp == 5) {  // 客胜11-15
                results = @"客胜11-15";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"differGuest11_15"];
            }else if (temp == 6) {  // 主胜11-15
                results = @"主胜11-15";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"differMain11_15"];
            }else if (temp == 7) {  // 客胜16-20
                results = @"客胜16-20";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"differGuest16_20"];
            }else if (temp == 8) {  // 主胜16-20
                results = @"主胜16-20";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"differMain16_20"];
            }else if (temp == 9) {  // 客胜21-25
                results = @"客胜21-25";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"differGuest21_25"];
            }else if (temp == 10) { // 主胜21-25
                results = @"主胜21-25";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"differMain21_25"];
            }else if (temp == 11) { // 客胜26+
                results = @"客胜26+";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"differGuest26"];
            }else if (temp == 12) { // 主胜26+
                results = @"主胜26+";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"differMain26"];
            }
            
            odds = [NSString stringWithFormat:@"%.2f", [odds floatValue]];
        }
            break;
        case 3:     // 大小分
        {
            if (temp == 1) {
                results = @"大分";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"big"];
            }else if (temp == 2) {
                results = @"小分";
                odds = [[dic objectForKey:@"selectRowDic"] objectForKey:@"small"];
            }
        }
            break;
        case 4:     // 混合投注（暂不支持奖金优化）
        {
            
        }
            break;
            
        default:
            break;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:results == nil ? @"" : results forKey:@"results"];
    [dict setObject:odds == nil ? @"" : odds forKey:@"odds"];
    [dict setObject:resultsKey == nil ? @"" : resultsKey forKey:@"resultsKey"];
    [dict setObject:[[dic objectForKey:@"selectRowDic"] objectForKey:@"mainTeam"] forKey:@"teamName"];
    [dict setObject:[[dic objectForKey:@"selectRowDic"] objectForKey:@"matchId"] forKey:@"matchId"];              // 赛事ID
    
    return dict;
}

#pragma mark - 奖金优化算法 (获取对阵消息)单关
/** n串1 该方法暂不兼容混合投注的胆算法 (刘科)*/
/** 奖金优化算法
 @param  selectMatchArray   原对阵
 @param  ballType   竞彩彩种 (0:足球  1:篮球)
 @return 奖金优化对阵信息 */
+ (NSMutableArray *)getOneMatchWithArray:(NSMutableArray *)selectMatchArray ballType:(int)ballType{
    NSMutableArray *oneMatchArr = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [selectMatchArray count]; i++) {
        NSDictionary *dic = selectMatchArray[i];
        
        NSMutableArray *tempArr = [NSMutableArray array];
        for (int i1 = 0; i1 < [[dic objectForKey:@"selectArray"] count]; i1++) {
            
            if (ballType == 0) {    // 竞彩足球
                [tempArr addObject:[CalculateBetCount getFootBallTeamWithOne:i two:i1 selectMatchArray:selectMatchArray]];
            }else {     // 竞彩篮球
                [tempArr addObject:[CalculateBetCount getBasketBallTeamWithOne:i two:i1 selectMatchArray:selectMatchArray]];
            }
            
            // 预测奖金
            float odds = 2;
            for (int temp = 0; temp < tempArr.count; temp++) {
                odds = odds * [[[tempArr objectAtIndex:temp] objectForKey:@"odds"] floatValue];
            }
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:tempArr forKey:@"team"];    // 单注组合
            [dict setObject:[NSString stringWithFormat:@"%.2f", odds] forKey:@"castMoney"];     // 预测奖金
            [dict setObject:[NSString stringWithFormat:@"2"] forKey:@"passNumber"];             // 过关
            [dict setObject:[NSString stringWithFormat:@"1"] forKey:@"playCount"];              // 注数
            [dict setObject:[NSString stringWithFormat:@"2串1"] forKey:@"GGWay"];               // 串数
            
            [oneMatchArr addObject:dict];
            [dict release];
            
        }
    }
    
    return oneMatchArr;
}

@end
