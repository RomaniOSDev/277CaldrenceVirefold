import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject private var store: AppDataStore

    private struct DayPoint: Identifiable {
        let id = UUID()
        let label: String
        let series: String
        let value: Int
    }

    private struct TagPoint: Identifiable {
        let id: UUID
        let name: String
        let emoji: String
        let count: Int
    }

    private struct MixSlice: Identifiable {
        let id = UUID()
        let title: String
        let value: Int
        let color: Color
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    overviewGrid
                    weekCompareCard
                    activityChartCard
                    topTagsChartCard
                    mixChartCard
                }
                .padding(16)
                .padding(.bottom, 12)
            }
            .screenBackground(opacity: 0.16)
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var overviewGrid: some View {
        SoftCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Overview")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    statTile("Tags", "\(store.stats.itemsAdded)", "tag.fill")
                    statTile("Entries", "\(store.stats.entriesWritten)", "book.fill")
                    statTile("Unique", "\(store.stats.uniqueTags)", "square.grid.2x2.fill")
                    statTile("Streak", "\(store.stats.streak)d", "flame.fill")
                }
            }
        }
    }

    private var weekCompareCard: some View {
        let thisWeek = store.weekSnapshot(offsetWeeks: 0)
        let lastWeek = store.weekSnapshot(offsetWeeks: 1)
        return SoftCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("This Week vs Last")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                Text("Compare tags created and notes written")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))

                compareRow(title: "Tags", current: thisWeek.tagsCreated, previous: lastWeek.tagsCreated)
                compareRow(title: "Entries", current: thisWeek.entriesWritten, previous: lastWeek.entriesWritten)
                compareRow(title: "Tracks logged", current: thisWeek.songsLogged, previous: lastWeek.songsLogged)
            }
        }
    }

    private func compareRow(title: String, current: Int, previous: Int) -> some View {
        let delta = current - previous
        let deltaText: String = {
            if delta > 0 { return "+\(delta)" }
            if delta < 0 { return "\(delta)" }
            return "±0"
        }()
        let tint = delta > 0 ? Color("AppPrimary") : (delta < 0 ? Color.red.opacity(0.85) : Color("AppTextSecondary"))
        return HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Color("AppTextPrimary"))
            Spacer()
            Text("\(current)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
            Text("vs \(previous)")
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
            Text(deltaText)
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
                .frame(minWidth: 36, alignment: .trailing)
        }
        .padding(.vertical, 2)
    }

    private var activityChartCard: some View {
        SoftCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Last 7 Days")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                Text("Tags created and journal entries by day")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)

                if activityPoints.allSatisfy({ $0.value == 0 }) {
                    emptyChartPlaceholder("Add tags or journal entries to see activity.")
                } else {
                    Chart(activityPoints) { point in
                        BarMark(
                            x: .value("Day", point.label),
                            y: .value("Count", point.value)
                        )
                        .foregroundStyle(by: .value("Series", point.series))
                        .position(by: .value("Series", point.series))
                        .cornerRadius(4)
                    }
                    .chartForegroundStyleScale([
                        "Tags": Color("AppPrimary"),
                        "Entries": Color("AppAccent")
                    ])
                    .chartLegend(position: .bottom, alignment: .leading)
                    .frame(height: 220)
                    .accessibilityLabel("Activity chart for the last seven days")
                }
            }
        }
    }

    private var topTagsChartCard: some View {
        SoftCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Top Tags by Songs")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                Text("Your library tags ranked by song count")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)

                if topTagPoints.isEmpty {
                    emptyChartPlaceholder("Create tags and set song counts to populate this chart.")
                } else {
                    Chart(topTagPoints) { point in
                        BarMark(
                            x: .value("Songs", point.count),
                            y: .value("Tag", "\(point.emoji) \(point.name)")
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color("AppPrimary"), Color("AppAccent")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(6)
                    }
                    .chartXAxis {
                        AxisMarks(position: .bottom)
                    }
                    .frame(height: CGFloat(max(180, topTagPoints.count * 36)))
                    .accessibilityLabel("Top tags by song count")
                }
            }
        }
    }

    private var mixChartCard: some View {
        SoftCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Collection Mix")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                Text("How your library breaks down right now")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)

                if mixSlices.allSatisfy({ $0.value == 0 }) {
                    emptyChartPlaceholder("Your collection mix will appear once you add content.")
                } else {
                    Chart(mixSlices) { slice in
                        BarMark(
                            x: .value("Count", slice.value),
                            y: .value("Category", slice.title)
                        )
                        .foregroundStyle(slice.color)
                        .cornerRadius(6)
                    }
                    .frame(height: 160)
                    .accessibilityLabel("Collection mix chart")

                    VStack(spacing: 8) {
                        ForEach(mixSlices) { slice in
                            HStack {
                                Circle()
                                    .fill(slice.color)
                                    .frame(width: 10, height: 10)
                                Text(slice.title)
                                    .font(.subheadline)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .lineLimit(1)
                                Spacer()
                                Text("\(slice.value)")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                        }
                    }
                }
            }
        }
    }

    private func emptyChartPlaceholder(_ message: String) -> some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(Color("AppTextSecondary"))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 36)
    }

    private func statTile(_ title: String, _ value: String, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(Color("AppPrimary"))
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color("AppBackground").opacity(0.55))
        )
    }

    private var activityPoints: [DayPoint] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE"
        let today = calendar.startOfDay(for: Date())

        var points: [DayPoint] = []
        for offset in (0..<7).reversed() {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let label = formatter.string(from: day)
            let tagCount = store.libraryTags.filter { calendar.isDate($0.createdAt, inSameDayAs: day) }.count
            let entryCount = store.entries.filter { calendar.isDate($0.date, inSameDayAs: day) }.count
            points.append(DayPoint(label: label, series: "Tags", value: tagCount))
            points.append(DayPoint(label: label, series: "Entries", value: entryCount))
        }
        return points
    }

    private var topTagPoints: [TagPoint] {
        store.libraryTags
            .sorted { $0.songCount > $1.songCount }
            .prefix(6)
            .filter { $0.songCount > 0 }
            .map { TagPoint(id: $0.id, name: $0.name, emoji: $0.emoji, count: $0.songCount) }
    }

    private var mixSlices: [MixSlice] {
        [
            MixSlice(title: "Library Tags", value: store.libraryTags.count, color: Color("AppPrimary")),
            MixSlice(title: "Favorites", value: store.favoriteTags.count, color: Color("AppAccent")),
            MixSlice(title: "Journal Entries", value: store.entries.count, color: Color("AppTextSecondary"))
        ]
    }
}
