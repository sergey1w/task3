//
//  ViewController.swift
//  task3
//
//  Created by sergey on 07.11.2024.
//

import UIKit

class ViewController: UIViewController {
    
    private let squareView = UIView(frame: .zero)
    
    private let slider = UISlider()
    
    private let safeAreView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        safeAreView.frame = view.safeAreaLayoutGuide.layoutFrame
        
        let leftMargin = view.directionalLayoutMargins.leading
        let rigthMargin = view.directionalLayoutMargins.trailing
        let topMargin = view.directionalLayoutMargins.top
        
        let boundingRectHeight = (C.squareSize.width * C.finalScale) * sqrt(2)
        
        
        squareView.center.x = calculateSquareCenterX(
            value: CGFloat(slider.value),
            finalSquareWidth: squareView.frame.width
        )
        squareView.center.y = boundingRectHeight / 2 + topMargin
        
        slider.bounds.size.width = view.bounds.width - leftMargin - rigthMargin
        slider.center.x = view.center.x
        slider.center.y = squareView.frame.maxY + slider.bounds.midY + C.sliderTopSpace
    }
    
    @objc private func sliderValueChanged(sender: UISlider) {
        let value = CGFloat(sender.value)
        
        let scale = calculateSquareScale(value: value)
        let rotation = calculateSquareRotation(value: value)
        
        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
        let rotateTransform = CGAffineTransform(rotationAngle: rotation)
        
        let tranform = scaleTransform.concatenating(rotateTransform)
        
        squareView.transform = tranform
    }
    
    @objc private func sliderTouchUp() {
        slider.setValue(slider.maximumValue, animated: true)
        animateSquareView()
    }
    
    private func calculateSquareCenterX(value: CGFloat, finalSquareWidth: CGFloat) -> CGFloat {
        let layoutMargins = view.directionalLayoutMargins
        let horizontalPadding = layoutMargins.leading + layoutMargins.trailing
        
        let offset = layoutMargins.leading + finalSquareWidth / 2
        let availableWidth = (view.bounds.width - finalSquareWidth - horizontalPadding)
        
        let progress = value * availableWidth
        
        return offset + progress
    }
    
    private func calculateSquareRotation(value: CGFloat) -> CGFloat {
        return value * (C.finalRotation)
    }
    
    private func calculateSquareScale(value: CGFloat) -> CGFloat {
        return (value / 2) + CGFloat(slider.maximumValue)
    }
    
    private func animateSquareView() {
        let positionStart = squareView.layer.position.x
        let positionEnd = calculateSquareCenterX(
            value: 1,
            finalSquareWidth: C.squareSize.width * C.finalScale
        )
        
        let positionAnimation = CABasicAnimation(keyPath: "position.x")
        positionAnimation.fromValue = positionStart
        positionAnimation.toValue = positionEnd
        
        let transformAnimation = CABasicAnimation(keyPath: "transform")
        let transformStart = squareView.layer.transform
        
        let rotationTransform = CATransform3DMakeRotation(C.finalRotation, 0, 0, 1)
        let scaleTransform = CATransform3DMakeScale(C.finalScale, C.finalScale, 1)
        
        let transformEnd = CATransform3DConcat(rotationTransform, scaleTransform)
        
        transformAnimation.fromValue = transformStart
        transformAnimation.toValue = transformEnd
        
        
        let duration: CFTimeInterval = C.animationDuration
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [positionAnimation, transformAnimation]
        animationGroup.duration = duration
        
        
        squareView.layer.add(animationGroup, forKey: nil)
        
        squareView.center.x = positionEnd
        squareView.layer.transform = transformEnd
    }
}

// MARK: UI
extension ViewController {
    private func setup() {
        view.addSubview(safeAreView)
        safeAreView.backgroundColor = .brown.withAlphaComponent(0.6)
        view.addSubview(squareView)
        view.addSubview(slider)
        setupSquareView()
        setupSliderView()
    }
    
    private func setupSquareView() {
        squareView.bounds.size = C.squareSize
        squareView.backgroundColor = C.squareBackgroundColor
        squareView.layer.cornerRadius = C.squareCornerRadius
    }
    
    private func setupSliderView() {
        slider.minimumValue = 0
        slider.maximumValue = 1
        
        slider.addTarget(self, action: #selector(sliderTouchUp), for: [.touchUpInside, .touchUpOutside])
        slider.addTarget(self, action: #selector(sliderValueChanged(sender:)), for: .valueChanged)
    }
}

private extension ViewController {
    typealias C = Constants
    
    enum Constants {
        static let squareBackgroundColor: UIColor = .systemBlue
        static let squareCornerRadius: CGFloat = 8
        static let squareSize = CGSize(width: 100, height: 100)
        static let finalScale: CGFloat = 1.5
        static let finalRotation: CGFloat = .pi/2
        
        static let sliderTopSpace: CGFloat = 8
        static let animationDuration: TimeInterval = 0.25
    }
}
