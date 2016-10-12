//
//  DXProfileUpdateViewController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/10/30.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXProfileUpdateViewController.h"
#import "DXProfileBioEditViewController.h"
#import "HMProvince.h"
#import "DXProfileUpdateNameCell.h"
#import "DXProfileUpdateGenderCell.h"
#import "DXProfileUpdateLocationCell.h"
#import "DXProfileUpdateBioCell.h"
#import "DXDongXiApi.h"
#import "NSString+DXConvenient.h"

@interface DXProfileUpdateViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITextViewDelegate>

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, weak) UITextField *nameTextField;
@property (nonatomic, weak) UILabel *bioTextLabel;

@property (nonatomic, strong) NSArray *provinces;
@property (nonatomic, strong) NSArray *genders;

@property (nonatomic, strong) NSIndexPath * selectedLocationIndexPath;
@property (nonatomic, strong) NSIndexPath * selectedGenderIndexPath;

@property (nonatomic, weak) DXProfileUpdateGenderCell * genderCell;
@property (nonatomic, weak) DXProfileUpdateLocationCell * locationCell;

@property (nonatomic, assign, getter=isProfileModified) BOOL profileModified;
@property (nonatomic, strong) DXUserProfileChange * profileChange;

@property (nonatomic, assign) BOOL originInteractivePopGestureEnabled;

@end



@implementation DXProfileUpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dt_pageName = DXDataTrackingPage_SettingsProfile;
    
    self.title = @"个人资料";
    self.view.backgroundColor = DXRGBColor(222, 222, 222);
    self.navigationItem.leftBarButtonItem = [DXBarButtonItem defaultSystemBackItemForController:self];
    [self.navigationItem.leftBarButtonItem setTarget:self];
    [self.navigationItem.leftBarButtonItem setAction:@selector(navBackItemTapped:)];
    
    // 添加保存按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(navRightItemTapped:)];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = DXRGBColor(221, 221, 221);
    self.tableView.alwaysBounceVertical = YES;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[DXProfileUpdateNameCell class] forCellReuseIdentifier:@"DXProfileUpdateNameCell"];
    [self.tableView registerClass:[DXProfileUpdateGenderCell class] forCellReuseIdentifier:@"DXProfileUpdateGenderCell"];
    [self.tableView registerClass:[DXProfileUpdateLocationCell class] forCellReuseIdentifier:@"DXProfileUpdateLocationCell"];
    [self.tableView registerClass:[DXProfileUpdateBioCell class] forCellReuseIdentifier:@"DXProfileUpdateBioCell"];
    
    //给键盘注册观察者
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidChange:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    DXMainNavigationController * navigationController = (DXMainNavigationController * )self.navigationController;
    self.originInteractivePopGestureEnabled = navigationController.enableInteractivePopGesture;
    navigationController.enableInteractivePopGesture = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    DXMainNavigationController * navigationController = (DXMainNavigationController * )self.navigationController;
    navigationController.enableInteractivePopGesture = self.originInteractivePopGestureEnabled;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (void)navRightItemTapped:(UIBarButtonItem *)sender {
    if (self.isProfileModified) {
        [self checkAndSubmit];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)navBackItemTapped:(UIBarButtonItem *)sender {
    if (self.isProfileModified) {
        [self submitConfirm];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)submitConfirm {
    [self.view endEditing:NO];

    __weak DXProfileUpdateViewController * weakSelf = self;
    DXCompatibleAlert * confirm = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleActionSheet];
    [confirm addAction:[DXCompatibleAlertAction actionWithTitle:@"保存修改" style:DXCompatibleAlertActionStyleDestructive handler:^(DXCompatibleAlertAction *action) {
        [weakSelf checkAndSubmit];
    }]];
    [confirm addAction:[DXCompatibleAlertAction actionWithTitle:@"不保存" style:DXCompatibleAlertActionStyleDefault handler:^(DXCompatibleAlertAction *action) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }]];
    [confirm addAction:[DXCompatibleAlertAction actionWithTitle:@"取消" style:DXCompatibleAlertActionStyleCancel handler:nil]];
    [confirm showInController:self animated:YES completion:nil];
}

- (void)checkAndSubmit {
    __weak DXProfileUpdateViewController * weakSelf = self;
    if ([self.profileChange.username isEqualToString:@""]) {
        DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
        alert.title = @"昵称不能为空";
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"确定" style:DXCompatibleAlertActionStyleCancel handler:^(DXCompatibleAlertAction *action) {
            [weakSelf.nameTextField becomeFirstResponder];
        }]];
        [alert showInController:self animated:YES completion:nil];
    } else {
        DXScreenNotice * screenNotice = [[DXScreenNotice alloc] initWithMessage:@"个人资料更新中..." fromController:self];
        screenNotice.disableAutoDismissed = YES;
        [screenNotice show];

        __weak DXScreenNotice * weakScreenNotice = screenNotice;
        [[DXDongXiApi api] changeProfile:self.profileChange result:^(BOOL success, NSError *error) {
            if (success) {
                [weakScreenNotice updateMessage:@"个人资料更新成功"];
                [weakScreenNotice dismiss:YES completion:^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }];
                [[NSNotificationCenter defaultCenter] postNotificationName:DXProfileDidUpdateNotification object:nil];
            } else {
                NSString * errorDesc = error.localizedDescription;
                if (errorDesc) {
                    [weakScreenNotice updateMessage:errorDesc];
                } else {
                    [weakScreenNotice updateMessage:@"更新失败，请稍后再试"];
                }
                
                [weakScreenNotice dismiss:YES];
            }
        }];
    }
}

- (void)prepareLocationPickerState {
    self.selectedLocationIndexPath = [self proviceIndexPathForLocation:self.userProfile.location];
    if (!self.selectedLocationIndexPath) {
        self.selectedLocationIndexPath = [self proviceIndexPathForLocation:@"北京"];
    }
    [self.locationCell.pickerView selectRow:self.selectedLocationIndexPath.section inComponent:0 animated:NO];
    [self.locationCell.pickerView selectRow:self.selectedLocationIndexPath.row inComponent:1 animated:NO];
}

- (void)prepareGenderPickerState {
    NSUInteger index = [self.genders indexOfObject:self.userProfile.genderDescription];
    if (index == NSNotFound) {
        index = 0;
    }
    self.selectedGenderIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.genderCell.pickerView selectRow:self.selectedGenderIndexPath.row inComponent:0 animated:NO];
}

- (BOOL)checkIfNicknameChanged {
    NSString * currentNickname = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([currentNickname isEqualToString:self.userProfile.username]) {
        self.profileChange.username = nil;
        return NO;
    } else {
        self.profileChange.username = currentNickname;
        return YES;
    }
}

- (BOOL)checkIfBioChanged {
    NSString * currentBio = [self.profileChange.bio stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([currentBio isEqualToString:self.userProfile.bio]) {
        self.profileChange.bio = nil;
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)checkIfGenderModified {
    NSString * currentGender = self.genderCell.contentLabel.text;
    DXUserGenderType genderType;
    if ([currentGender isEqualToString:@"男"]) {
        genderType = DXUserGenderTypeMale;
    } else if ([currentGender isEqualToString:@"女"]) {
        genderType = DXUserGenderTypeFemale;
    } else {
        genderType = DXUserGenderTypeOther;
    }
    
    if ([currentGender isEqualToString:self.userProfile.genderDescription]) {
        self.profileChange.gender = nil;
        return NO;
    } else {
        self.profileChange.gender = @(genderType);
        return YES;
    }
}

- (BOOL)checkIfLocationModified {
    NSString * currentLocation = [self.locationCell.contentLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([currentLocation isEqualToString:self.userProfile.location]) {
        self.profileChange.location = nil;
        return NO;
    } else {
        self.profileChange.location = currentLocation;
        return YES;
    }
}

- (BOOL)isProfileModified {
    if (self.profileChange.username == nil &&
        self.profileChange.gender == nil &&
        self.profileChange.location == nil &&
        self.profileChange.bio == nil) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - 属性

- (NSArray *)provinces {
    if (_provinces == nil) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"provinces.plist" ofType:nil];
        
        NSArray *arr = [NSArray arrayWithContentsOfFile:filePath];
        NSMutableArray *arrM = [NSMutableArray array];
        
        for (NSDictionary *dict in arr) {
            HMProvince *province = [HMProvince provinceWithDict:dict];
            [arrM addObject:province];
        }
        
        _provinces = arrM;
    }
    return _provinces;
}

- (NSIndexPath *)proviceIndexPathForLocation:(NSString *)location {
    NSIndexPath * indexPath = nil;
    for (NSUInteger i = 0; i < self.provinces.count; i++) {
        HMProvince * province = self.provinces[i];
        NSRange provinceRange = [location rangeOfString:province.name];
        if (provinceRange.location != NSNotFound) {
            BOOL foundCity = NO;
            for (NSUInteger j = 0; j < province.cities.count; j++) {
                NSString * cityName = province.cities[j];
                NSRange cityRange = [location rangeOfString:cityName];
                if (cityRange.location != NSNotFound) {
                    indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                    foundCity = YES;
                    break;
                }
            }
            if (!foundCity) {
                indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
            }
        }
    }
    return indexPath;
}

- (NSArray *)genders {
    if (_genders == nil) {
        _genders = @[@"男", @"女", @"其他"];
    }
    return _genders;
}

- (DXUserProfileChange *)profileChange {
    if (nil == _profileChange) {
        _profileChange = [[DXUserProfileChange alloc] init];
    }
    return _profileChange;
}

#pragma mark - <UIPickerViewDelegate>

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if(pickerView == self.genderCell.pickerView){
        return 1;
    }
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.genderCell.pickerView) {
        return self.genders.count;
    } else if (pickerView == self.locationCell.pickerView) {
        if (component == 0) {
            return self.provinces.count;
        } else {
            NSInteger provinceIndex = [pickerView selectedRowInComponent:0];
            if (provinceIndex >= 0) {
                HMProvince *province = self.provinces[provinceIndex];
                return province.cities.count;
            } else {
                return 0;
            }
        }
    } else {
        return 0;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return DXRealValue(35);
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel * textLabel = (UILabel *)view;
    if (textLabel == nil) {
        textLabel = [[UILabel alloc] init];
        [textLabel setTextAlignment:NSTextAlignmentCenter];
        [textLabel setFont:[DXFont dxDefaultFontWithSize:20]];
        [textLabel setTextColor:DXRGBColor(28, 28, 28)];
    }
    NSString * title = nil;
    if (pickerView == self.genderCell.pickerView) {
        title = [self.genders objectAtIndex:row];
    } else {
        if (component == 0) {
            title = [self.provinces[row] name];
            [pickerView reloadComponent:1];
            [pickerView selectRow:0 inComponent:1 animated:NO];
        } else {
            NSInteger provinceIndex = [pickerView selectedRowInComponent:0];
            if (provinceIndex >= 0) {
                HMProvince *province = self.provinces[provinceIndex];
                if (row < province.cities.count) {
                    title = province.cities[row];
                } else {
                    title = @"";
                }
            }
        }
    }
    textLabel.text = title;
    return textLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.genderCell.pickerView) {
        self.genderCell.contentLabel.text = [self.genders objectAtIndex:row];
        
        [self checkIfGenderModified];
    }

    if (pickerView == self.locationCell.pickerView){
        if (component == 0) {
            [pickerView reloadComponent:1];
            [pickerView selectRow:0 inComponent:1 animated:NO];
        }
        
        NSInteger provinceIndex = [pickerView selectedRowInComponent:0];
        NSInteger cityIndex = [pickerView selectedRowInComponent:1];
        HMProvince * province = self.provinces[provinceIndex];
        NSString * provinceName = province.name;
        NSString * cityName = [province.cities objectAtIndex:cityIndex];
        self.locationCell.contentLabel.text = [NSString stringWithFormat:@"%@%@", provinceName, cityName];
        
        [self checkIfLocationModified];
    }
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else{
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        DXProfileUpdateNameCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DXProfileUpdateNameCell" forIndexPath:indexPath];
        cell.fieldLabel.text = @"昵称";
        cell.textField.delegate = self;
        cell.textField.text = self.profileChange.username ? self.profileChange.username : self.userProfile.username;
        self.nameTextField = cell.textField;
        return cell;
    } else {
        if (indexPath.row == 0) {
            DXProfileUpdateGenderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DXProfileUpdateGenderCell" forIndexPath:indexPath];
            cell.contentLabel.text = self.profileChange.gender ? self.profileChange.genderDescription : self.userProfile.genderDescription;
            cell.pickerView.delegate = self;
            self.genderCell = cell;
            return cell;
        } else if (indexPath.row == 1) {
            DXProfileUpdateLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DXProfileUpdateLocationCell" forIndexPath:indexPath];
            cell.contentLabel.text = self.profileChange.location ? self.profileChange.location : self.userProfile.location;
            cell.pickerView.delegate = self;
            self.locationCell = cell;
            return cell;
        } else {
            DXProfileUpdateBioCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DXProfileUpdateBioCell" forIndexPath:indexPath];
            cell.bioLabel.text = self.profileChange.bio ? self.profileChange.bio : self.userProfile.bio;
            _bioTextLabel = cell.bioLabel;
            return cell;
        }
    }
}


#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    const CGFloat standardRowHeight = ceilf(DXRealValue(62));
    if (indexPath.section == 1 && indexPath.row == 2) {
        DXProfileUpdateBioCell * cell = [[DXProfileUpdateBioCell alloc] init];
        cell.bioLabel.text = self.profileChange.bio ? self.profileChange.bio : self.userProfile.bio;
        [cell setBounds:CGRectMake(0, 0, DXScreenWidth, standardRowHeight)];
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        CGFloat height = [cell.containerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        return height < standardRowHeight ? standardRowHeight : height + 2;
    } else {
        return standardRowHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return DXRealValue(7);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // 避免使用默认的高
    return 0.1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            if (![self.nameTextField isFirstResponder]) {
                [self.nameTextField becomeFirstResponder];
            } else {
                [self.nameTextField resignFirstResponder];
            }
        }
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            if (!self.selectedGenderIndexPath) {
                [self prepareGenderPickerState];
            }
            if (![self.genderCell isFirstResponder]) {
                [self.genderCell becomeFirstResponder];
            } else {
                [self.genderCell resignFirstResponder];
            }
        }
        
        if (indexPath.row == 1){
            if (!self.selectedLocationIndexPath) {
                [self prepareLocationPickerState];
            }
            if (![self.locationCell isFirstResponder]) {
                [self.locationCell becomeFirstResponder];
            } else {
                [self.locationCell resignFirstResponder];
            }
        }
        
        if (indexPath.row == 2) {
            __weak typeof(self) weakSelf = self;
            DXProfileBioEditViewController * bioEditViewController = [[DXProfileBioEditViewController alloc] init];
            bioEditViewController.bioText = self.profileChange.bio ? self.profileChange.bio : self.userProfile.bio;
            bioEditViewController.maxBioTextCount = 32;
            bioEditViewController.bioDidChangeHandler = ^(NSString * bioText) {
                weakSelf.profileChange.bio = bioText;
                [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [weakSelf checkIfBioChanged];
            };
            [self.navigationController pushViewController:bioEditViewController animated:YES];
        }
    }
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:NO];
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [self.nameTextField resignFirstResponder];
        return NO;
    }
    return YES;
}


#pragma mark - UITextField Notification

- (void)textFieldDidChange:(NSNotification *)noti{
    UITextField *textField = (UITextField *)noti.object;
    if (textField == self.nameTextField) {
        const CGFloat kNameMaxLength = 8;
        NSString *toBeString = textField.text;
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制，有高亮选择的字符串，则暂不对文字进行统计和限制
        if (!position) {
            NSUInteger chineseLength = [toBeString chineseCharacterLength];
            if (chineseLength > kNameMaxLength) {
                textField.text = [toBeString stringByLimitedToChineseCharacterLength:kNameMaxLength];
            }
        }
        
        [self checkIfNicknameChanged];
    }
}

@end


