//
//  ContentView.swift
//  WeatherApp
//
//  Created by Vladyslav Pryl on 10.12.2024.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var weather: WeatherWM
    
    @State private var isNight = false
    
    typealias model = WeatherWM
    
    var body: some View {
        ZStack {
            backgroundColor
            VStack(spacing: 0) {
                largeInformation
                    .padding(.top, Const.padding)
                scrollingDaysInfo
                    .padding(.top, Const.padding)
                Spacer()
                printButton("Change Day Time")
                    .padding()
                Spacer()
            }
        }
    }
    
    private var largeInformation: some View {
        VStack(spacing: 0) {
            model.printLocation(name: weather.largeInfo.location,
                                size: Const.bigTextSize)
            .padding(.vertical)
            model.printImgIcon(model.codeToImg(weather.largeInfo.weatherCode),
                               size: Const.bigIconSize)
            .padding(.vertical)
            model.printTemperature(weather.largeInfo.temperature,
                                   fontSize: Const.bigTmpSize)
        }
    }
    
    private var scrollingDaysInfo: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(weather.week) { day in
                    printWeekdayAndAvgTemperature(day)
                }
            }
        }
        .scrollIndicators(.hidden)
    }
    
    private var backgroundColor: some View {
        LinearGradient(gradient: Gradient(colors: [isNight ? .black : weather.firstGradient,
                                                   isNight ? .gray : .barelyBlue] ),
                       startPoint: .topLeading, endPoint: .bottomTrailing)
        .ignoresSafeArea()
    }
    
    private func printWeekdayAndAvgTemperature(_ one: WeatherWM.OneDay) -> some View {
        VStack(spacing: Const.spacing) {
            Text(one.dayOfWeek)
                .font(.system(size: Const.bigTextSize/2, weight: .semibold))
                .foregroundStyle(.white)
            model.printImgIcon(model.codeToImg(one.weatherCode), size: Const.bigIconSize/3)
            model.printTemperature(one.temperature, fontSize: Const.bigTmpSize/2)
        }
        .padding(.horizontal, Const.spacing)
    }
    
    private func printButton( _ text: String, color: Color? = .white) -> some View {
        Button {
            isNight.toggle()
        } label: {
            Text(text)
                .frame(width: Const.buttonW, height: Const.buttonH)
                .background(color)
                .font(.system(size: Const.buttonFontSize, weight: .bold))
                .clipShape(.rect(cornerRadius: Const.buttonRadius))
        }
    }
    
    private struct Const {
        static let bigIconSize: CGFloat = 180
        static let bigTmpSize: CGFloat = 70
        static let bigTextSize: CGFloat = 42
        static let spacing: CGFloat = 10
        static let padding: CGFloat = 50
        static let buttonW: CGFloat = 280
        static let buttonH: CGFloat = 50
        static let buttonFontSize: CGFloat = 20
        static let buttonRadius: CGFloat = 10
    }
}


#Preview {
    ContentView(weather: WeatherWM())
}
