//
//  ContentView.swift
//  Ticker
//
//  Created by John Bethancourt on 8/26/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Ticker(thingsToScroll: ["The colors should be the same in the final products.", "JohnCoin: $50,000", "Is this working?", "MikeCoin: -$1.99" ])
        }
    }
}

 struct Ticker: View {
    var thingsToScroll: [String] = []
     @State var viewWidth = 1.0
     @State var moveToggle = true
     @State var counter: Int64 = 0
     @State var isDragging = false
     @State var dragDistance: Int64 = 0
 
     var valueToOffsetTo: Double {
         let offset = (counter + dragDistance).quotientAndRemainder(dividingBy: Int64(viewWidth)).remainder
         let absOffset = abs(offset)
         return Double(absOffset)
     }
     
     let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            HStack {
                ForEach(thingsToScroll, id: \.self) { thing in
                    Text(thing)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.red)
                }
            }
            .fixedSize()
            .offset(x: -valueToOffsetTo)
            .offset(x: moveToggle ?  0 : valueToOffsetTo)
            HStack {
                ForEach(thingsToScroll, id: \.self) { thing in
                    Text(thing)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)

                }

            }
            .fixedSize()

            .readSize { newSize in
                viewWidth = newSize.width
            }
            .offset(x: -valueToOffsetTo + viewWidth)
            //.offset(x: moveToggle ? valueToOffsetTo : valueToOffsetTo * 2)

        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    isDragging = true
                    dragDistance = -Int64(gesture.translation.width)
                }
                .onEnded { _ in
                    isDragging = false
                    counter += dragDistance
                    
                }
        )

        .onReceive(timer) { _ in
            print(".")
            guard !isDragging else { return }
            // overly cautious. doubt the phone would lat 10 trillion days
            if counter > (Int64.max - 100) { counter = 0 }
            if counter < Int64.min + 100 { counter = 0}
            dragDistance = 0
            counter += 10
          
        }
    }
     
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
            .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
 
}

private struct SizePreferenceKey: PreferenceKey {
    
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
