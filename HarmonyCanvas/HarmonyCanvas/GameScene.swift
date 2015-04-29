import SpriteKit

class GameScene: SKScene {

    // var currentLine: Line?
    // var lastUpdateTime: NSTimeInterval = 0.0
    // var lines: [Line] = []
    var dynamicLines: [DynamicLine] = []
    var currentDynamicLine: DynamicLine?

    override init(size: CGSize) {
        super.init(size: size)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            let location = touch.locationInNode(self)
            println("touchesBegan location => \(location)")
            let node = nodeAtPoint(location)
            println("touchesBegan node => \(node)")
            var dynamicLine = DynamicLine()
            println("touchesBegan dynamicLine => \(dynamicLine)")
            dynamicLine.addPoint(location)
            currentDynamicLine = dynamicLine
            currentDynamicLine!.draw(self)
            // var line = Line()
            // println("touchesBegan line => \(line)")
            // line.clearPoints()
            // line.addPoint(location)
            // currentLine = line
        }
    }

    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            let location = touch.locationInNode(self)
            println("touchesMoved location => \(location)")
            if let line = currentDynamicLine {
                line.addPoint(location)
                line.updatePath()
                // line.draw(self)
                // drawLine(line, tmp: true)
            }
            // if let line = currentLine {
            //     line.addPoint(location)
            //     drawLine(line, tmp: true)
            // }
        }
    }

    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        println("touchesEnded currentDynamicLine => \(currentDynamicLine)")
        if let line = currentDynamicLine {
            dynamicLines.append(line)
        }
        currentDynamicLine = nil
        // clearLines()
        // drawLines()
        // println("touchesEnded currentLine => \(currentLine)")
        // if let line = currentLine {
        //     lines.append(line)
        // }
        // currentLine = nil
        // clearLines()
        // drawLines()
    }

    override func update(currentTime: CFTimeInterval) {
        // println("update currentTime => \(currentTime)")
        // drawLines()
    }

    func drawLine(line: Line, tmp: Bool = false) {
        // enumerateChildNodesWithName("line", usingBlock: { node, stop in
        //     println("drawLine node => \(node)")
        //     if node.tmp == true {
        //         node.removeFromParent()
        //     }
        // })
        // if let path = line.createPath() {
        //     let shapeNode = SKShapeNode()
        //     shapeNode.path = path
        //     shapeNode.name = "line"
        //     shapeNode.strokeColor = UIColor.grayColor()
        //     shapeNode.lineWidth = 2
        //     shapeNode.zPosition = 1
        //     shapeNode.tmp = tmp
        //     self.addChild(shapeNode)
        // }
    }

    func drawLines() {
        // for line in lines {
        //     drawLine(line)
        // }
    }

    func clearLines() {
        enumerateChildNodesWithName("line", usingBlock: { node, stop in
            println("restartGame node => \(node)")
            node.removeFromParent()
        })
    }

}
