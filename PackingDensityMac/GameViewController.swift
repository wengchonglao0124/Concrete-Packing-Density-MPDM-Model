//
//  GameViewController.swift
//  PackingDensityMac
//
//  Created by Weng Chong LAO on 16/03/2023.
//
//  The University of Queensland
//  Faculty of Engineering, Architecture and Information Technology
//  Bachelor of Engineering (Honours)
//  Civil Engineering
//
//  CIVL4584 2023 Semester 1
//  Concrete Packing Density Experiment
//  Big Particles Dominated Case
//  Developer : Weng Chong LAO
//
// This project is my individual project that is developed for my thesis project in my civil engineering degree.
//
// MacOS Packing Density Model (MPDM) is a 3D computational model with a binary mixture of the larger particles and smaller particles,
// it is a model for predicting the packing density in the random particle packing. The MPDM is developed by implementing the game engine called “SceneKit” 
// in Swift programming language, the required operating system of the MPDM is the MacOS system. It can simulate the collision, rotation, friction and
// other physical movements of the particles due to gravity in the virtual environment, the simulation of the MPDM is much more accurate than the PPDM.
// Moreover, the MPDM is simulating the particle packing in the 3D environment which is close to the reality,
// while the PPDM can only simulate the 2D particle packing (disc packing).
//
// The environment of the MPDM is composed of a 3D rigid container with the transparent background, a binary mixture of the larger particles and
// smaller particles are generated randomly at the top of the rigid container. After a mixing process (vibration) and the particle settlement,
// the packing density of the system, number of larger particles and number of smaller particles can be measured as well as
// the volumetric fractions of either the larger particles or the smaller particles.


import Cocoa
import SceneKit
import Charts
import UniformTypeIdentifiers


/**
 Main view controller class which is used for the entire application
 */
class GameViewController: NSViewController, SCNSceneRendererDelegate, ChartViewDelegate {
    
    var scene: SCNScene!
    @IBOutlet var scnView: SCNView!
    var cameraNode = SCNNode()
    
    var containerSize: CGFloat = 10 // Default value: cannot be changed by user
    var containerThickness: CGFloat = 0.5 // Default value: cannot be changed by user
    
    var gravityAcceleration: Float = 9.81 // Default value: cannot be changed by user
    
    var numberOfBigParticleForSingleGeneration: Int = 10 // Default value: automatically be calculated according to the size ratio of container and big particles
    var numberOfSmallParticleForSingleGeneration: Int = 250 // Default value: automatically be calculated according to the size ratio of container and small particles
    
    var numberOfBigParticles: Int = 120 // Default value: cannot be changed by user; Note: will be modified depending on the expected volume of small particles
    var numberOfSmallParticles: Int = 6600 // Default value: cannot be changed by user; Note: will be modified depending on the expected volume of small particles
    
    var expectedVolumeOfSmallParticles: Float = 0.31 // Default value: can be changed by user; Note: 31%, range 0% to 55% for big particles dominated
    var calibrationFactor: Float = 0.68 // Default value: cannot be changed by user; Note: calibration factor for number of particle in 50% of the expected volume
    
    var containerBigParticleRatio: CGFloat = 5 // Default value: can be changed by user; Note: ratio for sphere is in its diameter
    var bigParticleSmallParticleRatio: CGFloat = 5 // Default value: can be changed by user; Note: ratio for sphere is in its diameter
    
    var particleRestitution: CGFloat = 0 // Default value: cannot be changed by user
    var particleFriction: CGFloat = 0.5 // Default value: cannot be changed by user
    
    var bigParticleMass: CGFloat = 1.0 // Default value: cannot be changed by user
    
    let removalErrorPercentage: Float = 0.02 // Default value: cannot be changed by user; Note: allow 2% error for particles outside the container
    
    var statusString: String = "Ready to start" // Default value: cannot be changed by user; Note: automatically be changed by system
    var experimentIndex: Int = 0 // Default value: cannot be changed by user; Note: automatically be changed by system
    var experimentResultData: [(packingDensity: Float, bigParticlesPercentage: Float, smallParticlesPercentage: Float, ratioOfContainerBigParticle: Float, ratioOfBigParticleSmallParticle: Float)] = [(Float, Float, Float, Float, Float)]() // Default value: cannot be changed by user; Note: automatically be changed by system
    
    var autoExperimentStatus = AutoExperimentStatus.empty // Default value: cannot be changed by user; Note: automatically be changed by system
    var autoExperimentStatusIndex: Int = 1 // Default value: cannot be changed by user; Note: automatically be changed by system
    var autoExperimentIsTerminated = false // Default value: cannot be changed by user; Note: automatically be changed by system
    
    var scatterChartSelectedIndex: Int = -1 // Default value: can be changed by user; Note: using "<" and ">" keys
    var scatterChartSelectedLayerIndex: Int = 0 // Default value: can be changed by user; Note: using "Q" keys
    
    var lastUpdateTime: TimeInterval? = nil // Default value: cannot be changed by user; Note: automatically be changed by system (in seconds)
    let updateInterval: TimeInterval = 1.0 // Default value: cannot be changed by user; Note: automatically be changed by system, set the desired time interval -> 1.0s
    
    // Accept first responder from key down
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    // Link the variables with the objects in the Main Storyboard ⬇️
    @IBOutlet weak var containerBigParticleRatioLabel: NSTextField!
    @IBOutlet weak var containerBigParticleRatioSlider: NSSlider!
    
    @IBOutlet weak var bigParticleSmallParticleRatioLabel: NSTextField!
    @IBOutlet weak var bigParticleSmallParticleRatioSlider: NSSlider!
    
    @IBOutlet weak var expectedVolumeOfSmallParticlesLabel: NSTextField!
    @IBOutlet weak var expectedVolumeOfSmallParticlesSlider: NSSlider!
    
    @IBOutlet weak var autoExperimentSwitch: NSSwitch!
    @IBOutlet weak var numberOfExperimentsPerCase: NSTextField!
    @IBOutlet weak var numberOfExperimentsPerCaseLabel: NSTextField!
    @IBOutlet weak var stepperForNumberOfExperimentsPerCase: NSStepper!
    @IBOutlet weak var experimentStep: NSTextField!
    @IBOutlet weak var experimentStepLabel: NSTextField!
    @IBOutlet weak var stepperForExperimentStep: NSStepper!
    @IBOutlet weak var autoExperimentTerminate: ClickableImageView!
    
    @IBOutlet weak var startExperimentButtonObject: NSButton!
    @IBOutlet weak var resetButton: NSButton!
    
    @IBOutlet weak var statusInformation: NSTextField!
    @IBOutlet weak var statusProgress: NSProgressIndicator!
    @IBOutlet weak var statusAvailable: NSImageView!
    @IBOutlet weak var statusRetry: ClickableImageView!
    
    @IBOutlet weak var displayResultSection: NSScrollView!
    @IBOutlet weak var clearResultButton: ClickableImageView!
    @IBOutlet weak var downloadResultButton: ClickableImageView!
    
    @IBOutlet weak var graphView: GraphSectionView!
    @IBOutlet weak var scatterChartViewSwitch: NSButton!
    @IBOutlet weak var scatterChartView: ScatterChartView!
    @IBOutlet weak var yAxisTitle: NSTextField!
    @IBOutlet weak var scatterChartDetailLabel: NSTextField!
    
    @IBOutlet weak var uploadResultButton: ClickableImageView!
    
    
    /**
    Update the ratio of container to big particles when the slider object in the Main Storyboard is active
     */
    @IBAction func changeContainerBigParticleRatio(_ sender: Any)    {
        self.containerBigParticleRatio = CGFloat(self.containerBigParticleRatioSlider.floatValue)
        self.containerBigParticleRatioLabel.stringValue = "\(Int(self.containerBigParticleRatio))"
        
        updateNumberOfBigParticleForSingleGeneration()
        updateNumberOfSmallParticleForSingleGeneration()
    }
    
    
    /**
    Update the ratio of big particles to small particles when the slider object in the Main Storyboard is active
     */
    @IBAction func changeBigParticleSmallParticleRatio(_ sender: Any) {
        self.bigParticleSmallParticleRatio = CGFloat(bigParticleSmallParticleRatioSlider.floatValue)
        self.bigParticleSmallParticleRatioLabel.stringValue = "\(Int(self.bigParticleSmallParticleRatio))"
        
        updateNumberOfSmallParticleForSingleGeneration()
    }
    
    
    /**
    Update the expected volume of the small particles when the slider object in the Main Storyboard is active
     */
    @IBAction func changeExpectedVolumeOfSmallParticles(_ sender: Any) {
        self.expectedVolumeOfSmallParticles = expectedVolumeOfSmallParticlesSlider.floatValue/100
        self.expectedVolumeOfSmallParticlesLabel.stringValue = String(format: "%.2f", self.expectedVolumeOfSmallParticles*100) + " %"
    }
    
    
    /**
     Update the automatic experiment status when the switch object in the Main Storyboard is toggled
     */
    @IBAction func autoExperimentSwitchClick(_ sender: Any) {
        updateAutoExperimentState()
    }
    
    
    /**
     Update the number of automatic experiments per case when the stepper object in the Main StoryBoard is active
     */
    @IBAction func stepperForNumberOfExperimentsPerCaseClick(_ sender: Any) {
        numberOfExperimentsPerCase.integerValue = stepperForNumberOfExperimentsPerCase.integerValue
    }
    
    
    /**
     Update the step amount of the automatic experiments when the stepper object in the Main StoryBoard is active
     */
    @IBAction func stepperForExperimentStepClick(_ sender: Any) {
        experimentStep.floatValue = stepperForExperimentStep.floatValue
    }
    
    
    /**
     Start the experiment when the button object in the Main StoryBoard is clicked
     */
    @IBAction func startExperimentButton(_ sender: Any) {
        updateNumberOfParticlesByExpectedVolume()
        disableControlSection()
        
        if autoExperimentSwitch.state == .on {
            autoExperimentStatus = .start
        }
        startExperiment()
    }
    
    
    /**
     Reset the experiment when the button object in the Main StoryBoard is clicked
     */
    @IBAction func resetButtonClick(_ sender: Any) {
        resetExperiment()
    }
    
    
    /**
     Clear all the experiment results from the display section when the button object in the Main StoryBoard is clicked
     */
    @IBAction func clearButtonClick(_ sender: Any) {
        clearAllResultFromDisplay()
    }
    
    
    /**
     Update the scatter chart status when the switch object in the Main StoryBoard is clicked
     */
    @IBAction func scatterChartViewSwitchClick(_ sender: Any) {
        if scatterChartViewSwitch.state == .on {
            // Pointing download -> turn off
            graphView.isHidden = true
        }
        else if scatterChartViewSwitch.state == .off {
            // Pointing upward -> turn on
            graphView.isHidden = false
        }
    }
    
    
    /**
     Reset the experiment to the original status
     */
    func resetExperiment() {
        enableControlSection()
        resetExperimentEnvironment()
        resetInputToDefaultValue()
        
        resetAutoExperiment()
        updateAutoExperimentState()
    }
    
    
    /**
     Re-do the experiment with the current settings
     */
    func retryExperiment() {
        disableControlSection()
        resetExperimentEnvironment()
        scene.rootNode.runAction(SCNAction.wait(duration: 1)) // Delay 1s
        startExperiment()
    }
    
    
    /**
     Set all the objects in the control section to active status
     */
    func enableControlSection() {
        containerBigParticleRatioSlider.isEnabled = true
        bigParticleSmallParticleRatioSlider.isEnabled = true
        expectedVolumeOfSmallParticlesSlider.isEnabled = true
        
        autoExperimentSwitch.isEnabled = true
        stepperForNumberOfExperimentsPerCase.isEnabled = true
        stepperForExperimentStep.isEnabled = true
        
        startExperimentButtonObject.isEnabled = true
        resetButton.isEnabled = true
    }
    
    
    /**
     Set all the objects in the control section to inactive status
     */
    func disableControlSection() {
        containerBigParticleRatioSlider.isEnabled = false
        bigParticleSmallParticleRatioSlider.isEnabled = false
        expectedVolumeOfSmallParticlesSlider.isEnabled = false
        
        autoExperimentSwitch.isEnabled = false
        stepperForNumberOfExperimentsPerCase.isEnabled = false
        stepperForExperimentStep.isEnabled = false
        
        startExperimentButtonObject.isEnabled = false
        resetButton.isEnabled = false
        clearResultButton.isHidden = true
        downloadResultButton.isHidden = true
        uploadResultButton.isHidden = true
    }
    
    
    /**
     Reset all the parameters to the default values
     */
    func resetInputToDefaultValue() {
        expectedVolumeOfSmallParticles = 0.31
        expectedVolumeOfSmallParticlesSlider.floatValue = expectedVolumeOfSmallParticles*100
        expectedVolumeOfSmallParticlesLabel.stringValue = String(format: "%.2f", expectedVolumeOfSmallParticles*100) + " %"
        
        containerBigParticleRatio = 5
        containerBigParticleRatioSlider.floatValue = Float(containerBigParticleRatio)
        containerBigParticleRatioLabel.stringValue = "\(Int(containerBigParticleRatio))"
        
        bigParticleSmallParticleRatio = 5
        bigParticleSmallParticleRatioSlider.floatValue = Float(bigParticleSmallParticleRatio)
        bigParticleSmallParticleRatioLabel.stringValue = "\(Int(self.bigParticleSmallParticleRatio))"
        
        updateNumberOfBigParticleForSingleGeneration()
        updateNumberOfSmallParticleForSingleGeneration()
    }
    
    
    /**
     Reset the experiment environment to the original status
     */
    func resetExperimentEnvironment() {
        scene.rootNode.enumerateChildNodes { (node, _) in
            if let geometry = node.geometry, geometry is SCNSphere {
                node.removeFromParentNode()
            }
        }
        resetStatus()
    }
    
    
    /**
     Reset the status labels
     */
    func resetStatus() {
        statusProgress.isHidden = true
        statusRetry.isHidden = true
        statusAvailable.isHidden = false
        
        statusString = "Ready to start"
        statusInformation.stringValue = statusString
        statusProgress.doubleValue = 0
    }
    
    
    /**
     Execute when the view appears, start of the application
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        scnView.isPlaying = true
        scnView.delegate = self
        
        // MARK: Create Container
        createContainer()
        
        setupAutoExperiment()
        
        setupImageClick()
        setupDisplayResultSection()
        
        setupChart()
    }
    
    
    override func viewWillAppear() {
        super.viewWillAppear()
        view.window?.makeFirstResponder(self)
    }
    
    
    /**
     Set the image as the clickable object
     */
    func setupImageClick() {
        statusRetry.onClick = { [weak self] in
            self?.retryExperiment()
        }
        
        clearResultButton.onClick = { [weak self] in
            self?.clearAllResultFromDisplay()
        }
        
        downloadResultButton.onClick = { [weak self] in
            self?.downloadAllResult()
        }
        
        graphView.onClick = { [weak self] in
            self?.clearScatterChartDataDetailLabel()
        }
        
        uploadResultButton.onClick = { [weak self] in
            self?.uploadResultData()
        }
        
        autoExperimentTerminate.onClick = { [weak self] in
            self?.terminateAutoExperiment()
        }
    }
    
    
    /**
     Setup the experiment environment
     */
    func setupScene() {
        scene = SCNScene()
        scnView.scene = scene
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 2, y: 5.2, z: 15)
        cameraNode.name = "camera"
        scene.rootNode.addChildNode(cameraNode)
        
        let gravity = SCNVector3(0, -gravityAcceleration, 0)
        scene.physicsWorld.gravity = gravity
    }
    
    
    /**
     Setup the automatic experiment
     */
    func setupAutoExperiment() {
        resetAutoExperiment()
        updateAutoExperimentState()
    }
    
    
    /**
     Reset the automatic experiment options to the default values
     */
    func resetAutoExperiment() {
        stepperForNumberOfExperimentsPerCase.integerValue = 2
        numberOfExperimentsPerCase.integerValue = stepperForNumberOfExperimentsPerCase.integerValue
        
        stepperForExperimentStep.floatValue = 1.0
        experimentStep.floatValue = stepperForExperimentStep.floatValue
        
        autoExperimentSwitch.state = .off
        autoExperimentStatus = .empty
        autoExperimentStatusIndex = 1
        autoExperimentTerminate.isHidden = true
        autoExperimentIsTerminated = false
    }
    
    
    /**
     Update the visibility of the automatic experiment options
     */
    func updateAutoExperimentState() {
        
        switch autoExperimentSwitch.state {
        case .off:
            numberOfExperimentsPerCase.isHidden = true
            numberOfExperimentsPerCaseLabel.isHidden = true
            stepperForNumberOfExperimentsPerCase.isHidden = true
            experimentStep.isHidden = true
            experimentStepLabel.isHidden = true
            stepperForExperimentStep.isHidden = true
            
        case .on:
            numberOfExperimentsPerCase.isHidden = false
            numberOfExperimentsPerCaseLabel.isHidden = false
            stepperForNumberOfExperimentsPerCase.isHidden = false
            experimentStep.isHidden = false
            experimentStepLabel.isHidden = false
            stepperForExperimentStep.isHidden = false
            
            expectedVolumeOfSmallParticles = 0.00
            expectedVolumeOfSmallParticlesSlider.floatValue = expectedVolumeOfSmallParticles*100
            expectedVolumeOfSmallParticlesLabel.stringValue = String(format: "%.2f", expectedVolumeOfSmallParticles*100) + " %"
            
        default:
            break
        }
    }
    
    
    /**
     Terminate the automatic experiment
     */
    func terminateAutoExperiment() {
        autoExperimentTerminate.isHidden = true
        autoExperimentIsTerminated = true
    }
    
    
    /**
     Setup the result display section of the application
     */
    func setupDisplayResultSection() {
        
        renewDocumentViewOfDisplayResultSection()
        displayResultSection.contentView.backgroundColor = NSColor(calibratedRed: 130/255, green: 130/255, blue: 130/255, alpha: 1)
        displayResultSection.contentView.drawsBackground = false
        
    
        if let documentView = displayResultSection.documentView {
            let maxY = documentView.frame.height - displayResultSection.contentSize.height
            displayResultSection.contentView.scroll(to: NSPoint(x: 0, y: maxY))
            displayResultSection.reflectScrolledClipView(displayResultSection.contentView)
        }
    }
    
    
    /**
     Update the contents of the result display section
     */
    func renewDocumentViewOfDisplayResultSection() {
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .leading
        
        displayResultSection.documentView = stackView
    }
    
    
    /**
     Start the experiment with the designed systematic procedures
     */
    func startExperiment() {
        var actions: [SCNAction] = []
        
        // MARK: Create Wall Slides for Particles
        actions.append(SCNAction.run({ _ in
            self.statusString = "Creating the wall slides..."
            self.createParticleSlides()
        }))
        actions.append(SCNAction.run({ _ in
            self.updateStatus()
        }))
        
        actions.append(SCNAction.wait(duration: 0.5)) // Delay 0.5s
        actions.append(SCNAction.run({ _ in
            self.updateStatus()
        }))
        
        
        // MARK: Generate Big Particles
        let numberOfLoopForBigParticles = Int((Float(numberOfBigParticles)/Float(numberOfBigParticleForSingleGeneration)).rounded(.up))
        
        actions.append(SCNAction.run({ _ in
            self.statusString = "Generating big particles..."
        }))
        actions.append(SCNAction.run({ _ in
            self.updateStatus()
        }))
        
        for _ in 1...numberOfLoopForBigParticles {
            let createAction = SCNAction.run { _ in
                self.generalBigParticlesRandomly()
            }
            
            actions.append(createAction)
            actions.append(SCNAction.run({ _ in
                self.updateStatus()
            }))
            
            let waitAction = SCNAction.wait(duration: 1) // Delay 1s
            actions.append(waitAction)
            actions.append(SCNAction.run({ _ in
                self.updateStatus()
            }))
        }
        
        actions.append(SCNAction.run({ _ in
            self.statusString = "Waiting particles to settle down..."
        }))
        actions.append(SCNAction.run({ _ in
            self.updateStatus()
        }))
        
        actions.append(SCNAction.wait(duration: 3)) // Delay 3s
        actions.append(SCNAction.run({ _ in
            self.updateStatus()
        }))
        
        
        // MARK: Elimination for Big Particles
        actions.append(SCNAction.run({ _ in
            self.statusString = "Eliminating big particles outside container..."
            self.removeParticlesOutsideContainer()
        }))
        actions.append(SCNAction.run({ _ in
            self.updateStatus()
        }))
        
        actions.append(SCNAction.run({ _ in
            self.statusString = "Waiting particles to settle down..."
        }))
        actions.append(SCNAction.run({ _ in
            self.updateStatus()
        }))
        
        actions.append(SCNAction.wait(duration: 1)) // Delay 1s
        actions.append(SCNAction.run({ _ in
            self.updateStatus()
        }))
        
        
        // MARK: Calculate Total Number of Loop For Small Particle Generation
        let numberOfLoopForSmallParticles = Int((Float(numberOfSmallParticles)/Float(numberOfSmallParticleForSingleGeneration)).rounded(.up))
        
        if numberOfLoopForSmallParticles > 0 {
            if numberOfLoopForSmallParticles/3 > 0 {
                
                // MARK: Generate Small Particles #1
                actions.append(SCNAction.run({ _ in
                    self.statusString = "Generating small particles #1..."
                }))
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                for _ in 1..<numberOfLoopForSmallParticles/3 {
                    let createAction = SCNAction.run { _ in
                        self.generalSmallParticlesRandomly()
                    }
                    actions.append(createAction)
                    actions.append(SCNAction.run({ _ in
                        self.updateStatus()
                    }))
                    
                    let waitAction = SCNAction.wait(duration: 0.5) // Delay 0.5s
                    actions.append(waitAction)
                    actions.append(SCNAction.run({ _ in
                        self.updateStatus()
                    }))
                }
                actions.append(SCNAction.run({ _ in
                    self.statusString = "Waiting particles to settle down..."
                }))
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                actions.append(SCNAction.wait(duration: 1)) // Delay 1s
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                
                // MARK: Calculate Vibration Order For Particles In Range Of Y Direction
                let vibrationOrderForRangeInY = [(containerSize*2/3, containerSize*1.1), (containerSize/3, containerSize*2/3), (0, containerSize/3)]
                
                
                // MARK: Vibration #1
                actions.append(SCNAction.run({ _ in
                    self.statusString = "Applying vibration #1..."
                }))
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                for vibrationRange in vibrationOrderForRangeInY {
                    actions.append(SCNAction.run({ _ in
                        self.applyVibration(minY: vibrationRange.0, maxY: vibrationRange.1)
                    }))
                    actions.append(SCNAction.run({ _ in
                        self.updateStatus()
                    }))
                    
                    actions.append(SCNAction.wait(duration: 0.15)) // Delay 0.15s
                    actions.append(SCNAction.run({ _ in
                        self.updateStatus()
                    }))
                }
                actions.append(SCNAction.run({ _ in
                    self.statusString = "Waiting particles to settle down..."
                }))
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                actions.append(SCNAction.wait(duration: 10)) // Delay 10s
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                
                // MARK: Generate Small Particles #2
                actions.append(SCNAction.run({ _ in
                    self.statusString = "Generating small particles #2..."
                }))
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                for _ in numberOfLoopForSmallParticles/3..<numberOfLoopForSmallParticles*2/3 {
                    let createAction = SCNAction.run { _ in
                        self.generalSmallParticlesRandomly()
                    }
                    actions.append(createAction)
                    actions.append(SCNAction.run({ _ in
                        self.updateStatus()
                    }))
                    
                    let waitAction = SCNAction.wait(duration: 0.5) // Delay 0.5s
                    actions.append(waitAction)
                    actions.append(SCNAction.run({ _ in
                        self.updateStatus()
                    }))
                }
                
                
                // MARK: Vibration #2
                actions.append(SCNAction.run({ _ in
                    self.statusString = "Applying vibration #2..."
                }))
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                for vibrationRange in vibrationOrderForRangeInY {
                    actions.append(SCNAction.run({ _ in
                        self.applyVibration(minY: vibrationRange.0, maxY: vibrationRange.1)
                    }))
                    actions.append(SCNAction.run({ _ in
                        self.updateStatus()
                    }))
        
                    actions.append(SCNAction.wait(duration: 0.15)) // Delay 0.15s
                    actions.append(SCNAction.run({ _ in
                        self.updateStatus()
                    }))
                }
                actions.append(SCNAction.run({ _ in
                    self.statusString = "Waiting particles to settle down..."
                }))
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                actions.append(SCNAction.wait(duration: 10)) // Delay 10s
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                
                // MARK: Generate Small Particles #3
                actions.append(SCNAction.run({ _ in
                    self.statusString = "Generating small particles #3..."
                }))
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                for _ in numberOfLoopForSmallParticles*2/3...numberOfLoopForSmallParticles {
                    let createAction = SCNAction.run { _ in
                        self.generalSmallParticlesRandomly()
                    }
                    actions.append(createAction)
                    actions.append(SCNAction.run({ _ in
                        self.updateStatus()
                    }))
                    
                    let waitAction = SCNAction.wait(duration: 0.5) // Delay 0.5s
                    actions.append(waitAction)
                    actions.append(SCNAction.run({ _ in
                        self.updateStatus()
                    }))
                }
                actions.append(SCNAction.run({ _ in
                    self.statusString = "Waiting particles to settle down..."
                }))
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                actions.append(SCNAction.wait(duration: 2)) // Delay 2s
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                
                // MARK: Vibration #3
                actions.append(SCNAction.run({ _ in
                    self.statusString = "Applying vibration #3..."
                }))
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                for vibrationRange in vibrationOrderForRangeInY {
                    actions.append(SCNAction.run({ _ in
                        self.applyVibration(minY: vibrationRange.0, maxY: vibrationRange.1)
                    }))
                    actions.append(SCNAction.run({ _ in
                        self.updateStatus()
                    }))
                    
                    actions.append(SCNAction.wait(duration: 0.15)) // Delay 0.15s
                    actions.append(SCNAction.run({ _ in
                        self.updateStatus()
                    }))
                }
                actions.append(SCNAction.run({ _ in
                    self.statusString = "Waiting particles to settle down..."
                }))
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                actions.append(SCNAction.wait(duration: 15)) // Delay 15s
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                
                // MARK: Elimination for Small Particles #1
                actions.append(SCNAction.run({ _ in
                    self.statusString = "Eliminating small particles outside container #1..."
                    self.removeParticlesOutsideContainer()
                }))
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                actions.append(SCNAction.run({ _ in
                    self.statusString = "Waiting particles to settle down..."
                }))
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                actions.append(SCNAction.wait(duration: 1)) // Delay 1s
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                
                if numberOfLoopForSmallParticles/6 > 0 {
                    
                    // MARK: Generate Small Particles For Fill
                    actions.append(SCNAction.run({ _ in
                        self.statusString = "Generating small particles for fill..."
                    }))
                    actions.append(SCNAction.run({ _ in
                        self.updateStatus()
                    }))
                    
                    for _ in 1...numberOfLoopForSmallParticles/6 {
                        let createAction = SCNAction.run { _ in
                            self.generalSmallParticlesRandomly()
                        }
                        actions.append(createAction)
                        actions.append(SCNAction.run({ _ in
                            self.updateStatus()
                        }))
                        
                        let waitAction = SCNAction.wait(duration: 0.5) // Delay 0.5s
                        actions.append(waitAction)
                        actions.append(SCNAction.run({ _ in
                            self.updateStatus()
                        }))
                    }
                    actions.append(SCNAction.run({ _ in
                        self.statusString = "Waiting particles to settle down..."
                    }))
                    actions.append(SCNAction.run({ _ in
                        self.updateStatus()
                    }))
                    
                    actions.append(SCNAction.wait(duration: 10)) // Delay 10s
                    actions.append(SCNAction.run({ _ in
                        self.updateStatus()
                    }))
                    
                    
                    // MARK: Elimination for Small Particles #2
                    actions.append(SCNAction.run({ _ in
                        self.statusString = "Eliminating small particles outside container #2..."
                    }))
                    actions.append(SCNAction.run({ _ in
                        self.updateStatus()
                    }))
                    
                    actions.append(SCNAction.run({ _ in
                        self.removeParticlesOutsideContainer()
                    }))
                    actions.append(SCNAction.run({ _ in
                        self.updateStatus()
                    }))
                    
                    actions.append(SCNAction.run({ _ in
                        self.statusString = "Waiting particles to settle down..."
                    }))
                    actions.append(SCNAction.run({ _ in
                        self.updateStatus()
                    }))
                    
                    actions.append(SCNAction.wait(duration: 5)) // Delay 5s
                    actions.append(SCNAction.run({ _ in
                        self.updateStatus()
                    }))
                }
            }
            else {
                
                // MARK: Generate Small Particles #X
                actions.append(SCNAction.run({ _ in
                    self.statusString = "Generating small particles..."
                }))
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                for _ in 1..<numberOfLoopForSmallParticles {
                    let createAction = SCNAction.run { _ in
                        self.generalSmallParticlesRandomly()
                    }
                    actions.append(createAction)
                    actions.append(SCNAction.run({ _ in
                        self.updateStatus()
                    }))
                    
                    let waitAction = SCNAction.wait(duration: 0.5) // Delay 0.5s
                    actions.append(waitAction)
                    actions.append(SCNAction.run({ _ in
                        self.updateStatus()
                    }))
                }
                actions.append(SCNAction.run({ _ in
                    self.statusString = "Waiting particles to settle down..."
                }))
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                actions.append(SCNAction.wait(duration: 1)) // Delay 1s
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                
                // MARK: Elimination for Small Particles #X
                actions.append(SCNAction.run({ _ in
                    self.statusString = "Eliminating small particles outside container..."
                }))
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                actions.append(SCNAction.run({ _ in
                    self.removeParticlesOutsideContainer()
                }))
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                actions.append(SCNAction.run({ _ in
                    self.statusString = "Waiting particles to settle down..."
                }))
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                actions.append(SCNAction.wait(duration: 1)) // Delay 1s
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
            }
        }
        else {
            
            // MARK: Generate Big Particles For Fill
            actions.append(SCNAction.run({ _ in
                self.statusString = "Generating big particles..."
            }))
            actions.append(SCNAction.run({ _ in
                self.updateStatus()
            }))
            
            for _ in 1...Int((Float(numberOfLoopForBigParticles)*0.15).rounded(.up)) {
                let createAction = SCNAction.run { _ in
                    self.generalBigParticlesRandomly()
                }
                
                actions.append(createAction)
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
                
                let waitAction = SCNAction.wait(duration: 1) // Delay 1s
                actions.append(waitAction)
                actions.append(SCNAction.run({ _ in
                    self.updateStatus()
                }))
            }
            
            actions.append(SCNAction.run({ _ in
                self.statusString = "Waiting particles to settle down..."
            }))
            actions.append(SCNAction.run({ _ in
                self.updateStatus()
            }))
            
            actions.append(SCNAction.wait(duration: 3)) // Delay 3s
            actions.append(SCNAction.run({ _ in
                self.updateStatus()
            }))
            
            // MARK: Elimination for Big Particles #X
            actions.append(SCNAction.run({ _ in
                self.statusString = "Eliminating big particles outside container..."
            }))
            actions.append(SCNAction.run({ _ in
                self.updateStatus()
            }))
            
            actions.append(SCNAction.run({ _ in
                self.removeParticlesOutsideContainer()
            }))
            actions.append(SCNAction.run({ _ in
                self.updateStatus()
            }))
            
            actions.append(SCNAction.run({ _ in
                self.statusString = "Waiting particles to settle down..."
            }))
            actions.append(SCNAction.run({ _ in
                self.updateStatus()
            }))
            
            actions.append(SCNAction.wait(duration: 2)) // Delay 2s
            actions.append(SCNAction.run({ _ in
                self.updateStatus()
            }))
        }
        
        // MARK: Remove Wall Slides
        actions.append(SCNAction.run({ _ in
            self.statusString = "Removing the wall slides..."
        }))
        actions.append(SCNAction.run({ _ in
            self.updateStatus()
        }))
        
        actions.append(SCNAction.run({ _ in
            self.removeParticleSlides()
        }))
        actions.append(SCNAction.run({ _ in
            self.updateStatus()
        }))
        
        
        // MARK: Display Result
        actions.append(SCNAction.run({ _ in
            self.statusString = "Displaying results..."
        }))
        actions.append(SCNAction.run({ _ in
            self.updateStatus()
        }))
        
        actions.append(SCNAction.run({ _ in
            self.displayResult()
        }))
        actions.append(SCNAction.run({ _ in
            self.updateStatus()
        }))
        
        actions.append(SCNAction.run({ _ in
            self.statusString = "Finished experiment"
        }))
        actions.append(SCNAction.run({ _ in
            self.updateStatus()
        }))
        
        // Calculate the total status progress
        statusProgress.maxValue = Double(actions.count/2)
        
        let sequenceAction = SCNAction.sequence(actions)
        scene.rootNode.runAction(sequenceAction)
    }
    
    
    /**
     Generate the rigid container for the experiment
     */
    func createContainer() {
        let containerGeometry = SCNBox(width: (containerSize + 2*containerThickness), height: containerThickness, length: (containerSize + 2*containerThickness), chamferRadius: 0)
        let containerNode = SCNNode(geometry: containerGeometry)
        containerNode.position = SCNVector3(0, -containerThickness/2, 0)
        containerNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        containerNode.name = "containerFloor"
        scene.rootNode.addChildNode(containerNode)
        
        let wallNodes = [
            createWall(length: containerThickness, width: (containerSize + containerThickness), height: containerSize, position: SCNVector3(0, containerSize/2, -(containerSize+containerThickness)/2)),
            createWall(length: containerThickness, width: (containerSize + containerThickness), height: containerSize, position: SCNVector3(0, containerSize/2, (containerSize+containerThickness)/2)),
            createWall(length: (containerSize + containerThickness), width: containerThickness, height: containerSize, position: SCNVector3((containerSize+containerThickness)/2, containerSize/2, 0)),
            createWall(length: (containerSize + containerThickness), width: containerThickness, height: containerSize, position: SCNVector3(-(containerSize+containerThickness)/2, containerSize/2, 0))
        ]
        
        wallNodes.forEach { scene.rootNode.addChildNode($0) }
    }
    

    /**
     Generate the wall for the container
     */
    func createWall(length: CGFloat, width: CGFloat, height: CGFloat, position: SCNVector3) -> SCNNode {
        let wallGeometry = SCNBox(width: width, height: height, length: length, chamferRadius: 0)
        
        // Create a transparent material
        let transparentMaterial = SCNMaterial()
        transparentMaterial.diffuse.contents = NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
        
        // Apply the transparent material to all sides of the wallGeometry
        wallGeometry.materials = [transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial]
        
        let wallNode = SCNNode(geometry: wallGeometry)
        wallNode.position = position
        wallNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        wallNode.name = "containerWall"
        
        return wallNode
    }
    
    
    /**
     Generate the sliding wall for the container
     */
    func createSlide(length: CGFloat, width: CGFloat, height: CGFloat, position: SCNVector3, rotation: Float, rotationDirection: String) -> SCNNode {
        let wallGeometry = SCNBox(width: width, height: height, length: length, chamferRadius: 0)
        
        // Create a transparent material
        let transparentMaterial = SCNMaterial()
        transparentMaterial.diffuse.contents = NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.1)
        
        // Apply the transparent material to all sides of the wallGeometry
        wallGeometry.materials = [transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial]
        
        let wallNode = SCNNode(geometry: wallGeometry)
        wallNode.position = position
        wallNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        wallNode.name = "containerWallSlide"
        
        if rotationDirection == "x" {
            // Rotate the wall around the x-axis
            wallNode.eulerAngles.x = CGFloat(rotation)
        }
        else if rotationDirection == "z" {
            wallNode.eulerAngles.z = CGFloat(rotation)
        }
        
        return wallNode
    }
    
    
    /**
     Generate the sliding walls for the container to prevent the particles overflow outside the container
     */
    func createParticleSlides() {
        let wallSlides = [
            createSlide(length: containerSize, width: containerSize, height: containerThickness, position: SCNVector3(0, containerSize+sin(CGFloat.pi/3)*containerSize/2, -containerSize/2*(1+cos(CGFloat.pi/3))-containerThickness), rotation: Float.pi/3, rotationDirection: "x"),
            createSlide(length: containerSize, width: containerSize, height: containerThickness, position: SCNVector3(0, containerSize+sin(CGFloat.pi/3)*containerSize/2, containerSize/2*(1+cos(CGFloat.pi/3))+containerThickness), rotation: -Float.pi/3, rotationDirection: "x"),
            createSlide(length: containerSize, width: containerSize, height: containerThickness, position: SCNVector3(-containerSize/2*(1+cos(CGFloat.pi/3))-containerThickness, containerSize+sin(CGFloat.pi/3)*containerSize/2, 0), rotation: -Float.pi/3, rotationDirection: "z"),
            createSlide(length: containerSize, width: containerSize, height: containerThickness, position: SCNVector3(containerSize/2*(1+cos(CGFloat.pi/3))+containerThickness, containerSize+sin(CGFloat.pi/3)*containerSize/2, 0), rotation: Float.pi/3, rotationDirection: "z")
        ]
        
        wallSlides.forEach { scene.rootNode.addChildNode($0) }
    }
    
    
    /**
     Remove the sliding walls for the container
     */
    func removeParticleSlides() {
        scene.rootNode.enumerateChildNodes { (node, _) in
            if let geometry = node.geometry, geometry is SCNBox {
                if node.name == "containerWallSlide" {
                    node.removeFromParentNode()
                }
            }
        }
    }
    
    
    /**
     Return the radius of the big particles
     */
    func getBigParticleRadius() -> CGFloat {
        return (containerSize/containerBigParticleRatio)/2
    }
    
    
    /**
     Return the radius of the small particles
     */
    func getSmallParticleRadius() -> CGFloat {
        return ((containerSize/containerBigParticleRatio)/2)/bigParticleSmallParticleRatio
    }
    
    
    /**
     Update the amount of big particles to be generated at once
     */
    func updateNumberOfBigParticleForSingleGeneration() {
        numberOfBigParticleForSingleGeneration = Int((pow(containerBigParticleRatio, 2)*0.4).rounded(.up))
    }
    
    
    /**
     Update the amount of small particles to be generated at once
     */
    func updateNumberOfSmallParticleForSingleGeneration() {
        numberOfSmallParticleForSingleGeneration = Int((pow(containerBigParticleRatio*bigParticleSmallParticleRatio, 2)*0.4).rounded(.up))
    }
    
    
    /**
     Update and calculate the total amount of big and small particles to be generated
     */
    func updateNumberOfParticlesByExpectedVolume() {
        let modifiedFactor: Float = 0.96
        
        if expectedVolumeOfSmallParticles >= 0.31 {
            numberOfBigParticles = Int(modifiedFactor*calibrationFactor*Float(pow(containerBigParticleRatio, 3))*(1-expectedVolumeOfSmallParticles)/0.5)
            numberOfSmallParticles = Int(Float(numberOfBigParticles)*Float(pow(bigParticleSmallParticleRatio, 3))/(1/expectedVolumeOfSmallParticles-1))
            //Int(1.1*calibrationFactor*Float(pow(containerBigParticleRatio*bigParticleSmallParticleRatio, 3))*expectedVolumeOfSmallParticles/0.5)
        }
        else {
            numberOfBigParticles = Int(modifiedFactor*Float(pow(containerBigParticleRatio, 3)))
            numberOfSmallParticles = Int(Float(numberOfBigParticles)*Float(pow(bigParticleSmallParticleRatio, 3))/(1/expectedVolumeOfSmallParticles-1))
        }
    }
  
    
    /**
     Update and display the experiment status in the application
     */
    func updateStatus() {
        DispatchQueue.main.async {
            // At the beginning of the experiment
            if self.statusProgress.isHidden {
                self.experimentIndex += 1
                self.statusAvailable.isHidden = true
                self.statusProgress.isHidden.toggle()
            }
            
            // During the experiment
            self.statusInformation.stringValue = self.statusString
            self.statusProgress.doubleValue += 1
            
            // At the end of the experiment
            if self.statusProgress.doubleValue >= self.statusProgress.maxValue {
                self.statusProgress.isHidden = true
                self.statusRetry.isHidden = false
                self.resetButton.isEnabled = true
                
                self.updateExperimentDataSection()
                
                if self.autoExperimentSwitch.state == .on {
                    self.autoExperimentStatus = .end
                }
            }
        }
    }
    
    
    /**
     Update and display the experiment results in the application
     */
    func updateExperimentDataSection() {
        if !self.experimentResultData.isEmpty {
            self.clearResultButton.isHidden = false
            self.downloadResultButton.isHidden = false
            
            self.updateScatterChartData()
            if self.scatterChartViewSwitch.isHidden {
                self.scatterChartViewSwitch.isHidden = false
            }
        }
    }
    
    
    /**
     Randomly generate the big particles in the container
     */
    func generalBigParticlesRandomly() {
        let range: Float = Float(containerSize/2)
        
        for _ in 1...numberOfBigParticleForSingleGeneration {
            let position = SCNVector3(Float.random(in: -range...range), Float(containerSize+getBigParticleRadius()), Float.random(in: -range...range))
            let sphereNode = createBigParticle(at: position)
            
            scene.rootNode.addChildNode(sphereNode)
        }
    }
    
    
    /**
     Generate a big particle at a position
     */
    func createBigParticle(at position: SCNVector3) -> SCNNode {
        let bigParticleRadius = getBigParticleRadius()
        let sphereGeometry = SCNSphere(radius: bigParticleRadius)
        let sphereNode = SCNNode(geometry: sphereGeometry)
        sphereNode.position = position
        sphereNode.name = "bigParticle"
        
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        physicsBody.mass = bigParticleMass
        physicsBody.restitution = particleRestitution
        physicsBody.friction = particleFriction
        sphereNode.physicsBody = physicsBody
        
        return sphereNode
    }
    
    
    /**
     Randomly generate the small particles in the container
     */
    func generalSmallParticlesRandomly() {
        let range: Float = Float(containerSize/2)
        
        for _ in 1...numberOfSmallParticleForSingleGeneration {
            let position = SCNVector3(Float.random(in: -range...range), Float(containerSize+getSmallParticleRadius()), Float.random(in: -range...range))
            let sphereNode = createSmallParticle(at: position)
            
            scene.rootNode.addChildNode(sphereNode)
        }
    }
    
    
    /**
     Generate a small particle at a position
     */
    func createSmallParticle(at position: SCNVector3) -> SCNNode {
        let smallParticleRadius = getSmallParticleRadius()
        let sphereGeometry = SCNSphere(radius: smallParticleRadius)
        let sphereNode = SCNNode(geometry: sphereGeometry)
        sphereNode.position = position
        sphereNode.name = "smallParticle"
        
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        physicsBody.mass = getSmallParticleMass()
        physicsBody.restitution = particleRestitution
        physicsBody.friction = particleFriction
        sphereNode.physicsBody = physicsBody
        
        return sphereNode
    }
    
    
    /**
     Eliminate all the particles which are outside the container
     */
    func removeParticlesOutsideContainer() {
        let error: CGFloat = 1+CGFloat(removalErrorPercentage)
        let containerMinBound = SCNVector3(-containerSize*error/2, -containerThickness*error, -containerSize*error/2)
        let containerMaxBound = SCNVector3(containerSize*error/2, containerSize*error, containerSize*error/2)
        
        scene.rootNode.enumerateChildNodes { (node, _) in
            if let geometry = node.geometry, geometry is SCNSphere {
                
                var radius: CGFloat = 0
                if node.name == "bigParticle" {
                    radius = getBigParticleRadius()
                }
                else if node.name == "smallParticle" {
                    radius = getSmallParticleRadius()
                }
                
                let position = node.presentation.position
                
                if position.x-radius < containerMinBound.x || position.x+radius > containerMaxBound.x ||
                    position.y-radius < containerMinBound.y || position.y+radius > containerMaxBound.y ||
                    position.z-radius < containerMinBound.z || position.z+radius > containerMaxBound.z {
                    node.removeFromParentNode()
                }
            }
        }
    }
    
    
    /**
     Calculate the number of big particles inside the container
     */
    func countBigParticles() -> Float {
        var count: Float = 0
        
        scene.rootNode.enumerateChildNodes { (node, _) in
            if let geometry = node.geometry, geometry is SCNSphere {
                if node.name == "bigParticle" {
                    count += 1
                }
            }
        }
        return count
    }
    
    
    /**
     Calculate the number of small particles inside the container
     */
    func countSmallParticles() -> Float {
        var count: Float = 0
        
        scene.rootNode.enumerateChildNodes { (node, _) in
            if let geometry = node.geometry, geometry is SCNSphere {
                if node.name == "smallParticle" {
                    count += 1
                }
            }
        }
        return count
    }
    
    
    /**
     Return and calculate the mass of small particles
     */
    func getSmallParticleMass() -> CGFloat {
        // Assuming the density of big particles is same as the density of small particles
        // Formula is density = mass/volume
        return pow(getSmallParticleRadius()/getBigParticleRadius(), 3)*bigParticleMass
    }
    
    
    /**
     Return and calculate the packing density of the system
     */
    func calculatePackingDensity() -> Float {
        let containerVolume: Float = pow(Float(containerSize), 3)
        let totalBigParticleVolume: Float = calculateTotalBigParticleVolume()
        let totalSmallParticleVolume: Float = calculateTotalSmallParticleVolume()
        
        let packingDensity: Float = (totalBigParticleVolume+totalSmallParticleVolume)/containerVolume
        return packingDensity
    }
    
    
    /**
     Return and calculate the total volume of the big particles inside the container
     */
    func calculateTotalBigParticleVolume() -> Float {
        let bigParticleRadius = Float(getBigParticleRadius())
        let bigParticleVolume: Float = (4/3)*(Float.pi*pow(bigParticleRadius, 3))
        let totalBigParticleVolume: Float = countBigParticles()*bigParticleVolume
        
        return totalBigParticleVolume
    }
    
    
    /**
     Return and calculate the total volume of the small particles inside the container
     */
    func calculateTotalSmallParticleVolume() -> Float {
        let smallParticleRadius = Float(getSmallParticleRadius())
        let smallParticleVolume: Float = (4/3)*(Float.pi*pow(smallParticleRadius, 3))
        let totalSmallParticleVolume: Float = countSmallParticles()*smallParticleVolume
        
        return totalSmallParticleVolume
    }
    
    
    /**
     Return and calculate the volumetric percentage of the big particles in the system
     */
    func calculateBigParticlePercentage() -> Float {
        return calculateTotalBigParticleVolume()/(calculateTotalBigParticleVolume()+calculateTotalSmallParticleVolume())
    }
    
    
    /**
     Return and calculate the volumetric percentage of the small particles in the system
     */
    func calculateSmallParticlePercentage() -> Float {
        return calculateTotalSmallParticleVolume()/(calculateTotalBigParticleVolume()+calculateTotalSmallParticleVolume())
    }
    
    
    /**
     Apply the vibrational force to all particles inside the container
     */
    func applyVibration(minY: CGFloat, maxY: CGFloat) {
        let forceMagnitudeOfBigParticle = bigParticleMass*7
        let forceMagnitudeOfSmallParticle = getSmallParticleMass()*7
        
        scene.rootNode.enumerateChildNodes { (node, _) in
            if let geometry = node.geometry, geometry is SCNSphere {
                
                let position = node.presentation.position
                if position.y >= minY && position.y <= maxY {
                    
                    if node.name == "bigParticle" {
                        // Apply force on the big particle
                        let forceVector = SCNVector3(0, forceMagnitudeOfBigParticle, 0)
                        let asImpulse = true // Set whether the force should be applied as an impulse
                        node.physicsBody?.applyForce(forceVector, asImpulse: asImpulse)
                    }
                    else if node.name == "smallParticle" {
                        // Apply force on the sphere
                        let forceVector = SCNVector3(0, forceMagnitudeOfSmallParticle, 0)
                        let asImpulse = true // Set whether the force should be applied as an impulse
                        node.physicsBody?.applyForce(forceVector, asImpulse: asImpulse)
                    }
                }
            }
        }
    }
    
    
    /**
     Format and display the experiment result to the result section
     */
    func displayResult() {
        DispatchQueue.main.async {
            
            let packingDensity = Float(String(format: "%.4f", self.calculatePackingDensity()*0.92))! // Need to be modified
            let bigParticlePercentage = Float(String(format: "%.2f", self.calculateBigParticlePercentage()*100))!
            let smallParticlePercentage = Float(String(format: "%.2f", self.calculateSmallParticlePercentage()*100))!
            
            self.saveAndPrintResultToDisplay(packingDensity: packingDensity, bigParticlePercentage: bigParticlePercentage, smallParticlePercentage: smallParticlePercentage, ratioOfContainerBigParticle: Int(self.containerBigParticleRatio), ratioOfBigParticleSmallParticle: Int(self.bigParticleSmallParticleRatio))
        }
    }
    
    
    /**
     Save the experiment result data and display in the application
     */
    func saveAndPrintResultToDisplay(packingDensity: Float, bigParticlePercentage: Float, smallParticlePercentage: Float, ratioOfContainerBigParticle: Int, ratioOfBigParticleSmallParticle: Int) {
        
        self.experimentResultData.append((packingDensity, bigParticlePercentage, smallParticlePercentage, Float(ratioOfContainerBigParticle), Float(ratioOfBigParticleSmallParticle)))
        
        let displayResultView = self.displayResultSection.documentView as! NSStackView
        
        let spaceLabelTop = NSTextField(labelWithString: "     ")
        spaceLabelTop.alignment = .center
        displayResultView.addArrangedSubview(spaceLabelTop)
        
        let titleLabel = NSTextField(labelWithString: "    Experiment Result #\(self.experimentIndex) {")
        titleLabel.alignment = .center
        displayResultView.addArrangedSubview(titleLabel)
        
        let packingDensityLabel = NSTextField(labelWithString: "        Packing Density: " + String(format: "%.4f", packingDensity))
        packingDensityLabel.alignment = .center
        displayResultView.addArrangedSubview(packingDensityLabel)
        
        let bigParticleLabel = NSTextField(labelWithString: "        Big Particle: \(bigParticlePercentage) %")
        bigParticleLabel.alignment = .center
        displayResultView.addArrangedSubview(bigParticleLabel)
        
        let smallParticleLabel = NSTextField(labelWithString: "        Small Particle: \(smallParticlePercentage) %")
        smallParticleLabel.alignment = .center
        displayResultView.addArrangedSubview(smallParticleLabel)
        
        let ratioInfoLabel = NSTextField(labelWithString: "        @ C:B = 1:\(ratioOfContainerBigParticle) & B:S = 1:\(ratioOfBigParticleSmallParticle)")
        ratioInfoLabel.alignment = .center
        displayResultView.addArrangedSubview(ratioInfoLabel)
        
        let closeBracketLabel = NSTextField(labelWithString: "    }")
        closeBracketLabel.alignment = .center
        displayResultView.addArrangedSubview(closeBracketLabel)
    }
    
    
    /**
     Clear all the contents in the result display section
     */
    func clearAllResultFromDisplay() {
        experimentResultData = [(Float, Float, Float, Float, Float)]()
        experimentIndex = 0
        clearResultButton.isHidden = true
        downloadResultButton.isHidden = true
        renewDocumentViewOfDisplayResultSection()
        
        uploadResultButton.isHidden = false
        
        graphView.isHidden = true
        scatterChartViewSwitch.state = .on
        scatterChartViewSwitch.isHidden = true
        
        scatterChartSelectedIndex = -1
        scatterChartSelectedLayerIndex = 0
    }
    
    
    /**
     Download all the experiment results
     */
    func downloadAllResult() {
        saveDataToCSVFile(data: experimentResultData)
    }
    

    /**
     Save all the experiment result data to the .csv file for further analysis
     */
    func saveDataToCSVFile(data: [(packingDensity: Float, bigParticlesPercentage: Float, smallParticlesPercentage: Float, ratioOfContainerBigParticle: Float, ratioOfBigParticleSmallParticle: Float)]) {
        
        let savePanel = NSSavePanel()
        savePanel.nameFieldStringValue = "Packing_Density.csv"
        //savePanel.allowedFileTypes = ["csv"]
        savePanel.allowsOtherFileTypes = false
        savePanel.canCreateDirectories = true
        
        // Set the default save location to the Downloads folder
        let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        if let downloadsURL = downloadsURL {
            savePanel.directoryURL = downloadsURL
        }
        
        // Block the rest of the app, and users will need to respond to the save panel (either by choosing a location or by canceling) before they can interact with the app again
        let response = savePanel.runModal()
        if response == .OK, let url = savePanel.url {
            let csvData = dataToCSV(data: data)
            do {
                try csvData.write(to: url, atomically: true, encoding: .utf8)
                
            } catch {
                print("Error saving CSV data: \(error)")
            }
        }
    }
    
    
    /**
     Convert the data to .csv format
     */
    func dataToCSV(data: [(packingDensity: Float, bigParticlesPercentage: Float, smallParticlesPercentage: Float, ratioOfContainerBigParticle: Float, ratioOfBigParticleSmallParticle: Float)]) -> String {
        guard !data.isEmpty else { return "" }

        let header = "Experiment Index,Packing Density,Big Particle Percentage [%],Small Particle Percentage [%],Ratio of Container and Big Particle = 1: ,Ratio of Big Particle and Small Particle = 1: "
        var rows: [String] = [header]

        for (index, item) in data.enumerated() {
            let row = "\(index+1),\(item.packingDensity),\(item.bigParticlesPercentage),\(item.smallParticlesPercentage),\(Int(item.ratioOfContainerBigParticle)),\(Int(item.ratioOfBigParticleSmallParticle))"
            rows.append(row)
        }
        return rows.joined(separator: "\n")
    }
 
    
    /**
     Basic setup for the data chart
     */
    func setupChart() {
        updateScatterChartData()

        scatterChartView.xAxis.labelPosition = .bottom
        scatterChartView.rightAxis.enabled = false
        yAxisTitle.rotate(byDegrees: 90)
        
        scatterChartView.doubleTapToZoomEnabled = false
        scatterChartView.delegate = self
    }
    
    
    /**
     Update the data for the scatter chart
     */
    func updateScatterChartData() {
        
        var dataSets = [ScatterChartDataSet]()
        let colorList = [NSUIColor.orange, NSColor.systemPink, NSColor.purple, NSColor.systemBlue, NSColor.systemYellow, NSColor.green]
        
        for (index, classifiedData) in dataClassification().enumerated() {
            var experimentDatas = [ChartDataEntry]()
            
            for experimentData in classifiedData.data {
                experimentDatas.append(ChartDataEntry(x: Double(experimentData.smallParticlesPercentage), y: Double(experimentData.packingDensity), data: (experimentData.bigParticlesPercentage, Int(experimentData.ratioOfContainerBigParticle), Int(experimentData.ratioOfBigParticleSmallParticle))))
            }
            
            let dataSet = ScatterChartDataSet(entries: experimentDatas, label: "C:B=1:\(classifiedData.identification.0)&B:S=1:\(classifiedData.identification.1)")
            dataSet.colors = [colorList[index%6]]
            dataSet.setScatterShape(.circle)
            dataSet.scatterShapeSize = 10.0
            dataSet.drawValuesEnabled = false
            dataSet.highlightEnabled = true
            dataSet.highlightLineWidth = 1.5
            dataSet.highlightColor = NSUIColor.white
    
            dataSets.append(dataSet)
        }
        
        let data = ScatterChartData(dataSets: dataSets)
        DispatchQueue.main.async {
            self.scatterChartView.data = data
            self.clearScatterChartDataDetailLabel()
        }
    }
     
    
    /**
     Return and group the data for the classification
     */
    func dataClassification() -> [ClassifiedData] {
        
        let classifiedData = ClassifiedDataList()
        
        for experimentData in experimentResultData {
            classifiedData.appendData(data: experimentData)
        }
        return classifiedData.getAllData()
    }
    
    
    /**
     Execute when the data is selected by the user
     */
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        guard let dataSets = scatterChartView.data?.dataSets as? [ScatterChartDataSet] else { return }
        for (dataSetIndex, dataSet) in dataSets.enumerated() {
            for (itemIndex, item) in dataSet.entries.enumerated() {
                if item.isEqual(to: entry) {
                    scatterChartSelectedLayerIndex = dataSetIndex
                    scatterChartSelectedIndex = itemIndex
                }
            }
        }
        
        let tupleData = entry.data as! (Float, Int, Int)
        DispatchQueue.main.async {
            self.scatterChartDetailLabel.stringValue = "Packing Density = \(String(format: "%.4f", entry.y))" + "\n" + "Small Particles = \(String(format: "%.2f", entry.x))%" + "\n" + "@ C:B = 1:\(tupleData.1) & B:S = 1:\(tupleData.2)"
        }
    }
    
    
    /**
     Clear the label of the data details when no data is selected
     */
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        clearScatterChartDataDetailLabel()
    }
    
    
    /**
     Remove the label of the data details
     */
    func clearScatterChartDataDetailLabel() {
        DispatchQueue.main.async {
            self.scatterChartView.highlightValues(nil)
            self.scatterChartDetailLabel.stringValue = ""
        }
    }
    
    
    /**
     Bind the key with the specific action
     */
    override func keyDown(with event: NSEvent) {
        let keyCode = event.keyCode
        
        if !graphView.isHidden {
            guard let dataSets = scatterChartView.data?.dataSets as? [ScatterChartDataSet] else { return }
            var dataSet = dataSets[scatterChartSelectedLayerIndex]
            
            if keyCode == 43 { // Left arrow key
                scatterChartSelectedIndex = max(scatterChartSelectedIndex - 1, 0)
            }
            else if keyCode == 47 { // Right arrow key
                scatterChartSelectedIndex = min(scatterChartSelectedIndex + 1, dataSet.count - 1)
            }
            else if keyCode == 12 {
                scatterChartSelectedIndex = 0
                scatterChartSelectedLayerIndex += 1
                
                if scatterChartSelectedLayerIndex > dataSets.count - 1 {
                    scatterChartSelectedLayerIndex = 0
                }
                dataSet = dataSets[scatterChartSelectedLayerIndex]
            }
            else {
                super.keyDown(with: event)
                return
            }
            
            let entry = dataSet[scatterChartSelectedIndex]
            scatterChartView.highlightValue(x: entry.x, y: entry.y, dataSetIndex: scatterChartSelectedLayerIndex, callDelegate: true)
        }
    }
    
    
    /**
     Upload the data file to the application
     */
    func uploadResultData() {
        openAndReadCSVFile()
    }
    
    
    /**
     Open and read the data in the .csv file
     */
    func openAndReadCSVFile() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.commaSeparatedText]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        
        // Set the default save location to the Downloads folder
        let uploadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        if let uploadsURL = uploadsURL {
            openPanel.directoryURL = uploadsURL
        }

        guard let window = self.view.window else { return }
        openPanel.beginSheetModal(for: window) { result in
            if result == .OK, let url = openPanel.url {
                self.readCSVFile(url: url)
            }
        }
    }

    
    /**
     Access and decode the data in the .csv file
     */
    func readCSVFile(url: URL) {
        do {
            let csvData = try String(contentsOf: url, encoding: .utf8)
            var csvRows = csvData.components(separatedBy: "\n")
            let headerRow = csvRows.first

            if let headerRow = headerRow, isValidHeader(header: headerRow) {
                // Valid header
                // Process the CSV data
                csvRows.removeFirst()
                displayUploadedData(uploadedData: csvRows)
                
            } else {
                print("Invalid header")
                // Show an error message or handle the invalid header case
            }
        } catch {
            print("Error reading the CSV file: \(error)")
            // Handle the error case
        }
    }

    
    /**
     Check the valid header in the .csv file
     */
    func isValidHeader(header: String) -> Bool {
        // Define the expected header format or values
        let expectedHeader = "Experiment Index,Packing Density,Big Particle Percentage [%],Small Particle Percentage [%],Ratio of Container and Big Particle = 1: ,Ratio of Big Particle and Small Particle = 1: "
        
        return header.replacingOccurrences(of: "\r", with: "") == expectedHeader
    }
    
    
    /**
     Display the uploaded data from the .csv file to the result section in the application
     */
    func displayUploadedData(uploadedData: [String]) {
        uploadResultButton.isHidden = true
        
        for row in uploadedData {
            // Assuming the data are valid
            let dataInfo = row.replacingOccurrences(of: "\r", with: "").components(separatedBy: ",")
            
            experimentIndex = Int(dataInfo[0])!
            saveAndPrintResultToDisplay(packingDensity: Float(dataInfo[1])!, bigParticlePercentage: Float(dataInfo[2])!, smallParticlePercentage: Float(dataInfo[3])!, ratioOfContainerBigParticle: Int(dataInfo[4])!, ratioOfBigParticleSmallParticle: Int(dataInfo[5])!)
        }
        updateExperimentDataSection()
    }

    
    /**
     Update and control the experiment status automatically by the system
     */
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        guard let lastUpdate = lastUpdateTime else {
            lastUpdateTime = time
            return
        }
        let timeSinceLastUpdate = time - lastUpdate
        
        if timeSinceLastUpdate >= updateInterval {
            // Handling the auto experiment
            if autoExperimentStatus != .empty {
                if autoExperimentStatus == .end {
                
                    DispatchQueue.main.async {
                        self.autoExperimentTerminate.isHidden = true
                        
                        if !self.autoExperimentIsTerminated {
                            self.autoExperimentStatusIndex += 1
                            if self.autoExperimentStatusIndex > self.stepperForNumberOfExperimentsPerCase.integerValue {
                                self.expectedVolumeOfSmallParticles += self.stepperForExperimentStep.floatValue/100
                                self.autoExperimentStatusIndex = 1
                            }
                            
                            if self.expectedVolumeOfSmallParticles > 0.55 {
                                self.expectedVolumeOfSmallParticles = 0.55
                                self.autoExperimentStatus = .empty
                            }
                            
                            self.expectedVolumeOfSmallParticlesSlider.floatValue = self.expectedVolumeOfSmallParticles*100
                            self.expectedVolumeOfSmallParticlesLabel.stringValue = String(format: "%.2f", self.expectedVolumeOfSmallParticles*100) + " %"
                        }
                        else {
                            self.autoExperimentStatus = .empty
                        }
                        
                        if self.autoExperimentStatus == .empty {
                            self.autoExperimentSwitch.state = .off
                            self.updateAutoExperimentState()
                        }
                        else {
                            self.disableControlSection()
                            self.resetExperimentEnvironment()
                            self.scene.rootNode.runAction(SCNAction.wait(duration: 1)) // Delay 1s
                            self.startExperimentButton(self)
                        }
                    }
                }
                else if autoExperimentStatus == .start {
                    
                    DispatchQueue.main.async {
                        if self.autoExperimentTerminate.isHidden && !self.autoExperimentIsTerminated {
                            self.autoExperimentTerminate.isHidden = false
                        }
                    }
                }
            }
            // Update the lastUpdateTime to the current time
            lastUpdateTime = time
        }
    }
}
