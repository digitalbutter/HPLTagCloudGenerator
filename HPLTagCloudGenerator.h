//
//  HPLTagCloudGenerator.h
//  Awkward
//
//  Created by Matthew Conlen on 5/8/13.
//  Copyright (c) 2013 Huffington Post Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HPLTagCloudGenerator : NSObject

@property UIFont *tagFont;

// Dictionary of tags -> # of occurances
@property NSArray *tagDict;
@property NSArray *attributesDict;
@property NSArray *titlesDict;

// The size of the view that
// we are creating a tag cloud for
@property CGSize size;

// How far along the spiral do
// we increment each time.
// defaults to 0.35
@property float spiralStep;

// The spiral is defined
// by the equation
//
// r = a + b*Θ
//
// where Θ is the angle
//
@property float a;
@property float b;


// Returns an array of views.
- (NSArray *)generateTagViews;

@end

@interface HPLBorderedTag : UIButton
@property (nonatomic, strong) HPLTagCloudGenerator *generator;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, assign) CGFloat outerMargin;
@end
