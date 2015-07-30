//
//  MediaTableViewCell.m
//  Fakestagram
//
//  Created by Brian Douglas on 7/25/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "MediaTableViewCell.h"
#import "Media.h"
#import "Comment.h"
#import "User.h"
#import "UIColorExt.h"

@interface MediaTableViewCell () {
    Media* _mediaItem;
}

@property (nonatomic, strong) UIImageView *mediaImageView;
@property (nonatomic, strong) UILabel *usernameAndCaptionLabel;
@property (nonatomic, strong) UILabel *commentLabel;

@end

static UIFont *lightFont;
static UIFont *boldFont;
static UIColor *usernameLabelGray;
static UIColor *commentLabelGray;
static UIColor *commentLabelOrange;
static UIColor *linkColor;
static NSParagraphStyle *paragraphStyle;

@implementation MediaTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setMediaItem:(Media *)mediaItem {
    _mediaItem = mediaItem;
    self.mediaImageView.image = _mediaItem.image;
    self.usernameAndCaptionLabel.attributedText = [self usernameAndCaptionString];
    self.commentLabel.attributedText = [self commentString];
}

+ (void)load {
    lightFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:11];
    boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
    usernameLabelGray = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1];
    commentLabelGray = [UIColor colorWithRed:0.345 green:0.314 blue:0.427 alpha:1];
    commentLabelOrange = [UIColor pxColorWithHexValue:@"#FFA500"];
    linkColor = [UIColor colorWithRed:0.345 green:0.314 blue:0.427 alpha:1];
    
    NSMutableParagraphStyle *mutableParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    mutableParagraphStyle.headIndent = 20.0;
    mutableParagraphStyle.firstLineHeadIndent = 20.0;
    mutableParagraphStyle.tailIndent = -20.0;
    mutableParagraphStyle.paragraphSpacingBefore = 5;
    
    paragraphStyle = mutableParagraphStyle;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.mediaImageView = [[UIImageView alloc] init];
        self.usernameAndCaptionLabel = [[UILabel alloc] init];
        self.usernameAndCaptionLabel.numberOfLines = 0;
        self.usernameAndCaptionLabel.backgroundColor = usernameLabelGray;
                               
        self.commentLabel = [[UILabel alloc] init];
        self.commentLabel.numberOfLines = 0;
        self.commentLabel.backgroundColor = commentLabelGray;

        for (UIView *view in @[self.mediaImageView, self.usernameAndCaptionLabel, self.commentLabel]) {
           [self.contentView addSubview:view];
        }

    }
    return self;
}

- (NSAttributedString *) usernameAndCaptionString {
    CGFloat usernameFontSize = 15;
    
    NSString *baseString = [NSString stringWithFormat:@"%@ %@", self.mediaItem.user.userName, self.mediaItem.caption];
    NSMutableAttributedString *mutableUsernameAndCaptionString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : [lightFont fontWithSize:usernameFontSize], NSParagraphStyleAttributeName : paragraphStyle}];
    NSRange usernameRange = [baseString rangeOfString:self.mediaItem.user.userName];
    [mutableUsernameAndCaptionString addAttribute:NSFontAttributeName value:[boldFont fontWithSize:usernameFontSize] range:usernameRange];
    [mutableUsernameAndCaptionString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
     
    return mutableUsernameAndCaptionString;
}
     
 - (NSAttributedString * ) commentString {
     NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] init];
     
     for (Comment *comment in self.mediaItem.comments) {
         NSString *baseString = [NSString stringWithFormat:@"%@ %@\n", comment.from.userName, comment.text];
         NSMutableAttributedString *oneCommentString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : lightFont, NSParagraphStyleAttributeName : paragraphStyle}];
         
         NSRange usernameRange = [baseString rangeOfString:comment.from.userName];
         [oneCommentString addAttribute:NSFontAttributeName value:boldFont range:usernameRange];
         [oneCommentString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
         
         // Increase the kerning (character spacing) of the image caption.
         float spacing = 1.0f;
         [commentString addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [commentString length])];
         [commentString appendAttributedString:oneCommentString];
         
         // change first comment to orange
         if ([self.mediaItem.comments indexOfObject:comment] == 0) {
             NSRange selectedRange = NSMakeRange(0, oneCommentString.length);
             [commentString setAttributes:@{NSForegroundColorAttributeName: commentLabelOrange} range:selectedRange];
         }
         
         // paragraph align right for every other comment.
         NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
         paragraph.alignment = NSTextAlignmentLeft;

         if ([self.mediaItem.comments indexOfObject:comment] % 2 == 0) {
             NSTextTab *t = [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentRight location:commentString.size.width options:nil];
             paragraph.tabStops = @[t];
         }
     }
     
     return commentString;
 }
     
 - (CGSize) sizeOfString:(NSAttributedString *)string {
     CGSize maxSize = CGSizeMake(CGRectGetWidth(self.contentView.bounds) - 30, 0.0);
     CGRect sizeRect = [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
     sizeRect.size.height += 20;
     sizeRect = CGRectIntegral(sizeRect);
     return sizeRect.size;
 }

 - (void) layoutSubviews {
     [super layoutSubviews];
     
     CGFloat imageHeight = self.mediaItem.image.size.height / self.mediaItem.image.size.width *  CGRectGetWidth(self.contentView.bounds);
     self.mediaImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), imageHeight);
     
     CGSize sizeOfUsernameAndCaptionLabel = [self sizeOfString:self.usernameAndCaptionLabel.attributedText];
     self.usernameAndCaptionLabel.frame = CGRectMake(0, CGRectGetMaxY(self.mediaImageView.frame), CGRectGetWidth(self.contentView.bounds), sizeOfUsernameAndCaptionLabel.height);
     
     CGSize sizeOfCommentLabel = [self sizeOfString:self.commentLabel.attributedText];
     self.commentLabel.frame = CGRectMake(0, CGRectGetMaxY(self.usernameAndCaptionLabel.frame), CGRectGetWidth(self.bounds), sizeOfCommentLabel.height);
 }

+ (CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width {
    // Make a cell
    MediaTableViewCell *layoutCell = [[MediaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"layoutCell"];
    
    // Set it to the given width, and the maximum possible height
    layoutCell.frame = CGRectMake(0, 0, width, CGFLOAT_MAX);
    
    // Give it the media item
    layoutCell.mediaItem = mediaItem;
    
    // Make it adjust the image view and labels
    [layoutCell layoutSubviews];
    
    // The height will be wherever the bottom of the comments label is
    return CGRectGetMaxY(layoutCell.commentLabel.frame);
}
     
@end
