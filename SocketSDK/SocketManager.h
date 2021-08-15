//
//  SocketManager.h
//  aw
//
//  Created by Abillchen on 2018/6/11.
//  Copyright © 2018年 Abillchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCD/GCDAsyncSocket.h"
typedef NS_ENUM(NSInteger, SocketFlag) {
    SocketFlag_heart = 0,
    SocketFlag_login,
    SocketFlag_location,
    SocketFlag_poweroff,
    SocketFlag_factory,
    SocketFlag_VOICE_ACT,
    SocketFlag_monitor,
    SocketFlag_monitorcancel,
    SocketFlag_picture,
};


@protocol SokectManagerDelegate <NSObject>

- (void)readString:(NSString*)string;

@end

@interface SocketManager : NSObject
@property   (nonatomic,strong)GCDAsyncSocket  *socket;
/**
 单列
 @return 返回单列类
 */
+ (instancetype)shareInstance;

/**
 连接服务器
 @param host 服务器地址
 @param port 服务器端口
 @return 是否连接成功
 */
- (BOOL)connectServerWith:(NSString*)host onPort:(uint16_t)port;

/**
 发送心跳数据
 @param heartData 心跳数据
 */
- (void)threadStart:(NSData*)heartData;
/**
 发送数据
 @param data 数据
 @param flag tagtype
 */
- (void)writeData:(NSData*)data withFlag:(SocketFlag)flag;
/**
 断开连接服务器
 */
+ (void)disconnect;

@property (nonatomic,strong)id <SokectManagerDelegate> delegate;

@end
