//
//  RNVideoTrimmerViewManager.m
//  react-native-legit-video-trimmer
//
//  Created by Andrii Novoselskyi on 27.08.2020.
//

#import "React/RCTViewManager.h"

@interface RCT_EXTERN_MODULE(VideoTrimmerViewManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(source, NSString)
RCT_EXPORT_VIEW_PROPERTY(minDuration, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(maxDuration, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(mainColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(handleColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(positionBarColor, NSString)

@end
