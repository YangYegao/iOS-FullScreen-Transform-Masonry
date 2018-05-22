//
//  MovieViewController.h
//  FullScreen_Transform_Masonry
//
//  Created by 杨业高(外包) on 2018/5/21.
//  Copyright © 2018年 杨业高(外包). All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,FullscreenMode){
    FullscreenModeOnCurrentController,
    FullscreenModeOnKeyWindow
};

@interface MovieViewController : UIViewController

- (instancetype)initWithFullscreenMode:(FullscreenMode)mode;

@end
