//
//  HPLTagCloudGenerator.m
//  Awkward
//
//  Created by Matthew Conlen on 5/8/13.
//  Copyright (c) 2013 Huffington Post Labs. All rights reserved.
//

#import "HPLTagCloudGenerator.h"
#import <math.h>

@implementation HPLBorderedTag
@synthesize backgroundColor = _backgroundColor;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.layer.cornerRadius = frame.size.width / 2;
    self.layer.shadowOffset = CGSizeMake(.0f, .0f);
    self.layer.shadowRadius = 4.0f;
    self.layer.shadowOpacity = 0.2f;
    
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.outerMargin = 3.0f;
    
    CGFloat innerMargin = 3.0f;
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0f, innerMargin, 0.0f, innerMargin);
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = self.frame.size.width / 2;
    self.clipsToBounds = YES;
    
    if (self.backgroundColor)
        [self setBackgroundColor:self.backgroundColor];
}

#pragma mark mutators
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    
    CGFloat h, s, b, a;
    [backgroundColor getHue:&h saturation:&s brightness:&b alpha:&a];
    UIColor *darkerBackgroundColor = [UIColor colorWithHue:h saturation:s brightness:b * 0.9 alpha:a];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(self.outerMargin,
                                     self.outerMargin,
                                     self.bounds.size.width - self.outerMargin * 2,
                                     self.bounds.size.height - self.outerMargin * 2);
    gradientLayer.cornerRadius = gradientLayer.frame.size.width / 2;
    gradientLayer.colors = @[(id)backgroundColor.CGColor, (id)darkerBackgroundColor.CGColor];
    gradientLayer.startPoint = CGPointMake(1.0f, 0.0f);
    gradientLayer.endPoint = CGPointMake(1.0f, 1.0f);
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer isKindOfClass:[CAGradientLayer class]]) {
            [layer removeFromSuperlayer];
            break;
        }
    }
    [self.layer insertSublayer:gradientLayer atIndex:0];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

#pragma mark -
@interface HPLTagCloudGenerator () {
    int spiralCount;
}

@end

@implementation HPLTagCloudGenerator

- (id) init {
    self = [super init];
    spiralCount = 0;
    self.spiralStep = 0.35;
    self.a = 5;
    self.b = 6;
    return self;
}

- (CGPoint) getNextPosition:(CGSize)tagSize {
    
    float offsetX = tagSize.width / 2;
    float offsetY = tagSize.height / 2;
    int x = arc4random() % (int)floorf(self.size.width - tagSize.width);
    int y = arc4random() % (int)floorf(self.size.height - tagSize.height);
    
    return CGPointMake(x+offsetX,y+offsetY);
}

- (BOOL) checkIntersectionWithView:(UIView *)checkView viewArray:(NSArray*)viewArray {
    return NO;
}

+ (CGSize)sizeForString:(NSString*)string withFont:(UIFont*)font
{
    CGSize size;
    if ([string respondsToSelector:@selector(sizeWithAttributes:)])
    {
        size = [string sizeWithAttributes:@{NSFontAttributeName:font}];
    }
    else
    {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        size = [string sizeWithFont:font];
#pragma GCC diagnostic pop
    }
    return size;
}

- (NSArray *)generateTagViews {
    float maxFontsize = 30.0;
    
    NSMutableDictionary *smoothedTagDict = [NSMutableDictionary dictionaryWithDictionary:self.tagDict];
    
    NSMutableArray *tagViews = [[NSMutableArray alloc] init];
    NSArray *sortedTags = [self.tagDict allKeys];
    
    int max = [(NSNumber *) [smoothedTagDict objectForKey:[sortedTags objectAtIndex:0]] intValue];
    int min = [(NSNumber *) [smoothedTagDict objectForKey:[sortedTags objectAtIndex:[sortedTags count]-1]] intValue];
    
    min--;
    
    CGFloat maxWidth = self.size.width - 64.0f;
    CGFloat minWidth = 32.0f;
    
    for (NSString *tag in sortedTags) {
        NSString *title = self.titlesDict[tag];
        
        int count = [(NSNumber *) [smoothedTagDict objectForKey:tag] intValue];
        float bubbleSize = ceilf((maxWidth / [sortedTags count]) * (count - min) / (max - min)) + minWidth;
        
        CGSize tagSize = [HPLTagCloudGenerator sizeForString:[title uppercaseString] withFont:self.tagFont];
        tagSize = CGSizeMake(bubbleSize, bubbleSize);
        
        while (tagSize.width >= maxWidth) {
            maxFontsize-=2;
            bubbleSize = ceilf((maxWidth / [sortedTags count]) * (count - min) / (max - min)) + minWidth;
            
            tagSize = [HPLTagCloudGenerator sizeForString:[title uppercaseString] withFont:self.tagFont];
            tagSize = CGSizeMake(bubbleSize, bubbleSize);
        }
        
        // check intersections
        CGPoint center = [self getNextPosition:tagSize];
        HPLBorderedTag *tagLabel = [[HPLBorderedTag alloc] initWithFrame:CGRectMake(center.x - tagSize.width/2, center.y - tagSize.width/2, tagSize.width, tagSize.width)];
        
        [tagLabel setTitle:[title uppercaseString] forState:UIControlStateNormal];
        tagLabel.titleLabel.font = self.tagFont;
        
        UIColor *backgroundColor = self.attributesDict[tag][NSBackgroundColorAttributeName];
        tagLabel.backgroundColor = backgroundColor;
        
        while([self checkIntersectionWithView:tagLabel viewArray:tagViews]) {
            CGPoint center = [self getNextPosition:tagSize];
            tagLabel.frame = CGRectMake(center.x - tagSize.width/2, center.y - tagSize.width/2, tagSize.width, tagSize.width);
        }
        
        [tagViews addObject:tagLabel];
    }
    
    return tagViews;
}

@end

