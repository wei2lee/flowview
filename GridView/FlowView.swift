//
//  GridView.swift
//  GridView
//
//  Created by Yee Chuan Lee on 21/03/2019.
//  Copyright © 2019 Yee Chuan Lee. All rights reserved.
//

import UIKit

protocol FlowViewContentViewType {
    func flowViewContentHeight(flowView: FlowView, width: CGFloat) -> CGFloat
}

@IBDesignable
class FlowView : UIView {
    fileprivate var sizeCache: [Int: CGFloat] = [:]
    
    var columnNumber: Int = 3 {
        didSet {
            invalidateAllSubviewSize()
        }
    }
    
    var interitemSpacing: CGFloat = 10 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var lineSpacing: CGFloat = 10 {
        didSet {
            invalidateAllSubviewSize()
        }
    }
    var rowHeight: CGFloat? = nil {
        didSet {
            invalidateAllSubviewSize()
        }
    }
    
    func invalidateSubviewSize(view: UIView) {
        sizeCache[view.hashValue] = nil
        setNeedsLayout()
    }
    
    func invalidateSubviewSize(index: Int) {
        sizeCache[subviews[index].hashValue] = nil
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
            let size:CGSize = self.flowViewContentSize(subview: subview, index: i, width: columnWidth)
            if let value = sizeCache[subview.hashValue], value != size.height {
                sizeCache[subview.hashValue] = size.height
                invalidateIntrinsicContentSize()
            } else {
                sizeCache[subview.hashValue] = size.height
                invalidateIntrinsicContentSize()
            }
            
            let origin = offset
            subview.frame = CGRect(origin: origin,
                                   size: size)
            offset.x = max(offset.x, subview.frame.maxX + lineSpacing)
            
            rowMaxY = max(rowMaxY, subview.frame.maxY)
            
            if (i+1) >= columnNumber && (i+1) % (columnNumber) == 0  {
                offset.x = 0
                offset.y = rowMaxY + interitemSpacing
            }
        }
    }
    
    func flowViewContentSize(subview: UIView, index: Int,  width columnWidth: CGFloat) -> CGSize {
        let size:CGSize
        if let rowHeight = rowHeight {
            size = CGSize(width: columnWidth, height: rowHeight)
        } else {
            if sizeCache[subview.hashValue] == nil {
                
                if let contentView = subview as? FlowViewContentViewType {
                    
                    let height: CGFloat = contentView.flowViewContentHeight(flowView: self, width: columnWidth)
                    size = CGSize(width: columnWidth, height: height)
                    
                } else {
                    
                    var targetSize = UIView.layoutFittingCompressedSize
                    targetSize.width = columnWidth
                    
                    let viewToSize = subview is UICollectionViewCell ? (subview as! UICollectionViewCell).contentView : subview
                    
                    size = viewToSize.systemLayoutSizeFitting(targetSize,
                                                              withHorizontalFittingPriority: UILayoutPriority(999),
                                                              verticalFittingPriority: UILayoutPriority(1))
                }
            } else {
                size = CGSize(width: columnWidth,
                              height: sizeCache[subview.hashValue]!)
            }
        }
        return size
    }
    
    override var intrinsicContentSize: CGSize {
        let frames: [CGRect] = subviews.map { $0.frame }
        let maxYs = frames.map { $0.maxY }
        let maxXs = frames.map { $0.maxX }
        let ret = CGSize(width: maxXs.max() ?? 0, height: maxYs.max() ?? 0)
        return ret
    }
}
