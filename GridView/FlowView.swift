//
//  GridView.swift
//  GridView
//
//  Created by Yee Chuan Lee on 21/03/2019.
//  Copyright © 2019 Yee Chuan Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol FlowViewContentViewType {
    func flowViewContentHeight(flowView: FlowView, width: CGFloat) -> CGFloat
}

fileprivate extension NSObject {
    var objectIdentifierHashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}

@IBDesignable
class FlowView : UIView {
    fileprivate var sizeCache: [Int: CGFloat] = [:]
    fileprivate var subviewDisposables: [Int: Disposable] = [:]
    
    @IBInspectable
    var columnNumber: Int = 3 {
        didSet {
            invalidateAllSubviewSize()
        }
    }
    
    @IBInspectable
    var interitemSpacing: CGFloat = 10 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable
    var lineSpacing: CGFloat = 10 {
        didSet {
            invalidateAllSubviewSize()
        }
    }
    
    @IBInspectable
    var rowHeight: CGFloat = -1 {
        didSet {
            invalidateAllSubviewSize()
        }
    }
    
    func invalidateSubviewSize(view: UIView) {
        sizeCache[view.objectIdentifierHashValue] = nil
        setNeedsLayout()
    }
    
    func invalidateSubviewSize(index: Int) {
        sizeCache[subviews[index].objectIdentifierHashValue] = nil
        setNeedsLayout()
    }
    
    func invalidateAllSubviewSize() {
        sizeCache = [:]
        setNeedsLayout()
    }
    
    var visibleSubviews: [UIView] { return subviews.filter { !$0.isHidden } }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for subview in subviews {
            subview.translatesAutoresizingMaskIntoConstraints = true
        }
        let columnWidth = floor((bounds.width - (lineSpacing * (CGFloat(columnNumber) - 1))) / CGFloat(columnNumber))
        var offset:CGPoint = .zero
        var rowMaxY: CGFloat = 0
        
        let visibleSubviews = self.visibleSubviews
        
        for (i,subview) in visibleSubviews.enumerated() {
            let size:CGSize = self.flowViewContentSize(subview: subview, index: i, width: columnWidth)
            if let value = sizeCache[subview.objectIdentifierHashValue], value != size.height {
                sizeCache[subview.objectIdentifierHashValue] = size.height
                invalidateIntrinsicContentSize()
            } else if sizeCache[subview.objectIdentifierHashValue] == nil {
                sizeCache[subview.objectIdentifierHashValue] = size.height
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
        if rowHeight >= 0 {
            size = CGSize(width: columnWidth, height: rowHeight)
        } else {
            if sizeCache[subview.objectIdentifierHashValue] == nil {
                
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
                              height: sizeCache[subview.objectIdentifierHashValue]!)
            }
        }
        return size
    }
    
    override var intrinsicContentSize: CGSize {
        let visibleSubviews = self.visibleSubviews
        
        let frames: [CGRect] = visibleSubviews.map { $0.frame }
        let maxYs = frames.map { $0.maxY }
        let maxXs = frames.map { $0.maxX }
        let ret = CGSize(width: maxXs.max() ?? 0, height: maxYs.max() ?? 0)
        return ret
    }
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        let disposable = subview.rx.observe(Bool.self, #keyPath(UIView.isHidden)).subscribe(onNext: { [weak self, weak subview] value in
            guard let `self` = self, let subview = subview else { return }
            if value != nil {
                self.invalidateSubviewSize(view: subview)
            }
        })
        subviewDisposables[subview.objectIdentifierHashValue] = disposable
    }
    
    override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        if let disposable = subviewDisposables[subview.objectIdentifierHashValue] {
            disposable.dispose()
            subviewDisposables[subview.objectIdentifierHashValue] = nil
        }
    }
}
