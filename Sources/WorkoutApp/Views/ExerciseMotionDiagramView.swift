import SwiftUI

/// One generic renderer for every animated exercise diagram — all of it driven
/// by `ExercisePose` data, no per-exercise drawing code. Ported from the design
/// handoff's HTML reference (see `docs/backlog` / the handoff README).
///
/// The figure loops one rep on a cosine ease: `t = (1 − cos(2π·p)) / 2`, so it
/// travels A → B → A with a natural dwell at both ends. A muscle-target glow
/// pulses with the rep, brightest where the lift should be felt. Honors Reduce
/// Motion by freezing on the end pose.
struct ExerciseMotionDiagramView: View {
    let pose: ExercisePose
    /// One knob for the whole animation. Handoff default 2.8s; range 1.4–6s.
    var repDuration: Double = 2.8

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// The 400 × 260 design space everything is authored in.
    private static let designSize = CGSize(width: 400, height: 260)

    var body: some View {
        Group {
            if reduceMotion {
                // Freeze at the end pose with the glow at mid opacity.
                Canvas { context, size in
                    draw(pose, into: &context, size: size, t: 1, glowOpacity: 0.6)
                }
            } else {
                TimelineView(.animation) { timeline in
                    let t = phase(at: timeline.date)
                    Canvas { context, size in
                        draw(pose, into: &context, size: size, t: t, glowOpacity: nil)
                    }
                }
            }
        }
        .aspectRatio(Self.designSize.width / Self.designSize.height, contentMode: .fit)
        .accessibilityElement()
        .accessibilityLabel("Animated form diagram: \(pose.exerciseName), target \(pose.target.capitalized).")
    }

    /// Rep progress on the cosine loop, 0…1, from absolute time so the loop is
    /// seamless without tracking a start date.
    private func phase(at date: Date) -> CGFloat {
        let elapsed = date.timeIntervalSinceReferenceDate
        let p = elapsed.truncatingRemainder(dividingBy: repDuration) / repDuration
        return CGFloat((1 - cos(2 * .pi * p)) / 2)
    }

    // MARK: - Drawing

    private func draw(_ d: ExercisePose, into ctx: inout GraphicsContext, size: CGSize, t: CGFloat, glowOpacity: Double?) {
        // Aspect-fit the design space into the canvas; scale the whole context so
        // stroke widths, radii, and dashes (all authored in design units) scale too.
        let scale = min(size.width / Self.designSize.width, size.height / Self.designSize.height)
        ctx.translateBy(
            x: (size.width - Self.designSize.width * scale) / 2,
            y: (size.height - Self.designSize.height * scale) / 2
        )
        ctx.scaleBy(x: scale, y: scale)

        // Interpolated position of a named joint at the current phase.
        func at(_ joint: String) -> CGPoint { lerp(d.joints[joint]?.a, d.joints[joint]?.b, t) }
        func barPos(_ bar: PoseBar) -> CGPoint {
            if let follow = bar.follow { return at(follow) }
            return lerp(bar.a, bar.b, t)
        }

        let sc = d.scaffold

        // 1. Scaffolding (back-most).
        if let floorY = sc.floorY {
            stroke(&ctx, from: p(30, floorY), to: p(370, floorY), Theme.Diagram.rail, width: 1)
            text(&ctx, "FLOOR", at: p(30, floorY + 15), size: 9, tracking: 1,
                 color: Theme.textSecondary.opacity(0.7))
        }
        if let plumbX = sc.plumbX {
            stroke(&ctx, from: p(plumbX, 36), to: p(plumbX, (sc.floorY ?? 230) - 4),
                   Theme.Diagram.accent600, width: 1, dash: [2, 4])
        }
        if let bench = sc.bench {
            let rect = CGRect(x: bench.x, y: bench.y, width: bench.w, height: 8)
            let path = Path(roundedRect: rect, cornerRadius: 2)
            ctx.fill(path, with: .color(Theme.Diagram.headFill))
            ctx.stroke(path, with: .color(Theme.Diagram.rail), lineWidth: 1)
            let footY = sc.floorY ?? bench.y + 8
            stroke(&ctx, from: p(bench.leg1, bench.y + 8), to: p(bench.leg1, footY), Theme.Diagram.rail, width: 2)
            stroke(&ctx, from: p(bench.leg2, bench.y + 8), to: p(bench.leg2, footY), Theme.Diagram.rail, width: 2)
        }
        if let bar = sc.topBar {
            stroke(&ctx, from: p(bar.x1, bar.y), to: p(bar.x2, bar.y), Theme.Diagram.rail, width: 3, cap: .round)
        }
        for l in sc.lines {
            stroke(&ctx, from: p(l.x1, l.y1), to: p(l.x2, l.y2), Theme.Diagram.rail, width: l.w, cap: .round)
        }
        for r in sc.rects {
            let path = Path(roundedRect: CGRect(x: r.x, y: r.y, width: r.w, height: r.h), cornerRadius: 2)
            ctx.fill(path, with: .color(Theme.Diagram.headFill))
            ctx.stroke(path, with: .color(Theme.Diagram.rail), lineWidth: 1)
        }
        if let bp = d.barPath {
            var path = Path()
            path.move(to: bp.from)
            path.addQuadCurve(to: bp.to, control: bp.control)
            ctx.stroke(path, with: .color(Theme.Diagram.accent600),
                       style: StrokeStyle(lineWidth: 1, dash: [2, 4]))
        }

        // 2. Cables.
        for cable in d.cables where d.bars.indices.contains(cable.barIndex) {
            stroke(&ctx, from: barPos(d.bars[cable.barIndex]), to: cable.to, Theme.Diagram.rail, width: 1.5)
        }

        // 3. Body segments.
        for seg in d.segments {
            stroke(&ctx, from: at(seg.a), to: at(seg.b), Theme.Diagram.body, width: seg.w, cap: .round)
        }

        // 4. Head + neck.
        let headCenter = lerp(d.head.a, d.head.b, t)
        let headRect = CGRect(x: headCenter.x - d.head.r, y: headCenter.y - d.head.r,
                              width: d.head.r * 2, height: d.head.r * 2)
        let headPath = Path(ellipseIn: headRect)
        ctx.fill(headPath, with: .color(Theme.Diagram.headFill))
        ctx.stroke(headPath, with: .color(Theme.Diagram.body), lineWidth: 4)
        if let neck = d.neck {
            stroke(&ctx, from: neck.from, to: at(neck.to), Theme.Diagram.body, width: 7, cap: .round)
        }

        // 5. Muscle glow — group opacity pulses with the rep; blurred halo + solid core.
        let op = glowOpacity ?? (d.glow == .start ? 0.9 - 0.5 * Double(t) : 0.35 + 0.55 * Double(t))
        ctx.drawLayer { layer in
            layer.opacity = op
            // Blurred halo pass.
            layer.drawLayer { halo in
                halo.addFilter(.blur(radius: 4))
                for overlay in d.musclesOverlay {
                    switch overlay {
                    case let .line(a, b, w):
                        stroke(&halo, from: at(a), to: at(b), Theme.Diagram.accent400, width: w, cap: .round)
                    case let .ellipse(a, b, rx, ry, rot):
                        halo.fill(ellipsePath(center: lerp(a, b, t), rx: rx, ry: ry, rot: rot),
                                  with: .color(Theme.Diagram.accent400))
                    }
                }
            }
            // Solid core pass.
            for overlay in d.musclesOverlay {
                switch overlay {
                case let .line(a, b, w):
                    stroke(&layer, from: at(a), to: at(b), Theme.Diagram.accent200,
                           width: max(w - 8, 3), cap: .round)
                case let .ellipse(a, b, rx, ry, rot):
                    layer.fill(ellipsePath(center: lerp(a, b, t), rx: rx * 0.6, ry: ry * 0.6, rot: rot),
                               with: .color(Theme.Diagram.accent200))
                }
            }
        }

        // 6. Muscle label: leader line + letter-spaced anatomical name.
        stroke(&ctx, from: d.leaderFrom, to: p(d.labelAt.x - 4, d.labelAt.y + 3),
               Theme.Diagram.accent500, width: 1)
        text(&ctx, d.target, at: d.labelAt, size: 10, tracking: 1.2, color: Theme.Diagram.accent300)

        // 7. Bars / plates (over the glow, so the implement stays crisp).
        for bar in d.bars {
            let pos = barPos(bar)
            if let len = bar.len {
                // Horizontal handle bar (e.g. a lat-pulldown bar).
                stroke(&ctx, from: p(pos.x - len / 2, pos.y), to: p(pos.x + len / 2, pos.y),
                       Theme.Diagram.accent300, width: 5, cap: .round)
            } else {
                let rect = CGRect(x: pos.x - bar.r, y: pos.y - bar.r, width: bar.r * 2, height: bar.r * 2)
                let path = Path(ellipseIn: rect)
                ctx.fill(path, with: .color(Theme.Diagram.accent800))
                ctx.stroke(path, with: .color(Theme.Diagram.accent300), lineWidth: 2.5)
            }
        }

        // 8. Joint markers (front-most).
        for joint in d.dots {
            let pos = at(joint)
            ctx.fill(Path(ellipseIn: CGRect(x: pos.x - 2.5, y: pos.y - 2.5, width: 5, height: 5)),
                     with: .color(Theme.Diagram.accent300))
        }
    }

    // MARK: - Primitives

    private func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }

    /// Linear interpolation A → B at `t`; a nil `b` (static joint) stays at A.
    private func lerp(_ a: CGPoint?, _ b: CGPoint?, _ t: CGFloat) -> CGPoint {
        guard let a else { return .zero }
        guard let b else { return a }
        return CGPoint(x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t)
    }

    private func stroke(_ ctx: inout GraphicsContext, from a: CGPoint, to b: CGPoint,
                        _ color: Color, width: CGFloat, cap: CGLineCap = .butt, dash: [CGFloat] = []) {
        var path = Path()
        path.move(to: a)
        path.addLine(to: b)
        ctx.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: cap, dash: dash))
    }

    /// An ellipse centered on `center`, rotated `rot` degrees about that center.
    private func ellipsePath(center: CGPoint, rx: CGFloat, ry: CGFloat, rot: Double) -> Path {
        let base = Path(ellipseIn: CGRect(x: center.x - rx, y: center.y - ry, width: rx * 2, height: ry * 2))
        guard rot != 0 else { return base }
        let transform = CGAffineTransform(translationX: center.x, y: center.y)
            .rotated(by: rot * .pi / 180)
            .translatedBy(x: -center.x, y: -center.y)
        return base.applying(transform)
    }

    private func text(_ ctx: inout GraphicsContext, _ string: String, at point: CGPoint,
                      size: CGFloat, tracking: CGFloat, color: Color) {
        let resolved = Text(string)
            .font(.system(size: size, weight: .regular, design: .default))
            .tracking(tracking)
            .foregroundStyle(color)
        ctx.draw(resolved, at: point, anchor: .bottomLeading)
    }
}

#Preview("Bench (glow at lockout)") {
    ExerciseMotionDiagramView(pose: ExercisePoses.byName["Barbell Bench Press"]!)
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding()
        .background(Theme.bg)
}

#Preview("Squat (glow in the hole)") {
    ExerciseMotionDiagramView(pose: ExercisePoses.byName["Barbell Squat"]!)
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding()
        .background(Theme.bg)
}
