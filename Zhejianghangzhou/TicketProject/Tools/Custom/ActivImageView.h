//
//  ActivImageView.h
//  CarPooling
//
//  Created by KAI on 15-1-31.
//  Copyright (c) 2015年 KAI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivImageView : UIImageView{
    UIActivityIndicatorView *_activityIndicatorView;	/**< 图片下载时的风火轮 */
    UIProgressView          *_progressView;		     	/**< 下载进度条 */
    UILabel                 *_progressLabel;			/**< 下载进度文字控件 */
}

@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, readonly) UIProgressView          *progressView;
@property (nonatomic, readonly) UILabel                 *progressLabel;

- (void)startActivityAnimating;

- (void)stopActivityAnimating;

- (void)setactivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)_style;

- (void)setProgress:(NSInteger)current total:(NSInteger)total;

- (void)setProgressHidden:(BOOL)hidden;

- (void)setProgressLabelText:(NSString *)text;

- (void)setProgressViewRect:(CGRect)progressViewRect;

- (void)fakeFromSuperview;

@end