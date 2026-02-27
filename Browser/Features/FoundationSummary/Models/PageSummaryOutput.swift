import FoundationModels

@Generable
struct PageSummaryOutput: Equatable {
    var title: String
    var tldr: String

    @Guide(description: "Exactly eight concrete details that cover the page's main points and important specifics", .count(8))
    var details: [String]
}
