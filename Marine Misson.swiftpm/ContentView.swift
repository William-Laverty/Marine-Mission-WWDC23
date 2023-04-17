import PlaygroundSupport
import SwiftUI
import SpriteKit

// Global Varibles
var view = SKView(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
var sceneType = "introScene" // Current scene selected [ Mainly for debug ]
let colorScheme = [#colorLiteral(red: 0.8279624581336975, green: 0.9216256737709045, blue: 0.960345447063446, alpha: 1.0), #colorLiteral(red: 0.4549018144607544, green: 0.7058825492858887, blue: 0.8529413342475891, alpha: 1.0), #colorLiteral(red: -0.005245536100119352, green: 0.5800858736038208, blue: 0.9784795641899109, alpha: 1.0), #colorLiteral(red: 0.25584304760661647, green: 0.3031634253182668, blue: 0.5348542203608248, alpha: 1.0), #colorLiteral(red: 0.4653213024, green: 0.7332682014, blue: 0.2536376119, alpha: 1.0)] // {}.fontColor = colorScheme[3]
let fadeIn = SKAction.fadeAlpha(by: 1, duration: 2) // Global fadeIn for nodes
var userAnimal = "" // User chooses an animal to play as
var isDead = Bool(false)
var addObstacles = Bool(true)
var highScore = 0

// Global Assets IntroScene
var owl = SKSpriteNode(imageNamed: "owl.png")
let penguin = SKSpriteNode(imageNamed: "penguin.png")
let iceberg = SKSpriteNode(imageNamed: "iceberg.png")
let playText = SKLabelNode(fontNamed: "Futura-Medium")
let playButton = SKShapeNode(path: UIBezierPath(roundedRect: CGRect(x: -100, y: -50, width: 200, height: 100), cornerRadius: 10).cgPath)

// Global Assets Instructions Scene
let waves = SKSpriteNode(imageNamed: "waves.png")
let ropeSign = SKSpriteNode(imageNamed: "ropeSign.png")
let userChoiceText = SKLabelNode(fontNamed: "Futura-Medium")

// Music Assets
let introMusic = SKAction.playSoundFileNamed("IntroMusic - By William Laverty.m4a", waitForCompletion: false)
let playButtonSFX = SKAction.playSoundFileNamed("ButtonPress - By William Laverty.m4a", waitForCompletion: false)
let trashSFX = SKAction.playSoundFileNamed("TrashSound.mp3", waitForCompletion: false)
let gameMusic = SKAction.playSoundFileNamed("GameMusic - By William Laverty.m4a", waitForCompletion: true)
var gameMusicRun = 1

// PlayButton Motion Effects
let buttonClickDown = SKAction.scale(to: 0.9, duration: 0.12)
let buttonClickUp = SKAction.scale(to: 1, duration: 0.12)
let buttonWaitAnimation : SKAction = SKAction.wait(forDuration: 0.1)
let sceneSwitchWaitTime : SKAction = SKAction.wait(forDuration: 0.2)

// Global Score
var playerLife = 3 

// Score Penguin
let penguinLifeSpan = 5000
var penguinLifeLeft = 5000 // Average lifespan in days

// Score Grampus
let grampusLifeSpan = 10000
var grampusLifeLeft = 10000 // Average lifespan in days

// Player Collison Score
var trashHit = 0
var trashMissed = 0

// Intro Scene
class introScene: SKScene, SKPhysicsContactDelegate {
    override func didMove(to view: SKView) {
        setupIntroScene()
    }
    
    func setupIntroScene() {
        // Background
        let introScreenBackground = SKSpriteNode(color: colorScheme[1], size: CGSize(width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.height * 2))
        introScreenBackground.position = CGPoint(x: frame.midX, y: frame.midY)
        
        // FadeIn Timer
        let owlShowTime : SKAction = SKAction.wait(forDuration: 3.76)
        let penguinShowTime : SKAction = SKAction.wait(forDuration: 3.9)
        let buttonShowTime : SKAction = SKAction.wait(forDuration: 5.5)

        // Owl Sprite
        owl.size = CGSize(width: 160, height: 160)
        owl.alpha = 0.9
        owl.isHidden = true
        owl.position = CGPoint(x: frame.midX - 140, y: frame.midY + 50)
        
        // Penguin Sprite
        penguin.size = CGSize(width: 136, height: 180)
        penguin.alpha = 0.9
        penguin.isHidden = true
        penguin.position = CGPoint(x: frame.midX + 140, y: frame.midY - 45)
        penguin.zRotation = -0.1
        
        // Iceberg Sizing 
        let icebergWidth = ((self.view!.frame.width * CGFloat(0.8)) / iceberg.size.width) // 80% of iceberg width relative to view
        let icebergHeight = ((self.view!.frame.height * CGFloat(0.8)) / iceberg.size.height) // 80% of iceberg height relative to view
        let icebergScale = min(icebergWidth, icebergHeight)
        
        // Iceberg Sprite
        iceberg.setScale(icebergScale)
        iceberg.physicsBody = SKPhysicsBody(rectangleOf: iceberg.size)
        iceberg.physicsBody?.allowsRotation = false
        iceberg.physicsBody?.isDynamic = true
        iceberg.position = CGPoint(x: frame.midX, y: frame.minY - 10)
        iceberg.anchorPoint = CGPoint(x: 0.5, y: 0)
        iceberg.alpha = 0
        
        // Title Text
        let introTitle = SKLabelNode(fontNamed: "Futura-Medium")
        introTitle.text = "Marine Mission"
        introTitle.alpha = 0
        introTitle.fontSize = 75
        introTitle.fontColor = colorScheme[0]
        introTitle.position = CGPoint(x: frame.midX, y: frame.maxY - 180)
        
        // Allows nodes to react with physics [Not needed]
        self.physicsBody?.collisionBitMask = 0b0001
        self.physicsBody?.categoryBitMask = 0b0001
        self.physicsWorld.contactDelegate = self
        
        // Gravity attributes || Vertical Force -2/second
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        
        // Boundary on nodes so they can't leave scene || Sprite specific
        iceberg.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        // Fading of sprites for intro
        introTitle.run(fadeIn)
        iceberg.run(fadeIn)

        run(introMusic)       
        
        // Fade in called sprites
        run(owlShowTime) { owl.isHidden = false }
        run(penguinShowTime) { penguin.isHidden = false }
        
        // Fade in button
        run(buttonShowTime) { [self] in
            run(fadeIn)
            setupPlayButton()
        }
        
        addChild(introScreenBackground)
        addChild(introTitle)
        addChild(iceberg)
        addChild(owl)
        addChild(penguin)
    }
    
    // Play Button Setup
    func setupPlayButton() {
        // Play button shape
        playButton.position = CGPoint(x: frame.midX, y: frame.minY + 100)
        playButton.fillColor = colorScheme[1]
        playButton.strokeColor = colorScheme[0]
        playButton.lineWidth = 4
        playButton.alpha = 0
        playButton.name = "playButton"
        
        // Text for play button
        playText.alpha = 0
        playText.text = "Play"
        playText.fontColor = SKColor.white
        playText.fontSize = 50
        playText.horizontalAlignmentMode = .center
        playText.verticalAlignmentMode = .center
        playText.position = CGPoint(x: frame.midX, y: frame.minY + 100)
        playText.name = "playText"
        
        // FadeIn button & text to start game
        let playButtonFade = SKAction.fadeAlpha(by: 1, duration: 1.5)
        playButton.run(playButtonFade)
        playText.run(playButtonFade)
        
        // Add childs of button to scene
        addChild(playButton)
        addChild(playText)
    }
    
    // Check for touchesBegan in nodes
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            // If touched node is the button/text || Animate & switch scenes
            if (touchedNode.name == "playButton" || touchedNode.name == "playText") {
                // Button Scale negative + music play
                run(playButtonSFX)
                playButton.run(buttonClickDown)
                playText.run(buttonClickDown)
                
                // Button Scale Positive with delay
                run(buttonWaitAnimation) {
                    playButton.run(buttonClickUp)
                    playText.run(buttonClickUp)
                }
                
                // Delay switch to scene
                run(sceneSwitchWaitTime) {
                    sceneType = "instructionsScene"
                    setupCurrentScene(view: self.view!)
                }
            }
        }
    }
}

// Instruction Scene
class instructionsScene: SKScene, SKPhysicsContactDelegate { 
    // Selection buttons
    let penguinButton = SKShapeNode(path: UIBezierPath(roundedRect: CGRect(x: -175, y: -145, width: 350, height: 350), cornerRadius: 10).cgPath)
    let grampusButton = SKShapeNode(path: UIBezierPath(roundedRect: CGRect(x: -175, y: -145, width: 350, height: 350), cornerRadius: 10).cgPath)
    
    // Player Icon
    let penguin = SKSpriteNode(imageNamed: "penguin")
    let grampus = SKSpriteNode(imageNamed: "grampus")
    
    // Player Labels || Title and Description
    let penguinLabel = SKLabelNode(fontNamed: "Futura-Medium")
    let grampusLabel = SKLabelNode(fontNamed: "Futura-Medium")
    let grampusDescription = SKLabelNode(fontNamed: "Futura-Medium")
    let penguinDescription = SKLabelNode(fontNamed: "Futura-Medium")
    
    // Player Abilities || Lifetime, Speed & Difficulty
    let penguinDayBold = SKLabelNode(fontNamed: "Futura-Bold")
    let grampusDayBold = SKLabelNode(fontNamed: "Futura-Bold")
    let penguinDayLabel = SKLabelNode(fontNamed: "Futura-Medium")
    let grampusDayLabel = SKLabelNode(fontNamed: "Futura-Medium")
    
    let penguinSpeedBold = SKLabelNode(fontNamed: "Futura-Bold")
    let grampusSpeedBold = SKLabelNode(fontNamed: "Futura-Bold")
    let penguinSpeedLabel = SKLabelNode(fontNamed: "Futura-Medium")
    let grampusSpeedLabel = SKLabelNode(fontNamed: "Futura-Medium")
    
    let penguinDifficultyBold = SKLabelNode(fontNamed: "Futura-Bold")
    let grampusDifficultyBold = SKLabelNode(fontNamed: "Futura-Bold")
    let penguinDifficultyLabel = SKLabelNode(fontNamed: "Futura-Medium")
    let grampusDifficultyLabel = SKLabelNode(fontNamed: "Futura-Medium")
    
    override func didMove(to view: SKView) {
        setupInstructionsScene()
        self.isUserInteractionEnabled = true 
    }
    
    func setupInstructionsScene() {
        // Reset all scores || INCASE OF RETRY 
        userAnimal = ""
        isDead = Bool(false)
        addObstacles = Bool(true)
        playerLife = 3 
        penguinLifeLeft = 5000 // Average lifespan in hours
        grampusLifeLeft = 10000 // Average lifespan in hours
        trashHit = 0
        trashMissed = 0
        
        // Background
        let backgroundInstructions = SKSpriteNode(color: colorScheme[1], size: CGSize(width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.height * 2))
        backgroundInstructions.position = CGPoint(x: frame.midX, y: frame.midY)
        
        // Waves backdrop
        waves.size = CGSize(width: 1246, height: 138.7)
        waves.position = CGPoint(x: frame.midX, y: frame.minY + 67)
        
        // Title Label
        userChoiceText.text = "Choose Your Animal"
        userChoiceText.numberOfLines = 1
        userChoiceText.preferredMaxLayoutWidth = 300
        userChoiceText.alpha = 0
        userChoiceText.fontSize = 48
        userChoiceText.fontColor = colorScheme[0]
        userChoiceText.position = CGPoint(x: frame.midX, y: frame.maxY - 190)
        
        // Rope Sign Image
        ropeSign.size = CGSize(width: 625, height: 450)
        ropeSign.position = CGPoint(x: frame.midX, y: frame.maxY + 100)
        
        // Animation lowering of sign
        let signLowering = SKAction.moveTo(y: frame.maxY - 45, duration: 0.4)
        let signGravity = SKAction.moveTo(y: frame.maxY - 35, duration: 0.2)
        let signCounterGravity = SKAction.moveTo(y: frame.maxY - 45, duration: 0.4)
        
        // Attempt at gravitational like effect || Shows text @ end of run
        ropeSign.run(signLowering, completion: {
            ropeSign.run(signGravity, completion: {
                ropeSign.run(signCounterGravity, completion: {
                    userChoiceText.run(fadeIn)
                    loadPlayerList()
                })
            })
        })
        
        func loadPlayerList() {
            // Description of playable animals
            penguinDescription.text = "Emperor penguins are indigenous to Antarctica and are facing numerous threats to its survival. It's suggested that 98% of emperor penguins colonies could disappear in 80 years due to exponential sea waste polluting Antartica's waters and surrounding continental areas." 
            penguinDescription.verticalAlignmentMode = .center // Meant to center text || Working?
            penguinDescription.position = CGPoint(x: frame.midX - 225, y: frame.midY + 5)
            
            grampusDescription.text = "The orca, or killer whale, is the largest member of the dolphin family and faces major threats such as plastics and toxins. Lack of research on the effects of these threats could result in at least half of all orca populations globally dying out within 50 years." 
            grampusDescription.verticalAlignmentMode = .center // Meant to center text || Working?
            grampusDescription.position = CGPoint(x: frame.midX + 225, y: frame.midY + 5)
            
            // Style of buttons [ Array for loop ]
            var playerListButton :[SKShapeNode] = [SKShapeNode]()
            playerListButton.append(penguinButton)
            playerListButton.append(grampusButton)
            
            // Style of labelTitles [ Array for loop ]
            var playerListText :[SKLabelNode] = [SKLabelNode]()
            playerListText.append(penguinLabel)
            playerListText.append(grampusLabel)
            
            // Style of labelDescriptions [ Array for loop ]
            var playerListDescriptionText :[SKLabelNode] = [SKLabelNode]()
            playerListDescriptionText.append(penguinDescription)
            playerListDescriptionText.append(grampusDescription)
            
            // Positioning of buttons
            let positionOfButtons = [CGPoint(x:  frame.midX - 225, y: frame.midY - 70), 
                                     CGPoint(x: frame.midX + 225, y: frame.midY - 70)]
            
            // Loop for styling buttons [ Dependent on array ]
            var counterButton = 0 // using playerListButton[i] didnt work || counts through array
            for _ in playerListButton {
                playerListButton[counterButton].position = positionOfButtons[counterButton]
                playerListButton[counterButton].fillColor = colorScheme[0]
                playerListButton[counterButton].strokeColor = colorScheme[0]
                playerListButton[counterButton].lineWidth = 4
                playerListButton[counterButton].alpha = 0
                counterButton += 1
            }
            
            // Loop for styling text [ Dependent on array ]
            var counterText = 0 // using playerListText[i] didnt work || counts through array
            for _ in playerListText {
                playerListText[counterText].alpha = 0
                playerListText[counterText].fontColor = SKColor.gray
                playerListText[counterText].fontSize = 30
                playerListText[counterText].position = positionOfButtons[counterText]
                counterText += 1
            }
            
            // Loop for styling text description [ Dependent on array ]
            var counterTextDescription = 0 // playerListDescriptionText[i] didnt work || counts through array
            for _ in playerListDescriptionText {
                playerListDescriptionText[counterTextDescription].alpha = 0
                playerListDescriptionText[counterTextDescription].fontColor = SKColor.gray
                playerListDescriptionText[counterTextDescription].fontSize = 14
                playerListDescriptionText[counterTextDescription].numberOfLines = 16
                playerListDescriptionText[counterTextDescription].horizontalAlignmentMode = .center
                playerListDescriptionText[counterTextDescription].verticalAlignmentMode = .center
                playerListDescriptionText[counterTextDescription].preferredMaxLayoutWidth = 300
                counterTextDescription += 1
            }
            
            // Extra styling not possible in loop
            penguinLabel.position = CGPoint(x: frame.midX - 225, y: frame.midY + 80)
            grampusLabel.position = CGPoint(x: frame.midX + 225, y: frame.midY + 80)
            penguinLabel.text = "Penguin"
            grampusLabel.text = "Orca"
            
            // Naming of nodes
            grampusLabel.name = "grampusText"
            grampusDescription.name = "grampusTextDesp"
            penguinLabel.name = "penguinText"
            penguinDescription.name = "penguinTextDesp"
            grampusButton.name = "grampusButton"
            penguinButton.name = "penguinButton"
            
            // Player Abilites || Using array lopp for styling
            
            // Player LifeSpan Rating
            penguinDayBold.text = "Lifespan:"
            grampusDayBold.text = "Lifespan:"
            penguinDayLabel.text = "5000 Days"
            grampusDayLabel.text = "10,000 Days"
            penguinDayBold.position = CGPoint(x: frame.midX - 341.5, y: frame.midY - 100)
            grampusDayBold.position = CGPoint(x: frame.midX + 108.5, y: frame.midY - 100)
            penguinDayLabel.position = CGPoint(x: frame.midX - 241, y: frame.midY - 100)
            grampusDayLabel.position = CGPoint(x: frame.midX + 208, y: frame.midY - 100)
            penguinDayBold.name = "pDB"
            grampusDayBold.name = "gDB"
            penguinDayLabel.name = "pDL"
            grampusDayLabel.name = "gDL"
            
            // Player Speed Rating
            penguinSpeedBold.text = "Swiftness:"
            grampusSpeedBold.text = "Swiftness:"
            penguinSpeedLabel.text = "Fast and Agile"
            grampusSpeedLabel.text = "Slow and Steady"
            penguinSpeedBold.position = CGPoint(x: frame.midX - 337.5, y: frame.midY - 130)
            grampusSpeedBold.position = CGPoint(x: frame.midX + 112.5, y: frame.midY - 130)
            penguinSpeedLabel.position = CGPoint(x: frame.midX - 230, y: frame.midY - 130)
            grampusSpeedLabel.position = CGPoint(x: frame.midX + 223, y: frame.midY - 130)
            penguinSpeedBold.name = "pSB"
            grampusSpeedBold.name = "gSB"
            penguinSpeedLabel.name = "pSL"
            grampusSpeedLabel.name = "gSL"
            
            // Player Difficulty Rating
            penguinDifficultyBold.text = "Difficulty:"
            grampusDifficultyBold.text = "Difficulty:"
            penguinDifficultyLabel.text = "Casual"
            grampusDifficultyLabel.text = "Challenging"
            penguinDifficultyBold.position = CGPoint(x: frame.midX - 340.5, y: frame.midY - 160)
            grampusDifficultyBold.position = CGPoint(x: frame.midX + 110, y: frame.midY - 160)
            penguinDifficultyLabel.position = CGPoint(x: frame.midX - 255, y: frame.midY - 160)
            grampusDifficultyLabel.position = CGPoint(x: frame.midX + 207, y: frame.midY - 160)
            penguinDifficultyBold.name = "pFB"
            grampusDifficultyBold.name = "gFB"
            penguinDifficultyLabel.name = "pFL"
            grampusDifficultyLabel.name = "gFL"
            
            // Array of ability nodes
            let playerAbilitiesNodes = [penguinDifficultyBold, grampusDifficultyBold, penguinDifficultyLabel, grampusDifficultyLabel, penguinSpeedBold, grampusSpeedBold, penguinSpeedLabel, grampusSpeedLabel, grampusDayBold, penguinDayBold, penguinDayLabel, grampusDayLabel]
            
            // Player Abilities Styling
            for node in playerAbilitiesNodes {
                // Looped Styling
                node.alpha = 0
                node.fontSize = 14
                node.fontColor = SKColor.gray
            }
            
            // Icons
            penguin.position = CGPoint(x: frame.midX - 125, y: frame.midY - 125)
            penguin.alpha = 0
            penguin.setScale(0.03)
            penguin.name = "pICON"
            
            grampus.position = CGPoint(x: frame.midX + 325, y: frame.midY - 125)
            grampus.alpha = 0
            grampus.setScale(0.03)
            grampus.zRotation += 0.6
            grampus.name = "gICON"
            
            // Run fade 
            let startFade = SKAction.fadeAlpha(by: 1, duration: 1.5)
            var counterAdd = 0
            for _ in playerListButton {
                // Fade in of button and text to start game
                playerListButton[counterAdd].run(startFade)
                playerListText[counterAdd].run(startFade)
                playerListDescriptionText[counterAdd].run(startFade)
                
                // Add childs of button & text to scene
                addChild(playerListButton[counterAdd])
                addChild(playerListText[counterAdd])
                addChild(playerListDescriptionText[counterAdd])
                counterAdd += 1
            }
            for node in playerAbilitiesNodes {
                node.run(startFade)
                addChild(node)
            }
            grampus.run(startFade)
            penguin.run(startFade)
            addChild(grampus)
            addChild(penguin)
        }
    
        addChild(backgroundInstructions)
        addChild(ropeSign)
        addChild(userChoiceText)
        addChild(waves)
    }
    
    // Check for touchesBegan in nodes
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            // Player Specific Node Filter Manual || array.filter didnt work
            let penguinAbilitiesNodes: [SKNode] = [penguinDifficultyBold, penguinDifficultyLabel, penguinSpeedBold, penguinSpeedLabel, penguinDayBold, penguinDayLabel]
            let grampusAbilitiesNodes: [SKNode] = [grampusDifficultyBold, grampusDifficultyLabel, grampusSpeedBold, grampusSpeedLabel, grampusDayBold, grampusDayLabel]
            
            // If touched node is the button/text || Animate & switch scenes
            if (touchedNode.name == "penguinButton" || touchedNode.name == "penguinText" || touchedNode.name == "penguinTextDesp" || touchedNode.name == "pDB" || touchedNode.name == "pDL" || touchedNode.name == "pSB" || touchedNode.name == "pSL" || touchedNode.name == "pFB" || touchedNode.name == "pFL" || touchedNode.name == "pICON") {
                userAnimal = "penguinChosen" // User player is Penguin
                
                // Button Scale negative + music play
                run(playButtonSFX)
                penguinButton.run(buttonClickDown)
                penguinLabel.run(buttonClickDown)
                penguinDescription.run(buttonClickDown)
                penguinAbilitiesNodes.forEach { $0.run(buttonClickDown) }
                
                // Button Scale positive with delay
                run(buttonWaitAnimation) { [self] in
                    penguinButton.run(buttonClickUp)
                    penguinLabel.run(buttonClickUp)
                    penguinDescription.run(buttonClickUp)
                    penguinAbilitiesNodes.forEach { $0.run(buttonClickUp) }
                }
                
                // Delay switch to scene
                run(sceneSwitchWaitTime) {
                    sceneType = "gameScene"
                    setupCurrentScene(view: self.view!)
                }
            } else if (touchedNode.name == "grampusButton" || touchedNode.name == "grampusText" || touchedNode.name == "grampusTextDesp" || touchedNode.name == "gDB" || touchedNode.name == "gDL" || touchedNode.name == "gSB" || touchedNode.name == "gSL" || touchedNode.name == "gFB" || touchedNode.name == "gFL" || touchedNode.name == "gICON") {
                userAnimal = "grampusChosen" // User player is Grampus
                
                // Button Scale negative + music play
                run(playButtonSFX)
                grampusButton.run(buttonClickDown)
                grampusLabel.run(buttonClickDown)
                grampusDescription.run(buttonClickDown)
                grampusAbilitiesNodes.forEach { $0.run(buttonClickDown) }
                
                // Button Scale positive with delay
                run(buttonWaitAnimation) { [self] in
                    grampusButton.run(buttonClickUp)
                    grampusLabel.run(buttonClickUp)
                    grampusDescription.run(buttonClickUp)
                    grampusAbilitiesNodes.forEach { $0.run(buttonClickUp) }
                }
                
                // Delay switch to scene
                run(sceneSwitchWaitTime) {
                    sceneType = "gameScene"
                    setupCurrentScene(view: self.view!)
                }
            }
        }
    }
}

// Game Scene
class gameScene: SKScene, SKPhysicsContactDelegate {
    // Penguin Animation
    var penguinAnimationFrames: [SKTexture] = []
    let penguinSwim1 = SKTexture(imageNamed: "penguinSwim1.png")
    let penguinSwim2 = SKTexture(imageNamed: "penguinSwim2.png")
    let penguin = SKSpriteNode()
    
    // Gramous Animation
    var grampusAnimationFrames: [SKTexture] = []
    let grampusSwim1 = SKTexture(imageNamed: "grampusSwim1.png")
    let grampusSwim2 = SKTexture(imageNamed: "grampusSwim2.png")
    let grampus = SKSpriteNode()
    
    // Trash Nodes
    var trashTextures: [SKTexture] = []
    var currentTrashTextureIndex = 0
    var trashCounter = 0
    
    // Create an array to hold the trash nodes
    var trashPool = [SKSpriteNode]()
    let maxTrashNodes = 200 // Maximum number of trash nodes in the pool [ CRASHES AT HIGH VALUE ]
    
    // Ocean Background
    let ocean = SKSpriteNode(color: colorScheme[1], size: CGSize(width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.height * 2))
    var fadeToLight = false
    var fadeToDark = true
    
    // Hidden line || Keeps player in one section of view
    let lineNodeLeft = SKShapeNode(rectOf: CGSize(width: 1, height: UIScreen.main.bounds.height))
    let lineNodeRight = SKShapeNode(rectOf: CGSize(width: 1, height: UIScreen.main.bounds.height))

    // Motion Effects
    let pause = SKAction.wait(forDuration: 0.15)
    var min = -0.3
    
    // Hearts Counter
    var hearts: [SKSpriteNode] = []
    let penguinLifeleftLabel = SKLabelNode(fontNamed: "Futura-Medium")
    let grampusLifeleftLabel = SKLabelNode(fontNamed: "Futura-Medium")
    var displayLink: CADisplayLink?

    override func didMove(to view: SKView) {
        setupTrashPool()
    }
    
    // Node Trash Pool
    func setupTrashPool() {
        // Add textures to trashTextures array
        for i in 1 ... 5 {
            let texture = SKTexture(imageNamed: "trash\(i)")
            trashTextures.append(texture)
        }
        
        // Background thread for trash pool
        DispatchQueue.global().async { [self] in 
            for i in 0 ..< maxTrashNodes {
                // Pre-allocate trash nodes and add them to the pool
                let trash = SKSpriteNode(texture: self.trashTextures[i % self.trashTextures.count])
                trash.name = "trash\(i)"
                trash.setScale(0.11)
                
                // Collision Handler 
                trash.physicsBody = SKPhysicsBody(texture: trash.texture!, size: trash.size)
                trash.physicsBody?.contactTestBitMask = 3 // Specific for animal collision
                trash.physicsBody?.collisionBitMask = 0 // set the collision mask of trash node
                trash.physicsBody?.affectedByGravity = false
                
                // Hide the node initially on seperate thread
                trash.isHidden = true 
                DispatchQueue.main.async {
                    self.trashPool.append(trash)
                }
            }
        }
        setupGameScene()
    }
    
    func setupGameScene() {
        // Size of nodes
        penguin.size = CGSize(width: 88, height: 110)
        grampus.size = CGSize(width: 135, height: 90)
        
        // Penguin Frames
        penguinAnimationFrames = [penguinSwim1, penguinSwim2]
        penguin.texture = penguinAnimationFrames[0]
        
        // Grampus Frames
        grampusAnimationFrames = [grampusSwim1, grampusSwim2]
        grampus.texture = grampusAnimationFrames[0]
        
        // Line Node || Player pusback (Hidden)
        lineNodeLeft.position = CGPoint(x: self.frame.width * 0.25, y: self.frame.midY)
        lineNodeRight.position = CGPoint(x: self.frame.width * 0.5, y: self.frame.midY)
        lineNodeLeft.isHidden = true
        lineNodeRight.isHidden = true
        
        // Ocean background
        ocean.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(ocean)
        
        // Gravity attributes || Vertical Force -1.25/second
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -1.25)
        self.physicsWorld.contactDelegate = self
        
        // Boundary on nodes so they can't leave scene || Categorised specific
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        // Set userSelected animal
        if (userAnimal == "penguinChosen") {
            setupPenguinScene()
        } else if (userAnimal == "grampusChosen") {
            setupGrampusScene()
        }
        
        // Penguin Life Left Label
        penguinLifeleftLabel.text = "\(penguinLifeLeft)"
        penguinLifeleftLabel.position = CGPoint(x: frame.maxX - 125, y: frame.maxY - 90)
        
        // Grampus Life Left Label
        grampusLifeleftLabel.text = "\(grampusLifeLeft)"
        grampusLifeleftLabel.position = CGPoint(x: frame.maxX - 125, y: frame.maxY - 90)
        
        // Hours left label
        if (userAnimal == "grampusChosen") {
            addChild(grampusLifeleftLabel)
        } else if (userAnimal == "penguinChosen") {
            addChild(penguinLifeleftLabel)
        }
        
        // Heart Counter Loop
        for i in 0...2 {
            let heart = SKSpriteNode(imageNamed: "heartFull")
            heart.setScale(0.15)
            heart.position = CGPoint(x: heart.frame.width * CGFloat(i + 1), y: frame.maxY - heart.frame.height)
            addChild(heart)
            hearts.append(heart)
        }
        
        addChild(lineNodeLeft)
        addChild(lineNodeRight)
        
        if (gameMusicRun == 1) {
            run(gameMusic)
            gameMusicRun += 2
        }
    }
    
    func setupPenguinScene() {
        // Create penguin animations
        penguin.position = CGPoint(x: frame.midX - 150, y: frame.midY)
        penguin.physicsBody = SKPhysicsBody(rectangleOf: penguin.size)
        penguin.physicsBody?.allowsRotation = false
        penguin.physicsBody?.isDynamic = true
        penguin.physicsBody?.collisionBitMask = 0b0001
        penguin.physicsBody?.categoryBitMask =  0b0001
        penguin.physicsBody?.contactTestBitMask = 3 // Specific for animal collision
        penguin.zRotation = -0.7
        penguin.name = "playerPenguin"
        ocean.name = "penguinOcean"
    
        //Add childs
        addChild(penguin)
        setupObstacles()
    }
    
    func setupGrampusScene() {
        // Create grampus animations
        grampus.position = CGPoint(x: frame.midX - 150, y: frame.midY)
        grampus.physicsBody = SKPhysicsBody(rectangleOf: grampus.size)
        grampus.physicsBody?.allowsRotation = false
        grampus.physicsBody?.isDynamic = true
        grampus.physicsBody?.collisionBitMask = 0b0001
        grampus.physicsBody?.categoryBitMask =  0b0001
        grampus.physicsBody?.contactTestBitMask = 3 // Specific for animal collision
        grampus.zRotation = -0.7
        grampus.name = "playerGrampus"
        ocean.name = "grampusOcean"
        
        // Add childs
        addChild(grampus)
        setupObstacles()
    }
    
    // Trash obstacle handler || Speeds up speed of trash movment over time
    func setupObstacles() {  
        let initialSpeed: TimeInterval = 3 // Initial duration for moveLeft action
        let minSpeed: TimeInterval = 0.5 // Minimum duration for moveLeft action
        var waitDuration: TimeInterval = 1 // Initial duration for wait action
        var lastTrashPosition = CGPoint.zero // keep track of the last trash node position
        
        // Add trash to scene
        let addTrash = SKAction.run { [self] in
            if addObstacles {
                // Check if there are any inactive trash nodes in the pool
                if let trash = trashPool.first(where: { $0.isHidden == true }) {
                    // Choose a random y-position for new trash node
                    var randomY = CGFloat.random(in: trash.size.height/2...size.height - trash.size.height/2)
                    
                    // New y-position is too close to the previous position || Adjust it
                    while abs(randomY - lastTrashPosition.y) < 100 {
                        randomY = CGFloat.random(in: trash.size.height/2...size.height - trash.size.height/2)
                    }
                    
                    // Set the position of the new trash node
                    trash.position = CGPoint(x: size.width + trash.size.width/2, y: randomY)
                    trash.isHidden = false
                    
                    // Modify duration of moveLeft action based on trashCounter
                    let speed = max(minSpeed, initialSpeed - (TimeInterval(trashCounter)/2) * 0.075)
                    let moveLeft = SKAction.moveBy(x: -size.width, y: 0, duration: speed)
                    let repeatForever = SKAction.repeatForever(moveLeft)
                    trash.run(repeatForever)
                    
                    addChild(trash)
                    
                    // Update the lastTrashPosition to the position of the new trash node
                    lastTrashPosition = trash.position
                    
                    // Reduce wait duration to speed up trash node creation
                    waitDuration = max(0, 1.5 - TimeInterval(trashCounter) * 0.05)
                }
                
                // Change to next trash texture
                self.currentTrashTextureIndex += 1
                self.trashCounter += 1
                if self.currentTrashTextureIndex >= self.trashTextures.count {
                    self.currentTrashTextureIndex = 0
                }
            }
        }
        let wait = SKAction.wait(forDuration: waitDuration)
        let createTrashNodes = SKAction.sequence([wait, addTrash])
        run(SKAction.repeatForever(createTrashNodes))

        
        // Check for trash nodes that leaves the screen edges
        let checkForOutOfBoundsTrash = SKAction.run {
            for node in self.children {
                if node.name?.hasPrefix("trash") == true {
                    if node.position.x < -self.size.width/2 || node.position.y < -self.size.height/2 {
                        node.removeFromParent() // Remove trash node
                        trashMissed += 1 // endScene Scoring
                    }
                }
            }
        }
        // Always check for nodes off screen
        let checkBoundsTrash = SKAction.sequence([wait, checkForOutOfBoundsTrash])
        run(SKAction.repeatForever(checkBoundsTrash))
    }
    
    var penguinHeld = false
    var grampusHeld = false
    
    // Check for touchesBegan in nodes
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {        
        // Penguin Animation
        let penguinAnimation = SKAction.animate(with: penguinAnimationFrames, timePerFrame: 0.1)
        let penguinLoopAnimation = SKAction.repeatForever(penguinAnimation)
        
        // Grampus Animation
        let grampusAnimation = SKAction.animate(with: grampusAnimationFrames, timePerFrame: 0.1)
        let grampusLoopAnimation = SKAction.repeatForever(grampusAnimation)
        
        if (userAnimal == "grampusChosen") {
            grampusHeld = true
            grampus.run(grampusLoopAnimation)
        } else {
            penguinHeld = true
            penguin.run(penguinLoopAnimation)
        }
    }
    
    // Check for touchesEnded in nodes
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Removes animations 
        if (userAnimal == "grampusChosen") {
            grampusHeld = false
            grampus.removeAllActions()
        } else {
            penguinHeld = false
            penguin.removeAllActions()
        }
    }
    

    var lastUpdateTime: TimeInterval = 0
    let updateTimeInterval: TimeInterval = 1.0 / 240 // 240 UPDATES PER SECOND
    
    // Delayed Update Check || FREQUENCY OF CONSTANT CHECK DOES NOT WORK
    public override func update(_ currentTime: TimeInterval) {
        // Calculate time since last update
        let deltaTime = currentTime - lastUpdateTime
        
        // Only update if enough time has passed
        if deltaTime >= updateTimeInterval {
            lastUpdateTime = currentTime
            
            // For the swimming of penguin dynamiccally
            if (penguinHeld == true) {
                if (penguin.zRotation < -0.3 && penguin.zRotation > -1.3) {
                    penguin.zRotation += 0.03
                    penguin.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 4))
                } else if (penguin.zRotation > -0.3) {
                    penguin.zRotation = -0.3 // Over rotation handeler
                    penguin.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 4))
                } else if (penguin.zRotation < -1.3) {
                    penguin.zRotation += 0.1
                    penguin.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 4))
                }
            }
            
            // Rotate downward heading
            if (penguinHeld == false) {
                if (penguin.zRotation < -0.3 && penguin.zRotation > -2) {
                    penguin.zRotation = penguin.zRotation - 0.01
                } else if (penguin.zRotation > -0.3) {
                    penguin.zRotation = penguin.zRotation - 0.01
                }
            }
            
            // For the swimming of grampus dynamiccally
            if (grampusHeld == true) {
                if (grampus.zRotation > -0.8 && grampus.zRotation < 0.7) {
                    grampus.zRotation += 0.04
                    grampus.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 3.5))
                } else if (grampus.zRotation > 0.7) {
                    grampus.zRotation -= 0.03
                    grampus.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 3.5))
                } else if (grampus.zRotation > -0.7) {
                    grampus.zRotation = -0.04
                    grampus.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 3.5))
                }
            }
            
            // Rotate downard heading
            if (grampusHeld == false) {
                if (grampus.zRotation > 0.7) {
                    grampus.zRotation = grampus.zRotation - 0.01
                } else if (grampus.zRotation > -0.7) {
                    grampus.zRotation = grampus.zRotation - 0.01
                }
            }
            
            // Player pushback [ Keeps player in 1/3 section ]
            let leftLine = self.frame.width * 0.25 
            let penguinXPosition = penguin.position.x
            let grampusXPosition = grampus.position.x
            
            if (penguinXPosition < leftLine) {
                penguin.physicsBody?.applyImpulse(CGVector(dx: 0.5, dy: 0))
            } else if (penguinXPosition > (leftLine * 2)) {
                penguin.physicsBody?.applyImpulse(CGVector(dx: -1, dy: 0))
            }
            
            if (grampusXPosition < leftLine) {
                grampus.physicsBody?.applyImpulse(CGVector(dx: 0.5, dy: 0))
            } else if (grampusXPosition > (leftLine * 2)) {
                grampus.physicsBody?.applyImpulse(CGVector(dx: -1, dy: 0))
            }
        }
    }
    
    // Collison Handler
    public func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        // If contactTestBitMask values collide [ Trash Node and Player ]
        if ((bodyA.contactTestBitMask == bodyB.contactTestBitMask) && (bodyA.contactTestBitMask == 3)) {
            bodyB.node?.removeFromParent()
            
            if (userAnimal == "penguinChosen") {
                updateScoreP()
            } else if (userAnimal == "grampusChosen") {
                updateScoreG()
            }
            run(trashSFX)
            trashHitCount()
            
            // Backup if removeFromParent crashess
            self.enumerateChildNodes(withName: "trash") {
                (node, stop) in 
                if (!self.scene!.frame.contains(node.position)) {
                    node.removeFromParent()
                }
            }
        }
    }
    
    // Penguin Score Handler
    func updateScoreP() {
        penguinLifeLeft -= ((Int(arc4random_uniform(2501)) + 2500)/15) // Choose random damage rate 
        
        // Label update for hoursLeft
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updatePenguinLabel))
        displayLink?.add(to: .current, forMode: .default)
        
        // Allocates lifespan to heart percentage
        if (penguinLifeLeft <= ((penguinLifeSpan / 3) * 3 )) && (penguinLifeLeft > (penguinLifeSpan / 2)) {
            animateHeart(atIndex: Int(2)) // Remove 3rd heart at <99% health
            playerLife = 2
        } else if (penguinLifeLeft <= (penguinLifeSpan / 3)) && (penguinLifeLeft > 0) {
            animateHeart(atIndex: Int(1)) // Remove 2nd heart at 33% health
            playerLife = 1
        } else if (penguinLifeLeft <= 0) {
            animateHeart(atIndex: Int(0)) // Remove 1st heart at 0% health
            playerLife = 0
            isDead = true; onDeath() // Call deathHandeler
        } else if (penguinLifeLeft >= (penguinLifeSpan / 3) * 2){
            // print("No Heart Decrease Needed") [ Debug Only ]
        }
    }
    
    // Grampus Score Handler
    func updateScoreG() {
        grampusLifeLeft -= ((Int(arc4random_uniform(5001)) + 5000)/15) // Choose random damage rate 
        
        // Label update for hoursLeft
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateGrampusLabel))
        displayLink?.add(to: .current, forMode: .default)
        
        // Allocates lifespan to heart percentage
        if (grampusLifeLeft <= ((grampusLifeSpan / 3) * 3 )) && (grampusLifeLeft > (grampusLifeSpan / 2)) {
            animateHeart(atIndex: Int(2)) // Remove 3rd heart at <99% health
            playerLife = 2
        } else if (grampusLifeLeft <= (grampusLifeSpan / 3)) && (grampusLifeLeft > 0) {
            animateHeart(atIndex: Int(1)) // Remove 2nd heart at 33% health
            playerLife = 1
        } else if (grampusLifeLeft <= 0) {
            animateHeart(atIndex: Int(0)) // Remove 1st heart at 0% health
            playerLife = 0
            isDead = true; onDeath() // Call deathHandeler
        } else if (grampusLifeLeft >= (grampusLifeSpan / 3) * 2){
            // print("No Heart Decrease Needed") [ Debug Only ]
        }
    }
    
    // Trash Hit Counter || More reliable with function call
    func trashHitCount() {
        trashHit += 1 // endScene Score
    }
    
    // Death Handeler || Hourse left <= 0
    func onDeath() {
        if (isDead == true) {
            addObstacles = false // Stop trash nodes 
            self.isUserInteractionEnabled = false // Stop user touch
            self.physicsBody = nil // Makes player fall off screen
            
            // Remove trashNode physics body
            for node in self.children {
                if node.name?.hasPrefix("trash") == true {
                    node.removeAllActions()
                    node.physicsBody?.affectedByGravity = false
                }
            }
            
            // Fade out to endScene
            let endSceneFade : SKAction = SKAction.wait(forDuration: 2)
            run(endSceneFade) {
                sceneType = "endScene"
                setupCurrentScene(view: self.view!)
            }
        }
    }
    
    // Smoothly animates the label for decreasing increments
    @objc func updatePenguinLabel() {
        if Int(penguinLifeleftLabel.text!)! > penguinLifeLeft {
            let newValue = Int(penguinLifeleftLabel.text!)! - 25
            penguinLifeleftLabel.text = "\(newValue)"
        } else {
            displayLink?.invalidate()
            displayLink = nil
            if penguinLifeLeft <= 0 {
                penguinLifeleftLabel.text = "0"
            } else {
                penguinLifeleftLabel.text = "\(penguinLifeLeft)"
            }
        }
    }
    
    // Smoothly animates the label for decreasing increments
    @objc func updateGrampusLabel() {
        if Int(grampusLifeleftLabel.text!)! > grampusLifeLeft {
            let newValue = Int(grampusLifeleftLabel.text!)! - 25
            grampusLifeleftLabel.text = "\(newValue)"
        } else {
            displayLink?.invalidate()
            displayLink = nil
            if grampusLifeLeft <= 0 {
                grampusLifeleftLabel.text = "0"
            } else {
                grampusLifeleftLabel.text = "\(grampusLifeLeft)"
            }
        }
    }
    
    // Heart Animation Update
    func animateHeart(atIndex index: Int) {
        let heart = hearts[index]
        let fadeOut = SKAction.fadeOut(withDuration: 0.25)
        let changeTexture = SKAction.run {
            heart.texture = SKTexture(imageNamed: "heartEmpty")
        }
        // Smoothly Fade Heart
        let fadeIn = SKAction.fadeIn(withDuration: 0.25)
        let sequence = SKAction.sequence([fadeOut, changeTexture, fadeIn])
        heart.run(sequence)
    }
}

// End Scene 
class endScene: SKScene, SKPhysicsContactDelegate {
    var score = 0
    let endScreenBackground = SKSpriteNode(color: colorScheme[1], size: CGSize(width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.height * 2))
    let mainText = SKLabelNode(fontNamed: "GillSans-UltraBold")
    let grave = SKSpriteNode(imageNamed: "graveEmoji")
    let highScoreLabel = SKLabelNode(fontNamed: "Futura-Medium")
    let trashAvoidedText = SKLabelNode(fontNamed: "Arial-Black")
    let trashHitText = SKLabelNode(fontNamed: "Arial-Black")
    let retryLabel = SKLabelNode(fontNamed: "Arial-Black")
    let creditsLabel = SKLabelNode(fontNamed: "Futura-Medium")
    
    override func didMove(to view: SKView) {
        setupEndScene()
    }
    
    func setupEndScene() {
        calculateHighScore()
        endScreenBackground.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(endScreenBackground)
        
        // Set up hill path
        let hillPath = UIBezierPath()
        hillPath.move(to: CGPoint(x: 0, y: 0))
        hillPath.addLine(to: CGPoint(x: size.width, y: 0))
        hillPath.addLine(to: CGPoint(x: size.width, y: size.height / 2))
        hillPath.addQuadCurve(to: CGPoint(x: 0, y: size.height / 2), controlPoint: CGPoint(x: size.width / 2, y: size.height))
        hillPath.close()
        
        // Create hillShape using path
        let hillShape = SKShapeNode(path: hillPath.cgPath)
        hillShape.fillColor = UIColor.brown
        hillShape.strokeColor = colorScheme[4]
        hillShape.lineWidth = 10
        hillShape.lineJoin = .round
        hillShape.position = CGPoint(x: 0, y: grave.position.y - 175)
        addChild(hillShape)
        
        // Grave Emoji
        grave.position = CGPoint(x: size.width / 2, y: ((size.height - (size.height / 4)) - ((size.height / 4) / 2)) + 25)
        grave.setScale(1.3)
        addChild(grave)
        
        // GameOver Label
        mainText.text = "Game Over"
        mainText.fontSize = 65
        mainText.fontColor = .white
        mainText.position = CGPoint(x: size.width/2, y: grave.position.y + 180)
        addChild(mainText)
        
        highScoreLabel.text = "High Score: \(highScore * 10)"
        highScoreLabel.fontSize = 20
        highScoreLabel.fontColor = .systemYellow
        highScoreLabel.position = CGPoint(x: mainText.position.x, y: mainText.position.y - 35)
        addChild(highScoreLabel)
        
        // Score Label [ Trash Hit ]
        trashHitText.text = "Trash Hit: \(trashHit / 2)" // Value doubled || BUG
        trashHitText.fontSize = 50
        trashHitText.fontColor = .white
        trashHitText.position = CGPoint(x: size.width/2, y: grave.position.y - 210)
        
        // Box [ Trash Hit ]
        let trashHitBox = SKShapeNode(rect: CGRect(x: -trashHitText.frame.width/2 - 103, y: -trashHitText.frame.height/2 - 30, width: trashHitText.frame.width + 223, height: trashHitText.frame.height + 60), cornerRadius: 20)
        trashHitBox.position = CGPoint(x: size.width/2, y: grave.position.y - 190)
        trashHitBox.fillColor = .systemRed
        trashHitBox.strokeColor = colorScheme[0]
        trashHitBox.lineWidth = 4
        addChild(trashHitBox)
        addChild(trashHitText)
        
        // Score Label [ Trash Avoided ]
        trashAvoidedText.text = "Trash Avoided: \(trashMissed)"
        trashAvoidedText.fontSize = 50
        trashAvoidedText.fontColor = .white
        trashAvoidedText.position = CGPoint(x: size.width/2, y: grave.position.y - 340)
        
        // Box [ Trash Avoided ]
        let trashAvoidedBox = SKShapeNode(rect: CGRect(x: -trashAvoidedText.frame.width/2 - 35, y: -trashAvoidedText.frame.height/2 - 30, width: trashAvoidedText.frame.width + 90, height: trashAvoidedText.frame.height + 60), cornerRadius: 20)
        trashAvoidedBox.position = CGPoint(x: size.width/2, y: grave.position.y - 320)
        trashAvoidedBox.fillColor = .systemGreen
        trashAvoidedBox.strokeColor = colorScheme[0]
        trashAvoidedBox.lineWidth = 4
        addChild(trashAvoidedBox)
        addChild(trashAvoidedText)
        
        // Retry Label 
        retryLabel.text = "Try Again"
        retryLabel.fontSize = 30
        retryLabel.fontColor = .white
        retryLabel.position = CGPoint(x: frame.midX, y: trashAvoidedBox.position.y - 157)
        retryLabel.name = "retryLabel"
        
        // Retry Box
        let retryBox = SKShapeNode(rect: CGRect(x: -retryLabel.frame.width/2 - 20, y: -retryLabel.frame.height/2 - 20, width: retryLabel.frame.width + 40, height: retryLabel.frame.height + 40), cornerRadius: 10)
        retryBox.position = CGPoint(x: frame.midX, y: trashAvoidedBox.position.y - 147)
        retryBox.fillColor = colorScheme[3]
        retryBox.strokeColor = colorScheme[0]
        retryBox.lineWidth = 4
        retryBox.name = "retryBox"
        addChild(retryBox)
        addChild(retryLabel)
        
        // Credits Label
        creditsLabel.text = "Artwork and music solely designed and composed by William Laverty"
        creditsLabel.fontSize = 18
        creditsLabel.fontColor = .white
        creditsLabel.position = CGPoint(x: frame.midX, y: frame.minY + 25)
        addChild(creditsLabel)
    } 
    
    func calculateHighScore() {
        // High Score Calulation
        score = (1000 - (trashHit * 5)) + (trashMissed * 10)
        if (score > highScore) {
            highScore = (score)
        }
        score = 0
    }
    
    // Check for game retry butoon
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            if (touchedNode.name == "retryLabel" || touchedNode.name == "retryBox") {
                sceneType = "restartScene"
                setupCurrentScene(view: self.view!)
            }
        }
    }
}

// Global SceneSwitcher
func setupCurrentScene(view: SKView) { 
    if (sceneType == "introScene") {
        // Present intro scene
        let introSceneDisplay = introScene(size: view.bounds.size)
        introSceneDisplay.scaleMode = .aspectFit
        view.presentScene(introSceneDisplay)
    } else if (sceneType == "instructionsScene") {
        // Present game scene
        let instructionsScreenSceneDisplay = instructionsScene(size: view.bounds.size)
        instructionsScreenSceneDisplay.scaleMode = .aspectFill
        view.presentScene(instructionsScreenSceneDisplay)
    } else if (sceneType == "gameScene") {
        // Present game scene
        let gameSceneDisplay = gameScene(size: view.bounds.size)
        gameSceneDisplay.scaleMode = .aspectFill
        view.presentScene(gameSceneDisplay, transition: SKTransition.fade(with: colorScheme[1], duration: 1))
    } else if (sceneType == "endScene") {
        // Present end scene
        let endSceneDisplay = endScene(size: view.bounds.size)
        endSceneDisplay.scaleMode = .aspectFill
        view.presentScene(endSceneDisplay, transition: SKTransition.fade(with: colorScheme[1], duration: 1))
    } else if (sceneType == "restartScene") {
        // Restart to instructions scene || FADE TRANSITION + RESET
        let restartSceneDisplay = instructionsScene(size: view.bounds.size)
        restartSceneDisplay.scaleMode = .aspectFill
        view.presentScene(restartSceneDisplay, transition: SKTransition.fade(with: colorScheme[1], duration: 1))
    }
    
}

// Creates instance of SKView and presents SKScenes
struct SpriteView: UIViewRepresentable {
    func makeUIView(context: Context) -> SKView {
        let view = SKView(frame: UIScreen.main.bounds)
        setupCurrentScene(view: view)
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
    }
}

// Initializes SpriteKitView
struct ContentView: View {
    var body: some View {
        SpriteView()
    }
}
