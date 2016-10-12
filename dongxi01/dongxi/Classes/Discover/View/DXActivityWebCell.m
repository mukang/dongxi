//
//  DXActivityWebCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/17.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXActivityWebCell.h"

typedef void(^WebContentLoadedCallBackType)(void);

@interface DXActivityWebCell () <UIWebViewDelegate>

@property (nonatomic) UIView * introContainer;
@property (nonatomic) DXMutiLineLabel * introTextLabel;
@property (nonatomic) UIImageView * dotImageView;
@property (nonatomic) UIButton * moreButton;

@property (nonatomic) UIView * htmlContainer;
@property (nonatomic) UIWebView * htmlView;
@property (nonatomic) UIButton * hideButton;

@property (nonatomic) NSArray * introVerticalContraints;
@property (nonatomic) NSArray * webVerticalContraints;

@property (nonatomic) CGFloat htmlContentHeight;
@property (nonatomic) BOOL htmlHeightAdded;

@property (nonatomic, copy) WebContentLoadedCallBackType afterLoadCallBack;

- (NSAttributedString *)attributedTextFromText:(NSString *)text;
- (NSString *)appendCSStoHTML:(NSString *)html;
- (void)toggleText;
- (CGFloat)transformScaleFromWeb;

@end

@implementation DXActivityWebCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    NSDictionary * metrics = @{
                               @"sideMargin"            : @(DXRealValue(115.0/3)),
                               @"topMargin"             : @(DXRealValue(60.0/3)),
                               @"bottomMargin"          : @(DXRealValue(83.0/3)),
                               @"subViewVerticalSpace"  : @(DXRealValue(50.0/3)),
                               };
    
    _introContainer = [[UIView alloc] initWithFrame:CGRectZero];
    _introContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    _introTextLabel = [[DXMutiLineLabel alloc] initWithFrame:CGRectZero];
    _introTextLabel.font = [DXFont fontWithName:DXCommonFontName size:15];
    _introTextLabel.textColor = DXRGBColor(72, 72, 72);
    _introTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    _dotImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"6point_detail"]];
    _dotImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _moreButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_moreButton setImage:[UIImage imageNamed:@"button_viewall_normal"] forState:UIControlStateNormal];
    [_moreButton addTarget:self action:@selector(moreButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    _moreButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    _hideButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_hideButton setImage:[UIImage imageNamed:@"button_pick_up"] forState:UIControlStateNormal];
    [_hideButton addTarget:self action:@selector(hideButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    _hideButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    _htmlContainer = [[UIView alloc] initWithFrame:CGRectZero];
    _htmlContainer.hidden = YES;
    _htmlContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGFloat estimatedHtmlWidth = DXScreenWidth - [[metrics objectForKey:@"sideMargin"] floatValue] * 2;
    _htmlView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, estimatedHtmlWidth, 0)];
    _htmlView.scalesPageToFit = NO;
    _htmlView.backgroundColor = [UIColor clearColor];
    _htmlView.opaque = NO;
    _htmlView.scrollView.showsHorizontalScrollIndicator = NO;
    _htmlView.scrollView.showsVerticalScrollIndicator = NO;
    _htmlView.scrollView.scrollEnabled = NO;
    _htmlView.scrollView.bounces = NO;
    _htmlView.scrollView.zoomScale = 1;
    _htmlView.scrollView.maximumZoomScale = 1;
    _htmlView.scrollView.minimumZoomScale = 1;
    _htmlView.translatesAutoresizingMaskIntoConstraints = NO;
    _htmlView.delegate = self;

    [_introContainer addSubview:_introTextLabel];
    [_introContainer addSubview:_dotImageView];
    [_introContainer addSubview:_moreButton];
    [_htmlContainer addSubview:_htmlView];
    [_htmlContainer addSubview:_hideButton];
    [self addSubview:_introContainer];
    [self addSubview:_htmlContainer];
    
    NSDictionary * views = @{
                             @"introContainer"  : _introContainer,
                             @"introTextLabel"  : _introTextLabel,
                             @"dotImageView"    : _dotImageView,
                             @"moreButton"      : _moreButton,
                             @"htmlContainer"   : _htmlContainer,
                             @"htmlView"        : _htmlView,
                             @"hideButton"      : _hideButton
                             };
    NSArray * visualFormats = @[
                                @"H:|-sideMargin-[introContainer]-sideMargin-|",
                                @"H:|[introTextLabel]|",
                                @"H:|-sideMargin-[htmlContainer]-sideMargin-|",
                                @"H:|[htmlView]|",
                                @"H:[hideButton]|",
                                @"V:|[introTextLabel]-subViewVerticalSpace-[dotImageView]-subViewVerticalSpace-[moreButton]|",
                                @"V:|[htmlView]-subViewVerticalSpace-[hideButton]|"
                                ];
    for (NSString * vf in visualFormats) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:metrics views:views]];
    }
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_dotImageView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_introContainer
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_moreButton
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_introContainer
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1 constant:0]];
    
    
    _introVerticalContraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topMargin-[introContainer]-bottomMargin-|"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views];
    _webVerticalContraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topMargin-[htmlContainer]-bottomMargin-|"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views];
    
    [self addConstraints:_introVerticalContraints];
    [self addConstraints:_webVerticalContraints];
}



#pragma mark - Property

- (void)setIntroText:(NSString *)introText {
    _introText = introText;
    _introTextLabel.attributedText = [self attributedTextFromText:introText];
}


- (void)setFullTextHtml:(NSString *)fullTextHtml {
    _fullTextHtml = fullTextHtml;
    
    if (fullTextHtml && fullTextHtml.length > 0) {
        NSString * html = [self appendCSStoHTML:fullTextHtml];
        [_htmlView loadHTMLString:html baseURL:nil];
    }
}

- (void)setShowFullText:(BOOL)showFullText {
    if (showFullText != _showFullText) {
        _showFullText = showFullText;
        if (self.delegate && [self.delegate respondsToSelector:@selector(webCell:willShowFullText:)]) {
            [self.delegate webCell:self willShowFullText:showFullText];
        }
        [self toggleText];
    }
}


- (void)afterWebContentLoaded:(WebContentLoadedCallBackType)loadCallBack {
    self.afterLoadCallBack = loadCallBack;
}

- (CGFloat)getFittingHeight {
    if (!self.showFullText) {
        return [self systemLayoutSizeFittingSize:CGSizeMake(self.frame.size.width, 0)].height;
    } else {
        [self removeConstraints:self.introVerticalContraints];
        CGFloat baseHeight = [self systemLayoutSizeFittingSize:CGSizeMake(self.frame.size.width, 0)].height;
        [self addConstraints:self.introVerticalContraints];
        return baseHeight + self.htmlContentHeight;
    }
}

#pragma mark - Methods

- (NSAttributedString *)attributedTextFromText:(NSString *)text {
    if (text == nil) {
        return nil;
    }

    NSMutableParagraphStyle * paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 6.0f;
    NSDictionary * textAttributes = @{
                                      NSParagraphStyleAttributeName : paragraphStyle,
                                      NSFontAttributeName           : [DXFont dxDefaultFontWithSize:15.0],
                                      NSForegroundColorAttributeName: DXRGBColor(72, 72, 72)
                                      };
    NSAttributedString * attributedText = [[NSAttributedString alloc] initWithString:text
                                                                          attributes:textAttributes];
    return attributedText;
}

- (NSString *)appendCSStoHTML:(NSString *)html {
    DXFont * font =[DXFont dxDefaultFontWithSize:DXRealValue(15.0)];
    CGFloat scale = [self transformScaleFromWeb];
    NSString * fontFamily = font.familyName;
    NSString * fontSize = [NSString stringWithFormat:@"%.4fem", scale];
    NSString * fontColor = @"#484848";
    NSString * headCSS = [NSString stringWithFormat:
                          @"<style type='text/css'>"
                          "body { font-size:15px; margin: 0; padding: 0; width: 100%%; background-size: 100%% auto; }"
                          "#ios-container {width: 100%%; font-family: %@; font-size: %@; color: %@; line-height: 1.5em;}"
                          "img {width: 100%%;}"
                          "</style>",
                          fontFamily, fontSize, fontColor];
    return [NSString stringWithFormat:@"%@<div id='ios-container'>%@</div>", headCSS, html];
}

- (CGFloat)transformScaleFromWeb {
    return DXScreenWidth / 414;
}

- (void)toggleText {
    if (self.showFullText) {
        self.htmlContainer.hidden = NO;
        self.htmlContainer.alpha = 0;
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.htmlContainer.alpha = 1;
            self.introContainer.alpha = 0;
        } completion:^(BOOL finished) {
            self.introContainer.hidden = YES;
            self.introContainer.alpha = 1;
        }];
    } else {
        self.introContainer.hidden = NO;
        self.htmlContainer.hidden = YES;
    }
}

#pragma mark - UI Actions

- (void)moreButtonTapped:(UIButton *)button {
    self.showFullText = YES;
}

- (void)hideButtonTapped:(UIButton *)button {
    self.showFullText = NO;
}

#pragma mark - <UIWebViewDelegate>

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.htmlContentHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"ios-container\").offsetHeight;"] floatValue];
    
    if (self.afterLoadCallBack) {
        self.afterLoadCallBack();
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
        return YES;
    } else {
        NSString * extension = [request.URL.pathExtension lowercaseString];
        if ([@[@"jpg", @"jpeg", @"png", @"gif"] indexOfObject:extension] != NSNotFound) {
            //暂时不做任何事情，看以后需要是否需要支持图片浏览
        }
    }
    return NO;
}

@end
