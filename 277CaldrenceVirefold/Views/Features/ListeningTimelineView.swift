import SwiftUI

struct ListeningTimelineView: View {
    @EnvironmentObject private var store: AppDataStore

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                if store.timelineItems().isEmpty {
                    SoftCard {
                        VStack(spacing: 12) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 36))
                                .foregroundStyle(Color("AppPrimary"))
                            Text("Timeline is empty")
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text("Add tags or journal notes to fill your listening history.")
                                .font(.subheadline)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                    }
                } else {
                    ForEach(store.timelineItems()) { item in
                        SoftCard {
                            HStack(alignment: .top, spacing: 12) {
                                Text(item.emoji)
                                    .font(.title2)
                                    .frame(width: 40)
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(item.title)
                                            .font(.headline)
                                            .foregroundStyle(Color("AppTextPrimary"))
                                            .lineLimit(1)
                                        Spacer()
                                        Text(item.date, style: .date)
                                            .font(.caption2)
                                            .foregroundStyle(Color("AppTextSecondary"))
                                    }
                                    Text(item.kind == .tag ? "TAG" : "JOURNAL")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(Color("AppAccent"))
                                    Text(item.detail)
                                        .font(.subheadline)
                                        .foregroundStyle(Color("AppTextSecondary"))
                                        .lineLimit(4)
                                }
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .screenBackground(opacity: 0.16)
        .navigationTitle("Listening History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
