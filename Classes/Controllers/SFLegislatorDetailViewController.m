//
//  SFLegislatorDetailViewController.m
//  Congress
//
//  Created by Daniel Cloud on 12/13/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "SFBoundaryService.h"
#import "SFDistrictMapViewController.h"
#import "SFLegislatorDetailViewController.h"
#import "SFLegislatorDetailView.h"
#import "SFLegislatorService.h"
#import "SFLegislator.h"
#import "UIImageView+AFNetworking.h"
#import "SFImageButton.h"

@implementation SFLegislatorDetailViewController
{
    SSLoadingView *_loadingView;
    NSMutableDictionary *_socialButtons;
}

@synthesize mapViewController = _mapViewController;
@synthesize legislator = _legislator;
@synthesize legislatorDetailView = _legislatorDetailView;

+ (NSDictionary *)socialButtonImages
{
    return @{@"facebook": [UIImage facebookImage], @"twitter": [UIImage twitterImage], @"youtube": [UIImage youtubeImage]};
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self _initialize];
        self.trackedViewName = @"Legislator Detail Screen";
        self.restorationIdentifier = NSStringFromClass(self.class);
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadView {
    _legislatorDetailView.frame = [[UIScreen mainScreen] applicationFrame];
    _legislatorDetailView.autoresizesSubviews = YES;
    self.view = _legislatorDetailView;
}

#pragma mark - Accessors

-(void)setLegislator:(SFLegislator *)legislator
{
    _legislator = legislator;
    _shareableObjects = [NSMutableArray array];
    [_shareableObjects addObject:_legislator];
    [_shareableObjects addObject:_legislator.shareURL];

    NSDictionary *socialImages = [[self class] socialButtonImages];
    for (NSString *key in _legislator.socialURLs) {
        UIButton *socialButton = [SFImageButton button];
        UIImage *socialImage = [socialImages valueForKey:key];
        [socialButton setImage:socialImage forState:UIControlStateNormal];
        [_socialButtons setObject:socialButton forKey:key];
        [socialButton setTarget:self action:@selector(handleSocialButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [_legislatorDetailView.socialButtonsView addSubview:socialButton];
    }

    [self updateView];
}

#pragma mark - Private

-(void)_initialize {

    if (!_legislatorDetailView) {
        _legislatorDetailView = [[SFLegislatorDetailView alloc] initWithFrame:CGRectZero];
        _legislatorDetailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    _socialButtons = [NSMutableDictionary dictionary];

    [_legislatorDetailView.favoriteButton addTarget:self action:@selector(handleFavoriteButtonPress) forControlEvents:UIControlEventTouchUpInside];
    _legislatorDetailView.favoriteButton.selected = NO;

    CGSize size = self.view.frame.size;
    _loadingView = [[SSLoadingView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    _loadingView.backgroundColor = [UIColor primaryBackgroundColor];
    [self.view addSubview:_loadingView];
    
    _mapViewController = [[SFDistrictMapViewController alloc] init];
    [self addChildViewController:_mapViewController];
    [self.view addSubview:_mapViewController.view];
    [_mapViewController didMoveToParentViewController:self];
    [_mapViewController.view sizeToFit];
    [_mapViewController.view setFrame:CGRectMake(0.0f, 300.0f, size.width, size.height - 300.0f)];

}

-(void)updateView
{
    self.title = _legislator.titledName;
    
    if (self.legislatorDetailView) {
        _legislatorDetailView.nameLabel.text = _legislator.fullName;
        _legislatorDetailView.favoriteButton.selected = _legislator.persist;

        NSMutableAttributedString *contactText = [[NSMutableAttributedString alloc] initWithString:@"CONTACT "];
        [contactText addAttribute:NSFontAttributeName value:[UIFont subitleStrongFont] range:NSMakeRange(0, contactText.length)];
        NSMutableAttributedString *legNameString =  [[NSMutableAttributedString alloc] initWithString:_legislator.fullName];
        [legNameString addAttribute:NSFontAttributeName value:[UIFont subitleEmFont] range:NSMakeRange(0, legNameString.length)];
        [contactText appendAttributedString:legNameString];
        _legislatorDetailView.contactLabel.attributedText = contactText;

        NSRange secondaryAddressRange = [_legislator.congressOffice rangeOfString:@"office building" options:NSCaseInsensitiveSearch];
        NSString *secondaryAddress = [_legislator.congressOffice substringWithRange:secondaryAddressRange];
        NSString *primaryAddress =  [_legislator.congressOffice substringToIndex:secondaryAddressRange.location];
        _legislatorDetailView.addressLabel.text = [NSString stringWithFormat:@"%@\n%@", primaryAddress, secondaryAddress];

        NSMutableAttributedString *infoText = [[NSMutableAttributedString alloc] init];

        NSMutableAttributedString *stateStr = [NSMutableAttributedString stringWithFormat:@"%@ ", _legislator.stateName];
        [stateStr addAttribute:NSFontAttributeName value:[UIFont subitleEmFont] range:NSMakeRange(0, stateStr.length)];
        [infoText appendAttributedString:stateStr];

        NSMutableAttributedString *partyStr = [[NSMutableAttributedString alloc] initWithString:_legislator.partyName];
        [partyStr addAttribute:NSFontAttributeName value:[UIFont subitleStrongFont] range:NSMakeRange(0, partyStr.length)];
        [infoText appendAttributedString:partyStr];

        [infoText appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        
        NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc] initWithString:_legislator.fullTitle];
        [titleStr addAttribute:NSFontAttributeName value:[UIFont subitleStrongFont] range:NSMakeRange(0, titleStr.length)];
        [infoText appendAttributedString:titleStr];

        NSMutableAttributedString *districtStr = [NSMutableAttributedString new];
        if (_legislator.district) {
            [districtStr appendAttributedString:[NSMutableAttributedString stringWithFormat:@" District %@\n", _legislator.district]];
            [districtStr addAttribute:NSFontAttributeName value:[UIFont subitleFont] range:NSMakeRange(0, districtStr.length)];
        }
        [infoText appendAttributedString:districtStr];

        [infoText addAttribute:NSForegroundColorAttributeName value:[UIColor subtitleColor] range:NSMakeRange(0, infoText.length)];
        NSMutableParagraphStyle *pStyle = [NSMutableParagraphStyle new];
        pStyle.alignment = NSTextAlignmentLeft;
        [infoText addAttribute:NSParagraphStyleAttributeName value:pStyle range:NSMakeRange(0, infoText.length)];
        self.legislatorDetailView.infoText.attributedText = infoText;

        LegislatorImageSize imgSize = [UIScreen mainScreen].scale > 1.0f ? LegislatorImageSizeLarge : LegislatorImageSizeMedium;
        NSURL *imageURL = [SFLegislatorService legislatorImageURLforId:_legislator.bioguideId size:imgSize];
        [self.legislatorDetailView.photo setImageWithURL:imageURL];

        NSString *genderedPronoun = [_legislator.gender isEqualToString:@"F"] ? @"her" : @"his";
        [self.legislatorDetailView.callButton setTitle:[NSString stringWithFormat:@"Call %@ office", genderedPronoun] forState:UIControlStateNormal];
        [self.legislatorDetailView.callButton addTarget:self action:@selector(handleCallButtonPress) forControlEvents:UIControlEventTouchUpInside];
//        [self.legislatorDetailView.map.expandoButton addTarget:self action:@selector(handleMapResizeButtonPress) forControlEvents:UIControlEventTouchUpInside];

        if (_legislator.websiteURL)
        {
            [self.legislatorDetailView.websiteButton addTarget:self action:@selector(handleWebsiteButtonPress) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            self.legislatorDetailView.websiteButton.enabled = NO;
        }

        if (_legislator.district) {
            [self.mapViewController loadBoundaryForLegislator:_legislator];
        }
        
        [_loadingView removeFromSuperview];
        [_legislatorDetailView layoutSubviews];
    }
}

-(void)handleSocialButtonPress:(id)sender
{
    NSString *senderKey = [_socialButtons mtl_keyOfEntryPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        return [obj isEqual:sender];
    }];
    NSURL *externalURL = [_legislator.socialURLs objectForKey:senderKey];
    BOOL urlOpened = [[UIApplication sharedApplication] openURL:externalURL];
    if (!urlOpened) {
        NSLog(@"Unable to open externalURL: %@", [externalURL absoluteString]);
    }
}

-(void)handleCallButtonPress
{
    NSURL *phoneURL = [NSURL URLWithFormat:@"tel:%@", _legislator.phone];
#if CONFIGURATION_Beta
    [TestFlight passCheckpoint:@"Pressed call legislator button"];
#endif
    BOOL urlOpened = [[UIApplication sharedApplication] openURL:phoneURL];
    if (!urlOpened) {
        NSLog(@"Unable to open phone url %@", [phoneURL absoluteString]);
    }
}

-(void)handleWebsiteButtonPress
{
    BOOL urlOpened = [[UIApplication sharedApplication] openURL:_legislator.websiteURL];
#if CONFIGURATION_Beta
    [TestFlight passCheckpoint:@"Pressed legislator website button"];
#endif
    if (!urlOpened) {
        NSLog(@"Unable to open _legislator.website: %@", [_legislator.websiteURL absoluteString]);
    }
}

#pragma mark - SFFavoriting protocol

- (void)handleFavoriteButtonPress
{
    self.legislator.persist = !self.legislator.persist;
    _legislatorDetailView.favoriteButton.selected = self.legislator.persist;
#if CONFIGURATION_Beta
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"%@avorited legislator", (self.legislator.persist ? @"F" : @"Unf")]];
#endif
}

@end
