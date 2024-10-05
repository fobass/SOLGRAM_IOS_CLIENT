//
//  QuoteTabsView.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 1/25/24.
//

import SwiftUI

extension View {
    /// - Parameters:
    ///   - id: used to differentiate a view and its ancestor if they both call `readFrame`
    /// - Note: `onChange` maybe called with duplicated values
    public func readFrame(in space: CoordinateSpace, id: String = "shared", onChange: @escaping (CGRect) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color
                    .clear
                    .preference(
                        key: FramePreferenceKey.self,
                        value: [.init(space: space, id: id): proxy.frame(in: space)])
            }
        )
        .onPreferenceChange(FramePreferenceKey.self) {
            onChange($0[.init(space: space, id: id)] ?? .zero)
        }
    }
}

private struct FramePreferenceKey: PreferenceKey {
    static var defaultValue: [PreferenceValueKey: CGRect] = [:]
    
    static func reduce(value: inout [PreferenceValueKey: CGRect], nextValue: () -> [PreferenceValueKey: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}

private struct PreferenceValueKey: Hashable {
    let space: CoordinateSpace
    let id: String
}

public struct ScrollSlidingTabBar: View {
    @Binding
    private var selection: Int
    
    private let tabs: [String]
    
    private let style: Style
    
    private let onTap: ((Int) -> Void)?
    
    @State
    private var buttonFrames: [Int: CGRect] = [:]
    
    private var containerSpace: String {
        return "container"
    }
    
    public init(selection: Binding<Int>,
                tabs: [String],
                style: Style = .default,
                onTap: ((Int) -> Void)? = nil) {
        self._selection = selection
        self.tabs = tabs
        self.style = style
        self.onTap = onTap
    }
    
    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    buttons()
                    
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(style.borderColor)
                            .frame(height: style.borderHeight, alignment: .leading)
                        indicatorContainer()
                            
                    }
                }
                .coordinateSpace(name: containerSpace)
                .padding(0)
            }
            .onChange(of: selection) { newValue in
                withAnimation {
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
        }
        
    }
    
}

extension ScrollSlidingTabBar {
    private func buttons() -> some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { obj in
                Button {
                    selection = obj.offset
                    onTap?(obj.offset)
                } label: {
                    HStack {
                        Text(obj.element)
                            .font(isSelected(index: obj.offset) ? style.selectedFont : style.font)
                    }
                    .padding(.horizontal, style.buttonHInset)
                    .padding(.vertical, style.buttonVInset)
                }
                .accentColor(
                    isSelected(index: obj.offset) ? style.activeAccentColor : style.inactiveAccentColor
                )
                .readFrame(in: .named(containerSpace)) {
                    buttonFrames[obj.offset] = $0
                }
                .id(obj.offset)
            }
        }
    }
    
    private func indicatorContainer() -> some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: tabWidth(), height: style.indicatorHeight)
            .overlay(indicator(), alignment: .center)
            .offset(x: selectionBarXOffset(), y: 0)
            .animation(.default, value: selection)
    }
    
    private func indicator() -> some View {
        Rectangle()
            .fill(style.activeAccentColor)
            .frame(width: indicatorWidth(selection: selection), height: style.indicatorHeight)
    }
}

extension ScrollSlidingTabBar {
    private func sanitizedSelection() -> Int {
        return max(0, min(tabs.count - 1, selection))
    }
    
    private func isSelected(index: Int) -> Bool {
        return sanitizedSelection() == index
    }
    
    private func selectionBarXOffset() -> CGFloat {
        return buttonFrames[sanitizedSelection()]?.minX ?? .zero
    }
    
    private func indicatorWidth(selection: Int) -> CGFloat {
        return max(tabWidth() - style.buttonHInset * 2, .zero)
    }
    
    private func tabWidth() -> CGFloat {
        return buttonFrames[sanitizedSelection()]?.width ?? .zero
    }
}

extension ScrollSlidingTabBar {
    public struct Style {
        public let font: Font
        public let selectedFont: Font
        
        public let activeAccentColor: Color
        public let inactiveAccentColor: Color
        
        public let indicatorHeight: CGFloat
        
        public let borderColor: Color
        public let borderHeight: CGFloat
        
        public let buttonHInset: CGFloat
        public let buttonVInset: CGFloat
        
        public init(font: Font, selectedFont: Font, activeAccentColor: Color, inactiveAccentColor: Color, indicatorHeight: CGFloat, borderColor: Color, borderHeight: CGFloat, buttonHInset: CGFloat, buttonVInset: CGFloat) {
            self.font = .caption
            self.selectedFont = .caption
            self.activeAccentColor = activeAccentColor
            self.inactiveAccentColor = inactiveAccentColor
            self.indicatorHeight = indicatorHeight
            self.borderColor = borderColor
            self.borderHeight = borderHeight
            self.buttonHInset = buttonHInset
            self.buttonVInset = buttonVInset
        }
        
        public static let `default` = Style(
            font: .caption,
            selectedFont: .body.bold(),
            activeAccentColor: .blue,
            inactiveAccentColor: .black.opacity(0.4),
            indicatorHeight: 2,
            borderColor: .gray.opacity(0.1),
            borderHeight: 0.1,
            buttonHInset: 20,
            buttonVInset: 1
        )
    }
}

//struct QuoteTabsView: View {
//    @Binding var selectTradeTab: Int
//    @State private var selection: Int = 0
//    @EnvironmentObject var instrumentStore: InstrumentStore
//    @ObservedObject var appData: AppData
//    var body: some View {
//        VStack(alignment: .leading) {
//            ScrollSlidingTabBar(selection: $selection,tabs: ["Hot", "Gainers", "Losers", "Favorits", "Vol 24"])
//            
//            TabView(selection: $selection) {
//                QuoteView(selectTradeTab: $selectTradeTab, appData: appData).environmentObject(instrumentStore)
//                    .tag(0)
//                
//                HStack {
//                    QuoteView(selectTradeTab: $selectTradeTab, appData: appData).environmentObject(instrumentStore)
//                }
//                .tag(1)
//                
//                HStack {
//                    QuoteView(selectTradeTab: $selectTradeTab, appData: appData).environmentObject(instrumentStore)
//                }
//                .tag(2)
//                
//            
//                
//                
//            }
//            .tabViewStyle(.page(indexDisplayMode: .never))
//            .animation(.default, value: selection)
//            
//        }
//        
//
//    }
//    
//    
//}


//#Preview {
//    QuoteTabsView(selectTradeTab: .constant(0), appData: AppData()).environmentObject(InstrumentStore())

//}
