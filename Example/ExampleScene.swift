//
//  ExampleScene.swift
//  Foil
//
//  Created by Pim Coumans on 30/12/16.
//  Copyright © 2016 pixelrock. All rights reserved.
//

import CoreGraphics

class ExampleScene: Scene {
	var textureNode:TextureNode!
	var lineNode:LineNode!
	
	var useAnimations: Bool = true
	var sequenceAnimation: SequenceAnimation?
	
	override func didMoveToRenderView() {
		guard let renderView = renderView else { return }
		renderView.screen.zoomScale = 60
		
		let rootNode = Node()
		rootNode.position = CGPoint(x:0, y:0)
		rootNode.scale = CGSize(width: 10, height: 10)
		addChild(rootNode)
		
		let textureNode = TextureNode(name: "pim", size:CGSize(width:2, height:2))
		textureNode.position = CGPoint(x: 0, y: 0)
		self.textureNode = textureNode
		rootNode.addChild(textureNode)
		
		lineNode = LineNode()
		lineNode.colors = [.yellow, .purple]
		rootNode.addChild(lineNode)
		
		if useAnimations {
			
			rootNode.animate(.rotation, to: CGFloat.pi * -2, duration: 6, curve: Linear()).loop()
			
			Animator.animate(duration: 2, curve: ElasticOut()) {
				textureNode.animate(.relativeRotation, to: CGFloat.pi / 2).loop()
			}
            
			sequenceAnimation = SequenceAnimation(curve: Spring(damping: 15, mass: 1.0, stiffness: 500, velocity: 0), duration: 2)
			sequenceAnimation?.animate {
				textureNode.animate(.position, to: CGPoint(x: 4, y: -4))
				textureNode.animate(.scale, to: CGSize(width: 2, height: 1))
				lineNode.animate(.position(at: 1), to: CGPoint(x: -4, y: 4))
				lineNode.animate(.position(at: 0), to: CGPoint(x: 4, y: 4))
				lineNode.animate(.color(at:0), to: Color(red: 1, green: 0, blue: 0))
				lineNode.animate(.color(at:1), to: Color(red: 0, green: 1, blue: 1))
			}.animate {
				textureNode.animate(.position, to: CGPoint(x: -4, y: 4))
				textureNode.animate(.scale, to: CGSize(width: 1, height: 2))
				lineNode.animate(.position(at: 1), to: CGPoint(x: 4, y: -4))
				lineNode.animate(.position(at: 0), to: CGPoint(x: -4, y: -4))
				lineNode.animate(.color(at:0), to: Color(red: 1, green: 0, blue: 1))
				lineNode.animate(.color(at:1), to: Color(red: 0, green: 1, blue: 0))
			}.animate {
				textureNode.animate(.position, to: CGPoint(x: 0, y: 0))
				textureNode.animate(.scale, to: CGSize(width: 1, height: 1))
				lineNode.animate(.position(at: 1), to: CGPoint(x: 0, y: 0))
				lineNode.animate(.position(at: 0), to: CGPoint(x: 2, y: -2))
				lineNode.animate(.color(at:0), to: Color(red: 0, green: 1, blue: 0))
				lineNode.animate(.color(at:0), to: Color(red: 1, green: 0, blue: 1))
			}.loop()
		}
	}
	
	var moveDirection = CGPoint(x: 1, y: 1)
	override func update(with context: RenderContext) {
		if !useAnimations {
			textureNode.rotation += 0.02
			
			guard let renderView = renderView, let rootNode = children.first, selectedChildNode == nil else { return }
			
			var textureNodePosition = textureNode.globalPosition
			textureNodePosition += (moveDirection * CGFloat(60 * context.delta))
			let convertedPosition = rootNode.convert(worldPosition: textureNodePosition)
			textureNode.position = convertedPosition
			
			var cappedPosition = textureNode.globalPosition
			let boundingRect = textureNode.globalFrame
			let screenbounds = renderView.screen.bounds
			if boundingRect.maxX >= screenbounds.maxX {
				cappedPosition.x = screenbounds.maxX - (boundingRect.width / 2)
				moveDirection.x = 0 - moveDirection.x
			}
			else if boundingRect.minX <= screenbounds.minX {
				cappedPosition.x = screenbounds.minX + (boundingRect.width / 2)
				moveDirection.x = 0 - moveDirection.x
			}
			
			if boundingRect.maxY >= screenbounds.maxY {
				cappedPosition.y = screenbounds.maxY - (boundingRect.height / 2)
				moveDirection.y = 0 - moveDirection.y
			}
			else if boundingRect.minY <= screenbounds.minY {
				cappedPosition.y = screenbounds.minY + (boundingRect.height / 2)
				moveDirection.y = 0 - moveDirection.y
			}
			
			if cappedPosition != textureNodePosition {
				textureNode.position = rootNode.convert(worldPosition: cappedPosition)
			}
			lineNode.points[1] = textureNode.position
		}
	}
	
	override func touchBegan(atPosition position: CGPoint) {
		if let node = self.node(atPosition: position) as? TextureNode, node.parent != nil {
			node.cancelAnimations()
			selectedChildNode = node
		}
	}
	
	override func touchMoved(toPosition position: CGPoint, delta: CGPoint) {
		if let node = selectedChildNode, let parent = node.parent {
			node.position = parent.convert(worldPosition: position)
			lineNode.points[1] = textureNode.position
		}
	}
	
	override func touchEnded(atPosition position: CGPoint, delta: CGPoint) {
		if let _ = selectedChildNode {
			selectedChildNode = nil
			moveDirection = delta
		}
		sequenceAnimation?.stop()
	}
	
	override func touchCancelled() {
		selectedChildNode = nil
	}
}
