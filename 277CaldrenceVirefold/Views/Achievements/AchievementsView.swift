import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var glow = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ZStack(alignment: .bottomLeading) {
                        Image("img_banner")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 150)
                            .clipped()
                            .overlay {
                                LinearGradient(
                                    colors: [Color.clear, Color("AppBackground").opacity(0.95)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            }
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Milestones")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(Color("AppTextPrimary"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            Text("\(unlockedCount)/\(AchievementKind.allCases.count) unlocked")
                                .font(.subheadline)
                                .foregroundStyle(Color("AppPrimary"))
                                .lineLimit(1)
                        }
                        .padding(16)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: Color("AppPrimary").opacity(glow ? 0.45 : 0.15), radius: glow ? 18 : 8, y: 8)
                    .padding(.horizontal, 16)

                    LazyVStack(spacing: 12) {
                        ForEach(AchievementKind.allCases, id: \.rawValue) { kind in
                            achievementRow(kind)
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.bottom, 28)
            }
            .screenBackground(opacity: 0.18)
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                    glow = true
                }
                store.evaluateAchievements()
            }
        }
    }

    private var unlockedCount: Int {
        AchievementKind.allCases.filter { store.unlockedAchievements.contains($0.rawValue) || $0.isUnlocked(stats: store.stats) }.count
    }

    private func achievementRow(_ kind: AchievementKind) -> some View {
        let unlocked = store.unlockedAchievements.contains(kind.rawValue) || kind.isUnlocked(stats: store.stats)
        let progress = min(kind.progress(stats: store.stats), kind.goal)
        return SoftCard {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(unlocked ? Color("AppPrimary").opacity(0.3) : Color("AppBackground"))
                        .frame(width: 48, height: 48)
                    Image(systemName: kind.icon)
                        .foregroundStyle(unlocked ? Color("AppPrimary") : Color("AppTextSecondary"))
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(kind.title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(unlocked ? kind.celebrationLine : kind.detail)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    ProgressView(value: Double(progress), total: Double(kind.goal))
                        .tint(Color("AppPrimary"))
                    Text("\(progress)/\(kind.goal)")
                        .font(.caption2)
                        .foregroundStyle(Color("AppAccent"))
                        .lineLimit(1)
                }
                if unlocked {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .opacity(unlocked ? 1 : 0.72)
    }
}
