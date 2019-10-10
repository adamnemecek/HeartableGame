// Copyright © 2019 Heartable LLC. All rights reserved.

import CoreGraphics

public enum HRT2DPositionAnchor {
    case center
    case top
    case topRight
    case right
    case bottomRight
    case bottom
    case bottomLeft
    case left
    case topLeft

    // MARK: - Props

    public var unitPoint: CGPoint {
        switch self {
        case .center: return CGPoint(x: 0.5, y: 0.5)
        case .top: return CGPoint(x: 0.5, y: 1)
        case .topRight: return CGPoint(x: 1, y: 1)
        case .right: return CGPoint(x: 1, y: 0.5)
        case .bottomRight: return CGPoint(x: 1, y: 0)
        case .bottom: return CGPoint(x: 0.5, y: 0)
        case .bottomLeft: return CGPoint(x: 0, y: 0)
        case .left: return CGPoint(x: 0, y: 0.5)
        case .topLeft: return CGPoint(x: 0, y: 1)
        }
    }

    public var isTop: Bool {
        switch self {
        case .topLeft, .top, .topRight: return true
        default: return false
        }
    }

    public var isRight: Bool {
        switch self {
        case .topRight, .right, .bottomRight: return true
        default: return false
        }
    }

    public var isBottom: Bool {
        switch self {
        case .bottomRight, .bottom, .bottomLeft: return true
        default: return false
        }
    }

    public var isLeft: Bool {
        switch self {
        case .topLeft, .left, .bottomLeft: return true
        default: return false
        }
    }

    public var isMidWidth: Bool {
        switch self {
        case .top, .center, .bottom: return true
        default: return false
        }
    }

    public var isMidHeight: Bool {
        switch self {
        case .left, .center, .right: return true
        default: return false
        }
    }

    // MARK: - Functionality

    public func unitDistance(from dest: HRT2DPositionAnchor) -> CGPoint {
        let x: CGFloat
        let y: CGFloat

        // Set x.
        if isLeft {
            if dest.isLeft {
                x = 0
            } else if dest.isMidWidth {
                x = 0.5
            } else {
                x = 1
            }
        } else if isMidWidth {
            x = dest.isMidWidth ? 0 : 0.5
        } else {
            if dest.isRight {
                x = 0
            } else if dest.isMidWidth {
                x = 0.5
            } else {
                x = 1
            }
        }

        // Set y.
        if isTop {
            if dest.isTop {
                y = 0
            } else if dest.isMidHeight {
                y = 0.5
            } else {
                y = 1
            }
        } else if isMidHeight {
            y = dest.isMidHeight ? 0 : 0.5
        } else {
            if dest.isBottom {
                y = 0
            } else if dest.isMidHeight {
                y = 0.5
            } else {
                y = 1
            }
        }

        return CGPoint(x: x, y: y)
    }

    // MARK: Position

    public func position(in area: CGSize) -> CGPoint {
        let unitPoint = self.unitPoint
        return CGPoint(x: area.width * unitPoint.x, y: area.height * unitPoint.y)
    }

    public func position(in rect: CGRect) -> CGPoint {
        let normalizedPosition = position(in: rect.size)
        return CGPoint(x: rect.minX + normalizedPosition.x, y: rect.minY + normalizedPosition.y)
    }

}
