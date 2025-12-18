import SwiftUI

struct Story {
    let backgroundColor: Color
    let image: Image
    let title: String
    let description: String
    let cardTitle: String
    
    static let allStories: [Story] = [
        .story1,
        .story2,
        .story3,
        .story4,
        .story5
    ]
    
    static let story1 = Story(
        backgroundColor: .appBlackUniversal,
        image: Image(ImageResource .story0),
        title: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text",
        description: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text",
        cardTitle: "Text"
    )
    
    static let story2 = Story(
        backgroundColor: .appBlackUniversal,
        image: Image(ImageResource .story1),
        title: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text",
        description: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text",
        cardTitle: "Text"
    )
    
    static let story3 = Story(
        backgroundColor: .appBlackUniversal,
        image: Image(ImageResource .story2),
        title: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text",
        description: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text",
        cardTitle: "Text"
    )
    
    static let story4 = Story(
        backgroundColor: .appBlackUniversal,
        image: Image(ImageResource .story0),
        title: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text",
        description: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text",
        cardTitle: "Text"
    )
    
    static let story5 = Story(
        backgroundColor: .appBlackUniversal,
        image: Image(ImageResource .story1),
        title: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text",
        description: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text",
        cardTitle: "Text"
    )
    
}
