//
//  GameLayer.m
//  转转贪吃蛇
//
//  Created by 邱峰 on 13-12-26.
//  Copyright 2013年 邱峰. All rights reserved.
//

#import "GameLayer.h"
#import "Snake.h"
#import "Food.h"
#import "Rocker.h"
#import "StartLayer.h"
#import <CoreMotion/CoreMotion.h>

@interface GameLayer()

@property (nonatomic,assign) CCMenuItemImage* pauseItem;
@property (nonatomic,assign) CCLayer* pauseLayer;

@end

@implementation GameLayer
{
    int score;
    CCSprite* food;
    Snake* snake;
    Model* model;
    CGSize winSize;
}

static BOOL isEnter=NO;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


-(instancetype) init
{
    if (self=[super init])
    {
        winSize=[[CCDirector sharedDirector] winSize];
        [self addBg];
        [self addPause];
        [self addModel];
        
//        snake=[Snake node];
//        snake.position=CGPointMake(winSize.width/2, winSize.height/2);
//        [self addChild:snake];
//        [self addFood];
        [self restart];
    }
    return self;
}

-(void)restart
{
    score=0;
    
    [food removeFromParent];
    [snake removeFromParent];
    
    snake=[Snake node];
    snake.position=CGPointMake(winSize.width/2, winSize.height/2);
    [self addChild:snake];
    [self addFood];
    
    if ([CCDirector sharedDirector].isPaused)
    {
        [self resumeGame:nil];
    }
}

-(void)addPause
{
    self.pauseItem=[CCMenuItemImage itemWithNormalImage:@"pauseButton.png" selectedImage:@"pauseButton.png" target:self selector:@selector(pauseGame:)];
    self.pauseItem.anchorPoint=CGPointZero;
    self.pauseItem.position=CGPointZero;
    CCMenu* menu= [CCMenu menuWithItems:self.pauseItem, nil];
    menu.position=CGPointZero;
    [self addChild:menu];
}

-(void)addBg
{
    CCSprite* sprite=[CCSprite spriteWithFile:@"gameLayerBg.png"];
    sprite.position=CGPointMake(winSize.width/2, winSize.height/2);
    [self addChild:sprite];
}

-(void)addModel
{
    model=[Model instanceTypeWithGameModel:[Model getGameModel]];
    
        model.position=CGPointMake(winSize.width-model.contentSize.width, 100);
        [self addChild:model];
}

-(void)addFood
{
    food=[[Food sharedFood] createFood];
    int x;
    int y;
    while (1)
    {
        x=arc4random()% (int)(winSize.width-2*minDis()) +minDis();
        y=arc4random()% (int)(winSize.height-2*minDis()) +minDis();
        if (![snake isCollisionOnPosition:CGPointMake(x, y)]) break;
    }
    [food setPosition:CGPointMake(x, y)];
    [self addChild:food];
}

-(void)eatFood
{
    [food removeFromParentAndCleanup:YES];
    [snake addBody];
    [self addFood];
}

-(BOOL)isEatFood
{
    CGPoint snakePosition=[snake getHeadPosition];
    CGPoint foodPosition=food.position;
    return isCollision(snakePosition, foodPosition);
}

-(BOOL) isCollision
{
    CGPoint snakePosition=[snake getHeadPosition];
    if (snakePosition.x<=minDis()/2) return YES;
    if (snakePosition.x>=winSize.width-minDis()/2) return YES;
    if (snakePosition.y<=minDis()/2) return YES;
    if (snakePosition.y>=winSize.height-minDis()/2) return YES;
    return [snake isEatSelf];
}

-(void)update:(ccTime)delta
{
    if ([self isCollision])
    {
        [self endGame];
        return ;
    }
    if ([self isEatFood])
    {
        [self eatFood];
    }
    [snake move:model.getDirctionVector];
}


#pragma mark - pause

-(CCLayer*) pauseLayer
{
    if (_pauseLayer==nil)
    {
        _pauseLayer=[CCLayer node];
        CCSprite* bg=[CCSprite spriteWithFile:@"pauseBackground.png"];
        bg.position=CGPointMake(winSize.width/2, winSize.height/2);
        
        CCMenuItemImage* returnHome=[CCMenuItemImage itemWithNormalImage:@"pauseBackHome.png" selectedImage:@"pauseBackHome.png" target:self selector:@selector(returnHome:)];
        returnHome.position=CGPointMake(50, 0);
        
        CCMenuItemImage* pauseNewGame=[CCMenuItemImage itemWithNormalImage:@"pauseNewGame.png" selectedImage:@"pauseNewGame.png" target:self selector:@selector(resumeNewGame:)];
        pauseNewGame.position=CGPointMake(250, 200);
        
        CCMenuItemImage* resumeGame=[CCMenuItemImage itemWithNormalImage:@"pauseContinue.png" selectedImage:@"pauseContinue.png" target:self selector:@selector(resumeGame:)];
        resumeGame.position=CGPointMake(500, 200);
        
        CCMenu* menu=[CCMenu menuWithItems:returnHome, pauseNewGame,resumeGame, nil];
        menu.position=CGPointZero;
        [_pauseLayer addChild:bg];
        [_pauseLayer addChild:menu];
    }
    return _pauseLayer;
}

-(void) returnHome:(id)sender
{
    CCScene* scene=[StartLayer node];
    [self unscheduleUpdate];
    [[CCDirector sharedDirector] resume];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.4 scene:scene]];
}

-(void) resumeNewGame:(id)sender
{
    [self restart];
}

-(void) resumeGame:(id)sender
{
    [self.pauseLayer removeFromParentAndCleanup:YES];
    self.pauseLayer=nil;
    [[CCDirector sharedDirector] resume];
}

-(void) pauseGame:(id)sender
{
    [[CCDirector sharedDirector] pause];
    [self addChild:self.pauseLayer];
}

-(void) endGame
{
    [self unscheduleUpdate];
    [self addChild:[self endGameLayer]];
}

-(CCLayer*)endGameLayer
{
    CCLayer* endGameLayer=[CCLayer node];
    
    CCSprite* bg=[CCSprite spriteWithFile:@"endBackground.png"];
     bg.position=CGPointMake(endGameLayer.contentSize.width/2, endGameLayer.contentSize.height/2);
    [endGameLayer addChild:bg];
    
    return endGameLayer;
}

+(BOOL) isEnter
{
    return isEnter;
}

-(void) onEnter
{
    [super onEnter];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"EnterBackgroundObserver" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseGame:) name:@"EnterBackgroundObserver" object:nil];
    isEnter=YES;
    [self scheduleUpdate];
}

-(void) onExit
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"EnterBackgroundObserver" object:nil];
    isEnter=NO;
    [super onExit];
}

@end
