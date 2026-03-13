import Foundation

struct ServingUnit: Identifiable, Hashable {
    let name: String
    let gramEquivalent: Double
    var id: String { name }
}
