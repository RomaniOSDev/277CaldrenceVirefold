import SwiftUI

struct TagRulesView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var keyword = ""
    @State private var tagName = ""
    @State private var emoji = "🏷️"

    private let emojiChoices = ["🏷️", "🌧️", "💪", "🌊", "🧘", "🎯", "🌙", "🎉", "☀️", "💕", "🎷", "📻"]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                SoftCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Auto-tag rules")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("When a journal note contains a keyword, the matching tag is applied.")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                        TextField("Keyword", text: $keyword)
                            .textInputAutocapitalization(.never)
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color("AppBackground").opacity(0.6)))
                        TextField("Tag name", text: $tagName)
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color("AppBackground").opacity(0.6)))
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 8) {
                            ForEach(emojiChoices, id: \.self) { item in
                                Text(item)
                                    .font(.title3)
                                    .padding(6)
                                    .background(Circle().fill(item == emoji ? Color("AppPrimary").opacity(0.35) : Color.clear))
                                    .onTapGesture { emoji = item }
                            }
                        }
                        Button {
                            store.addTagRule(keyword: keyword, tagName: tagName, emoji: emoji)
                            keyword = ""
                            tagName = ""
                        } label: {
                            Text("Add Rule")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }

                ForEach(store.tagRules) { rule in
                    SoftCard {
                        HStack {
                            Text(rule.emoji)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("“\(rule.keyword)” → \(rule.tagName)")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .lineLimit(2)
                            }
                            Spacer()
                            Button(role: .destructive) {
                                store.deleteTagRule(rule)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(16)
        }
        .screenBackground(opacity: 0.16)
        .navigationTitle("Tag Rules")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
