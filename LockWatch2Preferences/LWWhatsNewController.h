#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface LWWhatsNewController : UIViewController <WKNavigationDelegate> {
	NSBundle* prefBundle;
	WKWebView* webView;
}

@end