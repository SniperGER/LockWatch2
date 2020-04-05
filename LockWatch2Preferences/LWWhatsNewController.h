#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface LWWhatsNewController : UIViewController <WKNavigationDelegate> {
	WKWebView* webView;
}

@end