//
//  LWFaceLibraryOverlayView.m
//  LockWatch2
//
//  Created by janikschmidt on 1/19/2020.
//  Copyright © 2020 Team FESTIVAL. All rights reserved.
//

#import "Core/LWEmulatedDevice.h"

#import "LWFaceLibraryOverlayView.h"

@implementation LWFaceLibraryOverlayView 

- (id)initForDevice:(CLKDevice*)device {
	if (self = [super initWithFrame:device.actualScreenBounds]) {
		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
		[self setClipsToBounds:NO];
		[self setDelegate:self];
		
		_device = device;
		
		_titleLabels = [NSMutableDictionary dictionary];
		
		/// TODO: Edit Button
		/// TODO: Cancel Button
	}
	
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	[_titleLabels enumerateKeysAndObjectsUsingBlock:^(NSNumber* index, UILabel* label, BOOL* stop) {
		[label sizeToFit];
		[label setCenter:(CGPoint){ (CGRectGetWidth(self.bounds) / 2) + (CGRectGetWidth(self.bounds) * index.intValue), 14.5 }];
	}];
	
	[self updateContentSize];
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
	UIView* view = [super hitTest:point withEvent:event];
	
	if (view != _editButton && view != _cancelButton) {
		return nil;
	} else {
		return view;
	}
}

- (void)setContentOffset:(CGPoint)contentOffset {
	[super setContentOffset:contentOffset];
	
	// [self setLabelOffset:contentOffset.x];
}

#pragma mark - Instance Methods

- (void)addTitle:(NSString*)title forIndex:(NSInteger)index {
	if ([_titleLabels objectForKey:@(index)]) return;
	
	UILabel* titleLabel = [self newTitleLabel];
	[titleLabel setText:title];
	
	[self addSubview:titleLabel];
	[titleLabel sizeToFit];
	// [titleLabel setCenter:(CGPoint){ (CGRectGetWidth(self.bounds) / 2) + ((CGRectGetWidth(self.bounds) / 2) * index), 14.5 }];
	
	[_titleLabels setObject:titleLabel forKey:@(index)];
	
	// [self updateContentSize];
}

- (UILabel*)labelAtIndex:(NSInteger)index {
	if ([_titleLabels objectForKey:@(index)]) return [_titleLabels objectForKey:@(index)];
	
	return nil;
}

- (UILabel*)newTitleLabel {
	UILabel* label = [UILabel new];
	[label setFont:[UIFont systemFontOfSize:14]];
	[label setTextColor:[UIColor whiteColor]];
	
	return label;
}

- (void)scrollToLabelAtIndex:(NSInteger)index animated:(BOOL)animated {
	CGPoint contentOffset = (CGPoint){ CGRectGetWidth(self.bounds) * index, 0 };
	[self setContentOffset:contentOffset animated:animated];
	[self setLabelOffset:contentOffset.x];
}

- (void)setLabelOffset:(CGFloat)offset {
	NSInteger pageIndex = MAX(MIN(ceilf(offset / _distanceBetweenLabels), _titleLabels.allKeys.count - 1), 0);
	CGFloat width = _distanceBetweenLabels;
	CGFloat pageProgress = ((pageIndex * width) - offset) / width;
	pageProgress = (round(pageProgress * 100)) / 100.0;

	NSInteger previousPageIndex = (pageIndex > 0) ? pageIndex : 0;
	NSInteger nextPageIndex = (pageIndex < _titleLabels.allKeys.count - 1) ? pageIndex : _titleLabels.allKeys.count - 1;
	
	// if (_previousScrollPosition != offset) {
		[_titleLabels enumerateKeysAndObjectsUsingBlock:^(NSNumber* index, UILabel* label, BOOL* stop) {
			[label setAlpha:0];
		}];
		
		if (_previousScrollPosition == offset) {
			UILabel* currentPage = [self labelAtIndex:pageIndex];
			[currentPage setAlpha:1];
		}
		
		if (_previousScrollPosition < offset) {
			// Scroll from right to left
			UILabel* nextPage = [self labelAtIndex:nextPageIndex];
			
			if (offset + width <= self.contentSize.width && offset > 0) {
				NSInteger currentPageIndex = MAX(nextPageIndex - 1, 0);
				UILabel* currentPage = [self labelAtIndex:currentPageIndex];
				
				[currentPage setAlpha:MAX(0, pageProgress)];
				[nextPage setAlpha:MAX(0, 1 - pageProgress)];
			} else if (offset <= 0) {
				UILabel* currentPage = [self labelAtIndex:pageIndex];
				[currentPage setAlpha:MAX(0.35, 1 + (offset / width))];
			} else {
				UILabel* currentPage = [self labelAtIndex:pageIndex];
				[currentPage setAlpha:MAX(0, 1 - ((offset + width) - self.contentSize.width) / width)];
			}
		}
		
		if (_previousScrollPosition > offset) {
			// Scroll from left to right
			UILabel* previousPage = [self labelAtIndex:previousPageIndex];
			
			if (offset >= 0 && offset + width <= self.contentSize.width) {
				NSInteger currentPageIndex = MIN(previousPageIndex - 1, _titleLabels.allKeys.count);
				UILabel* currentPage = [self labelAtIndex:currentPageIndex];
				
				[currentPage setAlpha:MAX(0, pageProgress)];
				[previousPage setAlpha:MAX(0, 1 - pageProgress)];
			} else if (offset + width > self.contentSize.width) {
				UILabel* currentPage = [self labelAtIndex:pageIndex];
				[currentPage setAlpha:MAX(0, 1 - ((offset + width) - self.contentSize.width) / width)];
			} else {
				UILabel* currentPage = [self labelAtIndex:pageIndex];
				[currentPage setAlpha:MAX(0.35, 1 + (offset / width))];
			}
		}
	// }
	
	_previousScrollPosition = offset;
}

- (void)updateContentSize {
	[self setContentSize:(CGSize){ CGRectGetWidth(self.bounds) + (_distanceBetweenLabels * (_titleLabels.allKeys.count - 1)), 0 }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
	[self setLabelOffset:scrollView.contentOffset.x];
	/*NSInteger pageIndex = MAX(MIN(ceilf(scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds)), _titleLabels.allKeys.count - 1), 0);
	CGFloat width = CGRectGetWidth(scrollView.bounds);
	CGFloat pageProgress = ((pageIndex * width) - scrollView.contentOffset.x) / width;
	pageProgress = (round(pageProgress * 100)) / 100.0;
	
	NSInteger previousPageIndex = (pageIndex > 0) ? pageIndex : 0;
	NSInteger nextPageIndex = (pageIndex < _titleLabels.allKeys.count - 1) ? pageIndex : _titleLabels.allKeys.count - 1;
	
	if (_previousScrollPosition != scrollView.contentOffset.x) {
		[_titleLabels enumerateKeysAndObjectsUsingBlock:^(NSNumber* index, UILabel* label, BOOL* stop) {
			[label setAlpha:0];
		}];
		
		if (_previousScrollPosition < scrollView.contentOffset.x) {
			// Scroll from right to left
			UILabel* nextPage = [self labelAtIndex:nextPageIndex];
			
			if (scrollView.contentOffset.x + width <= scrollView.contentSize.width && scrollView.contentOffset.x > 0) {
				NSInteger currentPageIndex = MAX(nextPageIndex - 1, 0);
				UILabel* currentPage = [self labelAtIndex:currentPageIndex];
				
				[currentPage setAlpha:MAX(0, pageProgress)];
				[nextPage setAlpha:MAX(0, 1 - pageProgress)];
			} else if (scrollView.contentOffset.x <= 0) {
				UILabel* currentPage = [self labelAtIndex:pageIndex];
				[currentPage setAlpha:MAX(0.35, 1 + (scrollView.contentOffset.x / width))];
			} else {
				UILabel* currentPage = [self labelAtIndex:pageIndex];
				[currentPage setAlpha:MAX(0, 1 - ((scrollView.contentOffset.x + width) - scrollView.contentSize.width) / width)];
			}
		}
		
		if (_previousScrollPosition > scrollView.contentOffset.x) {
			// Scroll from left to right
			UILabel* previousPage = [self labelAtIndex:previousPageIndex];
			
			if (scrollView.contentOffset.x >= 0 && scrollView.contentOffset.x + width <= scrollView.contentSize.width) {
				NSInteger currentPageIndex = MIN(previousPageIndex - 1, _titleLabels.allKeys.count);
				UILabel* currentPage = [self labelAtIndex:currentPageIndex];
				
				[currentPage setAlpha:MAX(0, pageProgress)];
				[previousPage setAlpha:MAX(0, 1 - pageProgress)];
			} else if (scrollView.contentOffset.x + width > scrollView.contentSize.width) {
				UILabel* currentPage = [self labelAtIndex:pageIndex];
				[currentPage setAlpha:MAX(0, 1 - ((scrollView.contentOffset.x + width) - scrollView.contentSize.width) / width)];
			} else {
				UILabel* currentPage = [self labelAtIndex:pageIndex];
				[currentPage setAlpha:MAX(0.35, 1 + (scrollView.contentOffset.x / width))];
			}
		}
	}
	
	_previousScrollPosition = scrollView.contentOffset.x;*/
}

@end