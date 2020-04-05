#import "LWWhatsNewController.h"

@implementation LWWhatsNewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSBundle* prefBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/LockWatch2Preferences.bundle"];
	NSBundle* localizableBundle = [NSBundle bundleWithPath:@"/Library/Application Support/LockWatch2"];
	
	[self setTitle:[localizableBundle localizedStringForKey:@"WHATS_NEW_TITLE" value:nil table:nil]];
	
	UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
	self.navigationItem.rightBarButtonItem = rightButton;
	
	webView = [[WKWebView alloc] initWithFrame:CGRectZero];
	[webView setNavigationDelegate:self];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[prefBundle pathForResource:@"index" ofType:@"html"]]]];
	
	[self.view addSubview:webView];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[webView setFrame:self.view.bounds];
}

- (void)dismiss {
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id)coordinator {
	[coordinator animateAlongsideTransition:^(id  _Nonnull context) {
        [webView setFrame:self.view.bounds];
    } completion:nil];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
	if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
		if (navigationAction.request.URL) {
			[[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:nil];
			decisionHandler(WKNavigationActionPolicyCancel);
		} else {
			decisionHandler(WKNavigationActionPolicyAllow);
		}
	} else {
		decisionHandler(WKNavigationActionPolicyAllow);
	}
}

@end