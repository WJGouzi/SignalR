//
//  ViewController.m
//  SignalR
//
//  Created by zeb on 2018/11/8.
//  Copyright © 2018 zeb. All rights reserved.
//

#import "ViewController.h"
#import <SignalR.h>


@interface ViewController ()
@property (nonatomic, strong) SRHubProxy *imHub;
@property (nonatomic, copy) NSString *token;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self connectServer];
}

- (void)connectServer {
    SRHubConnection *hubConnection = [SRHubConnection connectionWithURLString:@"http://182.140.132.172/signalr"];
    SRHubProxy *imHub = [hubConnection createHubProxy:@"imHub"];
    [imHub on:@"addMessage" perform:self selector:@selector(addMessage:)];
    // Start the connection
    [hubConnection start];
    [hubConnection received];
    self.imHub = imHub;
    [hubConnection setStarted:^{
        NSLog(@"连接开始");
        [self.imHub invoke:@"login" withArgs:@[@"aa", @"ss"]];

    }];
    // 接收到的数据
    [hubConnection setReceived:^(NSString *message) {
        NSLog(@"接收到的数据:%@", message);
//        _IDlabel.text = message;//这里是我自己显示的聊天记录
        
    }];
    
    //连接缓慢
    [hubConnection setConnectionSlow:^{
        NSLog(@"连接缓慢");
    }];

    //重新连接
    [hubConnection setReconnecting:^{
        NSLog(@"重新连接");
    }];

    //重新连接2
    [hubConnection setReconnected:^{

        NSLog(@"重新连接2");
    }];

    //关闭连接
    [hubConnection setClosed:^{
        NSLog(@"关闭连接");
    }];
    
    //连接错误
    [hubConnection setError:^(NSError *error) {

        NSLog(@"error%@", error);
    }];

    //认可连接
    [hubConnection setReceived:^(NSString *data) {

        NSLog(@"认可连接");
        //
        NSDictionary *dataDict = (NSDictionary *)data;
        NSString *M = dataDict[@"M"];
        if ([M isEqualToString:@"loginDone"]) { // 登录成功拿到token
            NSArray *tokenArray = dataDict[@"A"];
            NSString *tokenStr = (tokenArray.firstObject);
            NSData *jsonData = [tokenStr dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *tokenDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
            NSString *token = tokenDict[@"Token"];
            self.token = token;
        } else if ([M isEqualToString:@"onMessage"]) { // 接收消息
            NSArray *userInfoArray = dataDict[@"A"];
            NSString *userId = userInfoArray.firstObject;
            NSString *message = userInfoArray.lastObject;
            NSLog(@"用户id：%@, 信息：%@", userId, message);
        }
    }];
    
}


- (void)addMessage:(NSString *)message {
    NSLog(@"message is : %@", message);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.imHub invoke:@"sendMessage" withArgs:@[@"test111", @"ss", self.token]];
}

@end
