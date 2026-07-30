import CoreGraphics

/// The animated-diagram library, ported 1:1 from the design handoff's
/// `exercise-poses.js` (all 50). Ordered to match the app's canonical exercise
/// list. Adding or editing one is pure data entry — see `ExercisePose` and the
/// renderer, `ExerciseMotionDiagramView`. No new drawing code should be required;
/// extend the scaffold vocabulary (`PoseScaffold.lines` / `.rects`, a bar `len`)
/// rather than writing bespoke drawing.
enum ExercisePoses {
    static let all: [ExercisePose] =
        chest + shoulders + triceps + back + rearDelts + biceps +
        quads + hamstringsGlutes + calves + core

    /// Catalog `Exercise.name` → diagram. Exercises without an entry fall back
    /// to the "Demo coming soon" placeholder.
    static let byName: [String: ExercisePose] = Dictionary(
        uniqueKeysWithValues: all.map { ($0.exerciseName, $0) }
    )
}

private func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }

// MARK: - Push · Chest

private extension ExercisePoses {
    static let chest: [ExercisePose] = [
        ExercisePose(
            id: "bench-press", exerciseName: "Barbell Bench Press",
            target: "PECTORALIS MAJOR",
            feel: "Across the chest — squeeze hardest at lockout, stay tense in the stretch.",
            tempo: "3-1-1 · 4×8", muscles: "Chest",
            glow: .start,
            head: PoseHead(95, 152, r: 13),
            joints: [
                "shoulder": PoseKeyframe(125, 166), "hip": PoseKeyframe(200, 168),
                "knee": PoseKeyframe(238, 196), "ankle": PoseKeyframe(240, 228),
                "toe": PoseKeyframe(258, 228),
                "elbow": PoseKeyframe(130, 120, 158, 192),
                "wrist": PoseKeyframe(127, 76, 152, 150),
            ],
            segments: [
                PoseSegment("shoulder", "hip", 13), PoseSegment("hip", "knee", 11),
                PoseSegment("knee", "ankle", 8), PoseSegment("ankle", "toe", 6),
                PoseSegment("shoulder", "elbow", 8), PoseSegment("elbow", "wrist", 7),
            ],
            neck: PoseNeck(fromX: 107, fromY: 158, to: "shoulder"),
            bars: [PoseBar(follow: "wrist", r: 8)],
            barPath: PoseBarPath(fromX: 127, fromY: 74, cX: 133, cY: 120, toX: 152, toY: 152),
            musclesOverlay: [.ellipse(a: p(141, 160), rx: 17, ry: 8, rot: -6)],
            labelAt: p(195, 105), leaderFrom: p(148, 148),
            scaffold: PoseScaffold(floorY: 230, bench: .init(x: 68, y: 170, w: 190, leg1: 85, leg2: 238)),
            dots: ["shoulder", "hip", "knee", "elbow"]
        ),
        ExercisePose(
            id: "db-bench-press", exerciseName: "Dumbbell Bench Press",
            target: "PECTORALIS MAJOR",
            feel: "Deeper stretch than the bar allows — bring the bells together over the chest.",
            tempo: "3-1-1 · 4×10", muscles: "Chest",
            glow: .start,
            head: PoseHead(95, 152, r: 13),
            joints: [
                "shoulder": PoseKeyframe(125, 166), "hip": PoseKeyframe(200, 168),
                "knee": PoseKeyframe(238, 196), "ankle": PoseKeyframe(240, 228),
                "toe": PoseKeyframe(258, 228),
                "elbow": PoseKeyframe(130, 120, 162, 196),
                "wrist": PoseKeyframe(127, 76, 155, 155),
            ],
            segments: [
                PoseSegment("shoulder", "hip", 13), PoseSegment("hip", "knee", 11),
                PoseSegment("knee", "ankle", 8), PoseSegment("ankle", "toe", 6),
                PoseSegment("shoulder", "elbow", 8), PoseSegment("elbow", "wrist", 7),
            ],
            neck: PoseNeck(fromX: 107, fromY: 158, to: "shoulder"),
            bars: [PoseBar(follow: "wrist", r: 7)],
            barPath: PoseBarPath(fromX: 127, fromY: 76, cX: 134, cY: 122, toX: 155, toY: 157),
            musclesOverlay: [.ellipse(a: p(141, 160), rx: 17, ry: 8, rot: -6)],
            labelAt: p(195, 105), leaderFrom: p(148, 148),
            scaffold: PoseScaffold(floorY: 230, bench: .init(x: 68, y: 170, w: 190, leg1: 85, leg2: 238)),
            dots: ["shoulder", "hip", "knee", "elbow"]
        ),
        ExercisePose(
            id: "incline-smith-press", exerciseName: "Incline Smith Machine Press",
            target: "UPPER CHEST",
            feel: "Upper chest doing the pressing — the rail fixes the path, you drive the squeeze.",
            tempo: "3-1-1 · 4×10", muscles: "Chest",
            glow: .end,
            head: PoseHead(110, 118, r: 12),
            joints: [
                "hip": PoseKeyframe(195, 192), "shoulder": PoseKeyframe(125, 135),
                "knee": PoseKeyframe(228, 198), "ankle": PoseKeyframe(230, 228),
                "toe": PoseKeyframe(248, 228),
                "elbow": PoseKeyframe(104, 126, 121, 88),
                "wrist": PoseKeyframe(122, 105, 118, 48),
            ],
            segments: [
                PoseSegment("shoulder", "hip", 13), PoseSegment("hip", "knee", 11),
                PoseSegment("knee", "ankle", 8), PoseSegment("ankle", "toe", 6),
                PoseSegment("shoulder", "elbow", 8), PoseSegment("elbow", "wrist", 7),
            ],
            bars: [PoseBar(follow: "wrist", r: 9)],
            musclesOverlay: [.ellipse(a: p(140, 142), rx: 14, ry: 8, rot: 32)],
            labelAt: p(220, 80), leaderFrom: p(148, 138),
            scaffold: PoseScaffold(floorY: 230, plumbX: 119,
                                   lines: [.init(98, 116, 206, 198, 6), .init(170, 200, 170, 230, 2)]),
            dots: ["shoulder", "hip", "knee", "elbow"]
        ),
        ExercisePose(
            id: "incline-db-press", exerciseName: "Incline Dumbbell Press",
            target: "UPPER CHEST",
            feel: "Upper chest stretching at the bottom, bells drifting together at the top.",
            tempo: "3-1-1 · 4×10", muscles: "Chest",
            glow: .end,
            head: PoseHead(110, 118, r: 12),
            joints: [
                "hip": PoseKeyframe(195, 192), "shoulder": PoseKeyframe(125, 135),
                "knee": PoseKeyframe(228, 198), "ankle": PoseKeyframe(230, 228),
                "toe": PoseKeyframe(248, 228),
                "elbow": PoseKeyframe(106, 128, 116, 90),
                "wrist": PoseKeyframe(124, 108, 112, 50),
            ],
            segments: [
                PoseSegment("shoulder", "hip", 13), PoseSegment("hip", "knee", 11),
                PoseSegment("knee", "ankle", 8), PoseSegment("ankle", "toe", 6),
                PoseSegment("shoulder", "elbow", 8), PoseSegment("elbow", "wrist", 7),
            ],
            bars: [PoseBar(follow: "wrist", r: 7)],
            barPath: PoseBarPath(fromX: 124, fromY: 108, cX: 112, cY: 72, toX: 113, toY: 52),
            musclesOverlay: [.ellipse(a: p(140, 142), rx: 14, ry: 8, rot: 32)],
            labelAt: p(220, 80), leaderFrom: p(148, 138),
            scaffold: PoseScaffold(floorY: 230,
                                   lines: [.init(98, 116, 206, 198, 6), .init(170, 200, 170, 230, 2)]),
            dots: ["shoulder", "hip", "knee", "elbow"]
        ),
        ExercisePose(
            id: "machine-chest-press", exerciseName: "Machine Chest Press",
            target: "CHEST",
            feel: "Chest closing the handles forward — no shoulder shrug, ribs down.",
            tempo: "2-1-2 · 3×12", muscles: "Chest",
            glow: .end,
            head: PoseHead(138, 72, r: 12),
            joints: [
                "hip": PoseKeyframe(140, 158), "knee": PoseKeyframe(186, 162),
                "ankle": PoseKeyframe(188, 218), "toe": PoseKeyframe(210, 218),
                "shoulder": PoseKeyframe(140, 92),
                "elbow": PoseKeyframe(150, 130, 185, 118),
                "wrist": PoseKeyframe(168, 110, 215, 110),
            ],
            segments: [
                PoseSegment("hip", "shoulder", 13), PoseSegment("hip", "knee", 11),
                PoseSegment("knee", "ankle", 8), PoseSegment("ankle", "toe", 6),
                PoseSegment("shoulder", "elbow", 8), PoseSegment("elbow", "wrist", 7),
            ],
            bars: [PoseBar(follow: "wrist", r: 6)],
            musclesOverlay: [.ellipse(a: p(152, 108), rx: 13, ry: 7)],
            labelAt: p(230, 60), leaderFrom: p(158, 102),
            scaffold: PoseScaffold(floorY: 230, lines: [.init(126, 84, 126, 162, 6), .init(140, 172, 140, 230, 2)],
                                   rects: [.init(112, 164, 58, 8)]),
            dots: ["shoulder", "hip", "knee", "elbow"]
        ),
        ExercisePose(
            id: "pec-deck", exerciseName: "Pec Deck",
            target: "CHEST (SQUEEZE)",
            feel: "Elbows sweeping together — squeeze the pads like closing a book.",
            tempo: "2-1-2 · 3×15", muscles: "Chest",
            glow: .end, view: .front,
            head: PoseHead(150, 58, r: 12),
            joints: [
                "neckC": PoseKeyframe(150, 74), "hipC": PoseKeyframe(150, 148),
                "shL": PoseKeyframe(128, 80), "shR": PoseKeyframe(172, 80),
                "kneeL": PoseKeyframe(132, 188), "kneeR": PoseKeyframe(168, 188),
                "ankL": PoseKeyframe(130, 222), "ankR": PoseKeyframe(170, 222),
                "eL": PoseKeyframe(92, 92, 118, 110), "eR": PoseKeyframe(208, 92, 182, 110),
                "wL": PoseKeyframe(76, 70, 138, 92), "wR": PoseKeyframe(224, 70, 162, 92),
            ],
            segments: [
                PoseSegment("shL", "shR", 9), PoseSegment("neckC", "hipC", 13),
                PoseSegment("shL", "eL", 7), PoseSegment("eL", "wL", 6),
                PoseSegment("shR", "eR", 7), PoseSegment("eR", "wR", 6),
                PoseSegment("hipC", "kneeL", 9), PoseSegment("kneeL", "ankL", 7),
                PoseSegment("hipC", "kneeR", 9), PoseSegment("kneeR", "ankR", 7),
            ],
            bars: [PoseBar(follow: "wL", r: 6), PoseBar(follow: "wR", r: 6)],
            musclesOverlay: [.ellipse(a: p(136, 96), rx: 8, ry: 8), .ellipse(a: p(164, 96), rx: 8, ry: 8)],
            labelAt: p(226, 40), leaderFrom: p(168, 90),
            scaffold: PoseScaffold(floorY: 230, lines: [.init(150, 162, 150, 230, 2)],
                                   rects: [.init(122, 154, 56, 8)]),
            dots: ["shL", "shR", "eL", "eR"]
        ),
        ExercisePose(
            id: "cable-fly", exerciseName: "Cable Fly",
            target: "CHEST",
            feel: "A hug against the cables — constant tension, hands meet in front of the sternum.",
            tempo: "2-1-2 · 3×12", muscles: "Chest",
            glow: .end, view: .front,
            head: PoseHead(150, 58, r: 12),
            joints: [
                "neckC": PoseKeyframe(150, 76), "hipC": PoseKeyframe(150, 132),
                "shL": PoseKeyframe(128, 80), "shR": PoseKeyframe(172, 80),
                "kneeL": PoseKeyframe(140, 178), "kneeR": PoseKeyframe(160, 178),
                "ankL": PoseKeyframe(138, 222), "ankR": PoseKeyframe(162, 222),
                "eL": PoseKeyframe(98, 92, 120, 104), "eR": PoseKeyframe(202, 92, 180, 104),
                "wL": PoseKeyframe(70, 74, 144, 100), "wR": PoseKeyframe(230, 74, 156, 100),
            ],
            segments: [
                PoseSegment("shL", "shR", 9), PoseSegment("neckC", "hipC", 13),
                PoseSegment("shL", "eL", 7), PoseSegment("eL", "wL", 6),
                PoseSegment("shR", "eR", 7), PoseSegment("eR", "wR", 6),
                PoseSegment("hipC", "kneeL", 9), PoseSegment("kneeL", "ankL", 7),
                PoseSegment("hipC", "kneeR", 9), PoseSegment("kneeR", "ankR", 7),
            ],
            bars: [PoseBar(follow: "wL", r: 5), PoseBar(follow: "wR", r: 5)],
            cables: [PoseCable(bar: 0, toX: 24, toY: 24), PoseCable(bar: 1, toX: 376, toY: 24)],
            musclesOverlay: [.ellipse(a: p(138, 94), rx: 8, ry: 7), .ellipse(a: p(162, 94), rx: 8, ry: 7)],
            labelAt: p(232, 50), leaderFrom: p(168, 88),
            scaffold: PoseScaffold(floorY: 230),
            dots: ["shL", "shR", "eL", "eR"]
        ),
        ExercisePose(
            id: "dips", exerciseName: "Dips",
            target: "CHEST · TRICEPS",
            feel: "Lean forward for chest, stay upright for triceps — press the bars apart at lockout.",
            tempo: "2-1-1 · 4×AMRAP", muscles: "Chest · Triceps",
            glow: .start,
            head: PoseHead(152, 60, 162, 92, r: 12),
            joints: [
                "wrist": PoseKeyframe(166, 110),
                "elbow": PoseKeyframe(158, 96, 184, 102),
                "shoulder": PoseKeyframe(150, 80, 158, 112),
                "hip": PoseKeyframe(156, 134, 160, 164),
                "knee": PoseKeyframe(138, 168, 134, 194),
                "ankle": PoseKeyframe(148, 198, 150, 218),
            ],
            segments: [
                PoseSegment("shoulder", "hip", 13), PoseSegment("hip", "knee", 10),
                PoseSegment("knee", "ankle", 8), PoseSegment("shoulder", "elbow", 8),
                PoseSegment("elbow", "wrist", 7),
            ],
            musclesOverlay: [.ellipse(a: p(150, 96), b: p(158, 128), rx: 12, ry: 7, rot: 15)],
            labelAt: p(250, 70), leaderFrom: p(160, 95),
            scaffold: PoseScaffold(floorY: 230,
                                   lines: [.init(112, 110, 252, 110, 4), .init(130, 110, 130, 230, 2),
                                           .init(236, 110, 236, 230, 2)]),
            dots: ["shoulder", "hip", "knee", "elbow"]
        ),
    ]
}

// MARK: - Push · Shoulders

private extension ExercisePoses {
    static let shoulders: [ExercisePose] = [
        ExercisePose(
            id: "overhead-press", exerciseName: "Overhead Press",
            target: "DELTOIDS",
            feel: "Delts from the rack position all the way up — head through at lockout.",
            tempo: "2-0-2 · 4×8", muscles: "Shoulders",
            glow: .end,
            head: PoseHead(150, 60, r: 12),
            joints: [
                "ankle": PoseKeyframe(150, 222), "toe": PoseKeyframe(176, 222),
                "knee": PoseKeyframe(150, 174), "hip": PoseKeyframe(150, 128),
                "shoulder": PoseKeyframe(150, 80),
                "elbow": PoseKeyframe(176, 96, 151, 48),
                "wrist": PoseKeyframe(168, 72, 152, 16),
            ],
            segments: [
                PoseSegment("ankle", "toe", 6), PoseSegment("ankle", "knee", 9),
                PoseSegment("knee", "hip", 12), PoseSegment("hip", "shoulder", 13),
                PoseSegment("shoulder", "elbow", 7), PoseSegment("elbow", "wrist", 6),
            ],
            bars: [PoseBar(170, 70, 152, 14, r: 9)],
            musclesOverlay: [.ellipse(a: p(153, 84), rx: 9, ry: 9)],
            labelAt: p(212, 60), leaderFrom: p(160, 82),
            scaffold: PoseScaffold(floorY: 230, plumbX: 152),
            dots: ["ankle", "knee", "hip", "shoulder", "elbow"]
        ),
        ExercisePose(
            id: "db-shoulder-press", exerciseName: "Dumbbell Shoulder Press",
            target: "DELTOIDS",
            feel: "Delts pressing the bells up and slightly in — no lower-back arch.",
            tempo: "2-0-2 · 4×10", muscles: "Shoulders",
            glow: .end,
            head: PoseHead(150, 60, r: 12),
            joints: [
                "ankle": PoseKeyframe(150, 222), "toe": PoseKeyframe(176, 222),
                "knee": PoseKeyframe(150, 174), "hip": PoseKeyframe(150, 128),
                "shoulder": PoseKeyframe(150, 80),
                "elbow": PoseKeyframe(178, 98, 152, 50),
                "wrist": PoseKeyframe(172, 74, 153, 18),
            ],
            segments: [
                PoseSegment("ankle", "toe", 6), PoseSegment("ankle", "knee", 9),
                PoseSegment("knee", "hip", 12), PoseSegment("hip", "shoulder", 13),
                PoseSegment("shoulder", "elbow", 7), PoseSegment("elbow", "wrist", 6),
            ],
            bars: [PoseBar(follow: "wrist", r: 7)],
            barPath: PoseBarPath(fromX: 172, fromY: 74, cX: 168, cY: 40, toX: 153, toY: 18),
            musclesOverlay: [.ellipse(a: p(153, 84), rx: 9, ry: 9)],
            labelAt: p(212, 50), leaderFrom: p(160, 82),
            scaffold: PoseScaffold(floorY: 230),
            dots: ["ankle", "knee", "hip", "shoulder", "elbow"]
        ),
        ExercisePose(
            id: "arnold-press", exerciseName: "Arnold Press",
            target: "DELTOIDS",
            feel: "Start palms-in at the chin, rotate out as you press — all three delt heads.",
            tempo: "2-1-2 · 3×10", muscles: "Shoulders",
            glow: .end,
            head: PoseHead(150, 60, r: 12),
            joints: [
                "ankle": PoseKeyframe(150, 222), "toe": PoseKeyframe(176, 222),
                "knee": PoseKeyframe(150, 174), "hip": PoseKeyframe(150, 128),
                "shoulder": PoseKeyframe(150, 80),
                "elbow": PoseKeyframe(140, 110, 151, 48),
                "wrist": PoseKeyframe(130, 88, 152, 18),
            ],
            segments: [
                PoseSegment("ankle", "toe", 6), PoseSegment("ankle", "knee", 9),
                PoseSegment("knee", "hip", 12), PoseSegment("hip", "shoulder", 13),
                PoseSegment("shoulder", "elbow", 7), PoseSegment("elbow", "wrist", 6),
            ],
            bars: [PoseBar(follow: "wrist", r: 7)],
            barPath: PoseBarPath(fromX: 130, fromY: 88, cX: 136, cY: 42, toX: 152, toY: 18),
            musclesOverlay: [.ellipse(a: p(153, 84), rx: 9, ry: 9)],
            labelAt: p(212, 50), leaderFrom: p(160, 82),
            scaffold: PoseScaffold(floorY: 230),
            dots: ["ankle", "knee", "hip", "shoulder", "elbow"]
        ),
        ExercisePose(
            id: "lateral-raise", exerciseName: "Lateral Raise",
            target: "DELTOIDS",
            feel: "Side delts floating the weight out — lead with the elbows, not the hands.",
            tempo: "2-1-2 · 3×15", muscles: "Shoulders",
            glow: .end, view: .front,
            head: PoseHead(150, 60, r: 12),
            joints: [
                "ankL": PoseKeyframe(136, 222), "ankR": PoseKeyframe(164, 222),
                "toeL": PoseKeyframe(124, 222), "toeR": PoseKeyframe(176, 222),
                "kneeL": PoseKeyframe(138, 176), "kneeR": PoseKeyframe(162, 176),
                "hipC": PoseKeyframe(150, 132), "neckC": PoseKeyframe(150, 78),
                "shL": PoseKeyframe(130, 82), "shR": PoseKeyframe(170, 82),
                "eL": PoseKeyframe(124, 112, 96, 86), "eR": PoseKeyframe(176, 112, 204, 86),
                "wLh": PoseKeyframe(120, 140, 66, 82), "wRh": PoseKeyframe(180, 140, 234, 82),
            ],
            segments: [
                PoseSegment("ankL", "toeL", 6), PoseSegment("ankR", "toeR", 6),
                PoseSegment("ankL", "kneeL", 8), PoseSegment("ankR", "kneeR", 8),
                PoseSegment("kneeL", "hipC", 10), PoseSegment("kneeR", "hipC", 10),
                PoseSegment("hipC", "neckC", 13), PoseSegment("shL", "shR", 9),
                PoseSegment("shL", "eL", 7), PoseSegment("eL", "wLh", 6),
                PoseSegment("shR", "eR", 7), PoseSegment("eR", "wRh", 6),
            ],
            bars: [PoseBar(118, 148, 58, 82, r: 6), PoseBar(182, 148, 242, 82, r: 6)],
            musclesOverlay: [.ellipse(a: p(130, 84), rx: 8, ry: 8), .ellipse(a: p(170, 84), rx: 8, ry: 8)],
            labelAt: p(206, 30), leaderFrom: p(174, 78),
            scaffold: PoseScaffold(floorY: 230),
            dots: ["shL", "shR", "eL", "eR", "hipC"]
        ),
        ExercisePose(
            id: "cable-lateral-raise", exerciseName: "Cable Lateral Raise",
            target: "LATERAL DELT",
            feel: "Tension from the very bottom — the cable never lets the delt rest.",
            tempo: "2-1-2 · 3×15", muscles: "Shoulders",
            glow: .end, view: .front,
            head: PoseHead(150, 60, r: 12),
            joints: [
                "ankL": PoseKeyframe(136, 222), "ankR": PoseKeyframe(164, 222),
                "toeL": PoseKeyframe(124, 222), "toeR": PoseKeyframe(176, 222),
                "kneeL": PoseKeyframe(138, 176), "kneeR": PoseKeyframe(162, 176),
                "hipC": PoseKeyframe(150, 132), "neckC": PoseKeyframe(150, 78),
                "shL": PoseKeyframe(130, 82), "shR": PoseKeyframe(170, 82),
                "eL": PoseKeyframe(124, 112), "wLh": PoseKeyframe(120, 140),
                "eR": PoseKeyframe(176, 112, 204, 86), "wRh": PoseKeyframe(180, 140, 234, 82),
            ],
            segments: [
                PoseSegment("ankL", "toeL", 6), PoseSegment("ankR", "toeR", 6),
                PoseSegment("ankL", "kneeL", 8), PoseSegment("ankR", "kneeR", 8),
                PoseSegment("kneeL", "hipC", 10), PoseSegment("kneeR", "hipC", 10),
                PoseSegment("hipC", "neckC", 13), PoseSegment("shL", "shR", 9),
                PoseSegment("shL", "eL", 7), PoseSegment("eL", "wLh", 6),
                PoseSegment("shR", "eR", 7), PoseSegment("eR", "wRh", 6),
            ],
            bars: [PoseBar(follow: "wRh", r: 5)],
            cables: [PoseCable(bar: 0, toX: 60, toY: 228)],
            musclesOverlay: [.ellipse(a: p(170, 84), rx: 8, ry: 8)],
            labelAt: p(206, 30), leaderFrom: p(174, 78),
            scaffold: PoseScaffold(floorY: 230),
            dots: ["shL", "shR", "eR", "hipC"]
        ),
    ]
}

// MARK: - Push · Triceps

private extension ExercisePoses {
    static let triceps: [ExercisePose] = [
        ExercisePose(
            id: "close-grip-bench", exerciseName: "Close-Grip Bench Press",
            target: "TRICEPS",
            feel: "Elbows tight to the ribs — triceps locking out, chest assisting.",
            tempo: "3-1-1 · 4×8", muscles: "Triceps · Chest",
            glow: .start,
            head: PoseHead(95, 152, r: 13),
            joints: [
                "shoulder": PoseKeyframe(125, 166), "hip": PoseKeyframe(200, 168),
                "knee": PoseKeyframe(238, 196), "ankle": PoseKeyframe(240, 228),
                "toe": PoseKeyframe(258, 228),
                "elbow": PoseKeyframe(128, 118, 150, 190),
                "wrist": PoseKeyframe(127, 76, 150, 148),
            ],
            segments: [
                PoseSegment("shoulder", "hip", 13), PoseSegment("hip", "knee", 11),
                PoseSegment("knee", "ankle", 8), PoseSegment("ankle", "toe", 6),
                PoseSegment("shoulder", "elbow", 8), PoseSegment("elbow", "wrist", 7),
            ],
            neck: PoseNeck(fromX: 107, fromY: 158, to: "shoulder"),
            bars: [PoseBar(follow: "wrist", r: 8)],
            barPath: PoseBarPath(fromX: 127, fromY: 76, cX: 131, cY: 116, toX: 150, toY: 150),
            musclesOverlay: [.line(a: "shoulder", b: "elbow", w: 9)],
            labelAt: p(195, 105), leaderFrom: p(138, 150),
            scaffold: PoseScaffold(floorY: 230, bench: .init(x: 68, y: 170, w: 190, leg1: 85, leg2: 238)),
            dots: ["shoulder", "hip", "knee", "elbow"]
        ),
        ExercisePose(
            id: "overhead-tricep-ext", exerciseName: "Overhead Tricep Extension",
            target: "TRICEPS",
            feel: "Long head stretching behind the head, then straightening the arm overhead.",
            tempo: "2-1-2 · 3×12", muscles: "Triceps",
            glow: .end,
            head: PoseHead(144, 64, r: 11),
            joints: [
                "ankle": PoseKeyframe(150, 222), "toe": PoseKeyframe(176, 222),
                "knee": PoseKeyframe(150, 174), "hip": PoseKeyframe(150, 128),
                "shoulder": PoseKeyframe(150, 80), "elbow": PoseKeyframe(156, 58),
                "wrist": PoseKeyframe(120, 64, 160, 18),
            ],
            segments: [
                PoseSegment("ankle", "toe", 6), PoseSegment("ankle", "knee", 9),
                PoseSegment("knee", "hip", 12), PoseSegment("hip", "shoulder", 13),
                PoseSegment("shoulder", "elbow", 7), PoseSegment("elbow", "wrist", 6),
            ],
            bars: [PoseBar(follow: "wrist", r: 7)],
            barPath: PoseBarPath(fromX: 120, fromY: 64, cX: 122, cY: 18, toX: 160, toY: 18),
            musclesOverlay: [.line(a: "shoulder", b: "elbow", w: 9)],
            labelAt: p(220, 60), leaderFrom: p(156, 70),
            scaffold: PoseScaffold(floorY: 230),
            dots: ["ankle", "knee", "hip", "shoulder", "elbow"]
        ),
        ExercisePose(
            id: "skull-crusher", exerciseName: "Skull Crusher",
            target: "TRICEPS",
            feel: "Upper arms frozen vertical — only the forearm hinges, triceps do everything.",
            tempo: "3-1-1 · 3×12", muscles: "Triceps",
            glow: .end,
            head: PoseHead(95, 152, r: 13),
            joints: [
                "shoulder": PoseKeyframe(125, 166), "hip": PoseKeyframe(200, 168),
                "knee": PoseKeyframe(238, 196), "ankle": PoseKeyframe(240, 228),
                "toe": PoseKeyframe(258, 228), "elbow": PoseKeyframe(128, 120),
                "wrist": PoseKeyframe(98, 118, 130, 76),
            ],
            segments: [
                PoseSegment("shoulder", "hip", 13), PoseSegment("hip", "knee", 11),
                PoseSegment("knee", "ankle", 8), PoseSegment("ankle", "toe", 6),
                PoseSegment("shoulder", "elbow", 8), PoseSegment("elbow", "wrist", 7),
            ],
            neck: PoseNeck(fromX: 107, fromY: 158, to: "shoulder"),
            bars: [PoseBar(follow: "wrist", r: 8)],
            barPath: PoseBarPath(fromX: 98, fromY: 118, cX: 96, cY: 74, toX: 130, toY: 76),
            musclesOverlay: [.line(a: "shoulder", b: "elbow", w: 9)],
            labelAt: p(195, 95), leaderFrom: p(132, 140),
            scaffold: PoseScaffold(floorY: 230, bench: .init(x: 68, y: 170, w: 190, leg1: 85, leg2: 238)),
            dots: ["shoulder", "hip", "knee", "elbow"]
        ),
        ExercisePose(
            id: "cable-pushdown", exerciseName: "Cable Push Down",
            target: "TRICEPS",
            feel: "Back of the arm locking the elbow out — hold the squeeze at the bottom.",
            tempo: "2-1-2 · 3×12", muscles: "Triceps",
            glow: .end,
            head: PoseHead(143, 62, r: 12),
            joints: [
                "ankle": PoseKeyframe(150, 222), "toe": PoseKeyframe(176, 222),
                "knee": PoseKeyframe(150, 174), "hip": PoseKeyframe(148, 128),
                "shoulder": PoseKeyframe(146, 80), "elbow": PoseKeyframe(152, 116),
                "wrist": PoseKeyframe(172, 88, 166, 156),
            ],
            segments: [
                PoseSegment("ankle", "toe", 6), PoseSegment("ankle", "knee", 9),
                PoseSegment("knee", "hip", 12), PoseSegment("hip", "shoulder", 13),
                PoseSegment("shoulder", "elbow", 7), PoseSegment("elbow", "wrist", 6),
            ],
            bars: [PoseBar(176, 86, 170, 158, r: 6)],
            cables: [PoseCable(bar: 0, toX: 198, toY: 10)],
            musclesOverlay: [.line(a: "shoulder", b: "elbow", w: 9)],
            labelAt: p(222, 120), leaderFrom: p(156, 100),
            scaffold: PoseScaffold(floorY: 230),
            dots: ["ankle", "knee", "hip", "shoulder", "elbow"]
        ),
    ]
}

// MARK: - Pull · Back

private extension ExercisePoses {
    static let back: [ExercisePose] = [
        ExercisePose(
            id: "pull-ups", exerciseName: "Pull Ups",
            target: "LATISSIMUS DORSI",
            feel: "Lats initiating from the dead hang; elbows driving down and back.",
            tempo: "2-0-1 · 4×AMRAP", muscles: "Back",
            glow: .end, view: .front,
            head: PoseHead(150, 86, 150, 34, r: 12),
            joints: [
                "wL": PoseKeyframe(118, 38), "wR": PoseKeyframe(182, 38),
                "shL": PoseKeyframe(130, 104, 124, 54), "shR": PoseKeyframe(170, 104, 176, 54),
                "eL": PoseKeyframe(123, 72, 112, 64), "eR": PoseKeyframe(177, 72, 188, 64),
                "neckC": PoseKeyframe(150, 100, 150, 48), "hipC": PoseKeyframe(150, 152, 150, 100),
                "kneeL": PoseKeyframe(142, 186, 138, 132), "kneeR": PoseKeyframe(158, 186, 162, 132),
                "ankL": PoseKeyframe(140, 216, 146, 158), "ankR": PoseKeyframe(160, 216, 154, 158),
            ],
            segments: [
                PoseSegment("shL", "shR", 9), PoseSegment("neckC", "hipC", 12),
                PoseSegment("shL", "eL", 7), PoseSegment("eL", "wL", 6),
                PoseSegment("shR", "eR", 7), PoseSegment("eR", "wR", 6),
                PoseSegment("hipC", "kneeL", 9), PoseSegment("kneeL", "ankL", 7),
                PoseSegment("hipC", "kneeR", 9), PoseSegment("kneeR", "ankR", 7),
            ],
            musclesOverlay: [.line(a: "shL", b: "hipC", w: 9), .line(a: "shR", b: "hipC", w: 9)],
            labelAt: p(232, 110), leaderFrom: p(166, 88),
            scaffold: PoseScaffold(topBar: .init(y: 36, x1: 90, x2: 310)),
            dots: ["shL", "shR", "eL", "eR", "hipC"]
        ),
        ExercisePose(
            id: "chin-ups", exerciseName: "Chin Ups",
            target: "BICEPS · LATS",
            feel: "Underhand grip puts the biceps in the pull — chin travels to the bar.",
            tempo: "2-0-1 · 4×AMRAP", muscles: "Back · Biceps",
            glow: .end, view: .front,
            head: PoseHead(150, 86, 150, 34, r: 12),
            joints: [
                "wL": PoseKeyframe(130, 38), "wR": PoseKeyframe(170, 38),
                "shL": PoseKeyframe(134, 104, 130, 54), "shR": PoseKeyframe(166, 104, 170, 54),
                "eL": PoseKeyframe(126, 72, 118, 66), "eR": PoseKeyframe(174, 72, 182, 66),
                "neckC": PoseKeyframe(150, 100, 150, 48), "hipC": PoseKeyframe(150, 152, 150, 100),
                "kneeL": PoseKeyframe(142, 186, 138, 132), "kneeR": PoseKeyframe(158, 186, 162, 132),
                "ankL": PoseKeyframe(140, 216, 146, 158), "ankR": PoseKeyframe(160, 216, 154, 158),
            ],
            segments: [
                PoseSegment("shL", "shR", 9), PoseSegment("neckC", "hipC", 12),
                PoseSegment("shL", "eL", 7), PoseSegment("eL", "wL", 6),
                PoseSegment("shR", "eR", 7), PoseSegment("eR", "wR", 6),
                PoseSegment("hipC", "kneeL", 9), PoseSegment("kneeL", "ankL", 7),
                PoseSegment("hipC", "kneeR", 9), PoseSegment("kneeR", "ankR", 7),
            ],
            musclesOverlay: [.line(a: "shL", b: "eL", w: 7), .line(a: "shR", b: "eR", w: 7)],
            labelAt: p(232, 110), leaderFrom: p(172, 66),
            scaffold: PoseScaffold(topBar: .init(y: 36, x1: 100, x2: 300)),
            dots: ["shL", "shR", "eL", "eR", "hipC"]
        ),
        ExercisePose(
            id: "lat-pulldown", exerciseName: "Lat Pulldown",
            target: "LATS",
            feel: "Elbows pulled down into the back pockets — bar to the collarbone, chest tall.",
            tempo: "2-1-2 · 4×10", muscles: "Back",
            glow: .end, view: .front,
            head: PoseHead(150, 66, r: 12),
            joints: [
                "neckC": PoseKeyframe(150, 88), "hipC": PoseKeyframe(150, 150),
                "shL": PoseKeyframe(128, 88), "shR": PoseKeyframe(172, 88),
                "kneeL": PoseKeyframe(132, 188), "kneeR": PoseKeyframe(168, 188),
                "ankL": PoseKeyframe(130, 222), "ankR": PoseKeyframe(170, 222),
                "eL": PoseKeyframe(118, 62, 106, 108), "eR": PoseKeyframe(182, 62, 194, 108),
                "wL": PoseKeyframe(110, 30, 112, 96), "wR": PoseKeyframe(190, 30, 188, 96),
            ],
            segments: [
                PoseSegment("shL", "shR", 9), PoseSegment("neckC", "hipC", 13),
                PoseSegment("shL", "eL", 7), PoseSegment("eL", "wL", 6),
                PoseSegment("shR", "eR", 7), PoseSegment("eR", "wR", 6),
                PoseSegment("hipC", "kneeL", 9), PoseSegment("kneeL", "ankL", 7),
                PoseSegment("hipC", "kneeR", 9), PoseSegment("kneeR", "ankR", 7),
            ],
            bars: [PoseBar(150, 28, 150, 94, len: 96)],
            cables: [PoseCable(bar: 0, toX: 150, toY: 8)],
            musclesOverlay: [.line(a: "shL", b: "hipC", w: 9), .line(a: "shR", b: "hipC", w: 9)],
            labelAt: p(240, 140), leaderFrom: p(162, 120),
            scaffold: PoseScaffold(floorY: 230, lines: [.init(150, 164, 150, 230, 2)],
                                   rects: [.init(122, 156, 56, 8)]),
            dots: ["shL", "shR", "eL", "eR"]
        ),
        ExercisePose(
            id: "barbell-row", exerciseName: "Barbell Row",
            target: "LATS",
            feel: "Lats and mid-back pulling the elbow past the ribs — not the biceps.",
            tempo: "2-1-2 · 4×10", muscles: "Back",
            glow: .end,
            head: PoseHead(200, 108, r: 11),
            joints: [
                "ankle": PoseKeyframe(150, 222), "toe": PoseKeyframe(176, 222),
                "knee": PoseKeyframe(158, 182), "hip": PoseKeyframe(122, 146),
                "shoulder": PoseKeyframe(184, 114),
                "elbow": PoseKeyframe(186, 148, 156, 156),
                "wrist": PoseKeyframe(188, 180, 178, 136),
            ],
            segments: [
                PoseSegment("ankle", "toe", 6), PoseSegment("ankle", "knee", 9),
                PoseSegment("knee", "hip", 12), PoseSegment("hip", "shoulder", 13),
                PoseSegment("shoulder", "elbow", 7), PoseSegment("elbow", "wrist", 6),
            ],
            bars: [PoseBar(188, 186, 180, 132, r: 14)],
            musclesOverlay: [.ellipse(a: p(156, 128), rx: 15, ry: 7, rot: -14)],
            labelAt: p(255, 170), leaderFrom: p(165, 133),
            scaffold: PoseScaffold(floorY: 230),
            dots: ["ankle", "knee", "hip", "shoulder", "elbow"]
        ),
        ExercisePose(
            id: "db-row", exerciseName: "Dumbbell Row",
            target: "LATS",
            feel: "One side of the back rowing the bell to the hip — no torso twist.",
            tempo: "2-1-2 · 3×12", muscles: "Back",
            glow: .end,
            head: PoseHead(228, 102, r: 11),
            joints: [
                "kneeB": PoseKeyframe(120, 166), "ankB": PoseKeyframe(158, 164),
                "hip": PoseKeyframe(130, 120), "shoulder": PoseKeyframe(210, 110),
                "sElb": PoseKeyframe(216, 140), "sWr": PoseKeyframe(218, 166),
                "kneeS": PoseKeyframe(150, 172), "ankS": PoseKeyframe(146, 222),
                "toeS": PoseKeyframe(168, 222),
                "elbow": PoseKeyframe(207, 144, 196, 98),
                "wrist": PoseKeyframe(208, 178, 202, 132),
            ],
            segments: [
                PoseSegment("hip", "shoulder", 13), PoseSegment("hip", "kneeB", 10),
                PoseSegment("kneeB", "ankB", 8), PoseSegment("hip", "kneeS", 10),
                PoseSegment("kneeS", "ankS", 8), PoseSegment("ankS", "toeS", 6),
                PoseSegment("shoulder", "sElb", 6), PoseSegment("sElb", "sWr", 5),
                PoseSegment("shoulder", "elbow", 8), PoseSegment("elbow", "wrist", 7),
            ],
            bars: [PoseBar(follow: "wrist", r: 7)],
            musclesOverlay: [.ellipse(a: p(180, 116), rx: 14, ry: 7, rot: -6)],
            labelAt: p(258, 60), leaderFrom: p(186, 110),
            scaffold: PoseScaffold(floorY: 230, lines: [.init(105, 178, 105, 230, 2), .init(210, 178, 210, 230, 2)],
                                   rects: [.init(90, 170, 140, 8)]),
            dots: ["hip", "shoulder", "elbow", "kneeB"]
        ),
        ExercisePose(
            id: "t-bar-row", exerciseName: "T-Bar Row",
            target: "MID-BACK",
            feel: "Mid-back squeezing the plates to the chest — the lever fixes the arc.",
            tempo: "2-1-2 · 4×10", muscles: "Back",
            glow: .end,
            head: PoseHead(200, 108, r: 11),
            joints: [
                "ankle": PoseKeyframe(150, 222), "toe": PoseKeyframe(176, 222),
                "knee": PoseKeyframe(158, 182), "hip": PoseKeyframe(122, 146),
                "shoulder": PoseKeyframe(184, 114),
                "elbow": PoseKeyframe(186, 148, 156, 156),
                "wrist": PoseKeyframe(188, 180, 178, 136),
            ],
            segments: [
                PoseSegment("ankle", "toe", 6), PoseSegment("ankle", "knee", 9),
                PoseSegment("knee", "hip", 12), PoseSegment("hip", "shoulder", 13),
                PoseSegment("shoulder", "elbow", 7), PoseSegment("elbow", "wrist", 6),
            ],
            bars: [PoseBar(188, 186, 180, 138, r: 12)],
            cables: [PoseCable(bar: 0, toX: 332, toY: 226)],
            musclesOverlay: [.ellipse(a: p(156, 128), rx: 15, ry: 7, rot: -14)],
            labelAt: p(250, 80), leaderFrom: p(160, 120),
            scaffold: PoseScaffold(floorY: 230),
            dots: ["ankle", "knee", "hip", "shoulder", "elbow"]
        ),
        ExercisePose(
            id: "seated-cable-row", exerciseName: "Seated Cable Row",
            target: "LATS · MID-BACK",
            feel: "Handle to the belly button, elbows skimming the ribs — chest stays proud.",
            tempo: "2-1-2 · 4×10", muscles: "Back",
            glow: .end,
            head: PoseHead(126, 76, r: 12),
            joints: [
                "hip": PoseKeyframe(130, 160), "knee": PoseKeyframe(195, 152),
                "ankle": PoseKeyframe(240, 170), "shoulder": PoseKeyframe(128, 96),
                "elbow": PoseKeyframe(160, 110, 108, 122),
                "wrist": PoseKeyframe(200, 112, 150, 118),
            ],
            segments: [
                PoseSegment("hip", "shoulder", 13), PoseSegment("hip", "knee", 11),
                PoseSegment("knee", "ankle", 8), PoseSegment("shoulder", "elbow", 8),
                PoseSegment("elbow", "wrist", 7),
            ],
            bars: [PoseBar(follow: "wrist", r: 5)],
            cables: [PoseCable(bar: 0, toX: 254, toY: 118)],
            musclesOverlay: [.ellipse(a: p(122, 126), rx: 7, ry: 14, rot: 8)],
            labelAt: p(225, 50), leaderFrom: p(130, 110),
            scaffold: PoseScaffold(floorY: 230, lines: [.init(254, 96, 254, 204, 5), .init(132, 174, 132, 230, 2)],
                                   rects: [.init(100, 166, 64, 8)]),
            dots: ["hip", "knee", "shoulder", "elbow"]
        ),
        ExercisePose(
            id: "unilateral-seated-row", exerciseName: "Unilateral Seated Row",
            target: "LATS (UNILATERAL)",
            feel: "One lat doing all the work — feel the stretch forward, row without rotating.",
            tempo: "2-1-2 · 3×12 / side", muscles: "Back",
            glow: .end,
            head: PoseHead(126, 76, r: 12),
            joints: [
                "hip": PoseKeyframe(130, 160), "knee": PoseKeyframe(195, 152),
                "ankle": PoseKeyframe(240, 170), "shoulder": PoseKeyframe(128, 96),
                "elbow": PoseKeyframe(164, 108, 104, 122),
                "wrist": PoseKeyframe(204, 112, 144, 118),
            ],
            segments: [
                PoseSegment("hip", "shoulder", 13), PoseSegment("hip", "knee", 11),
                PoseSegment("knee", "ankle", 8), PoseSegment("shoulder", "elbow", 8),
                PoseSegment("elbow", "wrist", 7),
            ],
            bars: [PoseBar(follow: "wrist", r: 5)],
            cables: [PoseCable(bar: 0, toX: 254, toY: 118)],
            musclesOverlay: [.ellipse(a: p(122, 126), rx: 7, ry: 14, rot: 8)],
            labelAt: p(225, 50), leaderFrom: p(130, 110),
            scaffold: PoseScaffold(floorY: 230, lines: [.init(254, 96, 254, 204, 5), .init(132, 174, 132, 230, 2)],
                                   rects: [.init(100, 166, 64, 8)]),
            dots: ["hip", "knee", "shoulder", "elbow"]
        ),
        ExercisePose(
            id: "shrugs", exerciseName: "Shrugs",
            target: "TRAPEZIUS",
            feel: "Straight up toward the ears, two-second squeeze at the top — no rolling.",
            tempo: "2-2-2 · 3×15", muscles: "Back · Traps",
            glow: .end,
            head: PoseHead(150, 58, r: 12),
            joints: [
                "ankle": PoseKeyframe(150, 222), "toe": PoseKeyframe(176, 222),
                "knee": PoseKeyframe(150, 174), "hip": PoseKeyframe(150, 128),
                "shoulder": PoseKeyframe(150, 82, 150, 72),
                "elbow": PoseKeyframe(152, 112, 152, 104),
                "wrist": PoseKeyframe(153, 142, 153, 134),
            ],
            segments: [
                PoseSegment("ankle", "toe", 6), PoseSegment("ankle", "knee", 9),
                PoseSegment("knee", "hip", 12), PoseSegment("hip", "shoulder", 13),
                PoseSegment("shoulder", "elbow", 7), PoseSegment("elbow", "wrist", 6),
            ],
            bars: [PoseBar(follow: "wrist", r: 8)],
            musclesOverlay: [.ellipse(a: p(160, 76), b: p(160, 66), rx: 10, ry: 5, rot: -24)],
            labelAt: p(216, 40), leaderFrom: p(166, 66),
            scaffold: PoseScaffold(floorY: 230),
            dots: ["ankle", "knee", "hip", "shoulder"]
        ),
    ]
}

// MARK: - Pull · Rear Delts

private extension ExercisePoses {
    static let rearDelts: [ExercisePose] = [
        ExercisePose(
            id: "reverse-pec-deck", exerciseName: "Reverse Pec Deck",
            target: "REAR DELTS",
            feel: "Rear delts sweeping the arms wide — like opening a pair of doors.",
            tempo: "2-1-2 · 3×15", muscles: "Shoulders",
            glow: .end, view: .front,
            head: PoseHead(150, 58, r: 12),
            joints: [
                "neckC": PoseKeyframe(150, 74), "hipC": PoseKeyframe(150, 148),
                "shL": PoseKeyframe(128, 80), "shR": PoseKeyframe(172, 80),
                "kneeL": PoseKeyframe(132, 188), "kneeR": PoseKeyframe(168, 188),
                "ankL": PoseKeyframe(130, 222), "ankR": PoseKeyframe(170, 222),
                "eL": PoseKeyframe(118, 110, 92, 92), "eR": PoseKeyframe(182, 110, 208, 92),
                "wL": PoseKeyframe(138, 92, 76, 70), "wR": PoseKeyframe(162, 92, 224, 70),
            ],
            segments: [
                PoseSegment("shL", "shR", 9), PoseSegment("neckC", "hipC", 13),
                PoseSegment("shL", "eL", 7), PoseSegment("eL", "wL", 6),
                PoseSegment("shR", "eR", 7), PoseSegment("eR", "wR", 6),
                PoseSegment("hipC", "kneeL", 9), PoseSegment("kneeL", "ankL", 7),
                PoseSegment("hipC", "kneeR", 9), PoseSegment("kneeR", "ankR", 7),
            ],
            bars: [PoseBar(follow: "wL", r: 6), PoseBar(follow: "wR", r: 6)],
            musclesOverlay: [.ellipse(a: p(124, 82), rx: 7, ry: 7), .ellipse(a: p(176, 82), rx: 7, ry: 7)],
            labelAt: p(230, 40), leaderFrom: p(180, 78),
            scaffold: PoseScaffold(floorY: 230, lines: [.init(150, 162, 150, 230, 2)],
                                   rects: [.init(122, 154, 56, 8)]),
            dots: ["shL", "shR", "eL", "eR"]
        ),
        ExercisePose(
            id: "face-pulls", exerciseName: "Face Pulls",
            target: "REAR DELTS",
            feel: "Rope to the bridge of the nose, elbows high and wide — rear delts and rotators.",
            tempo: "2-1-2 · 3×15", muscles: "Shoulders",
            glow: .end,
            head: PoseHead(143, 62, r: 12),
            joints: [
                "ankle": PoseKeyframe(150, 222), "toe": PoseKeyframe(176, 222),
                "knee": PoseKeyframe(150, 174), "hip": PoseKeyframe(148, 128),
                "shoulder": PoseKeyframe(146, 80),
                "elbow": PoseKeyframe(178, 90, 170, 66),
                "wrist": PoseKeyframe(212, 86, 166, 86),
            ],
            segments: [
                PoseSegment("ankle", "toe", 6), PoseSegment("ankle", "knee", 9),
                PoseSegment("knee", "hip", 12), PoseSegment("hip", "shoulder", 13),
                PoseSegment("shoulder", "elbow", 7), PoseSegment("elbow", "wrist", 6),
            ],
            bars: [PoseBar(follow: "wrist", r: 5)],
            cables: [PoseCable(bar: 0, toX: 344, toY: 54)],
            musclesOverlay: [.ellipse(a: p(152, 82), rx: 7, ry: 7)],
            labelAt: p(60, 120), leaderFrom: p(144, 86),
            scaffold: PoseScaffold(floorY: 230),
            dots: ["ankle", "knee", "hip", "shoulder", "elbow"]
        ),
    ]
}

// MARK: - Pull · Biceps

private extension ExercisePoses {
    static let biceps: [ExercisePose] = [
        ExercisePose(
            id: "barbell-curl", exerciseName: "Barbell Curl",
            target: "BICEPS",
            feel: "Biceps only — elbows pinned to your sides, squeeze at the top.",
            tempo: "2-1-2 · 3×12", muscles: "Biceps",
            glow: .end,
            head: PoseHead(150, 60, r: 12),
            joints: [
                "ankle": PoseKeyframe(150, 222), "toe": PoseKeyframe(176, 222),
                "knee": PoseKeyframe(150, 174), "hip": PoseKeyframe(150, 128),
                "shoulder": PoseKeyframe(150, 80), "elbow": PoseKeyframe(154, 118),
                "wrist": PoseKeyframe(158, 160, 120, 106),
            ],
            segments: [
                PoseSegment("ankle", "toe", 6), PoseSegment("ankle", "knee", 9),
                PoseSegment("knee", "hip", 12), PoseSegment("hip", "shoulder", 13),
                PoseSegment("shoulder", "elbow", 7), PoseSegment("elbow", "wrist", 6),
            ],
            bars: [PoseBar(159, 166, 116, 102, r: 10)],
            musclesOverlay: [.line(a: "shoulder", b: "elbow", w: 9)],
            labelAt: p(212, 90), leaderFrom: p(158, 100),
            scaffold: PoseScaffold(floorY: 230),
            dots: ["ankle", "knee", "hip", "shoulder", "elbow"]
        ),
        ExercisePose(
            id: "db-curl", exerciseName: "Dumbbell Curl",
            target: "BICEPS",
            feel: "Supinate as you curl — pinky turning up recruits the whole biceps.",
            tempo: "2-1-2 · 3×12", muscles: "Biceps",
            glow: .end,
            head: PoseHead(150, 60, r: 12),
            joints: [
                "ankle": PoseKeyframe(150, 222), "toe": PoseKeyframe(176, 222),
                "knee": PoseKeyframe(150, 174), "hip": PoseKeyframe(150, 128),
                "shoulder": PoseKeyframe(150, 80), "elbow": PoseKeyframe(154, 118),
                "wrist": PoseKeyframe(158, 160, 120, 106),
            ],
            segments: [
                PoseSegment("ankle", "toe", 6), PoseSegment("ankle", "knee", 9),
                PoseSegment("knee", "hip", 12), PoseSegment("hip", "shoulder", 13),
                PoseSegment("shoulder", "elbow", 7), PoseSegment("elbow", "wrist", 6),
            ],
            bars: [PoseBar(follow: "wrist", r: 7)],
            musclesOverlay: [.line(a: "shoulder", b: "elbow", w: 9)],
            labelAt: p(212, 90), leaderFrom: p(158, 100),
            scaffold: PoseScaffold(floorY: 230),
            dots: ["ankle", "knee", "hip", "shoulder", "elbow"]
        ),
        ExercisePose(
            id: "incline-db-curl", exerciseName: "Incline Dumbbell Curl",
            target: "BICEPS (STRETCH)",
            feel: "Arm hanging behind the torso — the deepest biceps stretch of any curl.",
            tempo: "3-1-2 · 3×10", muscles: "Biceps",
            glow: .end,
            head: PoseHead(110, 118, r: 12),
            joints: [
                "shoulder": PoseKeyframe(125, 135), "hip": PoseKeyframe(195, 192),
                "knee": PoseKeyframe(228, 198), "ankle": PoseKeyframe(230, 228),
                "toe": PoseKeyframe(248, 228), "elbow": PoseKeyframe(132, 168),
                "wrist": PoseKeyframe(136, 198, 104, 152),
            ],
            segments: [
                PoseSegment("shoulder", "hip", 13), PoseSegment("hip", "knee", 11),
                PoseSegment("knee", "ankle", 8), PoseSegment("ankle", "toe", 6),
                PoseSegment("shoulder", "elbow", 8), PoseSegment("elbow", "wrist", 7),
            ],
            bars: [PoseBar(follow: "wrist", r: 7)],
            musclesOverlay: [.line(a: "shoulder", b: "elbow", w: 8)],
            labelAt: p(250, 120), leaderFrom: p(136, 158),
            scaffold: PoseScaffold(floorY: 230,
                                   lines: [.init(98, 116, 206, 198, 6), .init(170, 200, 170, 230, 2)]),
            dots: ["shoulder", "hip", "knee", "elbow"]
        ),
        ExercisePose(
            id: "cable-curls", exerciseName: "Cable Curls",
            target: "BICEPS",
            feel: "The cable keeps tension at the bottom where dumbbells go slack.",
            tempo: "2-1-2 · 3×12", muscles: "Biceps",
            glow: .end,
            head: PoseHead(150, 60, r: 12),
            joints: [
                "ankle": PoseKeyframe(150, 222), "toe": PoseKeyframe(176, 222),
                "knee": PoseKeyframe(150, 174), "hip": PoseKeyframe(150, 128),
                "shoulder": PoseKeyframe(150, 80), "elbow": PoseKeyframe(154, 118),
                "wrist": PoseKeyframe(158, 160, 120, 106),
            ],
            segments: [
                PoseSegment("ankle", "toe", 6), PoseSegment("ankle", "knee", 9),
                PoseSegment("knee", "hip", 12), PoseSegment("hip", "shoulder", 13),
                PoseSegment("shoulder", "elbow", 7), PoseSegment("elbow", "wrist", 6),
            ],
            bars: [PoseBar(159, 166, 116, 102, r: 5)],
            cables: [PoseCable(bar: 0, toX: 286, toY: 226)],
            musclesOverlay: [.line(a: "shoulder", b: "elbow", w: 9)],
            labelAt: p(212, 90), leaderFrom: p(158, 100),
            scaffold: PoseScaffold(floorY: 230),
            dots: ["ankle", "knee", "hip", "shoulder", "elbow"]
        ),
        ExercisePose(
            id: "hammer-curls", exerciseName: "Hammer Curls",
            target: "BRACHIALIS",
            feel: "Neutral grip — brachialis and forearm thickening the whole arm.",
            tempo: "2-1-2 · 3×12", muscles: "Biceps",
            glow: .end,
            head: PoseHead(150, 60, r: 12),
            joints: [
                "ankle": PoseKeyframe(150, 222), "toe": PoseKeyframe(176, 222),
                "knee": PoseKeyframe(150, 174), "hip": PoseKeyframe(150, 128),
                "shoulder": PoseKeyframe(150, 80), "elbow": PoseKeyframe(154, 118),
                "wrist": PoseKeyframe(158, 160, 120, 106),
            ],
            segments: [
                PoseSegment("ankle", "toe", 6), PoseSegment("ankle", "knee", 9),
                PoseSegment("knee", "hip", 12), PoseSegment("hip", "shoulder", 13),
                PoseSegment("shoulder", "elbow", 7), PoseSegment("elbow", "wrist", 6),
            ],
            bars: [PoseBar(follow: "wrist", r: 7)],
            musclesOverlay: [.line(a: "shoulder", b: "elbow", w: 9)],
            labelAt: p(212, 90), leaderFrom: p(158, 100),
            scaffold: PoseScaffold(floorY: 230),
            dots: ["ankle", "knee", "hip", "shoulder", "elbow"]
        ),
    ]
}

// MARK: - Legs · Quads

private extension ExercisePoses {
    static let quads: [ExercisePose] = [
        ExercisePose(
            id: "squat", exerciseName: "Barbell Squat",
            target: "QUADRICEPS",
            feel: "Front of the thigh loading in the descent, glutes driving out of the hole.",
            tempo: "3-1-1 · 4×6", muscles: "Quads · Glutes",
            glow: .end,
            head: PoseHead(150, 52, 152, 102, r: 12),
            joints: [
                "ankle": PoseKeyframe(150, 222), "toe": PoseKeyframe(178, 222),
                "knee": PoseKeyframe(150, 172, 174, 178),
                "hip": PoseKeyframe(150, 120, 124, 166),
                "shoulder": PoseKeyframe(150, 70, 146, 120),
                "elbow": PoseKeyframe(136, 88, 126, 130),
                "wrist": PoseKeyframe(146, 74, 138, 122),
            ],
            segments: [
                PoseSegment("ankle", "toe", 6), PoseSegment("ankle", "knee", 9),
                PoseSegment("knee", "hip", 12), PoseSegment("hip", "shoulder", 13),
                PoseSegment("shoulder", "elbow", 6), PoseSegment("elbow", "wrist", 5),
            ],
            bars: [PoseBar(148, 66, 144, 116, r: 9)],
            musclesOverlay: [.line(a: "knee", b: "hip", w: 13)],
            labelAt: p(255, 127), leaderFrom: p(160, 165),
            scaffold: PoseScaffold(floorY: 230, plumbX: 148),
            dots: ["ankle", "knee", "hip", "shoulder"]
        ),
        ExercisePose(
            id: "hack-squat", exerciseName: "Hack Squat",
            target: "QUADRICEPS",
            feel: "Back braced on the pad — quads take everything, no balance tax.",
            tempo: "3-1-1 · 4×10", muscles: "Quads",
            glow: .end,
            head: PoseHead(236, 62, 216, 94, r: 11),
            joints: [
                "ankle": PoseKeyframe(136, 206), "toe": PoseKeyframe(112, 206),
                "knee": PoseKeyframe(168, 186, 128, 168),
                "hip": PoseKeyframe(190, 148, 168, 182),
                "shoulder": PoseKeyframe(224, 78, 204, 110),
                "elbow": PoseKeyframe(214, 96, 194, 128),
                "wrist": PoseKeyframe(204, 82, 184, 114),
            ],
            segments: [
                PoseSegment("ankle", "toe", 6), PoseSegment("ankle", "knee", 9),
                PoseSegment("knee", "hip", 12), PoseSegment("hip", "shoulder", 13),
                PoseSegment("shoulder", "elbow", 6), PoseSegment("elbow", "wrist", 5),
            ],
            musclesOverlay: [.line(a: "knee", b: "hip", w: 12)],
            labelAt: p(48, 80), leaderFrom: p(150, 175),
            scaffold: PoseScaffold(floorY: 230, lines: [.init(240, 52, 144, 222, 6), .init(90, 210, 170, 210, 4)]),
            dots: ["ankle", "knee", "hip", "shoulder"]
        ),
        ExercisePose(
            id: "leg-press", exerciseName: "Leg Press",
            target: "QUADRICEPS",
            feel: "Quads loading deep in the bend — press through mid-foot, knees never locked hard.",
            tempo: "3-1-1 · 4×12", muscles: "Quads",
            glow: .start,
            head: PoseHead(85, 104, r: 11),
            joints: [
                "hip": PoseKeyframe(140, 180), "shoulder": PoseKeyframe(95, 120),
                "knee": PoseKeyframe(160, 120, 196, 136),
                "ankle": PoseKeyframe(200, 100, 248, 90),
                "elbow": PoseKeyframe(118, 152), "wrist": PoseKeyframe(136, 166),
            ],
            segments: [
                PoseSegment("hip", "shoulder", 13), PoseSegment("hip", "knee", 12),
                PoseSegment("knee", "ankle", 9), PoseSegment("shoulder", "elbow", 6),
                PoseSegment("elbow", "wrist", 5),
            ],
            bars: [PoseBar(follow: "ankle", r: 12)],
            musclesOverlay: [.line(a: "hip", b: "knee", w: 12)],
            labelAt: p(250, 200), leaderFrom: p(155, 150),
            scaffold: PoseScaffold(floorY: 230,
                                   lines: [.init(74, 96, 148, 196, 6), .init(120, 200, 120, 230, 2),
                                           .init(160, 196, 160, 230, 2)]),
            dots: ["hip", "knee", "shoulder"]
        ),
        ExercisePose(
            id: "bulgarian-split-squat", exerciseName: "Bulgarian Split Squat",
            target: "QUADS · GLUTES",
            feel: "Front leg owning the rep — rear foot is a kickstand, not a driver.",
            tempo: "3-1-1 · 3×10 / side", muscles: "Quads · Glutes",
            glow: .end,
            head: PoseHead(152, 54, 150, 98, r: 12),
            joints: [
                "ankle": PoseKeyframe(130, 222), "toe": PoseKeyframe(156, 222),
                "knee": PoseKeyframe(132, 172, 158, 178),
                "hip": PoseKeyframe(150, 120, 132, 164),
                "shoulder": PoseKeyframe(152, 72, 146, 116),
                "elbow": PoseKeyframe(142, 96, 130, 140),
                "wrist": PoseKeyframe(144, 124, 130, 166),
                "kneeR": PoseKeyframe(196, 176, 184, 200), "ankR": PoseKeyframe(252, 170),
            ],
            segments: [
                PoseSegment("ankle", "toe", 6), PoseSegment("ankle", "knee", 9),
                PoseSegment("knee", "hip", 12), PoseSegment("hip", "shoulder", 13),
                PoseSegment("shoulder", "elbow", 6), PoseSegment("elbow", "wrist", 5),
                PoseSegment("hip", "kneeR", 10), PoseSegment("kneeR", "ankR", 8),
            ],
            bars: [PoseBar(follow: "wrist", r: 7)],
            musclesOverlay: [.line(a: "knee", b: "hip", w: 12)],
            labelAt: p(36, 90), leaderFrom: p(134, 170),
            scaffold: PoseScaffold(floorY: 230, lines: [.init(246, 184, 246, 230, 2), .init(304, 184, 304, 230, 2)],
                                   rects: [.init(232, 176, 86, 8)]),
            dots: ["ankle", "knee", "hip", "kneeR"]
        ),
        ExercisePose(
            id: "walking-lunge", exerciseName: "Walking Lunge",
            target: "QUADS · GLUTES",
            feel: "Rear knee kissing the floor, front quad and glute lifting you into the next step.",
            tempo: "2-1-1 · 3×20 steps", muscles: "Quads · Glutes",
            glow: .end,
            head: PoseHead(150, 58, 148, 98, r: 12),
            joints: [
                "ankF": PoseKeyframe(120, 222), "toeF": PoseKeyframe(146, 222),
                "kneeF": PoseKeyframe(124, 176, 128, 172),
                "hip": PoseKeyframe(152, 124, 150, 164),
                "kneeR": PoseKeyframe(184, 180, 186, 208),
                "ankR": PoseKeyframe(210, 214, 208, 218),
                "toeR": PoseKeyframe(222, 220, 220, 224),
                "shoulder": PoseKeyframe(150, 76, 148, 116),
                "elbow": PoseKeyframe(152, 104, 150, 142),
                "wrist": PoseKeyframe(153, 132, 151, 168),
            ],
            segments: [
                PoseSegment("ankF", "toeF", 6), PoseSegment("ankF", "kneeF", 9),
                PoseSegment("kneeF", "hip", 12), PoseSegment("hip", "shoulder", 13),
                PoseSegment("hip", "kneeR", 11), PoseSegment("kneeR", "ankR", 8),
                PoseSegment("ankR", "toeR", 6), PoseSegment("shoulder", "elbow", 6),
                PoseSegment("elbow", "wrist", 5),
            ],
            bars: [PoseBar(follow: "wrist", r: 7)],
            musclesOverlay: [.line(a: "kneeF", b: "hip", w: 12)],
            labelAt: p(240, 70), leaderFrom: p(140, 150),
            scaffold: PoseScaffold(floorY: 230),
            dots: ["ankF", "kneeF", "hip", "kneeR"]
        ),
        ExercisePose(
            id: "leg-extension", exerciseName: "Leg Extension",
            target: "QUADRICEPS",
            feel: "Pure quad — pause and squeeze hard at full extension.",
            tempo: "2-1-2 · 3×15", muscles: "Quads",
            glow: .end,
            head: PoseHead(138, 75, r: 12),
            joints: [
                "hip": PoseKeyframe(145, 155), "knee": PoseKeyframe(195, 158),
                "ankle": PoseKeyframe(198, 205, 240, 150),
                "shoulder": PoseKeyframe(140, 95), "elbow": PoseKeyframe(152, 125),
                "wrist": PoseKeyframe(162, 150),
            ],
            segments: [
                PoseSegment("hip", "shoulder", 13), PoseSegment("hip", "knee", 12),
                PoseSegment("knee", "ankle", 9), PoseSegment("shoulder", "elbow", 6),
                PoseSegment("elbow", "wrist", 5),
            ],
            bars: [PoseBar(follow: "ankle", r: 7)],
            musclesOverlay: [.line(a: "hip", b: "knee", w: 11)],
            labelAt: p(240, 100), leaderFrom: p(175, 152),
            scaffold: PoseScaffold(floorY: 230, lines: [.init(114, 88, 114, 166, 6), .init(145, 168, 145, 230, 2)],
                                   rects: [.init(112, 160, 66, 8)]),
            dots: ["hip", "knee", "shoulder"]
        ),
    ]
}

// MARK: - Legs · Hamstrings & Glutes

private extension ExercisePoses {
    static let hamstringsGlutes: [ExercisePose] = [
        ExercisePose(
            id: "deadlift", exerciseName: "Conventional Deadlift",
            target: "POSTERIOR CHAIN",
            feel: "Hamstrings and glutes driving the floor away; lats pinning the bar to you.",
            tempo: "2-1-2 · 3×5", muscles: "Hamstrings · Glutes · Back",
            glow: .start,
            head: PoseHead(176, 96, 152, 58, r: 11),
            joints: [
                "ankle": PoseKeyframe(150, 222), "toe": PoseKeyframe(176, 222),
                "knee": PoseKeyframe(160, 184, 150, 176),
                "hip": PoseKeyframe(118, 152, 148, 128),
                "shoulder": PoseKeyframe(162, 106, 150, 76),
                "elbow": PoseKeyframe(167, 149, 152, 110),
                "wrist": PoseKeyframe(172, 192, 154, 146),
            ],
            segments: [
                PoseSegment("ankle", "toe", 6), PoseSegment("ankle", "knee", 9),
                PoseSegment("knee", "hip", 12), PoseSegment("hip", "shoulder", 13),
                PoseSegment("shoulder", "elbow", 7), PoseSegment("elbow", "wrist", 6),
            ],
            bars: [PoseBar(172, 198, 154, 152, r: 24)],
            musclesOverlay: [.line(a: "knee", b: "hip", w: 11)],
            labelAt: p(235, 70), leaderFrom: p(140, 160),
            scaffold: PoseScaffold(floorY: 230, plumbX: 166),
            dots: ["ankle", "knee", "hip", "shoulder"]
        ),
        ExercisePose(
            id: "romanian-deadlift", exerciseName: "Romanian Deadlift",
            target: "HAMSTRINGS",
            feel: "A deep stretch down the hamstrings as the hips travel back — glow peaks at the bottom.",
            tempo: "3-1-1 · 3×10", muscles: "Hamstrings · Glutes",
            glow: .end,
            head: PoseHead(150, 62, 200, 106, r: 11),
            joints: [
                "ankle": PoseKeyframe(150, 222), "toe": PoseKeyframe(176, 222),
                "knee": PoseKeyframe(150, 174, 155, 176),
                "hip": PoseKeyframe(150, 128, 122, 134),
                "shoulder": PoseKeyframe(150, 80, 184, 110),
                "elbow": PoseKeyframe(153, 108, 185, 142),
                "wrist": PoseKeyframe(155, 136, 186, 172),
            ],
            segments: [
                PoseSegment("ankle", "toe", 6), PoseSegment("ankle", "knee", 9),
                PoseSegment("knee", "hip", 12), PoseSegment("hip", "shoulder", 13),
                PoseSegment("shoulder", "elbow", 7), PoseSegment("elbow", "wrist", 6),
            ],
            bars: [PoseBar(156, 142, 187, 178, r: 16)],
            musclesOverlay: [.line(a: "knee", b: "hip", w: 11)],
            labelAt: p(42, 88), leaderFrom: p(136, 152),
            scaffold: PoseScaffold(floorY: 230, plumbX: 152),
            dots: ["ankle", "knee", "hip", "shoulder"]
        ),
        ExercisePose(
            id: "leg-curl", exerciseName: "Leg Curl",
            target: "HAMSTRINGS",
            feel: "Heels to the glutes — hamstrings curling, hips glued to the pad.",
            tempo: "2-1-2 · 3×12", muscles: "Hamstrings",
            glow: .end,
            head: PoseHead(95, 158, r: 12),
            joints: [
                "shoulder": PoseKeyframe(120, 168), "hip": PoseKeyframe(200, 168),
                "knee": PoseKeyframe(240, 172),
                "ankle": PoseKeyframe(284, 178, 232, 120),
                "sElb": PoseKeyframe(128, 186), "sWr": PoseKeyframe(112, 192),
            ],
            segments: [
                PoseSegment("shoulder", "hip", 13), PoseSegment("hip", "knee", 12),
                PoseSegment("knee", "ankle", 9), PoseSegment("shoulder", "sElb", 6),
                PoseSegment("sElb", "sWr", 5),
            ],
            bars: [PoseBar(follow: "ankle", r: 7)],
            musclesOverlay: [.line(a: "hip", b: "knee", w: 10)],
            labelAt: p(296, 214), leaderFrom: p(224, 172),
            scaffold: PoseScaffold(floorY: 230, lines: [.init(85, 180, 85, 230, 2), .init(238, 180, 238, 230, 2)],
                                   rects: [.init(68, 172, 196, 8)]),
            dots: ["shoulder", "hip", "knee"]
        ),
        ExercisePose(
            id: "seated-leg-curl", exerciseName: "Seated Leg Curl",
            target: "HAMSTRINGS",
            feel: "Hamstrings dragging the pad down and under — harder at long muscle length.",
            tempo: "2-1-2 · 3×12", muscles: "Hamstrings",
            glow: .end,
            head: PoseHead(138, 75, r: 12),
            joints: [
                "hip": PoseKeyframe(145, 155), "knee": PoseKeyframe(195, 158),
                "ankle": PoseKeyframe(240, 150, 200, 208),
                "shoulder": PoseKeyframe(140, 95), "elbow": PoseKeyframe(152, 125),
                "wrist": PoseKeyframe(162, 150),
            ],
            segments: [
                PoseSegment("hip", "shoulder", 13), PoseSegment("hip", "knee", 12),
                PoseSegment("knee", "ankle", 9), PoseSegment("shoulder", "elbow", 6),
                PoseSegment("elbow", "wrist", 5),
            ],
            bars: [PoseBar(follow: "ankle", r: 7)],
            musclesOverlay: [.line(a: "hip", b: "knee", w: 10)],
            labelAt: p(240, 80), leaderFrom: p(172, 150),
            scaffold: PoseScaffold(floorY: 230, lines: [.init(114, 88, 114, 166, 6), .init(145, 168, 145, 230, 2)],
                                   rects: [.init(112, 160, 66, 8)]),
            dots: ["hip", "knee", "shoulder"]
        ),
        ExercisePose(
            id: "hip-thrust", exerciseName: "Hip Thrust",
            target: "GLUTES",
            feel: "Glutes punching the hips to the ceiling — ribs down, chin tucked, full squeeze.",
            tempo: "2-2-1 · 4×10", muscles: "Glutes",
            glow: .end,
            head: PoseHead(90, 140, r: 12),
            joints: [
                "shoulder": PoseKeyframe(110, 152),
                "hip": PoseKeyframe(150, 196, 168, 152),
                "knee": PoseKeyframe(218, 176, 224, 162),
                "ankle": PoseKeyframe(220, 222), "toe": PoseKeyframe(244, 222),
                "elbow": PoseKeyframe(136, 178, 144, 158),
                "wrist": PoseKeyframe(150, 192, 162, 154),
            ],
            segments: [
                PoseSegment("shoulder", "hip", 13), PoseSegment("hip", "knee", 12),
                PoseSegment("knee", "ankle", 9), PoseSegment("ankle", "toe", 6),
                PoseSegment("shoulder", "elbow", 6), PoseSegment("elbow", "wrist", 5),
            ],
            bars: [PoseBar(152, 190, 170, 146, r: 14)],
            musclesOverlay: [.ellipse(a: p(146, 192), b: p(164, 150), rx: 9, ry: 9)],
            labelAt: p(252, 120), leaderFrom: p(178, 170),
            scaffold: PoseScaffold(floorY: 230, lines: [.init(55, 156, 55, 230, 2), .init(102, 156, 102, 230, 2)],
                                   rects: [.init(40, 148, 78, 8)]),
            dots: ["shoulder", "hip", "knee", "ankle"]
        ),
    ]
}

// MARK: - Legs · Calves

private extension ExercisePoses {
    static let calves: [ExercisePose] = [
        ExercisePose(
            id: "standing-calf-raise", exerciseName: "Standing Calf Raise",
            target: "CALVES",
            feel: "Full stretch off the block, then as tall on the toes as you can get.",
            tempo: "2-2-2 · 4×15", muscles: "Calves",
            glow: .end,
            head: PoseHead(150, 60, 148, 50, r: 12),
            joints: [
                "toe": PoseKeyframe(176, 222),
                "ankle": PoseKeyframe(150, 222, 146, 210),
                "knee": PoseKeyframe(150, 174, 148, 164),
                "hip": PoseKeyframe(150, 128, 148, 118),
                "shoulder": PoseKeyframe(150, 80, 148, 70),
                "elbow": PoseKeyframe(152, 110, 150, 100),
                "wrist": PoseKeyframe(153, 138, 151, 128),
            ],
            segments: [
                PoseSegment("ankle", "toe", 6), PoseSegment("ankle", "knee", 9),
                PoseSegment("knee", "hip", 12), PoseSegment("hip", "shoulder", 13),
                PoseSegment("shoulder", "elbow", 7), PoseSegment("elbow", "wrist", 6),
            ],
            bars: [PoseBar(follow: "wrist", r: 7)],
            musclesOverlay: [.line(a: "knee", b: "ankle", w: 9)],
            labelAt: p(220, 190), leaderFrom: p(154, 196),
            scaffold: PoseScaffold(floorY: 230, lines: [.init(160, 226, 206, 226, 4)]),
            dots: ["toe", "ankle", "knee", "hip"]
        ),
        ExercisePose(
            id: "seated-calf-raise", exerciseName: "Seated Calf Raise",
            target: "SOLEUS",
            feel: "Bent knee shifts the load to the soleus — slow and deep, pause both ends.",
            tempo: "2-2-2 · 4×15", muscles: "Calves",
            glow: .end,
            head: PoseHead(140, 76, r: 12),
            joints: [
                "hip": PoseKeyframe(145, 158),
                "knee": PoseKeyframe(190, 160, 188, 148),
                "ankle": PoseKeyframe(192, 218, 188, 204),
                "toe": PoseKeyframe(214, 218),
                "shoulder": PoseKeyframe(142, 96), "elbow": PoseKeyframe(152, 126),
                "wrist": PoseKeyframe(182, 152),
            ],
            segments: [
                PoseSegment("hip", "shoulder", 13), PoseSegment("hip", "knee", 11),
                PoseSegment("knee", "ankle", 8), PoseSegment("ankle", "toe", 6),
                PoseSegment("shoulder", "elbow", 6), PoseSegment("elbow", "wrist", 5),
            ],
            bars: [PoseBar(follow: "knee", r: 8)],
            musclesOverlay: [.line(a: "knee", b: "ankle", w: 8)],
            labelAt: p(250, 180), leaderFrom: p(192, 190),
            scaffold: PoseScaffold(floorY: 230, lines: [.init(140, 172, 140, 230, 2), .init(208, 222, 232, 222, 4)],
                                   rects: [.init(112, 164, 58, 8)]),
            dots: ["hip", "knee", "ankle"]
        ),
    ]
}

// MARK: - Core

private extension ExercisePoses {
    static let core: [ExercisePose] = [
        ExercisePose(
            id: "cable-crunchers", exerciseName: "Cable Crunchers",
            target: "ABDOMINALS",
            feel: "Ribs to hips — spine rounding down against the cable, hips staying put.",
            tempo: "2-1-2 · 3×15", muscles: "Abs",
            glow: .end,
            head: PoseHead(136, 92, 156, 132, r: 11),
            joints: [
                "knee": PoseKeyframe(150, 222), "ankle": PoseKeyframe(192, 222),
                "toe": PoseKeyframe(208, 216), "hip": PoseKeyframe(148, 172),
                "shoulder": PoseKeyframe(140, 110, 160, 150),
                "elbow": PoseKeyframe(152, 120, 172, 158),
                "wrist": PoseKeyframe(142, 100, 162, 140),
            ],
            segments: [
                PoseSegment("knee", "ankle", 8), PoseSegment("ankle", "toe", 6),
                PoseSegment("hip", "knee", 11), PoseSegment("hip", "shoulder", 13),
                PoseSegment("shoulder", "elbow", 7), PoseSegment("elbow", "wrist", 6),
            ],
            bars: [PoseBar(follow: "wrist", r: 5)],
            cables: [PoseCable(bar: 0, toX: 244, toY: 12)],
            musclesOverlay: [.ellipse(a: p(145, 142), b: p(156, 162), rx: 7, ry: 11, rot: -10)],
            labelAt: p(280, 120), leaderFrom: p(158, 150),
            scaffold: PoseScaffold(floorY: 230),
            dots: ["knee", "hip", "shoulder", "elbow"]
        ),
        ExercisePose(
            id: "leg-raise", exerciseName: "Leg Raise",
            target: "ABDOMINALS",
            feel: "Lower abs lifting the legs — low back pressed into the floor the whole way.",
            tempo: "2-1-2 · 3×15", muscles: "Abs",
            glow: .end,
            head: PoseHead(82, 214, r: 11),
            joints: [
                "shoulder": PoseKeyframe(105, 220), "hip": PoseKeyframe(180, 220),
                "knee": PoseKeyframe(230, 218, 196, 166),
                "ankle": PoseKeyframe(278, 218, 206, 118),
                "elbow": PoseKeyframe(130, 222), "wrist": PoseKeyframe(158, 222),
            ],
            segments: [
                PoseSegment("shoulder", "hip", 13), PoseSegment("hip", "knee", 11),
                PoseSegment("knee", "ankle", 9), PoseSegment("shoulder", "elbow", 6),
                PoseSegment("elbow", "wrist", 5),
            ],
            musclesOverlay: [.ellipse(a: p(150, 212), rx: 14, ry: 6)],
            labelAt: p(56, 110), leaderFrom: p(146, 206),
            scaffold: PoseScaffold(floorY: 230),
            dots: ["shoulder", "hip", "knee"]
        ),
        ExercisePose(
            id: "hanging-leg-raise", exerciseName: "Hanging Leg Raise",
            target: "ABDOMINALS",
            feel: "No swing — abs curling the pelvis up, knees rising past the hips.",
            tempo: "2-1-2 · 3×12", muscles: "Abs",
            glow: .end,
            head: PoseHead(160, 76, r: 11),
            joints: [
                "wrist": PoseKeyframe(168, 36), "elbow": PoseKeyframe(168, 66),
                "shoulder": PoseKeyframe(168, 96), "hip": PoseKeyframe(170, 150),
                "knee": PoseKeyframe(172, 192, 208, 134),
                "ankle": PoseKeyframe(174, 228, 198, 170),
            ],
            segments: [
                PoseSegment("shoulder", "hip", 13), PoseSegment("hip", "knee", 11),
                PoseSegment("knee", "ankle", 8), PoseSegment("shoulder", "elbow", 7),
                PoseSegment("elbow", "wrist", 6),
            ],
            musclesOverlay: [.ellipse(a: p(166, 128), b: p(176, 124), rx: 7, ry: 11)],
            labelAt: p(250, 90), leaderFrom: p(176, 120),
            scaffold: PoseScaffold(topBar: .init(y: 34, x1: 120, x2: 230)),
            dots: ["shoulder", "hip", "knee", "elbow"]
        ),
        ExercisePose(
            id: "ab-wheel-rollout", exerciseName: "Ab Wheel Rollout",
            target: "ABDOMINALS",
            feel: "Abs fighting extension as you reach out — hardest at the longest position.",
            tempo: "3-1-2 · 3×10", muscles: "Abs",
            glow: .end,
            head: PoseHead(180, 104, 244, 166, r: 11),
            joints: [
                "knee": PoseKeyframe(130, 222), "ankle": PoseKeyframe(92, 222),
                "toe": PoseKeyframe(80, 214),
                "hip": PoseKeyframe(130, 170, 164, 196),
                "shoulder": PoseKeyframe(168, 120, 230, 178),
                "elbow": PoseKeyframe(184, 142, 252, 192),
                "wrist": PoseKeyframe(198, 204, 272, 208),
            ],
            segments: [
                PoseSegment("knee", "ankle", 8), PoseSegment("ankle", "toe", 6),
                PoseSegment("knee", "hip", 11), PoseSegment("hip", "shoulder", 13),
                PoseSegment("shoulder", "elbow", 7), PoseSegment("elbow", "wrist", 6),
            ],
            bars: [PoseBar(202, 219, 276, 219, r: 11)],
            musclesOverlay: [.ellipse(a: p(150, 148), b: p(198, 190), rx: 8, ry: 12, rot: -30)],
            labelAt: p(46, 70), leaderFrom: p(148, 142),
            scaffold: PoseScaffold(floorY: 230),
            dots: ["knee", "hip", "shoulder", "elbow"]
        ),
    ]
}
