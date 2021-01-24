//
//  ContentView.swift
//  Body Temperture WatchKit Extension
//
//  Created by Satoshi on 2021/01/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MeasurementView()
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Text("Body Temperature").foregroundColor(.accentColor)
                }
            })
    }
}

struct MeasurementView: View {
    @State private var isMeasurementStarted = false
    @State private var isResultPresented = false
    
    @State private var timeVal: Int = 15
    
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Spacer()
            
            if isMeasurementStarted {
                HStack(alignment: .bottom) {
                    Text("\(timeVal)")
                        .font(.system(.largeTitle, design: .rounded))
                        .onReceive(timer, perform: { _ in
                            if timeVal > 0 {
                                timeVal -= 1
                            } else {
                                self.timer.upstream.connect().cancel()
                                isResultPresented = true
                            }
                        })
                    Text("sec")
                        .font(.system(.title, design: .rounded))
                    Spacer()
                }
            }
            else {
                Button(action: {
                    isMeasurementStarted = true
                    timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                    timeVal = 15
                }, label: {
                    Text("Start")
                })
            }
        }
        .sheet(isPresented: $isResultPresented, content: {
            ResultView(isPresented: $isResultPresented, isMeasurement: $isMeasurementStarted)
                .toolbar(content: {
                    ToolbarItem(placement: .cancellationAction) {
                        Text("Results").foregroundColor(.accentColor)
                    }
                })
        })
    }
}

func getTemperature() -> Float {
    var randomGenerator = SystemRandomNumberGenerator()
    return Float.random(in: 35.5..<36.9, using: &randomGenerator)
}

struct ResultView: View {
    @Binding var isPresented: Bool
    @Binding var isMeasurement: Bool
    
    private let bodyTemperature = getTemperature()
    
    var body: some View {
        VStack {
            List {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Body Temperture")
                            .font(.system(.body, design: .rounded))
                        Spacer()
                        Image(systemName: "info.circle")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(alignment: .bottom) {
                        Text(String(format: "%.1f", bodyTemperature))
                            .font(.system(.title, design: .rounded))
                        Text("°C")
                            .font(.system(.title2, design: .rounded))
                    }
                }
            }
            
            Button(action: {
                self.isPresented = false
                self.isMeasurement = false
            }, label: {
                Text("Done")
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            ResultView(isPresented: .constant(false), isMeasurement: .constant(false))
        }
    }
}
