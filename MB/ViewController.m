//
//  ViewController.m
//  MB
//
//  Created by 刘少华 on 2020/12/5.
//

#import "ViewController.h"
#import "LToastView.h"
#import "UIColor+Additions.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIControl *control = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [control addTarget:self action:@selector(clicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:control];
    
}

- (void)clicked
{
    static int i = 0;
        
    i = i % 8;
    switch (i) {
        case 0:
            [LToastView showWithTitle:@"hahahahhewfbaefafaefaefawefaweaweawefawefawefawefaefawefawfewefafawfeawe"];
            break;
        case 1:
            [LToastView showWithTitle:@"121212e" inView:self.view];
            break;
        case 2:
            [LToastView showErrorWithTitle:@"错误"];
            break;
        case 3:
            [LToastView showSuccessWithTitle:@"成功"];
            break;
        case 4:{
            id<LToastProtocol> hud = [LToastView showGifInView:nil];
            [hud hideAnimated:YES afterDelay:5];
        }
            break;
        case 5:{
            id<LToastProtocol> hud = [LToastView showGifWithTitle:@"hahh" InView:self.view];
            [hud hideAnimated:YES afterDelay:5];
        }
            break;
        case 6:{
            id<LToastProtocol> hud = [LToastView showLoadingWithTitle:@"hahhahh"];
            [hud hideAnimated:YES afterDelay:5];
        }
            break;
        case 7:{
            id<LToastProtocol> hud = [LToastView showLoadingWithTitle:@"加载中" inView:self.view];
            [hud hideAnimated:YES afterDelay:5];
        }
            break;
    
            
        default:
            break;
    }

    i ++;
}


@end
