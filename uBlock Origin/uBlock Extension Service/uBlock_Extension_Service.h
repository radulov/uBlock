//
//  uBlock_Extension_Service.h
//  uBlock Extension Service
//
//  Created by Viktor Radulov on 23.11.2021.
//

#import <Foundation/Foundation.h>
#import "uBlock_Extension_Service-Swift.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface uBlock_Extension_Service : NSObject <TestServiceProtocol>
@end
