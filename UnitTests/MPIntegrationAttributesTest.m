//
//  MPIntegrationAttributesTest.m
//
//  Copyright 2016 mParticle, Inc.
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
#import "MPIntegrationAttributes.h"
#import "MPEnums.h"

@interface MPIntegrationAttributesTest : XCTestCase

@end


@implementation MPIntegrationAttributesTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInstance {
    NSNumber *kitCode = @(MPKitInstanceUrbanAirship);
    NSDictionary<NSString *, NSString *> *attributes = @{@"key":@"value"};
    MPIntegrationAttributes *integrationAttributes = [[MPIntegrationAttributes alloc] initWithKitCode:kitCode attributes:attributes];
    XCTAssertNotNil(integrationAttributes);
    XCTAssertEqualObjects(integrationAttributes.kitCode, @(MPKitInstanceUrbanAirship));
    XCTAssertEqualObjects(integrationAttributes.attributes, @{@"key":@"value"});
}

- (void)testDataInstance {
    NSNumber *kitCode = @(MPKitInstanceUrbanAirship);
    NSDictionary<NSString *, NSString *> *attributes = @{@"key":@"value"};
    MPIntegrationAttributes *integrationAttributes = [[MPIntegrationAttributes alloc] initWithKitCode:kitCode attributes:attributes];
    NSData *attributesData = [NSJSONSerialization dataWithJSONObject:integrationAttributes.attributes options:0 error:nil];
    
    MPIntegrationAttributes *integrationAttributes2 = [[MPIntegrationAttributes alloc] initWithKitCode:kitCode attributesData:attributesData];
    XCTAssertNotNil(integrationAttributes2);
    
    attributesData = nil;
    integrationAttributes2 = [[MPIntegrationAttributes alloc] initWithKitCode:kitCode attributesData:attributesData];
    XCTAssertNil(integrationAttributes2);
    
    attributesData = (NSData *)[NSNull null];
    integrationAttributes2 = [[MPIntegrationAttributes alloc] initWithKitCode:kitCode attributesData:attributesData];
    XCTAssertNil(integrationAttributes2);
}

- (void)testInvalidInstance {
    NSNumber *kitCode = @(9999);
    NSDictionary<NSString *, NSString *> *attributes = @{@"key":@"value"};
    MPIntegrationAttributes *integrationAttributes = [[MPIntegrationAttributes alloc] initWithKitCode:kitCode attributes:attributes];
    XCTAssertNil(integrationAttributes);
    
    kitCode = nil;
    integrationAttributes = [[MPIntegrationAttributes alloc] initWithKitCode:kitCode attributes:attributes];
    XCTAssertNil(integrationAttributes);
    
    kitCode = (NSNumber *)@"This is not a number";
    integrationAttributes = [[MPIntegrationAttributes alloc] initWithKitCode:kitCode attributes:attributes];
    XCTAssertNil(integrationAttributes);
    
    kitCode = @(MPKitInstanceUrbanAirship);
    attributes = nil;
    integrationAttributes = [[MPIntegrationAttributes alloc] initWithKitCode:kitCode attributes:attributes];
    XCTAssertNil(integrationAttributes);
    
    attributes = @{@"pi":@314};
    integrationAttributes = [[MPIntegrationAttributes alloc] initWithKitCode:kitCode attributes:attributes];
    XCTAssertNil(integrationAttributes);
    
    attributes = @{@628:@"tau"};
    integrationAttributes = [[MPIntegrationAttributes alloc] initWithKitCode:kitCode attributes:attributes];
    XCTAssertNil(integrationAttributes);
    
    attributes = (NSDictionary *)[NSNull null];
    integrationAttributes = [[MPIntegrationAttributes alloc] initWithKitCode:kitCode attributes:attributes];
    XCTAssertNil(integrationAttributes);
}

- (void)testDictionaryRepresentation {
    NSNumber *kitCode = @(MPKitInstanceUrbanAirship);
    NSDictionary<NSString *, NSString *> *attributes = @{@"key":@"value"};
    MPIntegrationAttributes *integrationAttributes = [[MPIntegrationAttributes alloc] initWithKitCode:kitCode attributes:attributes];
    NSDictionary *dictionaryRepresentation = [integrationAttributes dictionaryRepresentation];
    XCTAssertNotNil(dictionaryRepresentation);
    
    NSDictionary *referenceDictionary = @{[@(MPKitInstanceUrbanAirship) stringValue]:@{@"key":@"value"}};
    XCTAssertEqualObjects(dictionaryRepresentation, referenceDictionary);
}

- (void)testSerialization {
    NSNumber *kitCode = @(MPKitInstanceUrbanAirship);
    NSDictionary<NSString *, NSString *> *attributes = @{@"key":@"value"};
    MPIntegrationAttributes *integrationAttributes = [[MPIntegrationAttributes alloc] initWithKitCode:kitCode attributes:attributes];
    NSString *serializedString = [integrationAttributes serializedString];
    XCTAssertNotNil(serializedString);
}

@end
