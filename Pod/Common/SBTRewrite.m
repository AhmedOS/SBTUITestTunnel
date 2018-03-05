// SBTRewrite.m
//
// Copyright (C) 2016 Subito.it S.r.l (www.subito.it)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#if DEBUG
#ifndef ENABLE_UITUNNEL
#define ENABLE_UITUNNEL 1
#endif
#endif

#if ENABLE_UITUNNEL

#import "SBTRewrite.h"

#pragma mark - SBTRewriteReplacement

@interface SBTRewriteReplacement()

@property (nonatomic, strong) NSData *findData;
@property (nonatomic, strong) NSData *replaceData;

@end

@implementation SBTRewriteReplacement

- (id)initWithCoder:(NSCoder *)decoder
{
    NSData *findData = [decoder decodeObjectForKey:NSStringFromSelector(@selector(findData))];
    NSData *replaceData = [decoder decodeObjectForKey:NSStringFromSelector(@selector(replaceData))];
    
    NSString *find = [findData base64EncodedStringWithOptions:0];
    NSString *replace = [replaceData base64EncodedStringWithOptions:0];

    SBTRewriteReplacement *ret = [self initWithFind:find replace:replace];
    
    return ret;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.findData forKey:NSStringFromSelector(@selector(findData))];
    [encoder encodeObject:self.replaceData forKey:NSStringFromSelector(@selector(replaceData))];
}

- (instancetype)initWithFind:(NSString *)find replace:(NSString *)replace
{
    if ((self = [super init])) {
        self.findData = [find dataUsingEncoding:NSUTF8StringEncoding];
        self.replaceData = [replace dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return self;
}

@end

#pragma mark - SBTRewrite

@interface SBTRewrite()

@property (nonatomic, strong) NSArray<SBTRewriteReplacement *> *urlReplacement;
@property (nonatomic, strong) NSArray<SBTRewriteReplacement *> *requestReplacement;
@property (nonatomic, strong) NSArray<SBTRewriteReplacement *> *responseReplacement;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *requestHeadersReplacement;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *responseHeadersReplacement;
@property (nonatomic, assign) NSInteger responseCode;

@end

@implementation SBTRewrite

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
    NSArray<SBTRewriteReplacement *> *urlReplacement = [decoder decodeObjectForKey:NSStringFromSelector(@selector(urlReplacement))];
    NSArray<SBTRewriteReplacement *> *requestReplacement = [decoder decodeObjectForKey:NSStringFromSelector(@selector(requestReplacement))];
    NSArray<SBTRewriteReplacement *> *responseReplacement = [decoder decodeObjectForKey:NSStringFromSelector(@selector(responseReplacement))];
    NSDictionary<NSString *, NSString *> *requestHeadersReplacement = [decoder decodeObjectForKey:NSStringFromSelector(@selector(requestHeadersReplacement))];
    NSDictionary<NSString *, NSString *> *responseHeadersReplacement = [decoder decodeObjectForKey:NSStringFromSelector(@selector(responseHeadersReplacement))];
    NSInteger responseCode = [decoder decodeIntegerForKey:NSStringFromSelector(@selector(responseCode))];

    return [self initWithUrlReplacement:urlReplacement
                     requestReplacement:requestReplacement
              requestHeadersReplacement:requestHeadersReplacement
                    responseReplacement:responseReplacement
             responseHeadersReplacement:responseHeadersReplacement
                           responseCode:responseCode];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.urlReplacement forKey:NSStringFromSelector(@selector(urlReplacement))];
    [encoder encodeObject:self.requestReplacement forKey:NSStringFromSelector(@selector(requestReplacement))];
    [encoder encodeObject:self.responseReplacement forKey:NSStringFromSelector(@selector(responseReplacement))];
    [encoder encodeObject:self.requestHeadersReplacement forKey:NSStringFromSelector(@selector(requestHeadersReplacement))];
    [encoder encodeObject:self.responseHeadersReplacement forKey:NSStringFromSelector(@selector(responseHeadersReplacement))];
    [encoder encodeInteger:self.responseCode forKey:NSStringFromSelector(@selector(responseCode))];
}

#pragma mark - Response

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

- (instancetype)initWithResponseReplacement:(NSArray<SBTRewriteReplacement *> *)responseReplacement
                                 headersReplacement:(NSDictionary<NSString *, NSString *> *)responseHeadersReplacement
                                       responseCode:(NSInteger)responseCode
{
    return [self initWithUrlReplacement:nil
                     requestReplacement:nil
              requestHeadersReplacement:nil
                    responseReplacement:responseReplacement
             responseHeadersReplacement:responseHeadersReplacement
                           responseCode:responseCode];
}

- (instancetype)initWithResponseReplacement:(NSArray<SBTRewriteReplacement *> *)responseReplacement
                                 headersReplacement:(NSDictionary<NSString *, NSString *> *)responseHeadersReplacement
{
    return [self initWithUrlReplacement:nil
                     requestReplacement:nil
              requestHeadersReplacement:nil
                    responseReplacement:responseReplacement
             responseHeadersReplacement:responseHeadersReplacement
                           responseCode:-1];
}

- (instancetype)initWithResponseReplacement:(NSArray<SBTRewriteReplacement *> *)responseReplacement
{
    return [self initWithUrlReplacement:nil
                     requestReplacement:nil
              requestHeadersReplacement:nil
                    responseReplacement:responseReplacement
             responseHeadersReplacement:nil
                           responseCode:-1];
}

#pragma mark - Request

- (instancetype)initWithRequestReplacement:(NSArray<SBTRewriteReplacement *> *)requestReplacement
                         requestHeadersReplacement:(NSDictionary<NSString *, NSString *> *)requestHeadersReplacement
{
    return [self initWithUrlReplacement:nil
                     requestReplacement:requestReplacement
              requestHeadersReplacement:requestHeadersReplacement
                    responseReplacement:nil
             responseHeadersReplacement:nil
                           responseCode:-1];
}

- (instancetype)initWithRequestReplacement:(NSArray<SBTRewriteReplacement *> *)requestReplacement
{
    return [self initWithUrlReplacement:nil
                     requestReplacement:requestReplacement
              requestHeadersReplacement:nil
                    responseReplacement:nil
             responseHeadersReplacement:nil
                           responseCode:-1];
}

#pragma mark - URL

- (instancetype)initWithRequestUrlReplacement:(NSArray<SBTRewriteReplacement *> *)urlReplacement
{
    return [self initWithUrlReplacement:urlReplacement
                     requestReplacement:nil
              requestHeadersReplacement:nil
                    responseReplacement:nil
             responseHeadersReplacement:nil
                           responseCode:-1];
}

#pragma mark - Designated

- (instancetype)initWithUrlReplacement:(NSArray<SBTRewriteReplacement *> *)urlReplacement
                    requestReplacement:(NSArray<SBTRewriteReplacement *> *)requestReplacement
             requestHeadersReplacement:(NSDictionary<NSString *, NSString *> *)requestHeadersReplacement
                   responseReplacement:(NSArray<SBTRewriteReplacement *> *)responseReplacement
            responseHeadersReplacement:(NSDictionary<NSString *, NSString *> *)responseHeadersReplacement
                          responseCode:(NSInteger)responseCode
{
    if ((self = [super init])) {
        self.urlReplacement = urlReplacement ?: @[];
        
        self.responseReplacement = responseReplacement ?: @[];
        self.requestReplacement = requestReplacement ?: @[];
        
        self.responseHeadersReplacement = responseHeadersReplacement ?: @{};
        self.requestHeadersReplacement = requestHeadersReplacement ?: @{};
        
        self.responseCode = responseCode;
    }
    
    return self;
}

#pragma clang diagnostic pop

@end

#endif
