//
//  Polygon.swift
//  KardiaApp
//
//  Created by Bernie Chu on 1/9/15.
//  Copyright (c) 2015 Kardia. All rights reserved.
//

import Foundation
import UIKit

class Polygon: UIView {
    
    
//    override func drawRect(rect:CGRect)
//        
//    {
//        
//        
//        var ctx = UIGraphicsGetCurrentContext()
//        
//        drawPolygonUsingPath(ctx: ctx, x: CGRectGetMidX(rect),y: CGRectGetMidY(rect),radius: CGRectGetWidth(rect)/3, sides: 3, color: UIColor.blueColor())
//        
//        drawPolygonBezier(x: CGRectGetMidX(rect),y: CGRectGetMidY(rect),radius: CGRectGetWidth(rect)/4, sides: 4, color: UIColor.yellowColor())
//        
//        drawPolygon(ctx: ctx, x: CGRectGetMidX(rect),y: CGRectGetMidY(rect),radius: CGRectGetWidth(rect)/5, sides: 6, color: UIColor.greenColor())
//        
//    }
}

func degree2radian(a:CGFloat)->CGFloat {
    let b = CGFloat(M_PI) * a/180
    return b
}

func polygonPointArray(sides:Int,x:CGFloat,y:CGFloat,radius:CGFloat)->[CGPoint] {
    let angle = degree2radian(360/CGFloat(sides))
    let cx = x // x origin
    let cy = y // y origin
    let r  = radius // radius of circle
    var i = 0
    var points = [CGPoint]()
    while i <= sides {
        var xpo = cx + r * cos(angle * CGFloat(i))
        var ypo = cy + r * sin(angle * CGFloat(i))
        points.append(CGPoint(x: xpo, y: ypo))
        i++;
    }
    return points
}


func drawPolygon(#ctx:CGContextRef, #x:CGFloat, #y:CGFloat, #radius:CGFloat, #sides:Int, #color:UIColor) {
    
    let points = polygonPointArray(sides,x,y,radius)
    
    CGContextAddLines(ctx, points, UInt(points.count))
    
    let cgcolor = color.CGColor
    CGContextSetFillColorWithColor(ctx,cgcolor)
    CGContextFillPath(ctx)
}

func drawPolygonUsingPath(#ctx:CGContextRef, #x:CGFloat, #y:CGFloat, #radius:CGFloat, #sides:Int, #color:UIColor) {
    let path = polygonPath(x: x, y: y, radius: radius, sides: sides)
    CGContextAddPath(ctx, path)
    let cgcolor = color.CGColor
    CGContextSetFillColorWithColor(ctx,cgcolor)
    CGContextFillPath(ctx)
}

func drawPolygonBezier(#x:CGFloat, #y:CGFloat, #radius:CGFloat, #sides:Int, #color:UIColor) {
    let path = polygonPath(x: x, y: y, radius: radius, sides: sides)
    let bez = UIBezierPath(CGPath: path)
    // no need to convert UIColor to CGColor when using UIBezierPath
    color.setFill()
    bez.fill()
}

func polygonPath(#x:CGFloat, #y:CGFloat, #radius:CGFloat, #sides:Int) -> CGPathRef {
    let path = CGPathCreateMutable()
    let points = polygonPointArray(sides,x,y,radius)
    var cpg = points[0]
    CGPathMoveToPoint(path, nil, cpg.x, cpg.y)
    for p in points {
        CGPathAddLineToPoint(path, nil, p.x, p.y)
    }
    CGPathCloseSubpath(path)
    return path
}

func drawPolygonLayer(#x:CGFloat, #y:CGFloat, #radius:CGFloat, #sides:Int, #color:UIColor) -> CAShapeLayer {
    
    var shape = CAShapeLayer()
    shape.path = polygonPath(x: x, y: y, radius: radius, sides: sides)
    shape.fillColor = color.CGColor
    return shape
    
}