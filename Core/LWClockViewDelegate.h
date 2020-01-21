@protocol LWClockViewDelegate <NSObject>

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event;
- (BOOL)isFaceEditing;
- (BOOL)isFaceSwitching;
- (void)beginZoom;
- (void)setZoomProgress:(CGFloat)progress;
- (void)endZoom:(BOOL)arg1;

@end