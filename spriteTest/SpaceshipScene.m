//
//  SpaceshipScene.m
//  spriteTest
//
//  Created by Filiph Eriksson-Falk on 01/05/15.
//  Copyright (c) 2015 Filiph Eriksson-Falk. All rights reserved.
//

#import "SpaceshipScene.h"

static NSString* ballCategoryName = @"ball";
static NSString* paddleCategoryName = @"paddle";
static NSString* blockCategoryName = @"block";
static NSString* blockNodeCategoryName = @"blockNode";
static NSString* bottomCategoryName = @"bottom";

static const uint32_t ballCategory  = 0x1 << 0;  // 00000000000000000000000000000001
static const uint32_t bottomCategory = 0x1 << 1; // 00000000000000000000000000000010
static const uint32_t blockCategory = 0x1 << 2;  // 00000000000000000000000000000100
static const uint32_t paddleCategory = 0x1 << 3; // 00000000000000000000000000001000


@interface SpaceshipScene ()

@property BOOL contentCreated;

@end



@implementation SpaceshipScene
- (void)didMoveToView:(SKView *)view
{
    if (!self.contentCreated)
    {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

- (void)createSceneContents
{
     self.physicsWorld.contactDelegate = self;
    // 1 Create a physics body that borders the screen
    SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    // 2 Set physicsBody of scene to borderBody
    self.physicsBody = borderBody;
    // 3 Set the friction of that physicsBody to 0
    self.physicsBody.friction = 0.0f;
    
    self.backgroundColor = [SKColor blackColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
    


    SKSpriteNode *player = [self newPaddle];
    player.position=CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-450);
    [self addChild:player];
    SKSpriteNode *ball = [self newBall];
    [self addChild:ball];
    [ball.physicsBody applyImpulse:CGVectorMake(6.0f, -50.0f)];
    
    // 1 Store some useful variables
    int numberOfBlocks = 4;
    int blockWidth = [SKSpriteNode spriteNodeWithImageNamed:@"tileBlack_26.png"].size.width;
    float padding = 20.0f;
    // 2 Calculate the xOffset
    float xOffset = (self.frame.size.width - (blockWidth * numberOfBlocks + padding * (numberOfBlocks-1))) / 2;
    // 3 Create the blocks and add them to the scene
    for (int i = 1; i <= numberOfBlocks; i++) {
        SKSpriteNode* block = [SKSpriteNode spriteNodeWithImageNamed:@"tileBlack_26"];
        block.size = CGSizeMake(100, 15);
        block.position = CGPointMake((i-0.5f)*block.frame.size.width + (i-1)*padding + xOffset, self.frame.size.height * 0.8f);
        block.physicsBody = [SKPhysicsBody bodyWithTexture:block.texture alphaThreshold:5.0 size:block.size];
        block.physicsBody.allowsRotation = NO;
        block.physicsBody.friction = 0.0f;
        block.name = blockCategoryName;
        block.physicsBody.contactTestBitMask=ballCategory;
        block.physicsBody.categoryBitMask = blockCategory;
        [self addChild:block];
    }
    
    SKNode *bottomRectCollider = [SKNode node];
    bottomRectCollider.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 1)];
    
    bottomRectCollider.name=bottomCategoryName;
    bottomRectCollider.physicsBody.categoryBitMask=bottomCategory;
    bottomRectCollider.physicsBody.collisionBitMask=ballCategory;
    bottomRectCollider.physicsBody.contactTestBitMask=ballCategory;
    [self addChild:bottomRectCollider];
}

-(void)didBeginContact:(SKPhysicsContact*)contact {
    // 1 Create local variables for two physics bodies
    SKPhysicsBody* firstBody;
    SKPhysicsBody* secondBody;
    // 2 Assign the two physics bodies so that the one with the lower category is always stored in firstBody
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    } else {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    // 3 react to the contact between ball and bottom
    if (firstBody.node.name == ballCategoryName && secondBody.node.name == bottomCategoryName) {
        //TODO: Replace the log statement with display of Game Over Scene
        NSLog(@"Hit bottom. First contact has been made.");
    }
    if(firstBody.node.name == ballCategoryName && secondBody.node.name == blockCategoryName){
        [secondBody.node removeFromParent];
        //Check if game is won
    }
    NSLog(@"Hit ground.");
}

-(SKSpriteNode *)newPaddle
{
    SKSpriteNode *player = [SKSpriteNode spriteNodeWithImageNamed:@"paddle_06.png"];
    player.size=CGSizeMake(300, 50);
    player.name = paddleCategoryName;
    
    player.physicsBody=[SKPhysicsBody bodyWithTexture:player.texture alphaThreshold:5.0 size:player.size];
    player.physicsBody.categoryBitMask=paddleCategory;
    
    player.physicsBody.restitution = 0.1f;
    player.physicsBody.friction = 0.4f;
    player.physicsBody.dynamic = NO;
    player.physicsBody.allowsRotation = NO;
    
    return player;
}

- (SKSpriteNode *)newBall
{
    // 1
    SKSpriteNode* ball = [SKSpriteNode spriteNodeWithImageNamed: @"ballYellow_10.png"];
    ball.name = ballCategoryName;
    ball.size = CGSizeMake(60.0f, 60.0f);
    ball.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    ball.physicsBody.categoryBitMask=ballCategory;
    ball.physicsBody.contactTestBitMask = bottomCategory | blockCategory;
    ball.physicsBody.collisionBitMask = bottomCategory;
    // 2
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.frame.size.width/2];
    // 3
    ball.physicsBody.friction = 0.0f;
    // 4
    ball.physicsBody.restitution = 1.0f;
    // 5
    ball.physicsBody.linearDamping = 0.0f;
    // 6
    ball.physicsBody.allowsRotation = NO;
    
    return ball;
}


@end