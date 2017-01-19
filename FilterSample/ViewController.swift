//
//  ViewController.swift
//  FilterSample
//
//  Created by Nerius V on 18/01/2017.
//  Copyright © 2017 nerius v. All rights reserved.
//

import UIKit
import CoreImage
import QuartzCore
class ViewController: UIViewController {

    var displayLink : CADisplayLink?

    //animation duration in seconds
    let animationDuration = 2.0
    
    //time of the last animation update
    var lastUpdate = CACurrentMediaTime()
    
    //time since the start of animation. range [0..animationDuration]
    var animationCurrentTime = 0.0
    
    @IBOutlet weak var filterSwitch: UISwitch!
    @IBOutlet weak var imageView: CIImageView!
    var ciImage : CIImage?
    var imageRotation = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        ciImage = CIImage(image : UIImage(named: "test_img")!)
        
        
        let screenScale = UIScreen.main.scale
        let width =  imageView.bounds.width * screenScale
        let height =  imageView.bounds.height * screenScale
        let scale = max(width / ciImage!.extent.width , height / ciImage!.extent.height)
        
        ciImage = ciImage!.applying(CGAffineTransform(scaleX: scale, y: scale))

        imageRotation = getImageRotation(image : ciImage!)
        print("image rotation: ", imageRotation)
        
        imageView.image = ciImage
    }

    override func viewWillAppear(_ animated: Bool) {
        displayLink = CADisplayLink(target: self, selector: #selector(refreshImage))
        displayLink!.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        displayLink?.invalidate()
    }
    
    @IBAction func onToggle(_ sender: UISwitch) {
    }

    func refreshImage() {
        let currentTime = CACurrentMediaTime()
        let deltaT = currentTime - lastUpdate
        lastUpdate = currentTime
        if (filterSwitch.isOn) {
            animationCurrentTime += deltaT
        } else {
            animationCurrentTime -= deltaT
        }
        //clamp animationCurrentTime to the [0..animationDuration] range
        if (animationCurrentTime < 0) {
            animationCurrentTime = 0
        } else if (animationCurrentTime > animationDuration) {
            animationCurrentTime = animationDuration
        }
        //normalize animationCurrentTime to the [0..1] range
        var animationProgress = animationCurrentTime / animationDuration
        //cubic ease-in/out:
        if (filterSwitch.isOn) {
            animationProgress = pow(animationProgress, 1 / 3)
        } else {
            animationProgress = pow(animationProgress, 3)
        }
        doFilter(progress: animationProgress)
    }

    func doFilter(progress : Double) {
        let grayscaleFilter = CIFilter(name: "CIColorControls")!
        grayscaleFilter.setValue(ciImage, forKey: "inputImage")
        grayscaleFilter.setValue(1.0 - progress, forKey: "inputSaturation")
        
        let straightenFilter = CIFilter(name: "CIStraightenFilter")!
        straightenFilter.setValue(grayscaleFilter.outputImage, forKey: "inputImage")
        straightenFilter.setValue(imageRotation * progress, forKey: "inputAngle")
        
        imageView.image = straightenFilter.outputImage
    }
    
    func getImageRotation(image : CIImage) -> Double {
        //we only want the filters for auto-level adjustment, so disable everything else
        let adjustmentFilters = image.autoAdjustmentFilters(options: [kCIImageAutoAdjustLevel : true,
                                                                      kCIImageAutoAdjustEnhance : false,
                                                                      kCIImageAutoAdjustRedEye : false,
                                                                      kCIImageAutoAdjustFeatures : false,
                                                                      kCIImageAutoAdjustCrop : false])
        for filter in adjustmentFilters {
            if (filter.name == "CIAffineTransform") {
                //extract the rotation angle from the 
                //"inputTransform" parameter of the CIAffineTransform filter
                let transform = filter.value(forKey: "inputTransform") as! CGAffineTransform
                return atan2(Double(transform.b), Double(transform.a))
            }
        }
        //couldn't find the CIAffineTransform, so just return 0
        return 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
