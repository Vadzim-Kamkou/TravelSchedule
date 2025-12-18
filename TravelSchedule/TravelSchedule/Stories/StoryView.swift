import SwiftUI

struct StoryView: View {
    let story: Story

    var body: some View {
        ZStack(alignment: .leading) {
            Color.appBlackUniversal
                .ignoresSafeArea()
            
            story.image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 40))
                .padding(.top, 40)
                .padding(.bottom, 60)
            
            VStack(spacing: 16) {
                Spacer()
                Text(story.title)
                    .font(.bold34)
                    .lineLimit(2)
                    .foregroundStyle(.white)
                Text(story.description)
                    .font(.regular20)
                    .lineLimit(3)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
    }
}

#Preview {
    StoryView(story: .story1)
}
