//
//  UIView+YGCommon.m
//  Sales
//
//  Created by Fingal Liu on 2018/12/11.
//  Copyright © 2018 MJB. All rights reserved.
//

#import "UIView+YGCommon.h"


@implementation UIView (YGCommon)


- (UIViewController *)next_viewController{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }else if ([nextResponder isKindOfClass:[UIApplication class]]){
            UIApplication *application = (UIApplication *)nextResponder;
            UIViewController *controller = application.keyWindow.rootViewController;
            return controller;
        }
    }
    return nil;
}

- (void)setCornerWithRadius:(CGFloat)radius {
    
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}

- (void)setCornerRadius{
    
    [self setCornerWithRadius:3];
}

- (UIView*)descendantOrSelfWithClass:(Class)cls {
    
    if ([self isKindOfClass:cls]) {
        return self;
    }
    
    for (UIView* child in self.subviews) {
        
        UIView* it = [child descendantOrSelfWithClass:cls];
        if (it) {
            return it;
        }
    }
    return nil;
}






- (UIView*)ancestorOrSelfWithClass:(Class)cls {
    
    if ([self isKindOfClass:cls]) {
        
        return self;
    } else if (self.superview) {
        
        return [self.superview ancestorOrSelfWithClass:cls];
    } else {
        
        return nil;
    }
}

- (void)removeAllSubviews {
    
    while (self.subviews.count) {
        
        UIView* child = self.subviews.lastObject;
        [child removeFromSuperview];
    }
}

- (UIViewController*)viewController {
    
    for (UIView* next = [self superview]; next; next = next.superview) {
        
        UIResponder* nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

- (id)subviewWithTag:(NSInteger)tag{
    
    for(UIView *view in [self subviews]){
        
        if(view.tag == tag){
            
            return view;
        }
    }
    return nil;
}

#pragma mark - View坐标方法
- (CGFloat)left {
    
    return self.frame.origin.x;
}


- (void)setLeft:(CGFloat)x {
    
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top {
    
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right {
    
    return self.left + self.width;
}

- (void)setRight:(CGFloat)right {
    
    if(right == self.right){
        
        return;
    }
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom {
    
    return self.top + self.height;
}

- (void)setBottom:(CGFloat)bottom {
    
    if(bottom == self.bottom){
        return;
    }
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)centerX {
    
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
    
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)width {
    
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    
    if(height == self.height){
        return;
    }
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGPoint)origin {
    
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    
    CGRect frame = self.frame;
    
    frame.origin = origin;
    
    self.frame = frame;
}

- (CGSize)size {
    
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

@end
