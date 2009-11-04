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

	// set username and password variables

NSString *username = nil;
NSString *password = nil;

- (void)web_setEmail:(NSString *)email password:(NSString *)secret {
	[self setEmail:email password:secret];
}

- (void)setEmail:(NSString *)email password:(NSString *)secret {
	username = email;
	password = secret;
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
	 iconData: [NSData dataWithData:[[NSImage imageNamed:@"Icon"] TIFFRepresentation]]
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

	// Here we define some methods for authentication with tumblr API

- (NSArray *)web_authenticate {
	[self authenticate];
}

- (NSArray *)authenticate {
	NSLog(@"authenticating");
	receivedData = [[NSMutableData alloc] init];
	NSString *url = @"http://www.tumblr.com/api/authenticate";	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
													   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
													   timeoutInterval:20];
	[request setHTTPShouldHandleCookies:NO];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[[NSString alloc] initWithFormat:@"email=%@", username
						  dataUsingEncoding: NSASCIIStringEncoding]];
	 */
	// [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost: [[NSURL URLWithString:url] host]];
	// [request addValue:@"Twatter" forHTTPHeaderField:@"X-Twitter-Client:"];
	[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark urlconnection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
		// this method is called when the server has determined that it
		// has enough information to create the NSURLResponse
	
		// it can be called multiple times, for example in the case of a
		// redirect, so each time we reset the data.
		// receivedData is declared as a method instance elsewhere
	[receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
		// append the new data to the receivedData
		// receivedData is declared as a method instance elsewhere
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	[connection release];
	
	NSLog(@"%@", receivedData);
	
	[receivedData release];
	receivedData = nil;
	
	NSLog(@"Connection failed!");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[connection release];
	
	NSLog(@"%@", receivedData);
	
	NSXMLDocument *xmlDoc;
    NSError *err=nil;
    
    xmlDoc = [[NSXMLDocument alloc] initWithData:receivedData
												  options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA)
													error:&err];
    if (xmlDoc == nil) {
        xmlDoc = [[NSXMLDocument alloc] initWithData:receivedData
													  options:NSXMLDocumentTidyXML
														error:&err];
    }
    if (xmlDoc == nil)  {
        if (err) {
            NSLog(@"empty :(");
        }
        return;
    }
	
    if (err) {
         NSLog(@"empty :(");
    }
	
	NSLog(@"%@", xmlDoc);
	
	[xmlDoc release];
	[receivedData release];
	receivedData = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	 NSLog(@"got auth challange");
	if ([challenge previousFailureCount] == 0) {
		[[challenge sender]  useCredential:[NSURLCredential credentialWithUser:username password:password persistence:NSURLCredentialPersistenceNone] forAuthenticationChallenge:challenge];
	} else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];        
    }
}

@end
