//
//  SocketManager.m
//  aw
//
//  Created by Abillchen on 2018/6/11.
//  Copyright © 2018年 Abillchen. All rights reserved.
//

#import "SocketManager.h"
#define SOCKETIP @""

#define SOCKETPORT 17

@interface SocketManager()<GCDAsyncSocketDelegate>
//定时器
@property(nonatomic,strong)NSTimer* connectTimer;

//发送心跳包的线程
@property (nonatomic, strong)NSThread *thread;

@end
@implementation SocketManager
+ (instancetype)shareInstance
{
    static id  _instance;
    static  dispatch_once_t _oncetoken;
    dispatch_once(&_oncetoken, ^{
        _instance   =   [[self alloc] init];
    });
    return _instance;
}
//全局唯一
- (GCDAsyncSocket *)socket
{
    if (!_socket)
    {
        _socket = [[GCDAsyncSocket alloc]
                   initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return _socket;
}
//连接服务器
- (BOOL)connectServerWith:(NSString*)host onPort:(uint16_t)port;
{
    static BOOL success;
    GCDAsyncSocket *sockte =  [SocketManager shareInstance].socket;
    if (!sockte.isConnected)
    {
        NSError *err;
        success = [sockte connectToHost:host onPort:port error:&err];
        if (err != nil)
        {
            NSLog(@"%@",err);
        }
    }
    return success;
}

//心跳包发送
- (void)threadStart:(NSData*)heartData
{
    @autoreleasepool
    {
        [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(heartBeat:) userInfo:heartData repeats:YES];
        [[NSRunLoop currentRunLoop] run];
    }
}
- (void)heartBeat:(NSTimer*)timer
{
    if(!self.socket.isConnected)
    {
        NSLog(@"socket断开重连");
        [self connectServerWith:SOCKETIP onPort:SOCKETPORT];
    }else{
        NSLog(@"socket发送心跳包");
        [self writeData:[@"" dataUsingEncoding:NSUTF8StringEncoding] withFlag:1];
    }
}
//发送数据
- (void)writeData:(NSData*)data withFlag:(SocketFlag)flag
{
    NSLog(@"socket发送数据");
    [self.socket writeData:data withTimeout:-1 tag:1];
}

//断开服务器
+ (void)disconnect
{
    //断开连接时候一定要清空socket
    GCDAsyncSocket *sockte =  [SocketManager shareInstance].socket;
    [sockte disconnect];
    sockte = nil;
}
#pragma mark GCDAsyncSocketDelegate ------
//连接成功
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
#pragma mark ----链接成功开始定时发送心跳包
    NSLog(@"socket链接成功");
    [self threadStart:nil];
}
//socket断开
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err
{
#pragma mark ----链接断开重链
    NSLog(@"socket链接断开");
    if (self.socket)
    {
        if(!self.socket.isConnected)
        {
            NSLog(@"socket断开重连");
            [self.socket connectToHost:SOCKETIP onPort:SOCKETPORT error:nil];
        }else
        {
            
        }
    }
}
/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"socket读到数据");
    NSLog(@"data==%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSString    *string =   [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (self.delegate)
    {
        [self.delegate readString:string];
    }
    [sock readDataWithTimeout:-1 tag:tag];
}
/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
     NSLog(@"socket发送数据成功");
     [sock readDataWithTimeout:-1 tag:tag];
}


@end
