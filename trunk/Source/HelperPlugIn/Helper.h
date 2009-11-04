//
//  Helper.h
//  HelperPlugIn
//
//  Created by frumin on 10/22/09.
//  Copyright 2009 LSD Programming. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>
#import <WebKit/WebKit.h>

@interface Helper : NSObject <GrowlApplicationBridgeDelegate> {
	NSMutableData *receivedData;
}

- (void)growlUploadComplete;
- (void)growlUploadFailure;
- (void)setEmail:(NSString *)email password:(NSString *)secret;
- (NSArray *)authenticate;

- (void)web_growlUploadComplete;
- (void)web_growlUploadFailure;
- (void)web_setEmail:(NSString *)email password:(NSString *)secret;
- (NSArray *)web_authenticate;

@end