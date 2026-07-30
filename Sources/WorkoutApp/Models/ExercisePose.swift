import CoreGraphics

/// Keyframe data for one animated exercise diagram. Ported from the design
/// handoff's `exercise-poses.js`; see `ExerciseMotionDiagramView` for the
/// renderer and `docs/backlog` for the handoff spec.
///
/// Coordinate space is 400 × 260, y-down. Every joint/implement carries a
/// rep-start position `a` and an optional rep-end position `b`; the renderer
/// interpolates `a → b → a` on a cosine loop. A missing `b` means static.
///
/// These are compiled-in assets, never persisted — so unlike the JSON models
/// they don't need `Optional` fields for forward-compat.

/// A joint's rep-start (`a`) and optional rep-end (`b`) position. Nil `b` = static.
struct PoseKeyframe {
    let a: CGPoint
    let b: CGPoint?

    init(_ ax: CGFloat, _ ay: CGFloat, _ bx: CGFloat? = nil, _ by: CGFloat? = nil) {
        a = CGPoint(x: ax, y: ay)
        if let bx, let by { b = CGPoint(x: bx, y: by) } else { b = nil }
    }
}

/// A round-capped body segment between two named joints, drawn at `w` width.
struct PoseSegment {
    let a: String
    let b: String
    let w: CGFloat

    init(_ a: String, _ b: String, _ w: CGFloat) {
        self.a = a; self.b = b; self.w = w
    }
}

/// The head circle: interpolated center (`a → b`) and radius.
struct PoseHead {
    let a: CGPoint
    let b: CGPoint?
    let r: CGFloat

    init(_ ax: CGFloat, _ ay: CGFloat, r: CGFloat) {
        a = CGPoint(x: ax, y: ay); b = nil; self.r = r
    }

    init(_ ax: CGFloat, _ ay: CGFloat, _ bx: CGFloat, _ by: CGFloat, r: CGFloat) {
        a = CGPoint(x: ax, y: ay); b = CGPoint(x: bx, y: by); self.r = r
    }
}

/// A bar / plate / handle. Either follows a joint, or carries its own keyframe.
/// `r` encodes load (24 = full plate, 6 = dumbbell/cable handle). When `len` is
/// set the bar renders as a horizontal handle of that length (e.g. a lat-pulldown
/// bar) instead of an end-on plate circle.
struct PoseBar {
    let follow: String?
    let a: CGPoint?
    let b: CGPoint?
    let r: CGFloat
    let len: CGFloat?

    init(follow: String, r: CGFloat, len: CGFloat? = nil) {
        self.follow = follow; a = nil; b = nil; self.r = r; self.len = len
    }

    init(_ ax: CGFloat, _ ay: CGFloat, _ bx: CGFloat? = nil, _ by: CGFloat? = nil,
         r: CGFloat = 0, len: CGFloat? = nil) {
        follow = nil
        a = CGPoint(x: ax, y: ay)
        if let bx, let by { b = CGPoint(x: bx, y: by) } else { b = nil }
        self.r = r
        self.len = len
    }
}

/// A cable: a thin line from bar `barIndex`'s current position to a fixed anchor.
struct PoseCable {
    let barIndex: Int
    let to: CGPoint

    init(bar: Int, toX: CGFloat, toY: CGFloat) {
        barIndex = bar; to = CGPoint(x: toX, y: toY)
    }
}

/// The neck: a short segment from a fixed point to an (interpolated) joint.
struct PoseNeck {
    let from: CGPoint
    let to: String

    init(fromX: CGFloat, fromY: CGFloat, to: String) {
        from = CGPoint(x: fromX, y: fromY); self.to = to
    }
}

/// The muscle-target glow — a `line` between two joints, or an interpolated
/// `ellipse`. Drawn twice by the renderer (blurred halo + solid core).
enum MuscleOverlay {
    case line(a: String, b: String, w: CGFloat)
    case ellipse(a: CGPoint, b: CGPoint? = nil, rx: CGFloat, ry: CGFloat, rot: Double = 0)
}

/// A decorative dashed bar-path guide (a single quadratic Bézier).
struct PoseBarPath {
    let from: CGPoint
    let control: CGPoint
    let to: CGPoint

    init(fromX: CGFloat, fromY: CGFloat, cX: CGFloat, cY: CGFloat, toX: CGFloat, toY: CGFloat) {
        from = CGPoint(x: fromX, y: fromY)
        control = CGPoint(x: cX, y: cY)
        to = CGPoint(x: toX, y: toY)
    }
}

/// Static clinical scaffolding: floor line, plumb line, bench, overhead bar,
/// plus free rail/machine `lines` and pad/seat `rects`.
struct PoseScaffold {
    var floorY: CGFloat?
    var plumbX: CGFloat?
    var bench: Bench?
    var topBar: TopBar?
    /// Free rail/machine lines, drawn rail-colored and round-capped.
    var lines: [Line]
    /// Pads/seats, drawn like the bench (head-filled, rail-stroked rounded rect).
    var rects: [Rect]

    init(floorY: CGFloat? = nil, plumbX: CGFloat? = nil, bench: Bench? = nil,
         topBar: TopBar? = nil, lines: [Line] = [], rects: [Rect] = []) {
        self.floorY = floorY; self.plumbX = plumbX; self.bench = bench
        self.topBar = topBar; self.lines = lines; self.rects = rects
    }

    /// An 8pt-tall rounded rect with two legs dropping to the floor.
    struct Bench {
        let x: CGFloat, y: CGFloat, w: CGFloat, leg1: CGFloat, leg2: CGFloat
    }

    struct TopBar {
        let y: CGFloat, x1: CGFloat, x2: CGFloat
    }

    /// A free line `[x1, y1, x2, y2, width]`; width defaults to 2.
    struct Line {
        let x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat, w: CGFloat
        init(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat, _ w: CGFloat = 2) {
            self.x1 = x1; self.y1 = y1; self.x2 = x2; self.y2 = y2; self.w = w
        }
    }

    /// A pad/seat rect `[x, y, w, h]`.
    struct Rect {
        let x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat
        init(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) {
            self.x = x; self.y = y; self.w = w; self.h = h
        }
    }
}

/// Which end of the rep the glow peaks at.
enum GlowPhase {
    /// Peak at rep start (e.g. bench lockout): opacity = 0.9 − 0.5·t.
    case start
    /// Peak at rep end (e.g. bottom of squat): opacity = 0.35 + 0.55·t.
    case end
}

/// Side view for hinge/press/squat patterns; front for lateral/symmetric motion.
enum PoseView {
    case side, front
}

/// One exercise's full diagram spec.
struct ExercisePose {
    let id: String
    /// Join key — must exactly match a catalog `Exercise.name`.
    let exerciseName: String
    /// Anatomical label, uppercase (e.g. "PECTORALIS MAJOR").
    let target: String
    /// Mind-muscle cue copy shown alongside the diagram.
    let feel: String
    /// Repeated-set/tempo copy from the handoff (e.g. "3-1-1 · 4×8"). Not shown
    /// on the workout screen — it would contradict the user's own target — but
    /// kept for the fuller card layout the handoff envisions.
    let tempo: String
    let muscles: String

    let glow: GlowPhase
    let view: PoseView

    let head: PoseHead
    let joints: [String: PoseKeyframe]
    let segments: [PoseSegment]
    let neck: PoseNeck?
    let bars: [PoseBar]
    let barPath: PoseBarPath?
    let cables: [PoseCable]
    let musclesOverlay: [MuscleOverlay]
    let labelAt: CGPoint
    let leaderFrom: CGPoint
    let scaffold: PoseScaffold
    let dots: [String]

    init(
        id: String,
        exerciseName: String,
        target: String,
        feel: String,
        tempo: String,
        muscles: String,
        glow: GlowPhase,
        view: PoseView = .side,
        head: PoseHead,
        joints: [String: PoseKeyframe],
        segments: [PoseSegment],
        neck: PoseNeck? = nil,
        bars: [PoseBar] = [],
        barPath: PoseBarPath? = nil,
        cables: [PoseCable] = [],
        musclesOverlay: [MuscleOverlay],
        labelAt: CGPoint,
        leaderFrom: CGPoint,
        scaffold: PoseScaffold,
        dots: [String]
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.target = target
        self.feel = feel
        self.tempo = tempo
        self.muscles = muscles
        self.glow = glow
        self.view = view
        self.head = head
        self.joints = joints
        self.segments = segments
        self.neck = neck
        self.bars = bars
        self.barPath = barPath
        self.cables = cables
        self.musclesOverlay = musclesOverlay
        self.labelAt = labelAt
        self.leaderFrom = leaderFrom
        self.scaffold = scaffold
        self.dots = dots
    }
}
