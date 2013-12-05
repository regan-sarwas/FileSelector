//
//  FSEntryCell.m
//  FileSelector
//
//  Created by Regan Sarwas on 11/7/13.
//  Copyright (c) 2013 GIS Team. All rights reserved.
//

#import "FSEntryCell.h"

@implementation FSEntryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [UIView animateWithDuration:0.1 animations:^{
        if (editing && !self.showingDeleteConfirmation) {
            self.titleTextField.enabled = YES;
            self.titleTextField.borderStyle = UITextBorderStyleRoundedRect;
        } else {
            self.titleTextField.enabled = NO;
            self.titleTextField.borderStyle = UITextBorderStyleNone;
        }
    }];
}



@end
