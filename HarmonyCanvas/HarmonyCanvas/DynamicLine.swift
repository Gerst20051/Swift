import SpriteKit

class DynamicLine {

    var shapeNode: SKShapeNode?
    var path = CGPathCreateMutable()
    var points: [CGPoint] = []

    init() {
        shapeNode = SKShapeNode()
    }

    func addPoint(point: CGPoint) {
        points.append(point)
        if points.count <= 1 {
            CGPathMoveToPoint(path, nil, point.x, point.y)
        } else {
            CGPathAddLineToPoint(path, nil, point.x, point.y)
        }
    }

    func clearPoints() {
        points.removeAll(keepCapacity: false)
    }

    func updatePath() {
        if let node = shapeNode {
            node.path = path
        }
    }

    func draw(scene: GameScene) {
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
