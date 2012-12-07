//
//  SFBillDetailView.m
//  Congress
//
//  Created by Daniel Cloud on 12/4/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "SFBillDetailView.h"

@implementation SFBillDetailView

@synthesize billTitleLabel = _billTitleLabel;
@synthesize billIdLabel = _billIdLabel;
@synthesize billSummary = _billSummary;

#pragma mark - UIView

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		[self _initialize];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initialize];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(void)layoutSubviews
{
    CGSize size = self.bounds.size;

    CGSize labelTextSize = [_billTitleLabel.text sizeWithFont:_billTitleLabel.font];
    _billTitleLabel.frame = CGRectMake(0.0f, 0.0f, size.width, labelTextSize.height);

    CGFloat offset_y = _billTitleLabel.frame.origin.y + labelTextSize.height + 6.0f;
    CGSize billIdLabelTextSize = [_billIdLabel.text sizeWithFont:_billIdLabel.font];
    _billIdLabel.frame = CGRectMake(0.0f, offset_y, size.width, billIdLabelTextSize.height);

    offset_y = _billIdLabel.frame.origin.y + billIdLabelTextSize.height + 6.0f;
    _billSummary.frame = CGRectMake(0.0f, offset_y, size.width, size.height);
}

#pragma mark - Private Methods

-(void)_initialize
{
    self.backgroundColor = [UIColor whiteColor];
	self.opaque = YES;

    _billTitleLabel = [[SSLabel alloc] initWithFrame:CGRectZero];
    _billTitleLabel.font = [UIFont boldSystemFontOfSize:18];
    _billTitleLabel.backgroundColor = [UIColor colorWithWhite:0.895 alpha:1.000]; // Gray for dev purposes
    _billTitleLabel.textColor = [UIColor blackColor];
    _billTitleLabel.textAlignment = NSTextAlignmentLeft;
    _billTitleLabel.verticalTextAlignment = SSLabelVerticalTextAlignmentTop;
    _billTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:_billTitleLabel];

    _billIdLabel = [[SSLabel alloc] initWithFrame:CGRectZero];
    _billIdLabel.font = [UIFont systemFontOfSize:16.0f];
    _billTitleLabel.backgroundColor = [UIColor colorWithWhite:0.702 alpha:1.000]; // Gray for dev purposes
    _billIdLabel.textAlignment = NSTextAlignmentLeft;
    _billIdLabel.verticalTextAlignment = SSLabelVerticalTextAlignmentTop;
    [self addSubview:_billIdLabel];

    
    _billSummary = [[SSLabel alloc] initWithFrame:CGRectZero];
    _billSummary.numberOfLines = 0;
    _billSummary.lineBreakMode = NSLineBreakByWordWrapping;
    _billSummary.font = [UIFont systemFontOfSize:14.0f];
    _billSummary.textColor = [UIColor blackColor];
    _billSummary.textAlignment = NSTextAlignmentLeft;
    _billSummary.verticalTextAlignment = SSLabelVerticalTextAlignmentTop;
    _billSummary.backgroundColor = [UIColor colorWithWhite:0.400 alpha:1.000]; // Gray for dev purposes

    [self addSubview:_billSummary];
}


@end