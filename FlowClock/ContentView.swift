//
//  ContentView.swift
//  FlowClock
//
//  Created by Jacob Rose on 5/26/25.
//

import SwiftUI

struct Tickmarks: Shape {
    @State var theta: CGFloat = 0.0
    @State var divisions: Int = 60
    @State var inneroffset: CGFloat = 5.0 // distance inward from outeroffset
    @State var outeroffset: CGFloat = 20.0

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for hour in (0..<divisions) {
            let center = (x: Double(rect.width)/2.0, y: Double(rect.height)/2.0)
            let innerradius = Double(rect.width)/2.0 + (outeroffset - inneroffset)
            let outerradius = Double(rect.width)/2.0 + outeroffset

            let radians = Double(hour) * (360.0/Double(divisions)) * Double.pi / 180.0 + theta

            path.move(to: CGPoint(x: center.x + innerradius * cos(radians), y: center.y + innerradius * sin(radians)))
            path.addLine(to: CGPoint(x: center.x + outerradius * cos(radians), y: center.y + outerradius * sin(radians)))
        }

        return path
    }
}

struct Dial: View {
    @Binding var value: Double

    @State var labels: [Int] = Array(0...59)
    @State var thickness: Double = 44.0
    @State var shadow: Double = 5.0
    @State var subdivisions: Int = 1
    @State var subdivisionProportion: Double = 1.0
    @State var tickmarkThickness: Double = 1.0
    @State var tickmarkLength: Double = 10.0

    @State private var size: CGSize = .zero

    var body: some View {
        let labelCount: Int = labels.count
        let proportion = value / Double(labelCount) / Double(subdivisions) / subdivisionProportion
        let theta = -2.0 * Double.pi * proportion
        let radius = Double(size.width) / 2.0

        ZStack {
            if (shadow > 0.0) {
                // Shadow
                Circle()
                    .stroke(Color(red: 0, green: 0, blue: 0, opacity: 0.2),
                            lineWidth: thickness + 2.0
                    )
                    .offset(CGSize(width: -1.0 * shadow, height: 0))
            }

            // Dial
            Circle()
                .stroke(
                    Color("DialColor"), // Colors should prevent eyestrain
                    lineWidth: thickness
                )

            Tickmarks(
                theta: theta,
                divisions: labels.count * subdivisions,
                inneroffset: tickmarkLength
            ).stroke(lineWidth: tickmarkThickness)

            // Labels
            ForEach (0..<labelCount) {
                labelIndex in

                let radians = Double(labelIndex) / Double(labelCount) * 2.0 * Double.pi // base spread
                    + Double.pi // rotate so zero is to the right
                    + theta

                Text("\(labels[labelIndex])")
                .rotationEffect(Angle(radians: radians + Double.pi))
                .offset(CGSize(
                    width: radius * cos(radians),
                    height: radius * sin(radians))
                )
            }
        }.onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: {
            size = $0
        }
    }
}

struct ContentView: View {
    @State var currentHour: Double = 0
    @State var currentMinute: Double = 0.0
    @State var currentSecond: Double = 0.0

    let timer = Timer.publish(every: 0.05, tolerance: 0.05, on: .main, in: .common).autoconnect()

    func updateClock() {
        let currentTime = Date()
        currentSecond = Double(Calendar.current.component(.second, from: currentTime))
            + Double(Calendar.current.component(.nanosecond, from: currentTime)) / 1000000000.0

        currentMinute = Double(Calendar.current.component(.minute, from: currentTime))
            + currentSecond / 60.0

        currentHour = Double(Calendar.current.component(.hour, from: currentTime) % 12)
            + currentMinute / 60.0
    }

    var body: some View {
        // Colors should de-emphasize seconds in each mode, treating it like an accent color; see "ringColor" for background
        let secondsDial = Dial(
            value: $currentSecond,
            labels: Array(stride(from: 0, through: 55, by: 5)),
            subdivisions: 5
        ).foregroundColor(Color("SecondLabelColor"))

        let minutesDial = Dial(
            value: $currentMinute,
            tickmarkThickness: 2
        ).foregroundColor(Color("MinuteLabelColor"))

        let hoursDial = Dial(
            value: $currentHour,
            labels: [12,1,2,3,4,5,6,7,8,9,10,11],
            subdivisions: 4,
            subdivisionProportion: 0.25, // each is 1/4 of an hour
            tickmarkThickness: 3,
            tickmarkLength: 8.0
        ).foregroundColor(Color("HourLabelColor"))

        HStack {
            secondsDial
                .frame(width: 100, height: 100)
                .offset(x: 100) // overlap
                .padding(.leading, 100) // nudge back to safe area
                .font(.caption)

            minutesDial
                .frame(width: 300, height: 300)
                .offset(x: 100) // overlap
                .font(.caption)

            hoursDial
                .frame(width: 600, height: 600)
                .offset(x: 100) // overlap
                .font(.title)
        }
        .environment(\.layoutDirection, .rightToLeft)
        .containerRelativeFrame([.horizontal, .vertical])
        .background(Color.black)
        .onReceive(timer) { _ in
            updateClock()
        }
    }
}

#Preview {
    ContentView()
}
