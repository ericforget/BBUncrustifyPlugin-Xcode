//
//  NSDocument+XCFAdditions.m
//  Created by Dominik Pich on 1/17/14.
//

#import "NSDocument+XCFAdditions.h"
#import "XCFDefaults.h"
#import "XCFXcodePrivate.h"
#import "XCFXcodeFormatter.h"
#import "JRSwizzle.h"
#import "BBMacros.h"

@implementation NSDocument (XCFAdditions)

#pragma mark - Setup and Teardown

+ (void)load {
    NSError *error = nil;
    if (![self jr_swizzleMethod:@selector(saveDocumentWithDelegate:didSaveSelector:contextInfo:) withMethod:@selector(xcf_saveDocumentWithDelegate:didSaveSelector:contextInfo:) error:&error]) {
        BBLogReleaseWithLocation(@"%@", error);
    }
    
}

#pragma mark - Additions

- (void)xcf_documentWillSave {
    
    BOOL shouldFormatBeforeSaving = [XCFXcodeFormatter canFormatDocument:self] && [[NSUserDefaults standardUserDefaults] boolForKey:XCFDefaultsKeyFormatOnSaveEnabled];
    
	if (shouldFormatBeforeSaving) {
		NSError *error;
		[XCFXcodeFormatter formatDocument:self withError:&error];
        //NSLog(@"%@: %@", self.presentedItemURL, error ? error : @"OK");
        if (error) {
            BBLogReleaseWithLocation(@"%@", error);
        }
	}
}


#pragma mark - Swizzled methods

- (void)xcf_saveDocumentWithDelegate:(id)delegate didSaveSelector:(SEL)didSaveSelector contextInfo:(void *)contextInfo {
	[self xcf_documentWillSave];

	[self xcf_saveDocumentWithDelegate:delegate didSaveSelector:didSaveSelector contextInfo:contextInfo];
}

@end
