//
//  LiveWhineView.m
//  app
//
//  Created by 宁丽环 on 2020/7/15.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "LiveWhineView.h"
#import "WhineCollectionViewCell.h"
#import "BaseMacro.h"
#import "NSBundle+Language.h"
#import "LiveFunctionModel.h"

@interface LiveWhineView()<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UISwitch *whineSwitch;
@property (nonatomic, strong) NSArray *whineDataArray;
@property (weak, nonatomic) IBOutlet UICollectionView *whineCollectionView;

@property (nonatomic, assign)ThunderRtcVoiceChangerMode mode;
@end

@implementation LiveWhineView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.whineCollectionView.dataSource = self;
    self.whineCollectionView.delegate = self;
    [self.whineCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([WhineCollectionViewCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:NSStringFromClass([WhineCollectionViewCell class])];
      UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
      layout.sectionInset =  UIEdgeInsetsMake(10, 10, 10, 10);
      layout.itemSize = CGSizeMake((kScreenWidth -  60)/3.0, 40);
      [self.whineCollectionView setCollectionViewLayout:layout];
    
}

+ (instancetype)shareWhineView
{
 return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}

- (NSArray *)whineDataArray
{
    if (!_whineDataArray) {
        _whineDataArray = @[[LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"空灵"] selectedTitle:nil image:nil functionType:LiveFunctionTypeNone],[LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"惊悚"] selectedTitle:nil image:nil functionType:LiveFunctionTypeNone],[LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"鲁班"] selectedTitle:nil image:nil functionType:LiveFunctionTypeNone],[LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"萝莉"] selectedTitle:nil image:nil functionType:LiveFunctionTypeNone],[LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"大叔"] selectedTitle:nil image:nil functionType:LiveFunctionTypeNone],[LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"死肥仔"] selectedTitle:nil image:nil functionType:LiveFunctionTypeNone],[LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"熊孩子"] selectedTitle:nil image:nil functionType:LiveFunctionTypeNone],[LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"魔兽农民"] selectedTitle:nil image:nil functionType:LiveFunctionTypeNone],[LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"重金属"] selectedTitle:nil image:nil functionType:LiveFunctionTypeNone],[LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"感冒"] selectedTitle:nil image:nil functionType:LiveFunctionTypeNone],[LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"重机械"] selectedTitle:nil image:nil functionType:LiveFunctionTypeNone],[LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"困兽"] selectedTitle:nil image:nil functionType:LiveFunctionTypeNone],[LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"强电流"] selectedTitle:nil image:nil functionType:LiveFunctionTypeNone]];
    }
    return _whineDataArray;
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.whineDataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WhineCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([WhineCollectionViewCell class]) forIndexPath:indexPath];
    cell.enabled = self.whineSwitch.on;
    cell.model = self.whineDataArray[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ThunderRtcVoiceChangerMode mode = THUNDER_VOICE_CHANGER_NONE;
    for (LiveFunctionModel *model in self.whineDataArray) {
        model.isSelected = NO;
    }
    LiveFunctionModel *model = self.whineDataArray[indexPath.row];
    model.isSelected = !model.isSelected;
    [collectionView reloadData];
    if ([model.normalTitle isEqualToString:[NSBundle jly_localizedStringWithKey:@"空灵"]]) {
        mode = THUNDER_VOICE_CHANGER_ETHEREAL;
    } else if ([model.normalTitle isEqualToString:[NSBundle jly_localizedStringWithKey:@"大叔"]]) {
        mode = THUNDER_VOICE_CHANGER_UNCLE;
    } else if ([model.normalTitle isEqualToString:[NSBundle jly_localizedStringWithKey:@"重金属"]]) {
        mode = THUNDER_VOICE_CHANGER_HEAVYMETAL;

    } else if ([model.normalTitle isEqualToString:[NSBundle jly_localizedStringWithKey:@"强电流"]]) {
        mode = THUNDER_VOICE_CHANGER_POWERCURRENT;

    } else if ([model.normalTitle isEqualToString:[NSBundle jly_localizedStringWithKey:@"惊悚"]]) {
        mode = THUNDER_VOICE_CHANGER_THRILLER;

    } else if ([model.normalTitle isEqualToString:[NSBundle jly_localizedStringWithKey:@"死肥仔"]]) {
        mode = THUNDER_VOICE_CHANGER_DIEFAT;

    } else if ([model.normalTitle isEqualToString:[NSBundle jly_localizedStringWithKey:@"感冒"]]) {
        mode = THUNDER_VOICE_CHANGER_COLD;

    } else if ([model.normalTitle isEqualToString:[NSBundle jly_localizedStringWithKey:@"鲁班"]]) {
        mode = THUNDER_VOICE_CHANGER_LUBAN;

    } else if ([model.normalTitle isEqualToString:[NSBundle jly_localizedStringWithKey:@"熊孩子"]]) {
        mode = THUNDER_VOICE_CHANGER_BADBOY;

    } else if ([model.normalTitle isEqualToString:[NSBundle jly_localizedStringWithKey:@"重机械"]]) {
        mode = THUNDER_VOICE_CHANGER_HEAVYMECHINERY;

    } else if ([model.normalTitle isEqualToString:[NSBundle jly_localizedStringWithKey:@"萝莉"]]) {
        mode =   THUNDER_VOICE_CHANGER_LORIE;
        
    } else if ([model.normalTitle isEqualToString:[NSBundle jly_localizedStringWithKey:@"魔兽农民"]]) {
        mode = THUNDER_VOICE_CHANGER_WRACRAFT;
    } else if ([model.normalTitle isEqualToString:[NSBundle jly_localizedStringWithKey:@"困兽"]]) {
        mode = THUNDER_VOICE_CHANGER_TRAPPEDBEAST;

    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(whineViewSetVoiceChanger:)]) {
        [self.delegate whineViewSetVoiceChanger:mode];
        self.mode = mode;
    }
}

- (IBAction)switchAction:(UISwitch *)sender
{
    [self.whineCollectionView reloadData];
    if (!sender.on) {
        [self close];
        if (self.delegate && [self.delegate respondsToSelector:@selector(offWhine)]) {
            [self.delegate offWhine];
        }
    } else {
        if (!self.mode) {
            ((LiveFunctionModel *)(self.whineDataArray.firstObject)).isSelected = YES;
            [self.whineCollectionView reloadData];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(onWhineWithMode:)]) {
            [self.delegate onWhineWithMode:self.mode];
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.hidden = YES;
}

- (void)close
{
    self.whineSwitch.on = NO;
    for (LiveFunctionModel *model in self.whineDataArray) {
        if ([model.normalTitle isEqualToString:[NSBundle jly_localizedStringWithKey:@"空灵"]]) {
            if (model.isSelected) {
                if (self.mode) {
                    model.isSelected = NO;
                } else {
                    model.isSelected = YES;
                }
            }
        }
    }
    [self.whineCollectionView reloadData];
}

//变声复位
- (void)reset
{
    self.whineSwitch.on = NO;
    self.mode = 0;
    for (LiveFunctionModel *model in self.whineDataArray) {
        if ([model.normalTitle isEqualToString:[NSBundle jly_localizedStringWithKey:@"空灵"]]) {
            model.isSelected = YES;
        } else {
            model.isSelected = NO;
        }
    }
    [self.whineCollectionView reloadData];
}
@end
