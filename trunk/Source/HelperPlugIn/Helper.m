//
//  Helper.m
//  HelperPlugIn
//
//  Created by frumin on 10/22/09.
//  Copyright 2009 LSD Programming. All rights reserved.
//

#import "Helper.h"


@implementation Helper

	// Dashboard methods
- (id)initWithWebView:(WebView *)webview {
	self = [super init];
	[GrowlApplicationBridge setGrowlDelegate:self];
	
    return self;
}

- (void)windowScriptObjectAvailable:(WebScriptObject *)webScriptObject {
	[webScriptObject setValue:self forKey:@"HelperPlugIn"];
}

+ (BOOL) isKeyExcludedFromWebScript:(const char*)key {
	return YES;
}

	// Used for convenience of WebScripting names below
NSString * const kWebSelectorPrefix = @"web_";

	// This is where prefixing our JavaScript methods with web_ pays off:
	// instead of a huge if/else trail to decide which methods to exclude,
	// just check the selector names for kWebSelectorPrefix
+ (BOOL) isSelectorExcludedFromWebScript:(SEL)aSelector {
	return !([NSStringFromSelector(aSelector) hasPrefix:kWebSelectorPrefix]);
}

	// Another simple implementation: take the first token of the Obj-C method signature
	// and remove the web_ prefix. So web_birthdaysToday is called from JavaScript as
	// BirthdaysPlugIn.birthdaysToday
+ (NSString *) webScriptNameForSelector:(SEL)aSelector {
	NSString*	selName = NSStringFromSelector(aSelector);
	
	if ([selName hasPrefix:kWebSelectorPrefix] && ([selName length] > [kWebSelectorPrefix length])) {
		return [[[selName substringFromIndex:[kWebSelectorPrefix length]] componentsSeparatedByString: @":"] objectAtIndex: 0];
	}
	return nil;
}

	// Growl implementation
- (void)growlUploadComplete {
	
		//Show Growl notification
	
	[GrowlApplicationBridge
	 notifyWithTitle:@"tumblr uploadr"
	 description:@"Upload complete"
	 notificationName:@"Upload notification"
	 iconData: nil
	 priority:1
	 isSticky:NO
	 clickContext:@"clickBack"];
}

- (void)web_growlUploadComplete {
	[self growlUploadComplete];
}

- (void)growlUploadFailure {
	
		// Show Growl notification
	
	[GrowlApplicationBridge
	 notifyWithTitle:@"tumblr uploadr"
	 description:@"Upload failed"
	 notificationName:@"Upload notification"
	 iconData: nil
	 priority:1
	 isSticky:NO
	 clickContext:@"clickBack"];
}

- (void)web_growlUploadFailure {
	[self growlUploadFailure];
}

- (NSDictionary *) registrationDictionaryForGrowl
{
	NSArray *notifications = [NSArray arrayWithObject: @"Upload notification"];
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  notifications, GROWL_NOTIFICATIONS_ALL,
						  notifications, GROWL_NOTIFICATIONS_DEFAULT, nil];
	
	return dict;
}

@end
