import Foundation
import SwiftUI

// https://github.com/pointfreeco/swiftui-navigation/discussions/37#discussioncomment-4219724
// https://gist.github.com/tgrapperon/e92d7699b2a6ca8093bdf2cb1abb3376

public extension ButtonStyle where Self == NavigationButtonStyle {
    static var navigation: NavigationButtonStyle { .init() }
}

public struct NavigationButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        NavigationLink {} label: {
            configuration.label
        }.background(
            ListRowInteractor(
                isSelected: configuration.isPressed
            )
        )
    }

    #if os(iOS)
        struct ListRowInteractor: UIViewRepresentable {
            let isSelected: Bool

            func makeUIView(context _: Context) -> CollectionViewCellFinder {
                CollectionViewCellFinder()
            }

            func updateUIView(_ uiView: CollectionViewCellFinder, context _: Context) {
                uiView.setSelected(isSelected)
            }

            final class CollectionViewCellFinder: UIView {
                func setSelected(_ isSelected: Bool) {
                    collectionViewCell(from: self)?.isSelected = isSelected
                }

                func collectionViewCell(from view: UIView?) -> UICollectionViewCell? {
                    guard let view else { return nil }
                    return (view as? UICollectionViewCell) ?? collectionViewCell(from: view.superview)
                }
            }
        }

    #elseif os(macOS)
        struct ListRowInteractor: NSViewRepresentable {
            let isSelected: Bool

            func makeNSView(context _: Context) -> TableRowFinder {
                TableRowFinder()
            }

            func updateNSView(_ nsView: TableRowFinder, context _: Context) {
                nsView.setSelected(isSelected)
            }

            final class TableRowFinder: NSView {
                func setSelected(_ isSelected: Bool) {
                    tableRowView(from: self)?.isSelected = isSelected
                }

                func tableRowView(from view: NSView?) -> NSTableRowView? {
                    guard let view else { return nil }
                    return (view as? NSTableRowView) ?? tableRowView(from: view.superview)
                }
            }
        }
    #endif
}
