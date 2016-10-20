import SpriteKit

class DynamicLine {

    var shapeNode: SKShapeNode?
    var path = CGMutablePath()
    var points: [CGPoint] = []

    init() {
        shapeNode = SKShapeNode()
    }

    func addPoint(_ point: CGPoint) {
        points.append(point)
        if points.count <= 1 {
            path.move(to: CGPoint(x: point.x, y: point.y))
        } else {
            path.addLine(to: CGPoint(x: point.x, y: point.y))
        }
    }

    func clearPoints() {
        points.removeAll(keepingCapacity: false)
    }

    func updatePath() {
        if let node = shapeNode {
            node.path = path
        }
    }

    func draw(_ scene: GameScene) {
        if let node = shapeNode {
            node.lineWidth = 2
            node.name = "line"
            node.path = path
            node.strokeColor = UIColor.randomGoldenRatioColor()
            node.zPosition = 1
            scene.addChild(node)
        }
    }

}
