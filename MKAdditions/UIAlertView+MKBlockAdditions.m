//
//  UIAlertView+MKBlockAdditions.m
//  UIKitCategoryAdditions
//
//  Created by Mugunth on 21/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIAlertView+MKBlockAdditions.h"
#import <objc/runtime.h>

static char DISMISS_IDENTIFER;
static char CANCEL_IDENTIFER;
static char TITLE_IDENTIFIER;

@implementation UIAlertView (Block)

@dynamic cancelBlock;
@dynamic dismissBlock;
@dynamic buttonTitleBlock;

- (void)setButtonTitleBlock:(ButtonTitleDismissBlock)buttonTitleBlock {
    objc_setAssociatedObject(self, &TITLE_IDENTIFIER, buttonTitleBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (ButtonTitleDismissBlock)buttonTitleBlock {
    return objc_getAssociatedObject(self, &TITLE_IDENTIFIER);
}

- (void)setDismissBlock:(DismissBlock)dismissBlock
{
    objc_setAssociatedObject(self, &DISMISS_IDENTIFER, dismissBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (DismissBlock)dismissBlock
{
    return objc_getAssociatedObject(self, &DISMISS_IDENTIFER);
}

- (void)setCancelBlock:(CancelBlock)cancelBlock
{
    objc_setAssociatedObject(self, &CANCEL_IDENTIFER, cancelBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CancelBlock)cancelBlock
{
    return objc_getAssociatedObject(self, &CANCEL_IDENTIFER);
}


+ (UIAlertView*) alertViewWithTitle:(NSString*) title                    
                    message:(NSString*) message 
          cancelButtonTitle:(NSString*) cancelButtonTitle
          otherButtonTitles:(NSArray*) otherButtons
                  onDismiss:(DismissBlock) dismissed
                   onCancel:(CancelBlock) cancelled {
        
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:[self class]
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:nil];
    
    [alert setDismissBlock:dismissed];
    [alert setCancelBlock:cancelled];
    
    for(NSString *buttonTitle in otherButtons)
        [alert addButtonWithTitle:buttonTitle];
    
    [alert show];
    return alert;
}

+ (UIAlertView*) alertViewWithTitle:(NSString*) title
                  otherButtonTitles:(NSArray*) otherButtons
                      buttonDismiss:(ButtonTitleDismissBlock) dismissed
                           onCancel:(CancelBlock) cancelled {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:nil
                                                   delegate:[self class]
                                          cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
                                          otherButtonTitles:nil];
    
    [alert setButtonTitleBlock:dismissed];
    [alert setCancelBlock:cancelled];
    
    for(NSString *buttonTitle in otherButtons)
        [alert addButtonWithTitle:buttonTitle];
    
    [alert show];
    return alert;
}


+ (UIAlertView*) alertViewWithTitle:(NSString*) title 
                    message:(NSString*) message {
    
    return [UIAlertView alertViewWithTitle:title 
                                   message:message 
                         cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")];
}

+ (UIAlertView*) alertViewWithTitle:(NSString*) title 
                    message:(NSString*) message
          cancelButtonTitle:(NSString*) cancelButtonTitle {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles: nil];
    [alert show];
    return alert;
}


+ (void)alertView:(UIAlertView*) alertView didDismissWithButtonIndex:(NSInteger) buttonIndex {
    
	if(buttonIndex == [alertView cancelButtonIndex])
	{
		if (alertView.cancelBlock) {
            alertView.cancelBlock();
        }
	}
    else
    {
        if (alertView.buttonTitleBlock) {
            NSString *titleForButton = [alertView buttonTitleAtIndex:buttonIndex];
            alertView.buttonTitleBlock(buttonIndex - 1,titleForButton); // cancel button is button 0
        }
        if (alertView.dismissBlock) {
            alertView.dismissBlock(buttonIndex - 1);
        }
    }
}

@end