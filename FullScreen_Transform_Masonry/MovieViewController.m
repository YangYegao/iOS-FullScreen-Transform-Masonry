//
//  MovieViewController.m
//  FullScreen_Transform_Masonry
//
//  Created by 杨业高(外包) on 2018/5/21.
//  Copyright © 2018年 杨业高(外包). All rights reserved.
//

#import "MovieViewController.h"
#import "Masonry/Masonry.h"

@interface MovieViewController ()
@property (nonatomic,assign)FullscreenMode mode;
@property (nonatomic,strong)UIView *movieView;
@property (nonatomic,strong)UIButton *backBtn;
@property (nonatomic,strong)UIButton *fullBtn;
@property (nonatomic,strong)UIButton *centerBtn; //中心测试按钮
@property (nonatomic,strong)UIButton *trBtn; //右上角测试按钮
@property (nonatomic,strong)UIButton *dlBtn; //左下角测试按钮
@end

#define kHeight 300

@implementation MovieViewController

- (instancetype)initWithFullscreenMode:(FullscreenMode)mode {
    if (self = [super init]) {
        self.mode = mode;
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (BOOL)shouldAutorotate {
    return NO; //不允许自转
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

//参考资料：iOS端一次视频全屏需求的实现 http://www.cocoachina.com/ios/20170329/18978.html

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubViews];
}

- (void)fullBtnClick:(UIButton *)sender {
    
    self.fullBtn.selected = !self.fullBtn.selected;
    
    if (self.fullBtn.selected) {
        [self enterFullscreen];
    }
    else{
        [self exitFullscreen];
    }
}

- (void)enterFullscreen {
    
    //首先，我们谈谈本demo实现视频全屏的原理，就是把 movieView 旋转90度，然后放大为屏幕大小。
    
    //坑1：我们通过设置 movieView 的transform属性，来达成旋转效果。但是，当movieView设置了transform之后，它的frame有可能出现混乱，所以官方文档中建议我们此时使用bounds和center。
    
    //坑2：是先旋转，然后放大；还是先放大，再旋转？这是个大坑！如果movieView上的子视图没有使用Masonry来设置约束条件的话，那么顺序无关紧要，谁先谁后，movieView都能正常显示。但是，如本demo
    //所写，movieView 上面有四个子视图，都使用了Masonry来设置约束条件，那么只能是先放大，再旋转！这样才能获得正确的布局，否则的话，布局错乱！更新约束、刷新布局，都没起作用。个中缘由，尚未找到直接的证据。哪位知道，可留言分享一下，谢谢🙏。
    
    //坑3：测试发现，在使用动画效果，进行旋转放大的时候，除了左上角的back按钮，其余方位的按钮，在旋转过程中，都会闪一下。为了提高用户体验，建议在旋转时，隐藏按钮，动画结束再恢复显示。
    self.fullBtn.hidden = YES;
    if (self.mode == FullscreenModeOnCurrentController) {
        [UIView animateWithDuration:0.5 animations:^{
            self.movieView.bounds = CGRectMake(0, 0, CGRectGetHeight(self.movieView.superview.bounds), CGRectGetWidth(self.movieView.superview.bounds));
            self.movieView.center = CGPointMake(CGRectGetMidX(self.movieView.superview.bounds), CGRectGetMidY(self.movieView.superview.bounds));
            self.movieView.transform = CGAffineTransformMakeRotation(M_PI_2);
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
        } completion:^(BOOL finished) {
            self.fullBtn.hidden = NO;
        }];
    }
    else{
        
        //坑4：如果将movieView从当前父视图上移除，然后添加到keyWindow上，这一移一加的过程中，会导致movieView上面的子视图坐标错误。为了获取正确的布局，重新add之后，可以调用updateConstraintsIfNeeded方法 或者 layoutIfNeeded方法。
        
        // movieView移到window上
        CGRect rectInWindow = [self.movieView convertRect:self.movieView.bounds toView:[UIApplication sharedApplication].keyWindow];
        [self.movieView removeFromSuperview];
        self.movieView.frame = rectInWindow;
        [[UIApplication sharedApplication].keyWindow addSubview:self.movieView];
        //[self.movieView updateConstraintsIfNeeded];
        [self.movieView layoutIfNeeded];
        
        self.fullBtn.hidden = YES;
        [UIView animateWithDuration:0.5 animations:^{
            self.movieView.bounds = CGRectMake(0, 0, CGRectGetHeight(self.movieView.superview.bounds), CGRectGetWidth(self.movieView.superview.bounds));
            self.movieView.center = CGPointMake(CGRectGetMidX(self.movieView.superview.bounds), CGRectGetMidY(self.movieView.superview.bounds));
            self.movieView.transform = CGAffineTransformMakeRotation(M_PI_2);
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
        } completion:^(BOOL finished) {
            self.fullBtn.hidden = NO;
        }];
    }
    

}

- (void)exitFullscreen {
    
    //坑5：缩回小屏的时候，设置bounds时，不能用[UIScreen mainScreen].bounds.size的数值，会导致视图异常，可采用movieView的父视图的bounds数据。
    
    self.fullBtn.hidden = YES;
    if (self.mode == FullscreenModeOnCurrentController) {
        [UIView animateWithDuration:0.5 animations:^{
            self.movieView.transform = CGAffineTransformIdentity;
            self.movieView.bounds = CGRectMake(0, 0, CGRectGetWidth(self.movieView.superview.bounds), kHeight);
            self.movieView.center = CGPointMake(self.view.frame.size.width/2.0, kHeight/2.0);
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];

        } completion:^(BOOL finished) {
            self.fullBtn.hidden = NO;
        }];
    }
    else{
        [UIView animateWithDuration:0.5 animations:^{
            self.movieView.transform = CGAffineTransformIdentity;
            [self.movieView removeFromSuperview];
            [self.view addSubview:self.movieView];
            self.movieView.bounds = CGRectMake(0, 0, CGRectGetWidth(self.movieView.superview.bounds), kHeight);
            self.movieView.center = CGPointMake(self.view.frame.size.width/2.0, kHeight/2.0);
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];

        } completion:^(BOOL finished) {
            self.fullBtn.hidden = NO;
        }];
    }
    
}

- (void)backBtnClick:(UIButton *)sender {
    if (self.fullBtn.selected) {
        [self fullBtnClick:nil];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)addSubViews {
    self.movieView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kHeight)];
    self.movieView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.movieView];
    
    
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backBtn.frame = CGRectMake(350, 270, 40, 30);
    self.backBtn.layer.borderWidth = 2;
    [self.backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.movieView addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.movieView.mas_top).offset(20);
        make.left.equalTo(self.movieView.mas_left).offset(20);
        make.height.equalTo(@(30));
        make.width.equalTo(@(40));
    }];
    
    
    self.fullBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.fullBtn.frame = CGRectMake(350, 270, 40, 30);
    self.fullBtn.layer.borderWidth = 2;
    [self.fullBtn setTitle:@"全屏" forState:UIControlStateNormal];
    [self.fullBtn setTitle:@"缩小" forState:UIControlStateSelected];
    [self.fullBtn addTarget:self action:@selector(fullBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.movieView addSubview:self.fullBtn];
    [self.fullBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.movieView.mas_right).offset(-20);
        make.bottom.equalTo(self.movieView.mas_bottom).offset(-20);
        make.height.equalTo(@(30));
        make.width.equalTo(@(40));
    }];
    
    //中心测试按钮
    self.centerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.centerBtn.frame = CGRectZero;
    self.centerBtn.layer.borderWidth = 2;
    [self.centerBtn setTitle:@"中心" forState:UIControlStateNormal];
    [self.movieView addSubview:self.centerBtn];
    [self.centerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.movieView.mas_centerX);
        make.centerY.equalTo(self.movieView.mas_centerY);
        make.height.equalTo(@(30));
        make.width.equalTo(@(40));
    }];
    
    //右上角测试按钮
    self.trBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.trBtn.frame = CGRectZero;
    self.trBtn.layer.borderWidth = 2;
    [self.trBtn setTitle:@"右上" forState:UIControlStateNormal];
    [self.movieView addSubview:self.trBtn];
    [self.trBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.movieView.mas_top).offset(20);
        make.right.equalTo(self.movieView.mas_right).offset(-20);
        make.height.equalTo(@(30));
        make.width.equalTo(@(40));
    }];
    
    //左下角测试按钮
    self.dlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.dlBtn.frame = CGRectZero;
    self.dlBtn.layer.borderWidth = 2;
    [self.dlBtn setTitle:@"左下" forState:UIControlStateNormal];
    [self.movieView addSubview:self.dlBtn];
    [self.dlBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.movieView.mas_left).offset(20);
        make.bottom.equalTo(self.movieView.mas_bottom).offset(-20);
        make.height.equalTo(@(30));
        make.width.equalTo(@(40));
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
