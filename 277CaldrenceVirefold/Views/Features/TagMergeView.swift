import SwiftUI

struct TagMergeView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var sourceId: UUID?
    @State private var targetId: UUID?

    private var library: [MusicTag] { store.libraryTags }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                SoftCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Merge duplicate tags")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("Source is removed. Songs and journal links move into the target.")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                if library.count < 2 {
                    SoftCard {
                        Text("Need at least two library tags to merge.")
                            .font(.subheadline)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .frame(maxWidth: .infinity)
                    }
                } else {
                    SoftCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Source (will be deleted)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color("AppTextSecondary"))
                            tagPicker(selection: $sourceId, excluding: targetId)

                            Text("Target (kept)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color("AppTextSecondary"))
                            tagPicker(selection: $targetId, excluding: sourceId)

                            Button {
                                guard let source = library.first(where: { $0.id == sourceId }),
                                      let target = library.first(where: { $0.id == targetId }) else {
                                    HapticService.warning()
                                    return
                                }
                                store.mergeTags(source: source, into: target)
                                sourceId = nil
                                targetId = nil
                            } label: {
                                Text("Merge Tags")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled(sourceId == nil || targetId == nil || sourceId == targetId)
                            .opacity(sourceId == nil || targetId == nil || sourceId == targetId ? 0.5 : 1)
                        }
                    }
                }
            }
            .padding(16)
        }
        .screenBackground(opacity: 0.16)
        .navigationTitle("Merge Tags")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private func tagPicker(selection: Binding<UUID?>, excluding: UUID?) -> some View {
        VStack(spacing: 8) {
            ForEach(library.filter { $0.id != excluding }) { tag in
                Button {
                    selection.wrappedValue = tag.id
                    HapticService.light()
                } label: {
                    HStack {
                        Text(tag.emoji)
                        Text(tag.name)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(1)
                        Spacer()
                        if selection.wrappedValue == tag.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color("AppPrimary"))
                        }
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(selection.wrappedValue == tag.id ? Color("AppPrimary").opacity(0.22) : Color("AppBackground").opacity(0.55))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
