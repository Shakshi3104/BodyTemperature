//
//  ContentView.swift
//  Body Temperature WatchKit Extension
//
//  Created by Satoshi on 2021/01/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MeasurementView()
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Text("app_name").foregroundColor(.accentColor)
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
                    // Monospaced font for timer
                    Text("\(timeVal)")
                        .font(Font.system(.largeTitle, design: .rounded).monospacedDigit())
                        .onReceive(timer, perform: { _ in
                            if timeVal > 0 {
                                timeVal -= 1
                            } else {
                                self.timer.upstream.connect().cancel()
                                isResultPresented = true
                            }
                        })
                    Text("sec_unit")
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
                    Text("start_button")
                })
            }
        }
        .sheet(isPresented: $isResultPresented, content: {
            ResultsView(isPresented: $isResultPresented, isMeasurement: $isMeasurementStarted)
                .toolbar(content: {
                    ToolbarItem(placement: .cancellationAction) {
                        Text("results_name").foregroundColor(.accentColor)
                    }
                })
        })
    }
}

func getTemperature() -> Float {
    var randomGenerator = SystemRandomNumberGenerator()
    return Float.random(in: 35.5..<36.9, using: &randomGenerator)
}

struct ResultsView: View {
    @Binding var isPresented: Bool
    @Binding var isMeasurement: Bool
    
    private let bodyTemperature = getTemperature()
    
    var body: some View {
        ScrollView {
//            NavigationView {
//                NavigationLink(
//                    destination: InfoView(),
//                    label: {
//                        
//                    })
//            }
            Button(action: {}, label: {
                VStack(alignment: .leading) {
                    HStack {
                        Text("body_temp")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.medium)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        Image(systemName: "info.circle")
                            .foregroundColor(.secondary)
                            .font(.title3)
                    }
                    
                    HStack(alignment: .bottom) {
                        Text(String(format: "%.1f", bodyTemperature))
                            .font(.system(.title, design: .rounded))
                        Text("°C")
                            .font(.system(.title2, design: .rounded))
                    }
                }
            })
            
            Spacer().frame(height: 10)
                
            Button(action: {
                self.isPresented = false
                self.isMeasurement = false
            }, label: {
                Text("done_button")
            })
            
            Text("health_app_text")
                .font(.system(.footnote))
                .foregroundColor(.secondary)
                .frame(alignment: .leading)
        }
    }
}

struct InfoView: View {
    var body: some View {
        ScrollView {
            Text("info_title")
                .font(.system(.headline, design: .rounded))
                .frame(maxWidth: .infinity,alignment: .leading)
            Divider()
            Text("info_contents")
                .font(.system(.body, design: .rounded))
                .frame(maxWidth: .infinity,alignment: .leading)
        }.navigationBarTitle(Text("info_bar_title"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()//.environment(\.locale, .init(identifier: "ja"))
            ResultsView(isPresented: .constant(false), isMeasurement: .constant(false))
            InfoView()
        }
    }
}
