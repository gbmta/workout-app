import Foundation

enum Influencer: String, Codable, CaseIterable, Identifiable {
    case samSulek = "Sam Sulek"
    case chrisBumstead = "Chris Bumstead"
    case jeffNippard = "Jeff Nippard"

    var id: String { rawValue }
}

/// Tip content is intentionally left empty in seed data — real cues need to be
/// sourced from each influencer's actual videos/content rather than invented,
/// since these are attributed to real people. Fill in per exercise later.
struct InfluencerTip: Identifiable, Codable, Hashable {
    let id: UUID
    var influencer: Influencer
    var tip: String
    var sourceURL: String?

    init(id: UUID = UUID(), influencer: Influencer, tip: String, sourceURL: String? = nil) {
        self.id = id
        self.influencer = influencer
        self.tip = tip
        self.sourceURL = sourceURL
    }
}
