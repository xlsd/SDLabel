# SDLabel
How to implementation a label? like UILabel that subclass UIView. SDLabel is a way to get it.当开始思考怎么实现一个系统控件，如UILabel一样，继承自UIView。我开始尝试很多方法，SDLabel是其中一种思路，当然我并没有完 全实现UIlabel的所有功能。 SDLabel并不是一个完整的功能齐全的控件，但可以提供一种解决方案。该Label在股大咖项目中得到了应用，在整个UITableView的性能优 化中，起到了比较重要的作用，使60fps成为常态。

> 如何显示文本内容？

在`text`赋值之后，使用`CoreText`将文本绘制到View上。如下
```
- (void)draw:(NSString *)text {
    NSInteger flag = drawFlag;
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
                
                if (self->drawFlag==flag) {
                    if ([temp isEqualToString:text]) {
                        if (self->_contentView.width!=screenShotimage.size.width) {
                            self->_contentView.width = screenShotimage.size.width;
                        }
                        if (self->_contentView.height!=screenShotimage.size.height) {
                            self->_contentView.height = screenShotimage.size.height;
                        }
                        self->_contentView.image = nil;
                        self->_contentView.image = screenShotimage;
                    }
                }
            });
        }
    });
}
```


> 如何用UIView实现UILabel的numberOfLines？

```
// 绘制过程中的判断
if (self.numberOfLines != 0 && self.numberOfLines <= numberOfLines) {
    numberOfLines = self.numberOfLines;
}
```
