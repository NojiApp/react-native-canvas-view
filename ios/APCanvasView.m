#import "APCanvasView.h"

#import <PencilKit/PencilKit.h>

@interface APCanvasView () <PKCanvasViewDelegate>

@end

@implementation APCanvasView {
  PKCanvasView *_canvasView;
  PKToolPicker *_toolPicker;
}

- (instancetype)init {
  if (self = [super init]) {
    _canvasView = [PKCanvasView new];
    [_canvasView setBackgroundColor:[UIColor whiteColor]];
    _canvasView.drawingPolicy = PKCanvasViewDrawingPolicyAnyInput;
    _canvasView.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    _canvasView.delegate = self;
    [self addSubview:_canvasView];
    _canvasView.frame = self.bounds;
    _canvasView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    _toolPicker = [PKToolPicker new];
    _toolPicker.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
  }
  return self;
}

- (void)showToolbar {
  [_toolPicker setVisible:YES forFirstResponder:_canvasView];
  [_toolPicker addObserver:_canvasView];
  [_canvasView becomeFirstResponder];
}

- (void)hideToolbar {
  [_toolPicker setVisible:NO forFirstResponder:_canvasView];
  [_toolPicker removeObserver:_canvasView];
  [_canvasView resignFirstResponder];
}

- (UIImage *)getDrawing {
  PKDrawing *drawing = _canvasView.drawing;

  CGFloat margin = 24.0;
  CGFloat scale = [UIScreen mainScreen].scale;

  CGRect drawingBounds = drawing.bounds;
  CGRect expandedBounds = CGRectInset(drawingBounds, -margin, -margin);

  UIGraphicsBeginImageContextWithOptions(expandedBounds.size, YES, scale);
  [[UIColor whiteColor] setFill];
  UIRectFill(CGRectMake(0, 0, expandedBounds.size.width, expandedBounds.size.height));

  UIImage *drawingImage = [drawing imageFromRect:expandedBounds scale:scale];
  [drawingImage drawInRect:CGRectMake(0, 0, expandedBounds.size.width, expandedBounds.size.height)];

  UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return finalImage;
}

- (void)undo {
  [_canvasView.undoManager undo];
  [self notifyUndoRedo];
}

- (void)redo {
  [_canvasView.undoManager redo];
  [self notifyUndoRedo];
}

# pragma mark - Internal

- (void)notifyUndoRedo {
  BOOL canUndo = _canvasView.undoManager.canUndo;
  BOOL canRedo = _canvasView.undoManager.canRedo;
  if (self.onUndoRedoChange) {
    self.onUndoRedoChange(@{@"canUndo": @(canUndo), @"canRedo": @(canRedo)});
  }
}

# pragma mark - PKCanvasViewDelegate

- (void)canvasViewDrawingDidChange:(PKCanvasView *)canvasView {
  [self notifyUndoRedo];
};

@end
