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
    @State private var progress: CGFloat
    @State private var timer: Timer.TimerPublisher
    @State private var cancellable: Cancellable?
    @State private var currentIndex: Int = 0
    
    @Binding var viewedStories: Set<Int>
    private let initialStoryIndex: Int
    
    @State private var storyStartTime: Date? = nil
    private let minimumViewDuration: TimeInterval = 1.0
    
    init(
        initialStoryIndex: Int = 0,
        viewedStories: Binding<Set<Int>>,
        stories: [Story] = Story.allStories
    ) {
        self.initialStoryIndex = initialStoryIndex
        self._viewedStories = viewedStories
        
        self.stories = stories
        _currentIndex = State(initialValue: initialStoryIndex)
        _progress = State(initialValue: CGFloat(initialStoryIndex) / CGFloat(stories.count))
        
        configuration = Configuration(storiesCount: stories.count)
        timer = Self.createTimer(configuration: configuration)
    }
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        ZStack(alignment: .topTrailing ) {
            Color("appBlackUniversal")
                .ignoresSafeArea()
            StoryView(story: currentStory)
                .overlay(
                    ZStack (alignment: .topTrailing) {
                        ProgressBar(numberOfSections: stories.count, progress: progress)                            .padding(.init(top: 80, leading: 16, bottom: 12, trailing: 16))
                        CloseButton(action: {
                            dismiss()
                        })
                        .padding(.top, 105)
                        .padding(.trailing, 8)
                    }
                )
        }
        .onAppear {
            storyStartTime = Date()
            timer = Self.createTimer(configuration: configuration)
            cancellable = timer.connect()
        }
        .onDisappear {
            cancellable?.cancel()
            markAsViewed(currentIndex)
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
        let nextProgress = progress + configuration.progressPerTick
        
        if nextProgress >= 1 {
            markAsViewed(currentIndex)
            dismiss()
            return
        }
        
        let newIndex = Int(nextProgress * CGFloat(stories.count))
        if newIndex != currentIndex {
            markAsViewed(currentIndex)
            currentIndex = newIndex
            storyStartTime = Date()
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
        currentIndex += 1
        withAnimation {
            progress = CGFloat(currentIndex) / CGFloat(storiesCount)
        }
        storyStartTime = Date()
    }
    
    private func previousStory() {
        let storiesCount = stories.count
        
        if currentIndex == 0 {
            withAnimation {
                progress = 0.0
            }
            resetTimer()
            storyStartTime = Date()
            return
        }
        
        markAsViewed(currentIndex)
        currentIndex -= 1
        withAnimation {
            progress = CGFloat(currentIndex) / CGFloat(storiesCount)
        }
        storyStartTime = Date()
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
        if let startTime = storyStartTime,
           Date().timeIntervalSince(startTime) >= minimumViewDuration {
            viewedStories.insert(index)
        }
    }
}

#Preview {
    StoriesView(viewedStories: .constant([]))
}
