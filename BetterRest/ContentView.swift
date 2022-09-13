//
//  ContentView.swift
//  BetterRest
//
//  Created by Ian Bailey on 10/9/2022.
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
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("When do you want to wake up?").font(.title2).foregroundColor(.primary)) {
                    HStack {
                        Spacer()
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute).labelsHidden()
                    }
                }.textCase(nil)
                
                Section(header: Text("Desired amount of sleep?")
                    .font(.title2).foregroundColor(.primary)) {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }.textCase(nil)
                
                Section(header: Text("Daily coffee intake?")
                    .font(.title2).foregroundColor(.primary)) {
                        Picker(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", selection: $coffeeAmount){
                            Text("1 cup")
                            ForEach(2...20, id: \.self) { i in
                                Text("\(i) cups")
                            }
                        }
                }.textCase(nil)
            }
            .navigationTitle("Better Rest")
            .toolbar { Button("Calculate", action: calculateBedtime) }
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("Okay"){}
        } message: {
            Text(alertMessage)
        }
    }
    
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = components.hour ?? 0
            let minute = components.minute ?? 0
            let seconds = (Double(hour)*60*60)+(Double(minute)*60)
            
            let prediction = try model.prediction(wake: seconds, estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bed time is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        }
        catch {
            alertTitle = "Error"
            alertMessage = "Could not calculate bed time"
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
