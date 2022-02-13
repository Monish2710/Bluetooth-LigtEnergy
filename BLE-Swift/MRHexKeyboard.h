

#import <UIKit/UIKit.h>

typedef void (^DoneAction) (void);

@interface MRHexKeyboard : UIView

- (MRHexKeyboard *)initWithTextField:(UITextField *)textField;

-(void)setDoneAction:(DoneAction)action;

@end
