//
//  DXComposeViewController.m
//  dongxi
//
//  Created by 穆康 on 15/11/12.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXComposeViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "UIImage+Extension.h"
#import "NSString+DXConvenient.h"
#import "DXDongXiApi.h"
#import "DXScreenNotice.h"
#import "NSString+DXConvenient.h"
#import "DXStatusBarHUD.h"
#import <YYText/YYText.h>
#import "DXReferViewController.h"
#import "DXTextParser.h"

@interface DXComposeViewController () <YYTextViewDelegate, DXReferViewControllerDelegate>

/** 输入框 */
@property (nonatomic, weak) YYTextView *textView;
/** 还可以输入多少字 */
@property (nonatomic, assign) int num;
/** 计数内容视图 */
@property (nonatomic, weak) UILabel *numL;
/** 内容块集合 */
@property (nonatomic, strong) NSMutableArray *contentPieces;

@property (nonatomic, assign) NSRange referRange;

@property (nonatomic, assign) BOOL isInsertReferText;

@property (nonatomic, strong) DXTextParser *textParser;

@end

@implementation DXComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.composeType == DXComposeTypeComment) {
        self.dt_pageName = DXDataTrackingPage_PhotoCommentPublish;
    } else {
        self.dt_pageName = DXDataTrackingPage_PhotoCommentReply;
    }
    self.view.backgroundColor = DXRGBColor(222, 222, 222);
    if (self.composeType == DXComposeTypeComment) {
        self.title = @"评论";
    } else {
        self.title = [NSString stringWithFormat:@"回复 %@", self.temp.nick];
    }
    self.contentPieces = [NSMutableArray array];
    self.isInsertReferText = NO;
    
    // 设置导航栏
    [self setupNav];
    
    // 设置内容
    [self setupContent];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self.textView becomeFirstResponder];
}

/**
 *  设置导航栏
 */
- (void)setupNav {
    
    UIImage *bgImage = [UIImage imageWithColor:DXRGBColor(247, 250, 251)];
    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:bgImage];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(sendCommentText)];
    
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSFontAttributeName : [UIFont fontWithName:DXCommonFontName size:18],
                                                                    NSForegroundColorAttributeName : DXCommonColor
                                                                    };
    
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{
                                                                    NSFontAttributeName: [UIFont fontWithName:DXCommonFontName size:17],
                                                                    NSForegroundColorAttributeName: DXCommonColor
                                                                    } forState:UIControlStateNormal];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{
                                                                     NSFontAttributeName: [UIFont fontWithName:DXCommonFontName size:17],
                                                                     NSForegroundColorAttributeName: DXCommonColor
                                                                     } forState:UIControlStateNormal];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{
                                                                     NSFontAttributeName: [UIFont fontWithName:DXCommonFontName size:17],
                                                                     NSForegroundColorAttributeName: DXRGBColor(181, 181, 181)
                                                                     } forState:UIControlStateDisabled];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

/**
 *  设置内容
 */
- (void)setupContent {
    
    YYTextView *textView = [[YYTextView alloc] init];
    textView.backgroundColor = [UIColor whiteColor];
    textView.x = DXRealValue(13);
    textView.y = DXRealValue(13);
    textView.width = DXScreenWidth - textView.x * 2;
    textView.height = DXRealValue(188);
    textView.layer.cornerRadius = 4;
    textView.textColor = DXRGBColor(72, 72, 72);
    textView.font = [UIFont fontWithName:DXCommonFontName size:15];
    textView.returnKeyType = UIReturnKeyDone;
    textView.delegate = self;
    textView.placeholderText = @"请输入回复内容...";
    textView.placeholderTextColor = DXRGBColor(143, 143, 143);
    textView.placeholderFont = [UIFont fontWithName:DXCommonFontName size:15];
    textView.textParser = [[DXTextParser alloc] init];
    [self.view addSubview:textView];
    self.textView = textView;
    self.textParser = textView.textParser;
    
    self.num = 150;
    
    UILabel *numL = [[UILabel alloc] init];
    numL.text = [NSString stringWithFormat:@"还可以输入%d个字", self.num];
    numL.textAlignment = NSTextAlignmentRight;
    numL.textColor = DXRGBColor(143, 143, 143);
    numL.font = [UIFont fontWithName:DXCommonFontName size:14];
    CGFloat numLW = 200.0f;
    CGFloat numLH = 14.0f;
    CGFloat numLX = DXScreenWidth - numLW - DXRealValue(13.0f);
    CGFloat numLY = CGRectGetMaxY(textView.frame) + DXRealValue(13.0f);
    numL.frame = CGRectMake(numLX, numLY, numLW, numLH);
    [self.view addSubview:numL];
    self.numL = numL;
}

#pragma mark - <UITextViewDelegate>

- (void)textViewDidChange:(YYTextView *)textView {
    
    self.navigationItem.rightBarButtonItem.enabled = textView.hasText;
    
    int length = (int)[textView.text chineseCharacterLength];
    self.num = 150 - length;
    self.numL.text = [NSString stringWithFormat:@"还可以输入%d个字", self.num];
    
//    DXLog(@"----------");
//    for (DXContentPiece *piece in self.contentPieces) {
//        DXLog(@"%@", piece.content);
//    }
//    DXLog(@"----------");
}

- (BOOL)textView:(YYTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if (self.isInsertReferText) {
        self.isInsertReferText = NO;
    } else {
        if ([text isEqualToString:@"\n"]) {
            [textView resignFirstResponder];
            return NO;
        }
        
        if ([text isEqualToString:@"@"]) {
            DXReferViewController *vc = [[DXReferViewController alloc] initWithReferType:DXReferTypeUser];
            vc.delegate = self;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
            self.referRange = NSMakeRange(range.location, 1);
        }
        
        if ([text isEqualToString:@"#"]) {
            DXReferViewController *vc = [[DXReferViewController alloc] initWithReferType:DXReferTypeTopic];
            vc.delegate = self;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
            self.referRange = NSMakeRange(range.location, 1);
        }
        
        [self formatNormalContentPiecesWithText:text inRange:range];
    }
    
    return YES;
}

#pragma mark - <DXReferViewControllerDelegate>

- (void)referViewController:(DXReferViewController *)controller didSelectedReferWithContentPiece:(DXContentPiece *)contentPiece {
    [self formatReferContentPiecesWithContentPiece:contentPiece inRange:self.referRange];
}

#pragma mark - 构建内容块

- (void)formatNormalContentPiecesWithText:(NSString *)text inRange:(NSRange)range {
    
    if (range.length) { // 替换或删除
        NSMutableArray *tempArray = [NSMutableArray array];
        int startIndex = 0;
        NSUInteger replaceLocation = 0;
        for (int i=0; i<self.contentPieces.count; i++) {
            DXContentPiece *piece = self.contentPieces[i];
            NSRange pieceRange = [self pieceRangeWithPiece:piece];
            if (NSLocationInRange(range.location, pieceRange)) {
                [tempArray addObject:piece];
                startIndex = i;
                replaceLocation = range.location - pieceRange.location;
                break;
            }
        }
        for (int i=startIndex+1; i<self.contentPieces.count; i++) {
            DXContentPiece *piece = self.contentPieces[i];
            NSRange pieceRange = [self pieceRangeWithPiece:piece];
            if (NSLocationInRange(pieceRange.location, range)) {
                [tempArray addObject:piece];
            } else {
                break;
            }
        }
        DXContentPiece *newPiece = [[DXContentPiece alloc] init];
        newPiece.type = DXContentPieceTypeNormal;
        newPiece.content = [NSString string];
        for (DXContentPiece *piece in tempArray) {
            newPiece.content = [newPiece.content stringByAppendingString:piece.content];
        }
        newPiece.content = [newPiece.content stringByReplacingCharactersInRange:NSMakeRange(replaceLocation, range.length) withString:text];
        [self.contentPieces removeObjectsInRange:NSMakeRange(startIndex, tempArray.count)];
        if (newPiece.content.length) {
            [self.contentPieces insertObject:newPiece atIndex:startIndex];
        }
    } else { // 插入
        NSRange allTextRange = NSMakeRange(0, self.textView.text.length);
        if (NSLocationInRange(range.location, allTextRange)) { // 不是在最后插入
            for (int i=0; i<self.contentPieces.count; i++) {
                DXContentPiece *piece = self.contentPieces[i];
                NSRange pieceRange = [self pieceRangeWithPiece:piece];
                if (range.location == pieceRange.location) {
                    DXContentPiece *newPiece = [[DXContentPiece alloc] init];
                    newPiece.type = DXContentPieceTypeNormal;
                    newPiece.content = text;
                    [self.contentPieces insertObject:newPiece atIndex:i];
                    break;
                } else if ((range.location > pieceRange.location) && ((range.location - pieceRange.location) < pieceRange.length)) {
                    NSRange replaceRange = NSMakeRange(range.location - pieceRange.location, 0);
                    piece.content = [piece.content stringByReplacingCharactersInRange:replaceRange withString:text];
                    piece.type = DXContentPieceTypeNormal;
                    break;
                }
            }
        } else { // 在最后插入
            DXContentPiece *piece = [self.contentPieces lastObject];
            if (piece && piece.type == DXContentPieceTypeNormal) { // 追加内容
                piece.content = [piece.content stringByAppendingString:text];
            } else { // 创建新的piece对象
                DXContentPiece *newPiece = [[DXContentPiece alloc] init];
                newPiece.type = DXContentPieceTypeNormal;
                newPiece.content = text;
                [self.contentPieces addObject:newPiece];
            }
        }
    }
    self.textParser.contentPieces = self.contentPieces;
}

- (void)formatReferContentPiecesWithContentPiece:(DXContentPiece *)contentPiece inRange:(NSRange)range {
    NSMutableArray *tempArray = [NSMutableArray array];
    int startIndex = 0;
    for (int i=0; i<self.contentPieces.count; i++) {
        DXContentPiece *piece = self.contentPieces[i];
        NSRange pieceRange = [self pieceRangeWithPiece:piece];
        if (NSLocationInRange(range.location, pieceRange)) {
            startIndex = i;
            if (range.location == pieceRange.location && range.length == pieceRange.length) {
                [tempArray addObject:contentPiece];
            } else {
                DXContentPiece *firstPiece = [[DXContentPiece alloc] init];
                firstPiece.type = DXContentPieceTypeNormal;
                firstPiece.content = [piece.content substringWithRange:NSMakeRange(0, range.location - pieceRange.location)];
                DXContentPiece *lastPiece = [[DXContentPiece alloc] init];
                lastPiece.type = DXContentPieceTypeNormal;
                NSUInteger lastPieceLoc = range.location - pieceRange.location + 1;
                NSUInteger lastPieceLen = pieceRange.length - lastPieceLoc;
                lastPiece.content = [piece.content substringWithRange:NSMakeRange(lastPieceLoc, lastPieceLen)];
                if (range.location == pieceRange.location) {
                    [tempArray addObjectsFromArray:@[contentPiece, lastPiece]];
                } else if ((range.location + range.length) == (pieceRange.location + pieceRange.length)) {
                    [tempArray addObjectsFromArray:@[firstPiece, contentPiece]];
                } else {
                    [tempArray addObjectsFromArray:@[firstPiece, contentPiece, lastPiece]];
                }
            }
            break;
        }
    }
    [self.contentPieces removeObjectAtIndex:startIndex];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startIndex, tempArray.count)];
    [self.contentPieces insertObjects:tempArray atIndexes:indexSet];
    
    self.textParser.contentPieces = self.contentPieces;
    
    // textView上添加相应文字
    self.isInsertReferText = YES;
    NSString *text = [contentPiece.content substringFromIndex:1];
    [self.textView insertText:text];
    [self.textView insertText:@" "];
}



- (NSRange)pieceRangeWithPiece:(DXContentPiece *)piece {
    NSInteger location = 0;
    NSInteger index = [self.contentPieces indexOfObject:piece];
    for (int i=0; i<index; i++) {
        DXContentPiece *tempPiece = self.contentPieces[i];
        location += tempPiece.content.length;
    }
    return NSMakeRange(location, piece.content.length);
}

#pragma mark - 点击按钮执行的方法

/**
 *  点击取消按钮
 */
- (void)cancel {
    
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  点击发送按钮
 */
- (void)sendCommentText {
    
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }
    
    // 检查是否有文字
    if (self.textView.text.length == 0 || [self.textView.text isWhiteSpacesAndNewLines]) {
        DXScreenNotice *screenNotice = [[DXScreenNotice alloc] initWithMessage:@"您还没有输入文字哦" fromController:self];
        [screenNotice show];
        return;
    }
    
    if (self.num < 0) {
        DXScreenNotice *screenNotice = [[DXScreenNotice alloc] initWithMessage:@"您的内容超过了限制长度" fromController:self];
        [screenNotice show];
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSString *msg;
    if (self.composeType == DXComposeTypeComment) {
        msg = @"正在发送评论";
    } else {
        msg = @"正在发送回复";
    }
    [DXStatusBarHUD showPublishingWithMsg:msg];
    
    DXCommentPost *post = [[DXCommentPost alloc] init];
    post.fid = self.temp.feedID;
    post.txt = self.textView.text;
    post.at_uid = self.temp.userID;
    post.at_id = self.temp.ID;
    post.content_pieces = self.contentPieces;
    
    __weak typeof(self) weakSelf = self;
    [[DXDongXiApi api] postCommentWithCommentPost:post result:^(DXComment *comment, NSError *error) {
        NSString *resultMsg;
        if (comment) {
            
            if (self.composeType == DXComposeTypeComment) {
                resultMsg = @"评论成功";
            } else {
                resultMsg = @"回复成功";
            }
            [DXStatusBarHUD showSuccessWithMsg:resultMsg];
            
            if (weakSelf.commentBlock) {
                weakSelf.commentBlock(comment);
            }
            
        } else {
            NSString * reason = error.localizedDescription ? error.localizedDescription : @"请稍候尝试";
            if (self.composeType == DXComposeTypeComment) {
                resultMsg = [NSString stringWithFormat:@"评论失败，%@", reason];
            } else {
                resultMsg = [NSString stringWithFormat:@"回复失败，%@", reason];
            }
            [DXStatusBarHUD showErrorWithMsg:resultMsg];
        }
    }];
}

/**
 *  点击其他地方退出键盘
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
}

@end
