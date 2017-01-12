//
//  VROSample.m
//  ViroRenderer
//
//  Created by Raj Advani on 10/13/15.
//  Copyright © 2015 Raj Advani. All rights reserved.
//

#import "VROSample.h"

typedef NS_ENUM(NSInteger, VROSampleScene) {
    VROSampleSceneBox = 0,
    VROSampleSceneTorus,
    VROSampleSceneOBJ,
    VROSampleSceneText,
    VROSampleSceneVideoSphere,
    VROSampleSceneNumScenes
};

@interface VROSample ()

@property (readwrite, nonatomic) VRODriver *driver;
@property (readwrite, nonatomic) BOOL tapEnabled;
@property (readwrite, nonatomic) float torusAngle;
@property (readwrite, nonatomic) float boxAngle;
@property (readwrite, nonatomic) float boxVideoAngle;
@property (readwrite, nonatomic) float objAngle;
@property (readwrite, nonatomic) int sceneIndex;
@property (readwrite, nonatomic) std::shared_ptr<VROVideoTexture> videoTexture;

@end

@implementation VROSample

- (std::shared_ptr<VROTexture>) niagaraTexture {
    std::vector<std::shared_ptr<VROImage>> cubeImages =  {
        std::make_shared<VROImageiOS>([UIImage imageNamed:@"px"]),
        std::make_shared<VROImageiOS>([UIImage imageNamed:@"nx"]),
        std::make_shared<VROImageiOS>([UIImage imageNamed:@"py"]),
        std::make_shared<VROImageiOS>([UIImage imageNamed:@"ny"]),
        std::make_shared<VROImageiOS>([UIImage imageNamed:@"pz"]),
        std::make_shared<VROImageiOS>([UIImage imageNamed:@"nz"])
    };
    
    return std::make_shared<VROTexture>(cubeImages);
}

- (std::shared_ptr<VROTexture>) cloudTexture {
    std::vector<std::shared_ptr<VROImage>> cubeImages =  {
        std::make_shared<VROImageiOS>([UIImage imageNamed:@"px1.jpg"]),
        std::make_shared<VROImageiOS>([UIImage imageNamed:@"nx1.jpg"]),
        std::make_shared<VROImageiOS>([UIImage imageNamed:@"py1.jpg"]),
        std::make_shared<VROImageiOS>([UIImage imageNamed:@"ny1.jpg"]),
        std::make_shared<VROImageiOS>([UIImage imageNamed:@"pz1.jpg"]),
        std::make_shared<VROImageiOS>([UIImage imageNamed:@"nz1.jpg"])
    };
    
    return std::make_shared<VROTexture>(cubeImages);
}

- (std::shared_ptr<VROTexture>) westlakeTexture {
    return std::make_shared<VROTexture>(std::make_shared<VROImageiOS>([UIImage imageNamed:@"360_westlake.jpg"]));
}

- (std::shared_ptr<VROSceneController>)loadVideoSphereScene {
    std::shared_ptr<VROSceneController> sceneController = std::make_shared<VROSceneController>();
    std::shared_ptr<VROScene> scene = sceneController->getScene();
    
    std::shared_ptr<VROLight> light = std::make_shared<VROLight>(VROLightType::Spot);
    light->setColor({ 1.0, 0.9, 0.9 });
    light->setPosition( { 0, 0, 0 });
    light->setDirection( { 0, 0, -1.0 });
    light->setAttenuationStartDistance(5);
    light->setAttenuationEndDistance(10);
    light->setSpotInnerAngle(0);
    light->setSpotOuterAngle(20);
    
    std::shared_ptr<VRONode> rootNode = std::make_shared<VRONode>();
    rootNode->setPosition({0, 0, 0});
    rootNode->addLight(light);
    
    scene->addNode(rootNode);
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"surfing" ofType:@"mp4"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    std::string url = std::string([[fileURL description] UTF8String]);
    
    self.videoTexture = std::make_shared<VROVideoTextureiOS>();
    self.videoTexture->loadVideo(url, [self.view frameSynchronizer], *self.driver);
    self.videoTexture->play();
    
    scene->setBackgroundSphere(self.videoTexture);
    self.view.reticle->setEnabled(true);
    
    return sceneController;
}

- (std::shared_ptr<VRONode>) newTorusWithPosition:(VROVector3f)position {
    std::shared_ptr<VROTorusKnot> torus = VROTorusKnot::createTorusKnot(3, 8, 0.2, 256, 32);
    std::shared_ptr<VROMaterial> material = torus->getMaterials()[0];
    material->setLightingModel(VROLightingModel::Blinn);
    material->getReflective().setTexture([self cloudTexture]);

    
    std::shared_ptr<VRONode> torusNode = std::make_shared<VRONode>();
    torusNode->setGeometry(torus);
    torusNode->setPosition(position);
    torusNode->setPivot({1, 0.5, 0.5});
    
    return torusNode;
}

- (std::shared_ptr<VROSceneController>)loadTorusScene {
    std::shared_ptr<VROSceneController> sceneController = std::make_shared<VROSceneController>();
    std::shared_ptr<VROScene> scene = sceneController->getScene();
    scene->setBackgroundCube([self cloudTexture]);
    
    std::shared_ptr<VROLight> light = std::make_shared<VROLight>(VROLightType::Spot);
    light->setColor({ 1.0, 0.3, 0.3 });
    light->setPosition( { 0, 0, 0 });
    light->setDirection( { 0, 0, -1.0 });
    light->setAttenuationStartDistance(5);
    light->setAttenuationEndDistance(10);
    light->setSpotInnerAngle(0);
    light->setSpotOuterAngle(20);
    
    std::shared_ptr<VRONode> rootNode = std::make_shared<VRONode>();
    rootNode->setPosition({0, 0, 0});
    rootNode->addLight(light);
    
    scene->addNode(rootNode);
    
    float d = 5;
    
    rootNode->addChildNode([self newTorusWithPosition:{ 0,  0, -d}]);
    rootNode->addChildNode([self newTorusWithPosition:{ d,  0, -d}]);
    rootNode->addChildNode([self newTorusWithPosition:{ 0,  d, -d}]);
    rootNode->addChildNode([self newTorusWithPosition:{ d,  d, -d}]);
    rootNode->addChildNode([self newTorusWithPosition:{ d, -d, -d}]);
    rootNode->addChildNode([self newTorusWithPosition:{-d,  0, -d}]);
    rootNode->addChildNode([self newTorusWithPosition:{ 0, -d, -d}]);
    rootNode->addChildNode([self newTorusWithPosition:{-d,  d, -d}]);
    rootNode->addChildNode([self newTorusWithPosition:{-d, -d, -d}]);
    
    rootNode->addChildNode([self newTorusWithPosition:{ 0,  0, d}]);
    rootNode->addChildNode([self newTorusWithPosition:{ d,  0, d}]);
    rootNode->addChildNode([self newTorusWithPosition:{ 0,  d, d}]);
    rootNode->addChildNode([self newTorusWithPosition:{ d,  d, d}]);
    rootNode->addChildNode([self newTorusWithPosition:{ d, -d, d}]);
    rootNode->addChildNode([self newTorusWithPosition:{-d,  0, d}]);
    rootNode->addChildNode([self newTorusWithPosition:{ 0, -d, d}]);
    rootNode->addChildNode([self newTorusWithPosition:{-d,  d, d}]);
    rootNode->addChildNode([self newTorusWithPosition:{-d, -d, d}]);
    
    self.view.reticle->setEnabled(true);
    
    std::shared_ptr<VROAction> action = VROAction::perpetualPerFrameAction([self] (VRONode *const node, float seconds) {
        self.torusAngle += .015;
        for (std::shared_ptr<VRONode> &torusNode : node->getSubnodes()) {
            torusNode->setRotation({ 0, self.torusAngle, 0});
        }
        
        return true;
    });
    
    rootNode->runAction(action);
    self.tapEnabled = true;
    return sceneController;
}

- (void)hoverOn:(std::shared_ptr<VRONode>)node {
    std::shared_ptr<VROMaterial> material = node->getGeometry()->getMaterials().front();
    
    VROTransaction::begin();
    VROTransaction::setAnimationDuration(0.2);
    material->getDiffuse().setColor( {1.0, 1.0, 1.0, 1.0 } );
    material->getReflective().setTexture([self cloudTexture]);
    VROTransaction::commit();
}

- (void)hoverOff:(std::shared_ptr<VRONode>)node {
    std::shared_ptr<VROMaterial> material = node->getGeometry()->getMaterials().front();
    
    VROTransaction::begin();
    VROTransaction::setAnimationDuration(0.2);
    material->getDiffuse().setColor( {1.0, 1.0, 1.0, 1.0 } );
    material->getReflective().clear();
    VROTransaction::commit();
}

- (std::shared_ptr<VROSceneController>)loadBoxScene {
    std::shared_ptr<VROSceneController> sceneController = std::make_shared<VROSceneController>();
    std::shared_ptr<VROScene> scene = sceneController->getScene();
    scene->setBackgroundSphere([self westlakeTexture]);
    
    std::shared_ptr<VRONode> rootNode = std::make_shared<VRONode>();
    rootNode->setPosition({0, 0, 0});
    
    std::shared_ptr<VROLight> ambient = std::make_shared<VROLight>(VROLightType::Ambient);
    ambient->setColor({ 0.4, 0.4, 0.4 });
    
    std::shared_ptr<VROLight> spotRed = std::make_shared<VROLight>(VROLightType::Spot);
    spotRed->setColor({ 1.0, 0.0, 0.0 });
    spotRed->setPosition( { -5, 0, 0 });
    spotRed->setDirection( { 1.0, 0, -1.0 });
    spotRed->setAttenuationStartDistance(20);
    spotRed->setAttenuationEndDistance(30);
    spotRed->setSpotInnerAngle(2.5);
    spotRed->setSpotOuterAngle(5.0);
    
    std::shared_ptr<VROLight> spotBlue = std::make_shared<VROLight>(VROLightType::Spot);
    spotBlue->setColor({ 0.0, 0.0, 1.0 });
    spotBlue->setPosition( { 5, 0, 0 });
    spotBlue->setDirection( { -1.0, 0, -1.0 });
    spotBlue->setAttenuationStartDistance(20);
    spotBlue->setAttenuationEndDistance(30);
    spotBlue->setSpotInnerAngle(2.5);
    spotBlue->setSpotOuterAngle(5.0);
    
    rootNode->addLight(ambient);
    rootNode->addLight(spotRed);
    rootNode->addLight(spotBlue);

    scene->addNode(rootNode);
    
    /*
     Create the box node.
     */
    std::shared_ptr<VROBox> box = VROBox::createBox(2, 4, 2);
    box->setName("Box 1");
    
    std::shared_ptr<VROMaterial> material = box->getMaterials()[0];
    material->setLightingModel(VROLightingModel::Blinn);
    material->getDiffuse().setTexture(std::make_shared<VROTexture>(std::make_shared<VROImageiOS>([UIImage imageNamed:@"boba"])));
    material->getDiffuse().setColor({0.6, 0.3, 0.3, 1.0});
    material->getSpecular().setTexture(std::make_shared<VROTexture>(std::make_shared<VROImageiOS>([UIImage imageNamed:@"specular"])));
    
    std::vector<std::string> modifierCode =  { "uniform float testA;",
                                               "uniform float testB;",
                                               "_geometry.position.x = _geometry.position.x + testA;"
                                             };
    std::shared_ptr<VROShaderModifier> modifier = std::make_shared<VROShaderModifier>(VROShaderEntryPoint::Geometry,
                                                                                      modifierCode);
    
    modifier->setUniformBinder("testA", [](VROUniform *uniform, GLuint location) {
        uniform->setFloat(1.0);
    });
    material->addShaderModifier(modifier);
    
    std::shared_ptr<VRONode> boxNode = std::make_shared<VRONode>();
    boxNode->setGeometry(box);
    boxNode->setPosition({0, 0, -5});

    rootNode->addChildNode(boxNode);
    boxNode->addConstraint(std::make_shared<VROBillboardConstraint>(VROBillboardAxis::All));
    
    /*
     Create a second box node behind the first.
     */
    std::shared_ptr<VROBox> box2 = VROBox::createBox(2, 4, 2);
    box2->setName("Box 2");
    
    std::shared_ptr<VROMaterial> material2 = box2->getMaterials()[0];
    material2->setLightingModel(VROLightingModel::Phong);
    material2->getDiffuse().setTexture(std::make_shared<VROTexture>(std::make_shared<VROImageiOS>([UIImage imageNamed:@"boba"])));
    material2->getSpecular().setTexture(std::make_shared<VROTexture>(std::make_shared<VROImageiOS>([UIImage imageNamed:@"specular"])));
    
    std::shared_ptr<VRONode> boxNode2 = std::make_shared<VRONode>();
    boxNode2->setGeometry(box2);
    boxNode2->setPosition({0, 0, -9});
    
    rootNode->addChildNode(boxNode2);
    
    /*
     Create a third box node behind the second.
     */
    std::shared_ptr<VROBox> box3 = VROBox::createBox(2, 4, 2);
    box3->setName("Box 3");
    
    std::shared_ptr<VROMaterial> material3 = box3->getMaterials()[0];
    material3->setLightingModel(VROLightingModel::Blinn);
    material3->getDiffuse().setTexture(std::make_shared<VROTexture>(std::make_shared<VROImageiOS>([UIImage imageNamed:@"boba"])));
    material3->getSpecular().setTexture(std::make_shared<VROTexture>(std::make_shared<VROImageiOS>([UIImage imageNamed:@"specular"])));
    
    std::shared_ptr<VRONode> boxNode3 = std::make_shared<VRONode>();
    boxNode3->setGeometry(box3);
    boxNode3->setPosition({0, 0, -13});
    
    rootNode->addChildNode(boxNode3);
    
    std::shared_ptr<VRONodeCamera> camera = std::make_shared<VRONodeCamera>();
    camera->setRotationType(VROCameraRotationType::Orbit);
    camera->setOrbitFocalPoint(boxNode->getPosition());
    camera->setPosition({0, -5, 0});
    
    std::shared_ptr<VRONode> cameraNode = std::make_shared<VRONode>();
    cameraNode->setCamera(camera);
    rootNode->addChildNode(cameraNode);
    
    [self.view setPointOfView:cameraNode];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        VROTransaction::begin();
        VROTransaction::setAnimationDuration(6);
        
        spotRed->setPosition({5, 0, 0});
        spotRed->setDirection({-1, 0, -1});
        
        spotBlue->setPosition({-5, 0, 0});
        spotBlue->setDirection({1, 0, -1});
        
        cameraNode->setPosition({0, 5, 0});
        
        VROTransaction::commit();
    });

    return sceneController;
}

- (std::shared_ptr<VROSceneController>)loadTextScene {
    std::shared_ptr<VROSceneController> sceneController = std::make_shared<VROSceneController>();
    std::shared_ptr<VROScene> scene = sceneController->getScene();
    scene->setBackgroundCube([self cloudTexture]);
    
    std::shared_ptr<VRONode> rootNode = std::make_shared<VRONode>();
    rootNode->setPosition({0, 0, 0});
    
    scene->addNode(rootNode);
    
    /*
     Create background for text.
     */
    int width = 10;
    int height = 10;
    
    std::shared_ptr<VROSurface> surface = VROSurface::createSurface(width, height);
    surface->getMaterials().front()->getDiffuse().setColor({1.0, 1.0, 1.0, 1.0});
    
    std::shared_ptr<VRONode> surfaceNode = std::make_shared<VRONode>();
    surfaceNode->setGeometry(surface);
    surfaceNode->setPosition({0, 0, -10.01});
    
    rootNode->addChildNode(surfaceNode);
    
    /*
     Create text.
     */
    VROLineBreakMode linebreakMode = VROLineBreakMode::Justify;
    VROTextClipMode clipMode = VROTextClipMode::ClipToBounds;
    
    std::shared_ptr<VROTypeface> typeface = self.driver->newTypeface("SF", 26);
    //std::string string = "Hello Freetype, this is a test of wrapping a long piece of text, longer than all the previous pieces of text.";
    
    std::string string = "In older times when wishing still helped one, there lived a king whose daughters were all beautiful; and the youngest was so beautiful that the sun itself, which has seen so much, was astonished whenever it shone in her face.\n\nClose by the king's castle lay a great dark forest, and under an old lime-tree in the forest was a well, and when the day was very warm, the king's child went out to the forest and sat down by the fountain; and when she was bored she took a golden ball, and threw it up on high and caught it; and this ball was her favorite plaything.";
    
    VROVector3f size = VROText::getTextSize(string, typeface, width, height, linebreakMode, clipMode);
    NSLog(@"Estimated size %f, %f", size.x, size.y);
    
    std::shared_ptr<VROText> text = VROText::createText(string, typeface, {1.0, 0.0, 0.0, 1.0}, width, height,
                                                        VROTextHorizontalAlignment::Left, VROTextVerticalAlignment::Top,
                                                        linebreakMode, clipMode);
    
    text->setName("Text");
    NSLog(@"Realized size %f, %f", text->getWidth(), text->getHeight());
    
    std::shared_ptr<VRONode> textNode = std::make_shared<VRONode>();
    textNode->setGeometry(text);
    textNode->setPosition({0, 0, -10});
    
    rootNode->addChildNode(textNode);
    
    self.view.reticle->setEnabled(true);
    self.tapEnabled = YES;

    return sceneController;
}

- (std::shared_ptr<VROSceneController>)loadOBJScene {
    std::shared_ptr<VROSceneController> sceneController = std::make_shared<VROSceneController>();
    std::shared_ptr<VROScene> scene = sceneController->getScene();
    scene->setBackgroundCube([self niagaraTexture]);
    
    NSString *objPath = [[NSBundle mainBundle] pathForResource:@"male02" ofType:@"obj"];
    NSURL *objURL = [NSURL fileURLWithPath:objPath];
    std::string url = std::string([[objURL description] UTF8String]);
    
    NSString *basePath = [objPath stringByDeletingLastPathComponent];
    NSURL *baseURL = [NSURL fileURLWithPath:basePath];
    std::string base = std::string([[baseURL description] UTF8String]);
    
    std::shared_ptr<VROLight> light = std::make_shared<VROLight>(VROLightType::Spot);
    light->setColor({ 1.0, 1.0, 1.0 });
    light->setPosition( { 0, 0, 0 });
    light->setDirection( { 0, 0, -1.0 });
    light->setAttenuationStartDistance(50);
    light->setAttenuationEndDistance(75);
    light->setSpotInnerAngle(45);
    light->setSpotOuterAngle(90);
    
    std::shared_ptr<VRONode> rootNode = std::make_shared<VRONode>();
    rootNode->setPosition({0, 0, 0});
    rootNode->addLight(light);
    
    scene->addNode(rootNode);
    
    std::shared_ptr<VRONode> objNode = VROOBJLoader::loadOBJFromURL(url, base, true,
        [](std::shared_ptr<VRONode> node, bool success) {
            if (!success) {
                return;
            }
        
            std::shared_ptr<VROMaterial> material = std::make_shared<VROMaterial>();
            node->setPosition({0, -100, -10});
            node->setScale({ 0.1, 0.1, 0.1 });
    });
    
    
    rootNode->addChildNode(objNode);
    
    std::shared_ptr<VROAction> action = VROAction::perpetualPerFrameAction([self](VRONode *const node, float seconds) {
        self.objAngle += .015;
        node->setRotation({ 0, self.objAngle, 0});
        
        return true;
    });
    
    objNode->runAction(action);
    return sceneController;
}

- (std::shared_ptr<VROSceneController>)loadSceneWithIndex:(int)index {
    int modulo = index % VROSampleSceneNumScenes;
    
    switch (modulo) {
        case VROSampleSceneTorus:
            return [self loadTorusScene];
        case VROSampleSceneVideoSphere:
            return [self loadVideoSphereScene];
        case VROSampleSceneText:
            return [self loadTextScene];
        case VROSampleSceneOBJ:
            return [self loadOBJScene];
        case VROSampleSceneBox:
            return [self loadBoxScene];
        default:
            break;
    }
    
    return [self loadTorusScene];
}

- (void)setupRendererWithDriver:(VRODriver *)driver {
    self.driver = driver;
    self.view.sceneController = [self loadSceneWithIndex:self.sceneIndex];
}

- (IBAction)nextScene:(id)sender {
    ++self.sceneIndex;
    
    std::shared_ptr<VROSceneController> sceneController = [self loadSceneWithIndex:self.sceneIndex];
    [self.view setSceneController:sceneController animated:YES];
}

- (void)shutdownRenderer {
    
}

- (void)willRenderEye:(VROEyeType)eye context:(const VRORenderContext *)renderContext {

}

- (void)didRenderEye:(VROEyeType)eye context:(const VRORenderContext *)renderContext {

}

- (void)reticleTapped:(VROVector3f)ray context:(const VRORenderContext *)renderContext {
    if (true) {
        [self nextScene:nullptr];
        return;
    }
    
    if (self.videoTexture) {
        if (self.videoTexture->isPaused()) {
            self.videoTexture->play();
        }
        else {
            self.videoTexture->pause();
        }
        
        return;
    }
}

- (void)renderViewDidChangeSize:(CGSize)size context:(VRORenderContext *)context {

}

- (void)userDidRequestExitVR {
    
}

@end

