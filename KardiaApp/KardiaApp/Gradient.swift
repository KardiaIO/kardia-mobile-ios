//
//  Gradient.swift
//  KardiaApp
//
//  Created by Bernie Chu on 1/12/15.
//  Copyright (c) 2015 Kardia. All rights reserved.
//

import UIKit

class Gradient {
    let colorTop = UIColor(red: 60.0/255.0, green: 120.0/255.0, blue: 216.0/255.0, alpha: 1.0).CGColor
    let colorBottom = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).CGColor
    
    let gl: CAGradientLayer
    
    init() {
        gl = CAGradientLayer()
        gl.colors = [ colorTop, colorBottom]
        gl.locations = [ 0.0, 1.0]
    }
}