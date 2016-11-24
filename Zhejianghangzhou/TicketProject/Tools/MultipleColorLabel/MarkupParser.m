//
//  MarkupParser.m
//  CoreTextMagazine
//
//  Created by zyq on 13-4-25.
//  Copyright (c) 2013年 zyq. All rights reserved.
//

#import "MarkupParser.h"
#import "Globals.h"

#define UIColorFromRGB(rgbValue) \
[UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:1.0]

/*callbacks*/
static void deallocCallback(void *ref)
{
    [(id)ref release];
}
static CGFloat ascentCallback(void *ref)
{
    return [(NSString*)[(NSDictionary*)ref objectForKey:@"height"]floatValue];
}
static CGFloat descentCallback(void *ref)
{
    return [(NSString *)[(NSDictionary *)ref objectForKey:@"descent"]floatValue];
}
static CGFloat widthCallback(void *ref)
{
    return [(NSString *)[(NSDictionary*)ref objectForKey:@"width"]floatValue];
}

@implementation MarkupParser
@synthesize font,color,strokeColor,strokeWidth;
@synthesize images;

- (id)init {
    self = [super init];
    if (self) {
        self.font = @"ArialMT";
        self.fontSize = XFIponeIpadFontSize14;
        self.color = [UIColor blackColor];
        self.strokeColor = [UIColor whiteColor];
        self.strokeWidth = 0.0;
        self.images = [NSMutableArray array];
    }
    return self;
}

- (id)initWithFontSize:(CGFloat)fontSize {
    self = [super init];
    if (self) {
        self.font = @"ArialMT";
        self.fontSize = fontSize;
        self.color = [UIColor blackColor];
        self.strokeColor = [UIColor whiteColor];
        self.strokeWidth = 0.0;
        self.images = [NSMutableArray array];
    }
    return self;
}

- (NSAttributedString *)attrStringFromMarkup:(NSString *)markup {
    if (markup == nil || markup.length == 0) {
        markup = @"";
    }
    
    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc]initWithString:@""];//1
    NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:@"(.*?)(<[^>]+>|\\z)" options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators error:nil];//2
    NSArray *chunks = [regex matchesInString:markup options:0 range:NSMakeRange(0, [markup length])];
    [regex release];
    
    for (NSTextCheckingResult *b in chunks) {
        NSArray *parts = [[markup substringWithRange:b.range] componentsSeparatedByString:@"<"];//1
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)self.font, self.fontSize, NULL);
        //apply the current text style //2
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:(id)self.color.CGColor,kCTForegroundColorAttributeName,(id)fontRef,kCTFontAttributeName,(id)self.strokeColor.CGColor,(NSString *)kCTStrokeColorAttributeName,(id)[NSNumber numberWithFloat:self.strokeWidth],(NSString *)kCTStrokeWidthAttributeName, nil];
        
        NSAttributedString *afterArrtiStr = [[NSAttributedString alloc] initWithString:[parts objectAtIndex:0] attributes:attrs];
        
        [aString appendAttributedString:afterArrtiStr];
        [afterArrtiStr release];
        CFRelease(fontRef);
        
        //handle new formatting tag //3
        if ([parts count] > 1) {
            NSString *tag = (NSString *)[parts objectAtIndex:1];
            
            if ([tag hasPrefix:@"font"]) {
                NSRegularExpression *scolorRegex = [[[NSRegularExpression alloc]initWithPattern:@"(?<=strokeColor=\")\\w+" options:0 error:NULL]autorelease];
                [scolorRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                    if ([[tag substringWithRange:result.range] isEqualToString:@"none"]) {
                        self.strokeWidth = 0.0;
                    }else
                    {
                        self.strokeWidth = -3.0f;
                        SEL colorSel = NSSelectorFromString([NSString stringWithFormat:@"%@Color",[tag substringWithRange:result.range]]);
                        self.strokeColor = [UIColor performSelector:colorSel];
                    }
                }];
                //color
                NSRegularExpression *colorRegex = [[[NSRegularExpression alloc]initWithPattern:@"(?<=color=\")\\w+" options:0 error:NULL]autorelease];
                [colorRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                    
                    NSString *str = [tag substringWithRange:result.range];
                    if ([str isEqualToString:@"red"]) {
                        self.color = [UIColor colorWithRed:187.0/255.0 green:48.0/255.0 blue:65.0/255.0 alpha:1.0];
                    } else if ([str isEqualToString:@"blue"]) {
                        self.color = [UIColor colorWithRed:14.0/255.0 green:86.0/255.0 blue:176.0/255.0 alpha:1.0];
                    } else if ([str length] >= 6) {
                        self.color = [UIColor colorWithRed:[self getColorWithText:[str substringWithRange:NSMakeRange(0,2)]] green:[self getColorWithText:[str substringWithRange:NSMakeRange(2,2)]] blue:[self getColorWithText:[str substringWithRange:NSMakeRange(4,2)]] alpha:1.0];
                    } else {
                        self.color = [UIColor blackColor];
                    }
                }];
                
                //face
                NSRegularExpression *faceRegex = [[[NSRegularExpression alloc]initWithPattern:@"(?<=face=\")[^\"]+" options:0 error:NULL]autorelease];
                [faceRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                    self.font = [tag substringWithRange:result.range];
                }];
            }//end of font parsing
            
            if ([tag hasPrefix:@"img"]) {
                __block NSNumber *width = [NSNumber numberWithInt:0];
                __block NSNumber *height = [NSNumber numberWithInt:0];
                __block NSString *fileName = @"";
                
                //width
                NSRegularExpression *widthRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=width=\")[^\"]+" options:0 error:NULL]autorelease];
                [widthRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                    width = [NSNumber numberWithInt:[[tag substringWithRange:result.range] intValue]];
                }];
                
                //height
                NSRegularExpression *faceRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=height=\")[^\"]+" options:0 error:NULL]autorelease];
                [faceRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                    height = [NSNumber numberWithInt:[[tag substringWithRange:result.range]intValue]];
                }];
                
                //image
                NSRegularExpression *srcRegex = [[[NSRegularExpression alloc]initWithPattern:@"(?<=src=\")[^\"]+" options:0 error:NULL]autorelease];
                [srcRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                    fileName = [tag substringWithRange:result.range];
                }];
                
                //add the image for drawing
                [self.images addObject:[NSDictionary dictionaryWithObjectsAndKeys:width,@"width",height,@"height",fileName,@"fileName",[NSNumber numberWithInteger:[aString length]],@"location", nil]];
                
                //render empty space for drawing the image in the text //1
                CTRunDelegateCallbacks callbacks;
                callbacks.version = kCTRunDelegateVersion1;
                callbacks.getAscent = ascentCallback;
                callbacks.getDescent = descentCallback;
                callbacks.getWidth = widthCallback;
                callbacks.dealloc = deallocCallback;
                
                NSDictionary *imgAttr = [[NSDictionary dictionaryWithObjectsAndKeys:width,@"width",height,@"height", nil]retain];
                CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, imgAttr);
                NSDictionary *attrDictionaryDelegate = [NSDictionary dictionaryWithObjectsAndKeys:(id)delegate,(NSString*)kCTRunDelegateAttributeName, nil];
                
                [aString appendAttributedString:[[[NSAttributedString alloc]initWithString:@" " attributes:attrDictionaryDelegate] autorelease]];
            }
        }
    }
    
    return [(NSAttributedString*)aString autorelease];
}

- (CGFloat)getColorWithText:(NSString *)textColorNumber {
    NSInteger colorNumber = 0;
    
    for (NSInteger charartInt = 0; charartInt < textColorNumber.length && charartInt < 2; charartInt++) {
        colorNumber *= 16;
        NSString *singleNum = [textColorNumber substringWithRange:NSMakeRange(charartInt, 1)];//一个一个字符去取组号码，（因为号码都是个位数且已经消去空格）
        if ([singleNum isEqualToString:@"a"] || [singleNum isEqualToString:@"A"]) {
            colorNumber += 10;
        } else if ([singleNum isEqualToString:@"b"] || [singleNum isEqualToString:@"B"]) {
            colorNumber += 11;
        } else if ([singleNum isEqualToString:@"c"] || [singleNum isEqualToString:@"C"]) {
            colorNumber += 12;
        } else if ([singleNum isEqualToString:@"d"] || [singleNum isEqualToString:@"D"]) {
            colorNumber += 13;
        } else if ([singleNum isEqualToString:@"e"] || [singleNum isEqualToString:@"E"]) {
            colorNumber += 14;
        } else if ([singleNum isEqualToString:@"f"] || [singleNum isEqualToString:@"F"]) {
            colorNumber += 15;
        } else {
            colorNumber += [singleNum integerValue];
        }
    }
    return colorNumber/255.0f;
}

- (void)dealloc {
    self.font=nil;
    self.color=nil;
    self.strokeColor=nil;
    self.images=nil;
    
    [super dealloc];
}
@end
