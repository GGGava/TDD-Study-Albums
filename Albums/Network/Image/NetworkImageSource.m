//
//  NetworkImageSource.m
//  Albums
//
//  Created by Gustavo Gava on 29/11/2024.
//

#import "NetworkImageSource.h"

@implementation NetworkImageSource

@end


@implementation NetworkImageSource (CreateImageSource)

+ (CGImageSourceRef _Nullable (*_Nonnull)(CFDataRef _Nonnull, CFDictionaryRef _Nullable))createImageSource {
  return CGImageSourceCreateWithData;
}

+ (CGImageSourceRef)createImageSourceWithData:(CFDataRef)data
                                      options:(CFDictionaryRef)options {
  return [self createImageSource](data, options);
}

@end

@implementation NetworkImageSource (CreateImage)

+ (CGImageRef _Nullable (*_Nonnull)(CGImageSourceRef _Nonnull, size_t, CFDictionaryRef _Nullable))createImage {
  return CGImageSourceCreateImageAtIndex;
}

+ (CGImageRef)createImageWithImageSource:(CGImageSourceRef)imageSource
                                 atIndex:(size_t)index
                                 options:(CFDictionaryRef)options {
  return [self createImage](imageSource, index, options);
}

@end
