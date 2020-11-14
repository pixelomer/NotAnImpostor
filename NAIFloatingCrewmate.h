#import <UIKit/UIKit.h>

@interface NAIFloatingCrewmate : UIView
@property (nonatomic, assign) NSUInteger crewmateID;
@property (nonatomic, strong) UIColor *_Nonnull lightColor;
@property (nonatomic, strong) UIColor *_Nonnull darkColor;
+ (NSUInteger)crewmateCount;
@end