//
//  MPURLRequestBuilderTests.m
//
//  Copyright 2015 mParticle, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <XCTest/XCTest.h>
#import "MPURLRequestBuilder.h"
#import "MPURLRequestBuilder+Tests.h"
#import "MPStateMachine.h"
#import "MPConstants.h"
#import "MPConsumerInfo.h"
#import "MPNetworkCommunication.h"
#import "MPNetworkCommunication+Tests.h"

@interface MPURLRequestBuilderTests : XCTestCase

@end

@implementation MPURLRequestBuilderTests

- (void)setUp {
    [super setUp];
    
    MPStateMachine *stateMachine = [MPStateMachine sharedInstance];
    stateMachine.apiKey = @"unit_test_app_key";
    stateMachine.secret = @"unit_test_secret";
}

- (void)tearDown {
    [super tearDown];
}

- (void)testHMACSha256Encode {
    MPURLRequestBuilder *urlRequestBuilder = [MPURLRequestBuilder newBuilderWithURL:[NSURL URLWithString:@"http://mparticle.com"]];
    MPStateMachine *stateMachine = [MPStateMachine sharedInstance];
    
    NSString *message = @"The Quick Brown Fox Jumped Over The Lazy Dog.";
    NSString *referenceEncodedMessage = @"6c51252301b0052f3309b5ae8fe43ed5f73364b3590d7b8658d300a3b723cc0c";
    NSString *encodedMessage = [urlRequestBuilder hmacSha256Encode:message key:stateMachine.apiKey];
    
    XCTAssertEqualObjects(encodedMessage, referenceEncodedMessage, @"HMAC Sha 256 is failing to encode correctly.");
}

- (void)testInvalidHMACSha256Encode {
    MPURLRequestBuilder *urlRequestBuilder = [MPURLRequestBuilder newBuilderWithURL:[NSURL URLWithString:@"http://mparticle.com"]];
    MPStateMachine *stateMachine = [MPStateMachine sharedInstance];
    
    NSString *message = nil;
    NSString *encodedMessage = [urlRequestBuilder hmacSha256Encode:message key:stateMachine.apiKey];
    XCTAssertNil(encodedMessage, @"Should not have tried to encode a nil message.");
    
    message = @"";
    encodedMessage = [urlRequestBuilder hmacSha256Encode:message key:stateMachine.apiKey];
    XCTAssertNotNil(encodedMessage, @"Encoded message should not have been nil.");
    
    message = @"The Quick Brown Fox Jumped Over The Lazy Dog.";
    encodedMessage = [urlRequestBuilder hmacSha256Encode:message key:nil];
    XCTAssertNil(encodedMessage, @"Should not have tried to encode with a nil key.");
}

- (void)testURLRequestComposition {
    MPNetworkCommunication *networkCommunication = [[MPNetworkCommunication alloc] init];
    MPURLRequestBuilder *urlRequestBuilder = [MPURLRequestBuilder newBuilderWithURL:[networkCommunication configURL] message:nil httpMethod:@"GET"];
    NSMutableURLRequest *asyncURLRequest = [urlRequestBuilder build];
    
    NSDictionary *headersDictionary = [asyncURLRequest allHTTPHeaderFields];
    NSArray *keys = [headersDictionary allKeys];
    NSArray *headers = @[@"User-Agent", @"Accept-Encoding", @"Content-Encoding", @"locale", @"Content-Type", @"timezone", @"secondsFromGMT", @"x-mp-kits", @"Date", @"x-mp-signature", @"x-mp-env"];
    NSString *headerValue;
    
    for (NSString *header in headers) {
        XCTAssertTrue([keys containsObject:header], @"HTTP header %@ is missing", header);
        
        headerValue = headersDictionary[header];
        
        if ([header isEqualToString:@"Accept-Encoding"] || [header isEqualToString:@"Content-Encoding"]) {
            XCTAssertTrue([headerValue isEqualToString:@"gzip"], @"%@ has an invalid value: %@", header, headerValue);
        } else if ([header isEqualToString:@"Content-Type"]) {
            BOOL validContentType = [headerValue isEqualToString:@"application/json"] ||
            [headerValue isEqualToString:@"application/x-www-form-urlencoded"];
            
            XCTAssertTrue(validContentType, @"%@ http header is invalid: %@", header, headerValue);
        } else if ([header isEqualToString:@"secondsFromGMT"] || [header isEqualToString:@"x-mp-signature"]) {
            XCTAssert([headerValue length] > 0, @"%@ has invalid length", header);
//        } else if ([header isEqualToString:@"x-mp-kits"]) {
//            NSString *supportedEmbeddedKits = [[MPEmbeddedKit supportedEmbeddedKits] componentsJoinedByString:@","];
//            XCTAssertEqualObjects(headerValue, supportedEmbeddedKits, @"Supported embedded kits is not being set.");
        } else if ([header isEqualToString:@"x-mp-env"]) {
            BOOL validEnvironment = [headerValue isEqualToString:[@(MPEnvironmentDevelopment) stringValue]] ||
            [headerValue isEqualToString:[@(MPEnvironmentProduction) stringValue]];
            
            XCTAssertTrue(validEnvironment, @"Invalid environment value: %@", headerValue);
        }
    }
}

- (void)testComposingWithHeaderData {
    NSString *urlString = @"http://mparticle.com";
    MPURLRequestBuilder *urlRequestBuilder = [MPURLRequestBuilder newBuilderWithURL:[NSURL URLWithString:urlString]];
    
    NSString *userAgent = [NSString stringWithFormat:@"UnitTests/1.0 (iPhone; CPU iPhone OS like Mac OS X) (KHTML, like Gecko) mParticle/%@", kMParticleSDKVersion];
    
    NSDictionary *headersDictionary = @{@"User-Agent":userAgent,
                                        @"Accept-Encoding":@"gzip",
                                        @"Content-Encoding":@"gzip"};
    
    NSError *error = nil;
    NSData *headerData = [NSJSONSerialization dataWithJSONObject:headersDictionary options:0 error:&error];
    
    XCTAssertNil(error, @"Error serializing http header.");
    
    [urlRequestBuilder withHeaderData:headerData];
    
    NSMutableURLRequest *asyncURLRequest = [urlRequestBuilder build];
    
    headersDictionary = [asyncURLRequest allHTTPHeaderFields];
    NSArray *keys = [headersDictionary allKeys];
    NSArray *headers = @[@"User-Agent", @"Accept-Encoding", @"Content-Encoding"];
    NSString *headerValue;
    
    for (NSString *header in headers) {
        XCTAssertTrue([keys containsObject:header], @"HTTP header %@ is missing", header);
        
        headerValue = headersDictionary[header];
        
        if ([header isEqualToString:@"User-Agent"]) {
            XCTAssertEqualObjects(headerValue, userAgent, @"User-Agent is not being set correctly.");
        } else if ([header isEqualToString:@"Accept-Encoding"] || [header isEqualToString:@"Content-Encoding"]) {
            XCTAssertTrue([headerValue isEqualToString:@"gzip"], @"%@ has an invalid value: %@", header, headerValue);
        }
    }
}

- (void)testPOSTURLRequest {
    NSString *urlString = @"http://mparticle.com";
    MPURLRequestBuilder *urlRequestBuilder = [MPURLRequestBuilder newBuilderWithURL:[NSURL URLWithString:urlString]];
    
    [urlRequestBuilder withHttpMethod:@"POST"];
    
    NSDictionary *postDictionary = @{@"key1":@"value1",
                                     @"arrayKey":@[@"item1", @"item2"],
                                     @"key2":@2,
                                     @"key3":@{@"nestedKey":@"nestedValue"}
                                     };
    
    NSError *error = nil;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary options:0 error:&error];
    
    XCTAssertNil(error, @"Error serializing POST data.");
    
    [urlRequestBuilder withPostData:postData];
    
    NSMutableURLRequest *asyncURLRequest = [urlRequestBuilder build];
    
    XCTAssertEqualObjects([asyncURLRequest HTTPMethod], @"POST", @"HTTP method is not being set to POST.");
    
    XCTAssertEqualObjects(postData, [asyncURLRequest HTTPBody], @"HTTP body is not being set as the post data.");
}

- (void)testInvalidURLs {
    MPURLRequestBuilder *urlRequestBuilder = [MPURLRequestBuilder newBuilderWithURL:nil];
    
    XCTAssertNil(urlRequestBuilder, @"Retuning a request builder from an invalid URL.");
    
    urlRequestBuilder = [MPURLRequestBuilder newBuilderWithURL:nil message:nil httpMethod:@"GET"];
    
    XCTAssertNil(urlRequestBuilder, @"Retuning a request builder from an invalid URL.");
    
    NSString *urlString = @"http://mparticle.com";
    urlRequestBuilder = [MPURLRequestBuilder newBuilderWithURL:[NSURL URLWithString:urlString] message:nil httpMethod:nil];
    
    XCTAssertEqualObjects(urlRequestBuilder.httpMethod, @"GET", @"HTTP method is assuming GET as default.");
}

@end
