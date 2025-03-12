//
//  HelloView.swift
//  MinorvaMVP
//
//  Created by Ryoga Sakai on 2025/03/04.
//

import SwiftUI


//自分のファッションより、アプリのデザインが気になる

struct HelloView: View {
//    let firstColor = Color(uiColor: UIColor(red: 161/255, green: 142/255, blue: 245/255, alpha: 1.0))
//    let secondColor = Color(uiColor: UIColor(red: 249/255, green: 117/255, blue: 136/255, alpha: 1.0))
//    #a18ef5 と #f97588　ファンシー
//    let firstColor = Color(uiColor: UIColor(red: 56/255, green: 101/255, blue: 206/255, alpha: 1.0))
//    let secondColor = Color(uiColor: UIColor(red: 248/255, green: 68/255, blue: 58/255, alpha: 1.0))
//    let firstColor = Color(red: 0.2, green: 0.6, blue: 0.8)
//    let secondColor = Color(red: 0.2, green: 0.6, blue: 0.8)
//    #3865ce　と　#f8443a
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    @EnvironmentObject var settings : AppSettings
    
    var body: some View {
        NavigationStack{
            ZStack{
                LinearGradient(colors: [settings.firstColor.opacity(0.3), settings.secondColor.opacity(0.5)],
                                                      startPoint: .topLeading,
                                                      endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 60){
//                    Image(uiImage: UIImage(named:  "TrashTraceTrance")!)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: screenWidth * 0.8 , height: screenWidth * 0.8)
                    
                    VStack(spacing: 20){
                        NavigationLink(destination: SignInView()
                                        .onAppear {
                                            settings.isEnglish = true
                                        }) {
                            Text("Start with English")
                                .font(.system(size: 25, weight: .semibold, design: .default))
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .foregroundStyle(.ultraThinMaterial)
                                        .shadow(color: .init(white: 0.4, opacity: 0.4), radius: 5, x: 0, y: 0)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.init(white: 1, opacity: 0.5), lineWidth: 1)
                                )
                        }
                        
                        NavigationLink(destination: SignInView()
                                        .onAppear {
                                        settings.isEnglish = false
                                      }) {
                            Text("日本語で始める")
                                .font(.system(size: 25, weight: .semibold, design: .default))
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .foregroundStyle(.ultraThinMaterial)
                                        .shadow(color: .init(white: 0.4, opacity: 0.4), radius: 5, x: 0, y: 0)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.init(white: 1, opacity: 0.5), lineWidth: 1)
                                )
                        }.onTapGesture {
                            settings.isEnglish = false
                        }

                        Text("App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")")
                            .foregroundColor(.white)
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct SymplePath: View {
  
  var body: some View {
     VStack {
        sample()
        sample(dashPhase: 10)
        sample(dashPhase: 20)
     }
  }
  
  func sample(dashPhase: CGFloat = 0) -> some View {
     ZStack {
        Path { path in
           path.addLines(points)
        }
        .stroke(Color.black,
              style: StrokeStyle(lineWidth: lineWidth,
                             dash: [10, 10, 40, 10],
                             dashPhase: dashPhase ))

        Path { path in

           for index in points.indices {
              path.addEllipse(in: CGRect(x: points[index].x - 2,
                                   y: points[index].y - 2,
                                   width: 4,
                                   height: 4))
           }

           path.addLines(points)
        }
        .stroke(Color.green,
              style: StrokeStyle(lineWidth: 1.0,
                             lineCap: .butt))

     }
  }
  static let xOffset: CGFloat = 80
  static let topY: CGFloat = 50
  static let bottomX: CGFloat = 170
  static let sampleWidth: CGFloat = 100
  let points = [
     CGPoint(x: xOffset, y: bottomX),
     CGPoint(x: xOffset + 0.5 * sampleWidth, y: topY),
     CGPoint(x: xOffset + sampleWidth, y: bottomX),
  ]
  let lineWidth: CGFloat = 20
}

struct CircleAnimation: View{
    @State private var viewState1 = false
    @State private var viewState2 = true
    
    var body: some View {
        ZStack {

        }
        .onAppear {
            withAnimation {
                self.viewState1 = true
                self.viewState2 = false
            }
        }
    }
}

struct PuffEffect: ViewModifier {
    @State var isOn: Bool = false
    let opacityRange: ClosedRange<Double>
    let interval: Double
    let offsetRange: ClosedRange<CGFloat>

    init(opacity: ClosedRange<Double>, interval: Double, offset: ClosedRange<CGFloat> = -2...2) {
        self.opacityRange = opacity
        self.interval = interval
        self.offsetRange = offset
    }

    func body(content: Content) -> some View {
        content
            .opacity(self.opacityRange.upperBound)
            .offset(y: self.isOn ? self.offsetRange.lowerBound : self.offsetRange.upperBound)
//            .animation(Animation.linear(duration: self.interval).repeatForever())
            .animation(.linear(duration: self.interval).repeatForever(), value: self.isOn)
            .onAppear(perform: {
                self.isOn = true
            })
    }
}

extension View {
    func puffEffect(opacity: ClosedRange<Double> = 0.5...1, interval: Double = 3.0, offset: ClosedRange<CGFloat> = -1...1) -> some View {
        self.modifier(PuffEffect(opacity: opacity, interval: interval, offset: offset))
    }
}
