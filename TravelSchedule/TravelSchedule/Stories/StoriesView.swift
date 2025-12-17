import SwiftUI
import Combine

struct StoriesView: View {
    
    struct Configuration {
        let timerTickInternal: TimeInterval
        let progressPerTick: CGFloat
        
        init(
            storiesCount: Int,
            secondsPerStory: TimeInterval = 10,
            timerTickInternal: TimeInterval = 0.05
        ) {
            self.timerTickInternal = timerTickInternal
            self.progressPerTick = 1.0 / CGFloat(storiesCount) / secondsPerStory * timerTickInternal
        }
    }
    
    private let stories: [Story]
    private let configuration: Configuration
    private var currentStory: Story { stories[currentIndex] }
    private var currentStoryIndex: Int { Int(progress * CGFloat(stories.count)) }
    @State private var progress: CGFloat = 0
    @State private var timer: Timer.TimerPublisher
    @State private var cancellable: Cancellable?
    @State private var currentIndex: Int = 0
    
    @Binding var viewedStories: Set<Int>
    private let initialStoryIndex: Int
    
    init(
        initialStoryIndex: Int = 0,
        viewedStories: Binding<Set<Int>>,
        stories: [Story] = Story.allStories
    ) {
        self.initialStoryIndex = initialStoryIndex
        self._viewedStories = viewedStories
        self.stories = stories
        configuration = Configuration(storiesCount: stories.count)
        timer = Self.createTimer(configuration: configuration)
        _currentIndex = State(initialValue: initialStoryIndex)
    }
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        ZStack(alignment: .topTrailing ) {
            Color("appBlackUniversal")
                .ignoresSafeArea()
            StoryView(story: currentStory)
                .overlay(
                    ZStack (alignment: .topTrailing) {
                        ProgressBar(numberOfSections: stories.count, progress: progress)
                            .padding(.init(top: 80, leading: 16, bottom: 12, trailing: 16))
                        CloseButton(action: {
                            dismiss()
                        })
                        .padding(.top, 105)
                        .padding(.trailing, 8)
                    }
                )
        }
        .onAppear {
            markAsViewed(currentIndex)
            timer = Self.createTimer(configuration: configuration)
            cancellable = timer.connect()
        }
        .onDisappear {
            cancellable?.cancel()
        }
        .onReceive(timer) { _ in
            timerTick()
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onEnded { value in
                    let horizontalAmount = value.translation.width
                    let verticalAmount = value.translation.height
                    let distance = sqrt(pow(horizontalAmount, 2) + pow(verticalAmount, 2))
                    
                    if distance > 20 {
                        if abs(horizontalAmount) > abs(verticalAmount) {
                            if horizontalAmount < 0 {
                                nextStory()
                                resetTimer()
                            } else if horizontalAmount > 0 {
                                previousStory()
                                resetTimer()
                            }
                        } else {
                            if verticalAmount > 0 {
                                dismiss()
                            }
                        }
                    } else {
                        let location = value.location.x
                        let screenWidth = UIScreen.main.bounds.width
                        
                        if location > screenWidth / 2 {
                            nextStory()
                            resetTimer()
                        } else {
                            previousStory()
                            resetTimer()
                        }
                    }
                }
        )
    }
    
    private func timerTick() {
        var nextProgress = progress + configuration.progressPerTick
        if nextProgress >= 1 {
            markAsViewed(currentIndex)
            if currentIndex == stories.count - 1 {
                dismiss()
                return
            } else {
                nextProgress = 0
                currentIndex = 0
            }
        }
        
        let newIndex = Int(nextProgress * CGFloat(stories.count))
        if newIndex != currentIndex {
            markAsViewed(currentIndex)
            currentIndex = newIndex
        }
        progress = nextProgress
    }
    
    private func nextStory() {
        markAsViewed(currentIndex)
        
        let storiesCount = stories.count
        
        if currentIndex == storiesCount - 1 {
            dismiss()
            return
        }
        currentIndex = currentIndex + 1 < storiesCount ? currentIndex + 1 : 0
        withAnimation {
            progress = CGFloat(currentIndex) / CGFloat(storiesCount)
        }
    }
    
    private func previousStory() {
        let storiesCount = stories.count
        
        if currentIndex == 0 {
            withAnimation {
                progress = 0.0
            }
            resetTimer()
            return
        }
        
        markAsViewed(currentIndex)
        currentIndex = currentIndex - 1 >= 0 ? currentIndex - 1 : storiesCount - 1
        withAnimation {
            progress = CGFloat(currentIndex) / CGFloat(storiesCount)
        }
    }
    
    private func resetTimer() {
        cancellable?.cancel()
        timer = Self.createTimer(configuration: configuration)
        cancellable = timer.connect()
    }
    
    private static func createTimer(configuration: Configuration) -> Timer.TimerPublisher {
        Timer.publish(every: configuration.timerTickInternal, on: .main, in: .common)
    }
    
    private func markAsViewed(_ index: Int) {
        viewedStories.insert(index)
    }
}

#Preview {
    StoriesView(viewedStories: .constant([]))
}
