//
//  main.m
//  jsonlint
//
//  Created by Tom Harrington on 2/4/10.
//  Copyright 2010 Atomic Bird, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <getopt.h>
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"

BOOL quiet = NO;
BOOL formatted = NO;
BOOL plist = NO;

/* options descriptor */
static struct option longopts[] = {
	{ "quiet",			no_argument,	(int *)&quiet,		'q' },
	{ "formatted",		no_argument,	(int *)&formatted,	'f' },
	{ "plist",			no_argument,	(int *)&plist,		'p' },
	{ "force-array",	no_argument,	NULL,				'a' },
	{ "force-dict",		no_argument,	NULL,				'd' },
	{ NULL,				0,				NULL,				0 }
};


typedef enum inputType {
	inputTypeArray,
	inputTypeDict,
	inputTypeAuto
} inputType_t;

inputType_t inputType = inputTypeAuto;

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	int ch;
	
	while ((ch = getopt_long(argc, (char * const *)argv, "qfpad", longopts, NULL)) != -1)
		switch (ch) {
			case 'a':
			{
				inputType = inputTypeArray;
				break;
			}
			case 'd':
			{
				inputType = inputTypeDict;
				break;
			}
		}
	
	NSFileHandle *standardInput = [NSFileHandle fileHandleWithStandardInput];
	NSData *inputData = [standardInput readDataToEndOfFile];
	
	NSError *deserializeError = nil;
	id json;
	switch (inputType) {
		case inputTypeArray:
		{
			json = [[CJSONDeserializer deserializer] deserializeAsArray:inputData error:&deserializeError];
			break;
		}
		case inputTypeDict:
		{
			json = [[CJSONDeserializer deserializer] deserializeAsDictionary:inputData error:&deserializeError];
			break;
		}
		default:
		{
			json = [[CJSONDeserializer deserializer] deserialize:inputData error:&deserializeError];
		}
	}
	
	if (json != nil) {
		if (!quiet) {
			if (plist) {
				printf("%s\n", [[json description] UTF8String]);
			} else {
				NSError *serializeError = nil;
				CJSONSerializer *serializer = [CJSONSerializer serializer];
				serializer.format = formatted;
				NSData *jsonData = [serializer serializeObject:json error:&serializeError];
				[jsonData writeToFile:@"/tmp/junk.json" atomically:YES];
				//		printf("%s\n", [[json description] UTF8String]);
				NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
				printf("%s\n", [jsonString UTF8String]);
				[jsonString release];
			}
		}
	}
	
	if (deserializeError != nil) {
		fprintf(stderr, "%s\n", [[deserializeError localizedDescription] UTF8String]);
	}
	
	[pool drain];
    return (deserializeError != nil);
}
