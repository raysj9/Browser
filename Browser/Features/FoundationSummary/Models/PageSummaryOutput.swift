import FoundationModels

@Generable
struct PageSummaryOutput {
    var title: String
    var tldr: String

    @Guide(description: "Exactly five key points", .count(5))
    var key_points: [String]

    @Guide(description: "Exactly three important details", .count(3))
    var important_details: [String]
}
