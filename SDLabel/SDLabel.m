//
//  SDLabel.m
//  SDLabel
//
//  Created by xuelin on 2018/7/21.
//  Copyright © 2018年 upchina. All rights reserved.
//

#import "SDLabel.h"
#import <CoreText/CoreText.h>
#import "UIView+Additions.h"

static inline CGFLOAT_TYPE CGFloat_ceil(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return ceil(cgfloat);
#else
    return ceilf(cgfloat);
#endif
}


@implementation SDLabel {
    NSInteger _drawFlag;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _drawFlag = arc4random();
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        _textAlignment = NSTextAlignmentLeft;
        _textColor = [UIColor blackColor];
        _font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        _lineSpace = 5;
        _numberOfLines = 0;
    }
    return self;
}

//使用coretext将文本绘制到图片。
- (void)setText:(NSString *)text{
    if (text == nil || text.length <= 0) {
        self.layer.contents = nil;
        return;
    }
    [self draw:text];
}

- (void)draw:(NSString *)text {
    NSInteger flag = _drawFlag;
    __block CGSize size = self.frame.size;
    UIColor *backgroundColor = self.backgroundColor;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *temp = text;
        self->_text = text;
        size.height += 10;
        
        // 确定context大小
        UIGraphicsBeginImageContextWithOptions(size, ![backgroundColor isEqual:[UIColor clearColor]], 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context==NULL) {
            return;
        }
        if (![backgroundColor isEqual:[UIColor clearColor]]) {
            [backgroundColor set];
            CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
        }
        CGContextSetTextMatrix(context,CGAffineTransformIdentity);
        CGContextTranslateCTM(context,0,size.height);
        CGContextScaleCTM(context,1.0,-1.0);
        //Determine default text color
        UIColor* textColor = self.textColor;
        
        //Set line height, font, color and break mode
        CGFloat minimumLineHeight = self.font.pointSize,maximumLineHeight = minimumLineHeight, linespace = self.lineSpace;
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName, self.font.pointSize,NULL);
        CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
        
        CTTextAlignment alignment = (CTTextAlignment)self.textAlignment;
        //Apply paragraph settings
        CTParagraphStyleRef style = CTParagraphStyleCreate((CTParagraphStyleSetting[6]){
            {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
            {kCTParagraphStyleSpecifierMinimumLineHeight,sizeof(minimumLineHeight),&minimumLineHeight},
            {kCTParagraphStyleSpecifierMaximumLineHeight,sizeof(maximumLineHeight),&maximumLineHeight},
            {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(linespace), &linespace},
            {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(linespace), &linespace},
            {kCTParagraphStyleSpecifierLineBreakMode,sizeof(CTLineBreakMode),&lineBreakMode}
        },6);
        
        NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)font,(NSString*)kCTFontAttributeName,
                                    textColor.CGColor,kCTForegroundColorAttributeName,
                                    style,kCTParagraphStyleAttributeName,
                                    nil];
        
        //Create attributed string, with applied syntax highlighting
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
        
        CFAttributedStringRef attributedString = (__bridge CFAttributedStringRef)attributedStr;
        
        //Draw the frame
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
        
        CGRect rect = CGRectMake(0, 5,(size.width),(size.height-5));
        
        if ([temp isEqualToString:text]) {
            [self drawFramesetter:framesetter attributedString:attributedStr textRange:CFRangeMake(0, text.length) inRect:rect context:context];
            CGContextSetTextMatrix(context,CGAffineTransformIdentity);
            CGContextTranslateCTM(context,0,size.height);
            CGContextScaleCTM(context,1.0,-1.0);
            UIImage *screenShotimage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            dispatch_async(dispatch_get_main_queue(), ^{
                CFRelease(font);
                CFRelease(framesetter);
                [[attributedStr mutableString] setString:@""];
                
                if (self->_drawFlag == flag) {
                    if ([temp isEqualToString:text]) {
                        self.layer.contents = (__bridge id _Nullable)(screenShotimage.CGImage);
                    }
                }
            });
        }
    });
}


// 绘制文字
- (void)drawFramesetter:(CTFramesetterRef)framesetter
       attributedString:(NSAttributedString *)attributedString
              textRange:(CFRange)textRange
                 inRect:(CGRect)rect
                context:(CGContextRef)c
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, textRange, path, NULL);
    
    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines = CFArrayGetCount(lines);
    BOOL truncateLastLine = YES;//tailMode
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        CGPoint lineOrigin = lineOrigins[lineIndex];
        lineOrigin = CGPointMake(CGFloat_ceil(lineOrigin.x), CGFloat_ceil(lineOrigin.y));
        
        CGContextSetTextPosition(c, lineOrigin.x, lineOrigin.y);
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        CGFloat descent = 0.0f;
        CGFloat ascent = 20.0f;
        CGFloat lineLeading;
        CTLineGetTypographicBounds((CTLineRef)line, &ascent, &descent, &lineLeading);
        
        // Adjust pen offset for flush depending on text alignment
        CGFloat flushFactor = NSTextAlignmentLeft;
        CGFloat penOffset;
        CGFloat y;
        if (self.numberOfLines != 0 && self.numberOfLines <= numberOfLines) {
            numberOfLines = self.numberOfLines;
        }
        if (lineIndex == numberOfLines - 1 && truncateLastLine) {
            // Check if the range of text in the last line reaches the end of the full attributed string
            CFRange lastLineRange = CTLineGetStringRange(line);
            
            if (!(lastLineRange.length == 0 && lastLineRange.location == 0) && lastLineRange.location + lastLineRange.length < textRange.location + textRange.length) {
                // Get correct truncationType and attribute position
                CTLineTruncationType truncationType = kCTLineTruncationEnd;
                CFIndex truncationAttributePosition = lastLineRange.location;
                
                NSString *truncationTokenString = @"\u2026";
                
                NSDictionary *truncationTokenStringAttributes = [attributedString attributesAtIndex:(NSUInteger)truncationAttributePosition effectiveRange:NULL];
                
                NSAttributedString *attributedTokenString = [[NSAttributedString alloc] initWithString:truncationTokenString attributes:truncationTokenStringAttributes];
                CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attributedTokenString);
                
                // Append truncationToken to the string
                // because if string isn't too long, CT wont add the truncationToken on it's own
                // There is no change of a double truncationToken because CT only add the token if it removes characters (and the one we add will go first)
                NSMutableAttributedString *truncationString = [[attributedString attributedSubstringFromRange:NSMakeRange((NSUInteger)lastLineRange.location, (NSUInteger)lastLineRange.length)] mutableCopy];
                if (lastLineRange.length > 0) {
                    // Remove any newline at the end (we don't want newline space between the text and the truncation token). There can only be one, because the second would be on the next line.
                    unichar lastCharacter = [[truncationString string] characterAtIndex:(NSUInteger)(lastLineRange.length - 1)];
                    if ([[NSCharacterSet newlineCharacterSet] characterIsMember:lastCharacter]) {
                        [truncationString deleteCharactersInRange:NSMakeRange((NSUInteger)(lastLineRange.length - 1), 1)];
                    }
                }
                [truncationString appendAttributedString:attributedTokenString];
                CTLineRef truncationLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)truncationString);
                
                // Truncate the line in case it is too long.
                CTLineRef truncatedLine = CTLineCreateTruncatedLine(truncationLine, rect.size.width, truncationType, truncationToken);
                if (!truncatedLine) {
                    // If the line is not as wide as the truncationToken, truncatedLine is NULL
                    truncatedLine = CFRetain(truncationToken);
                }
                
                penOffset = (CGFloat)CTLineGetPenOffsetForFlush(truncatedLine, flushFactor, rect.size.width);
                y = lineOrigin.y - descent - self.font.descender;
                CGContextSetTextPosition(c, penOffset, y);
                
                CTLineDraw(truncatedLine, c);
                
                CFRelease(truncatedLine);
                CFRelease(truncationLine);
                CFRelease(truncationToken);
            } else {
                penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, flushFactor, rect.size.width);
                y = lineOrigin.y - descent - self.font.descender;
                CGContextSetTextPosition(c, penOffset, y);
                CTLineDraw(line, c);
            }
        } else {
            penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, flushFactor, rect.size.width);
            y = lineOrigin.y - descent - self.font.descender;
            CGContextSetTextPosition(c, penOffset, y);
            CTLineDraw(line, c);
        }
    }
    CFRelease(frame);
    CFRelease(path);
}

- (void)clear{
    _drawFlag = arc4random();
    _text = @"";
    self.layer.contents = nil;
    [self removeSubviewExceptTag:NSIntegerMin];
}

- (void)removeSubviewExceptTag:(NSInteger)tag{
    for (UIView *temp in self.subviews) {
        if (temp.tag!=tag) {
            if ([temp isKindOfClass:[UIImageView class]]) {
                [(UIImageView *)temp setImage:nil];
            }
            [temp removeFromSuperview];
        }
    }
}

- (void)removeFromSuperview{
    [super removeFromSuperview];
}

- (void)dealloc{
    NSLog(@"dealloc %@", self);
}
@end
