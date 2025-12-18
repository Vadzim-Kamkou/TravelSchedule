import SwiftUI

struct StoryCardView: View {
    let story: Story
    let isViewed: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            story.image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 92, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 0) {
                Text(story.cardTitle)
            }
            .font(.system(size: 12))
            .foregroundStyle(.appWhiteUniversal)
            .padding(8)
        }
        .frame(width: 92, height: 140)
        .opacity(isViewed ? 0.5 : 1.0)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appBlueUniversal, lineWidth: isViewed ? 0 : 4)
        )
        .onTapGesture {
            onTap()
        }
    }
}
