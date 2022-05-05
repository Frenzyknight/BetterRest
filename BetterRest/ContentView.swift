//
//  ContentView.swift
//  BetterRest
//
//  Created by Gaurav Ganju on 21/02/22.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    init(){
           UITableView.appearance().backgroundColor = .clear
       }
       
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color("Hermes"), Color("Sunny")]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                Form {
                    
                    Section {
                        Text("When do you want to wake up ?")
                            .font(.headline)
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    .padding(10)
                    Section {
                        Text("Desired amount of sleep")
                            .font(.headline)
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    }
                    .padding(10)
                    Section {
                        Picker("Daily coffee intake", selection: $coffeeAmount) {
                            ForEach(1..<21) {
                                Text($0 == 1 ? "1 Cup" : "\($0) Cups")
                            }
                        }
                        .padding()
                        .font(.headline)
                    }
                }
                .listRowBackground(Color.red)
                .navigationTitle("Better Rest")
                .toolbar {
                    Button("Calculate", action: calculateBedTime)
                        .padding(3)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .alert(alertTitle, isPresented: $showingAlert) {
                    Button("OK") {}
                } message: {
                    Text(alertMessage)
                }
                
            }
        }
    }
    func calculateBedTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let compnents = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (compnents.hour ?? 0) * 60 * 60
            let minute = (compnents.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute) , estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your idel sleep time is... "
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened )
        }
        catch {
            alertTitle = "Error"
            alertMessage = "Sorry there was a problem calculating your bedtime."
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
