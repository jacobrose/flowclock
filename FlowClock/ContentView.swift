//
//  ContentView.swift
//  FlowClock
//
//  Created by Jacob Rose on 5/26/25.
//

import SwiftUI

struct Tickmarks: Shape {
    @State var theta: CGFloat = 0.0
    @State var divisions: Int = 24
    @State var inneroffset: CGFloat = 0.0
    @State var outeroffset: CGFloat = 20.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for hour in (0..<divisions) {
            let center = (x: Double(rect.width)/2.0, y: Double(rect.height)/2.0)
            let innerradius = Double(rect.width)/2.0 - inneroffset
            let outerradius = Double(rect.width)/2.0 + outeroffset
            
            let radians = Double(hour) * (360.0/Double(divisions)) * Double.pi / 180.0 + theta
            
            path.move(to: CGPoint(x: center.x + innerradius * cos(radians), y: center.y + innerradius * sin(radians)))
            path.addLine(to: CGPoint(x: center.x + outerradius * cos(radians), y: center.y + outerradius * sin(radians)))
        }
        
        return path
    }
}

struct ContentView: View {
    @State var currentHour: Int = 0
    @State var currentMinute: Double = 0.0
    @State var currentSecond: Double = 0.0
    
    let timer = Timer.publish(every: 0.05, tolerance: 0.05, on: .main, in: .common).autoconnect()
    
    func updateClock() {
        let currentTime = Date()
        currentHour = Calendar.current.component(.hour, from: currentTime)
        currentMinute = Double(Calendar.current.component(.minute, from: currentTime))
        currentSecond = Double(Calendar.current.component(.second, from: currentTime))
            + Double(Calendar.current.component(.nanosecond, from: currentTime)) / 1000000000.0
    }
    
    var body: some View {
        HStack {
            // avoid the island when oriented the wrong way around
            Spacer()
                .frame(width: 0, height: 0)
                .padding(10)
            
            // Seconds
            ZStack {
                // reflect current time
                let theta = -2.0 * Double.pi * currentSecond / 60.0

                Circle()
                    .stroke(Color(red: 0, green: 0, blue: 0, opacity: 0.2),
                        lineWidth: 46
                    )
                    .offset(CGSize(width: -5, height: 0))
                Circle()
                    .stroke(Color.white, lineWidth: 44)
                Tickmarks(theta: theta, divisions: 60, inneroffset: -10)
                    .stroke(Color.red, lineWidth: 1)
                ForEach (0..<12) {
                    label in
                    let center = (x: 0.0, y: 0.0)
                    let radians = Double(label) / 12.0 * 2.0 * Double.pi // base spread
                        + Double.pi // rotate so zero is to the right
                        + theta
                    let radius = 50.0
                    Text("\(label*5)")
                        .rotationEffect(Angle(radians: radians + Double.pi))
                        .offset(CGSize(width: center.x + radius * cos(radians), height: center.y + radius * sin(radians)))
                        .font(.caption)
                        .foregroundColor(Color.red)
                }
            }.frame(width: 100, height: 100).offset(x:100)
            
            
            // Minutes
            ZStack {
                // reflect current time
                let theta = -2.0 * Double.pi * (
                    currentMinute / 60.0 + currentSecond / 60.0 / 60.0
                )

                Circle()
                    .stroke(Color(red: 0, green: 0, blue: 0, opacity: 0.2),
                        lineWidth: 46
                    )
                    .offset(CGSize(width: -5, height: 0))
                Circle()
                    .stroke(Color.white, lineWidth: 44)
                Spacer()
                    .frame(width: 0, height: 0)
                    .padding(5)
                Tickmarks(theta: theta, divisions: 60, inneroffset: -5)
                    .stroke(Color.black, lineWidth: 2)
                ForEach (0..<60) {
                    label in
                    let center = (x: 0.0, y: 0.0)
                    let radians = Double(label) / 60.0 * 2.0 * Double.pi // base spread
                        + Double.pi // rotate so zero is to the right
                        + theta
                    let radius = 145.0
                    Text("\(label)")
                        .rotationEffect(Angle(radians: radians + Double.pi))
                        .offset(CGSize(width: center.x + radius * cos(radians), height: center.y + radius * sin(radians)))
                        .font(.caption)
                        .foregroundColor(Color.black)
                }
            }.frame(width:300, height: 300).offset(x: 100, y: 0)

            // Hours
            ZStack {
                let size = 600.0
                
                // reflect current time
                let theta = -2.0 * Double.pi * (
                    Double(currentHour % 12) / 12.0
                    + currentMinute / 12.0 / 60.0
                    + currentSecond / 12.0 / 60.0 / 60.0
                )
                Circle()
                    .stroke(Color(red: 0, green: 0, blue: 0, opacity: 0.2),
                        lineWidth: 46
                    )
                    .offset(CGSize(width: -5, height: 0))
                Circle()
                    .stroke(Color.white, lineWidth: 44)
                Tickmarks(theta: theta, divisions: 12, inneroffset: -6, outeroffset: 21)
                    .stroke(Color.red, lineWidth: 3)
                ForEach (0..<12) {
                    label in
                    let center = (x: 0.0, y: 0.0)
                    let radians = Double(label) / 12.0 * 2.0 * Double.pi // base spread
                        + Double.pi // rotate so zero is to the right
                        + theta
                    let radius = size / 2.0
                    Text("\(label == 0 ? 12 : label)")
                        .rotationEffect(Angle(radians: radians + Double.pi))
                        .offset(CGSize(width: center.x + radius * cos(radians), height: center.y + radius * sin(radians)))
                        .font(.caption)
                        .fontWeight(Font.Weight.bold)
                        .foregroundColor(Color.red)
                }
            }.frame(width: 600, height: 600).offset(x: 100, y: 0)
        }
        .environment(\.layoutDirection, .rightToLeft)
        .containerRelativeFrame([.horizontal, .vertical])
        .background(Color.black)
        .padding()
        .onReceive(timer) { _ in
            updateClock()
        }
    }
}

#Preview {
    ContentView()
}
