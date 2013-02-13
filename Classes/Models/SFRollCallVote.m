//
//  SFVote.m
//  Congress
//
//  Created by Daniel Cloud on 1/31/13.
//  Copyright (c) 2013 Sunlight Foundation. All rights reserved.
//

#import "SFRollCallVote.h"

@implementation SFRollCallVote

static NSMutableArray *_collection = nil;

static NSArray *kDefaultVoteChoices = nil;

#pragma mark - MTLModel Versioning

+ (NSUInteger)modelVersion {
    return 1;
}

#pragma mark - MTLModel Transformers

+ (NSDictionary *)externalRepresentationKeyPathsByPropertyKey {
    return [super.externalRepresentationKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
            @"rollId": @"roll_id",
            @"votedAt": @"voted_at",
            @"voteType": @"vote_type",
            @"rollType": @"roll_type",
            @"billId": @"bill_id",
            @"voterDict": @"voter_ids"
    }];
}

+ (NSValueTransformer *)votedAtTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [NSDate dateFromUnlocalizedDateString:str];
    } reverseBlock:^(NSDate *date) {
        return [[NSDateFormatter ISO8601DateTimeFormatter] stringFromDate:date];
    }];
}

#pragma mark - Class methods

+(NSArray *)defaultVoteChoices
{
    if (!kDefaultVoteChoices) {
        kDefaultVoteChoices = @[@"Yea", @"Nay", @"Present", @"Not Voting"];
    }
    return kDefaultVoteChoices;
}

#pragma mark - Convenience methods

-(NSArray *)votesbyVoterId
{
    return [self.voterDict allKeys];
}

-(NSArray *)choices
{
    if (!self.totals) {
        return nil;
    }
    NSMutableArray *choiceKeys = [NSMutableArray arrayWithArray:[self.totals allKeys]];
    [choiceKeys removeObjectsInArray:[[self class] defaultVoteChoices]];
    if ([choiceKeys count] == 0) {
        return [[self class] defaultVoteChoices];
    }
    return choiceKeys;
}

-(NSArray *)voterIdsForChoice:(NSString *)choice
{
    NSSet *chosenVoters = [self.voterDict keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        if ([choice isEqualToString:obj]) {
            return YES;
        }
        return NO;
    }];
    return [[chosenVoters allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

-(NSDictionary *)totals
{
    return [self.breakdown safeObjectForKey:@"total"];
}

#pragma mark - SynchronizedObject protocol methods

+(NSString *)__remoteIdentifierKey
{
    return @"rollId";
}

+(NSMutableArray *)collection;
{
    if (_collection == nil) {
        _collection = [NSMutableArray array];
    }
    return _collection;
}

@end