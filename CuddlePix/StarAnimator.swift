

import UIKit

extension UIImageView {
  public func showStars() {
    let particleEmitter = CAEmitterLayer()
    
    particleEmitter.emitterPosition = CGPoint(x: frame.width / 2.0, y: -25)
    particleEmitter.emitterShape = kCAEmitterLayerLine
    particleEmitter.emitterSize = CGSize(width: frame.width, height: 1)
    particleEmitter.renderMode = kCAEmitterLayerAdditive
    
    let cell = CAEmitterCell()
    cell.contents = #imageLiteral(resourceName: "star@2x").cgImage
    cell.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
    cell.birthRate = 20
    cell.lifetime = 5.0
    cell.velocity = 100
    cell.velocityRange = 50
    cell.emissionLongitude = .pi
    cell.spinRange = 5
    cell.scale = 0.1
    cell.scaleRange = 0.25
    cell.alphaSpeed = -0.025
    particleEmitter.emitterCells = [cell]
    
    layer.addSublayer(particleEmitter)
  }
}

