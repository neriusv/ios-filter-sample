//
//  CIImageView.swift
//  FilterSample
//
//  Created by Nerius V on 18/01/2017.
//  Copyright © 2017 nerius v. All rights reserved.
//

import Foundation
import AVFoundation
import CoreImage
import GLKit
class CIImageView: GLKView, GLKViewDelegate {
    var ciContext: CIContext?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.context = EAGLContext(api: EAGLRenderingAPI.openGLES2)
        EAGLContext.setCurrent(self.context)
        self.ciContext = CIContext(eaglContext: self.context)
        delegate = self
        
        //set to true so that the view gets redrawn after calling setNeedsDisplay()
        enableSetNeedsDisplay = true
    }
    
    var image: CIImage? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func layoutSubviews() {
        //redraw the image if device orientation has changed
        setNeedsDisplay()
        super.layoutSubviews()
    }
    
    public func glkView(_ view: GLKView, drawIn rect: CGRect) {
        //clear the color buffer to white color
        glClearColor(1, 1, 1, 1)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        guard let image = self.image else {
            //image is nil - nothing to draw
            return
        }

        //need to scale the rect, because the size should be in pixels not in points
        let scale = UIScreen.main.scale
        let scaledRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width * scale, height: rect.height * scale)
        //create a target rect that fits nicely inside of the scaled rect
        let targetRect = AVMakeRect(aspectRatio: image.extent.size, insideRect: scaledRect)

        //draw the image
        self.ciContext!.draw(image, in: targetRect, from: image.extent)
    }
}
