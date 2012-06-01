//
//  MOOMaskedIconButton.h
//  Tag
//
//  Created by Peyton Randolph on 5/31/12.
//

@class MOOMaskedIconView;
@protocol MOOStyleTrait;

@interface MOOMaskedIconButton : UIControl
{
    MOOMaskedIconView *_icon;
    id<MOOStyleTrait> _normalStyle;
    id<MOOStyleTrait> _highlightedStyle;
    id<MOOStyleTrait> _disabledStyle;
    
    UIEdgeInsets _contentEdgeInsets;
    
    struct {
        BOOL needsStyling: 1;
    } _iconButtonFlags;
}

@property (nonatomic, strong) MOOMaskedIconView *icon;
@property (nonatomic, strong) id<MOOStyleTrait> normalStyle;
@property (nonatomic, strong) id<MOOStyleTrait> highlightedStyle;
@property (nonatomic, strong) id<MOOStyleTrait> disabledStyle;

@property (nonatomic, assign) UIEdgeInsets contentEdgeInsets;

- (id)initWithIcon:(MOOMaskedIconView *)icon;

+ (MOOMaskedIconButton *)buttonWithIcon:(MOOMaskedIconView *)icon;

- (void)setNeedsStyling;
- (void)styleIfNeeded;

@end
