// XCTestCase+Extension.m
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

#import "XCTestCase+Extension.h"
#import "SBTSwizzleHelpers.h"

@implementation XCTestCase (Extension)

static char kAppAssociatedKey;

- (void)setApp:(SBTUITunneledApplication*)app
{
    return objc_setAssociatedObject(self, &kAppAssociatedKey, app, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SBTUITunneledApplication *)app
{
    return objc_getAssociatedObject(self, &kAppAssociatedKey);
}

- (void)swz_tearDown
{
    [self.app quit];
    [self swz_tearDown];
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SBTTestTunnelInstanceSwizzle(self, @selector(tearDown), @selector(swz_tearDown));
    });
}


@end

#endif
