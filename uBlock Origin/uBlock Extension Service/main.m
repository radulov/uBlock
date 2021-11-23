//
//  main.m
//  uBlock Extension Service
//
//  Created by Viktor Radulov on 23.11.2021.
//

#import <Foundation/Foundation.h>
#import "uBlock_Extension_Service.h"

@interface ServiceDelegate : NSObject <NSXPCListenerDelegate, TestServiceProtocol, TestClientProtocol>

@property NSXPCConnection *connectionToService;

- (void)connect;

@end

@implementation ServiceDelegate

- (void)connect {
    
    NSXPCConnection *connectionToService = [[NSXPCConnection alloc] initWithMachServiceName:@"com.yourCompany.uBlock-Origin.Agent" options:0];
    connectionToService.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(TestServiceProtocol)];
    connectionToService.invalidationHandler = ^{
        NSLog(@"kuBlock: xpc service connection to Agent invalidated");
    };
    
    connectionToService.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(TestClientProtocol)];
    
    connectionToService.exportedObject = self;
    [connectionToService resume];
    
    self.connectionToService = connectionToService;
}

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
   
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(TestServiceProtocol)];
    
    newConnection.exportedObject = self;
    
    newConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(TestClientProtocol)];
    
    newConnection.invalidationHandler = ^{
        NSLog(@"kuBlock: xpc service connection to Extension invalidated");
    };
    
    // Resuming the connection allows the system to deliver more incoming messages.
    [newConnection resume];
    
    // Returning YES from this method tells the system that you have accepted this connection. If you want to reject the connection for some reason, call -invalidate on the connection and return NO.
    return YES;
}

- (void)publishToAllClientsWithString:(NSString *)aString {
    NSLog(@"kuBlock: xpc service publish: %@", aString);
    
    [[self.connectionToService synchronousRemoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
        NSLog(@"kuBlock: xpc service error %@", error);
    }] publishToAllClientsWithString:aString];
}

- (void)receiveMessageWithString:(NSString *)string {
    NSLog(@"kuBlock: xpc service receive: %@", string);
}

@end

int main(int argc, const char *argv[])
{
    // Create the delegate for the service.
    ServiceDelegate *delegate = [ServiceDelegate new];
    [delegate connect];
    
    // Set up the one NSXPCListener for this service. It will handle all incoming connections.
    NSXPCListener *listener = [NSXPCListener serviceListener];
    listener.delegate = delegate;
    
    // Resuming the serviceListener starts this service. This method does not return.
    [listener resume];
    return 0;
}
