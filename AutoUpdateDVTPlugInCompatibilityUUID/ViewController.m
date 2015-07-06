//
//  ViewController.m
//  AutoUpdateDVTPlugInCompatibilityUUID
//
//  Created by 王晨 on 15/7/6.
//  Copyright (c) 2015年 zhfish. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak) IBOutlet NSTextField *statusField;
@property (unsafe_unretained) IBOutlet NSTextView *logView;

@end

@implementation ViewController {
    NSMutableArray *_plugins;
    NSString *_uuid;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _plugins = @[].mutableCopy;
    
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:@"/Applications/Xcode.app/Contents/Info.plist"];
    _uuid = dic[@"DVTPlugInCompatibilityUUID"];
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}
- (IBAction)click_find:(NSButton *)sender {
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString *userLibraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *pluginPath = [userLibraryPath stringByAppendingString:@"/Application Support/Developer/Shared/Xcode/Plug-ins"];
    
    NSArray * pluginsList = [filemanager contentsOfDirectoryAtPath:pluginPath error:nil];
    
    [pluginsList enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        if (![obj hasSuffix:@".xcplugin"]) {
            return ;
        }
        
        NSString *filepath = [pluginPath stringByAppendingFormat:@"/%@/Contents/Info.plist",obj];
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filepath];
        NSArray *uuids = dic[@"DVTPlugInCompatibilityUUIDs"];
        if ([uuids containsObject:_uuid]) {
            [self.logView.textStorage replaceCharactersInRange:NSMakeRange(self.logView.textStorage.length, 0) withString:[NSString stringWithFormat:@"%@, already support newest Xcode\n",obj]];
        }
        else {
            [_plugins addObject:filepath];
            [self.logView.textStorage replaceCharactersInRange:NSMakeRange(self.logView.textStorage.length, 0) withString:[NSString stringWithFormat:@"%@, support newest Xcode\n",obj]];
        }
    }];
    
}
- (IBAction)click_update:(NSButton *)sender {
    [_plugins enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:obj];
        [dict[@"DVTPlugInCompatibilityUUIDs"] addObject:_uuid];
        [dict writeToFile:obj atomically:NO];
        [self.logView.textStorage replaceCharactersInRange:NSMakeRange(self.logView.textStorage.length, 0) withString:[NSString stringWithFormat:@"%@, fixed\n",obj]];
    }];
}

@end
