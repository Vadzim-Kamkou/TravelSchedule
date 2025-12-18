import SwiftUI

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var filterSettings: FilterSettings

    @State private var selectedTimes: Set<DepartureTime> = []
    @State private var showTransfers: TransferOption = .yes
    
    @State private var hasChanges: Bool = false
    
    init(filterSettings: Binding<FilterSettings>) {
        self._filterSettings = filterSettings
        
        self._selectedTimes = State(initialValue: filterSettings.wrappedValue.selectedTimes)
        self._showTransfers = State(initialValue: filterSettings.wrappedValue.showTransfers)
    }
    
    var body: some View {
        ZStack {
            Color.appWhite.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                Text("filter_departure_time")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.appBlack)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                
                VStack(spacing: 0) {
                    ForEach(DepartureTime.allCases) { time in
                        TimeFilterRow(
                            title: time.displayText,
                            isSelected: selectedTimes.contains(time)
                        ) {
                            toggleTime(time)
                        }
                    }
                }
                .padding(.top, 16)
                
                Text("filter_show_transfers")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.appBlack)
                    .padding(.top, 32)
                    .padding(.horizontal, 16)
                
                VStack(spacing: 0) {
                    ForEach(TransferOption.allCases) { option in
                        TransferFilterRow(
                            title: option.displayText,
                            isSelected: showTransfers == option
                        ) {
                            selectTransfer(option)
                        }
                    }
                }
                .padding(.top, 16)
                
                Spacer()
                
                if hasChanges {
                    Button {
                        applyFilters()
                    } label: {
                        Text("filter_apply")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color.appBlueUniversal)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut(duration: 0.25), value: hasChanges)
    }
        
    private func toggleTime(_ time: DepartureTime) {
        if selectedTimes.contains(time) {
            selectedTimes.remove(time)
        } else {
            selectedTimes.insert(time)
        }
        updateHasChanges()
    }
    
    private func selectTransfer(_ option: TransferOption) {
        showTransfers = option
        updateHasChanges()
    }
    
    private func updateHasChanges() {
        hasChanges = selectedTimes != filterSettings.selectedTimes ||
        showTransfers != filterSettings.showTransfers
    }
    
    private func applyFilters() {
        filterSettings.selectedTimes = selectedTimes
        filterSettings.showTransfers = showTransfers
        
        dismiss()
    }
}

// MARK: - Time Filter Row (Checkbox)
struct TimeFilterRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 17))
                    .foregroundStyle(.appBlack)
                
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.appBlack, lineWidth: 2)
                        .frame(width: 24, height: 24)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(isSelected ? Color.appBlack : Color.clear)
                        )
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.appWhite)
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 60)
        }
        .buttonStyle(.plain)
    }
}

struct TransferFilterRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 17))
                    .foregroundStyle(.appBlack)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.appBlack, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.appBlack)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 60)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        FilterView(filterSettings: .constant(FilterSettings()))
    }
}
