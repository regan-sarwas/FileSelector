//
// Copyright 2011 ESCOZ Inc  - http://escoz.com
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License. You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
// ANY KIND, either express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//

#import <Foundation/Foundation.h>
#import "QuickDialog.h"

@interface QRootBuilder : NSObject {

}


// called by QRootElement(JsonBuilder).initWithJSON:andData:
//   obj is an NSArray or NSDictionary derived from the json.
// obj must be an NSDictionary with NSString keys (with sections, and root properties),
// or an NSObject with a sections property that returns an NSArray of section dictionarys
// or "section" objects see buildSection below
- (QRootElement *)buildWithObject:(id)obj;

//called by QBindingEvaluator.bindObject:toData:
+ (void)trySetProperty:(NSString *)propertyName onObject:(id)target withValue:(id)value localized:(BOOL)shouldLocalize;

//called by QBindingEvaluator.bindSection:toCollection: (and toProperties:)
//  obj is Qsection.elementTemplate (NSDictionary) or items in Qsection.beforeTemplateElements, Qsection.afterTemplateElements,
//      or items provided by the caller
- (QElement *)buildElementWithObject:(id)obj;

//FIXME - remove from interface, not called externally
// obj is an an NSDictionary with NSString keys (defining a elements and section properties)
// or an object with a key value of "type" that returns a string with the name of a class
// that inherits from QSection
- (void)buildSectionWithObject:(id)obj forRoot:(QRootElement *)root;

//called by QBindingEvaluator.bindRootElement:toCollection:
//  dictionary is QRootElement.sectionTemplate (NSDictionary)
- (QSection *)buildSectionWithObject:(NSDictionary *)dictionary;
@end
