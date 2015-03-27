import SpriteKit

class Line {

    var points: [CGPoint] = []

    func addPoint(point: CGPoint) {
        points.append(point)
    }

    func createPath() -> CGPathRef? {
        if points.count <= 1 {
            return nil
        }
        var ref = CGPathCreateMutable()
        for var i = 0; i < points.count; ++i {
            let p = points[i]
            if i == 0 {
                CGPathMoveToPoint(ref, nil, p.x, p.y)
            } else {
                CGPathAddLineToPoint(ref, nil, p.x, p.y)
            }
        }
        return ref
    }

    func clearPoints() {
        points.removeAll(keepCapacity: false)
    }

}
