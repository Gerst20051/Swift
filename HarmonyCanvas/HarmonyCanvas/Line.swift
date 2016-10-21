import SpriteKit

class Line {

    var points: [CGPoint] = []

    func addPoint(_ point: CGPoint) {
        points.append(point)
    }

    func createPath() -> CGPath? {
        if points.count <= 1 {
            return nil
        }
        let ref = CGMutablePath()
        for i in 0 ..< points.count {
            let p = points[i]
            if i == 0 {
                ref.move(to: CGPoint(x: p.x, y: p.y))
            } else {
                ref.addLine(to: CGPoint(x: p.x, y: p.y))
            }
        }
        return ref
    }

    func clearPoints() {
        points.removeAll(keepingCapacity: false)
    }

}
