//
//  GridView.swift
//  GridView
//
//  Created by Yee Chuan Lee on 21/03/2019.
//  Copyright © 2019 Yee Chuan Lee. All rights reserved.
//

import UIKit

@IBDesignable
class FlowView : UIView {
    var columnNumber: Int = 3 {
        didSet {
            invalidateAllSubviewSize()
        }
    }
    var lineSpacing: CGFloat = 10 {
        didSet {
            invalidateAllSubviewSize()
        }
    }
    var rowHeight: CGFloat? = nil {
        didSet {
            setNeedsLayout()
        }
    }
    fileprivate var sizeCache: [Int: CGFloat] = [:]
    fileprivate var sizeCacheInvalidated: Bool = false
    
    func invalidateSubviewSize(view: UIView) {
        sizeCache[view.hashValue] = nil
        setNeedsLayout()
    }
    
    func invalidateAllSubviewSize() {
        sizeCache = [:]
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for subview in subviews {
            subview.translatesAutoresizingMaskIntoConstraints = true
        }
        let columnWidth = floor((bounds.width - (lineSpacing * (CGFloat(columnNumber) - 1))) / CGFloat(columnNumber))
        var offset:CGPoint = .zero
        var rowMaxY: CGFloat = 0
        for (i,subview) in subviews.enumerated() {
            let size:CGSize
            if let rowHeight = rowHeight {
                size = CGSize(width: columnWidth, height: rowHeight)
            } else {
                if sizeCache[subview.hashValue] == nil {
                    var targetSize = UIView.layoutFittingCompressedSize
                    targetSize.width = columnWidth
                    
                    let viewToSize = subview is UICollectionViewCell ? (subview as! UICollectionViewCell).contentView : subview
                    
                    size = viewToSize.systemLayoutSizeFitting(targetSize,
                                                           withHorizontalFittingPriority: UILayoutPriority(999),
                                                           verticalFittingPriority: UILayoutPriority(1))
                    sizeCache[subview.hashValue] = size.height
                    invalidateIntrinsicContentSize()
                } else {
                    size = CGSize(width: columnWidth,
                                  height: sizeCache[subview.hashValue]!)
                }
            }
            
            let origin = offset
            subview.frame = CGRect(origin: origin,
                                   size: size)
            print("\(i) = \(subview.frame)")
            offset.x = max(offset.x, subview.frame.maxX + lineSpacing)
            
            rowMaxY = max(rowMaxY, subview.frame.maxY)
            
            if (i+1) >= columnNumber && (i+1) % (columnNumber) == 0  {
                offset.x = 0
                offset.y = rowMaxY + lineSpacing
            }
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let frames: [CGRect] = subviews.map { $0.frame }
        let maxYs = frames.map { $0.maxY }
        let maxXs = frames.map { $0.maxX }
        let ret = CGSize(width: maxXs.max() ?? 0, height: maxYs.max() ?? 0)
        return ret
    }
}
