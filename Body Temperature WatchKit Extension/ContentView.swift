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
            ResultsView(isPresented: $isResultPresented, isMeasurement: $isMeasurementStarted)
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

struct ResultsView: View {
    @Binding var isPresented: Bool
    @Binding var isMeasurement: Bool
    
    private let bodyTemperature = getTemperature()
    
    var body: some View {
        ScrollView {
//            NavigationView {
//            VStack {
                Button(action: {
                    
                }, label: {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Body Temperature")
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
                
//                NavigationLink(
//                    destination: InfoView()) {
//                    EmptyView()
//                }
//            }
//            }
            
            
            Spacer().frame(height: 10)
                
            Button(action: {
                self.isPresented = false
                self.isMeasurement = false
            }, label: {
                Text("Done")
            })
            
            Text("You can view Body Temperature measurements in the Health app on iPhone")
                .font(.system(.footnote))
                .foregroundColor(.secondary)
                .frame(alignment: .leading)
        }
        
    }
}

struct InfoView: View {
    var body: some View {
        ScrollView {
            Text("About Body Temperature Measurements")
                .font(.system(.headline, design: .rounded))
                .frame(maxWidth: .infinity,alignment: .leading)
            Divider()
            Text("Normal body temperature varies throughout the day－it's lower in the morning and higher in the late afternoon and evening. The average normal body temperature is 98.6°F (37°C). What's normal for you nay be a degree or more higher or lower than this.")
                .font(.system(.body, design: .rounded))
                .frame(maxWidth: .infinity,alignment: .leading)
        }.navigationBarTitle(Text("Info"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            ResultsView(isPresented: .constant(false), isMeasurement: .constant(false))
            InfoView()
        }
    }
}
