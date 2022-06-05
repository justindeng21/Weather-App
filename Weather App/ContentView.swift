//
//  ContentView.swift
//  Weather App
//
//  Created by Justin Deng on 6/2/22.
//

import SwiftUI



struct ContentView: View {
    @StateObject var weatherModel = weatherApi()
    
    
    
    var body: some View{
        ZStack{
            LinearGradient(gradient: Gradient(colors: [.blue, .white, .pink]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            VStack{
                HStack{
                    ForEach(weatherModel.results_, id: \.self){data in
                        weatherViewWithRoundedRect(data : data, weatherModel: weatherModel)
                    }
                }
                    .frame(minHeight: 0, maxHeight: .infinity, alignment: .top)
                    .padding()
            }
        }
    }
}

struct futureForcast : View{
    
    var date_ : String
    var day : daily
    
    func cleanTemp(tempFar_String : String)->String{
        let separators = CharacterSet(charactersIn: ".")
        return tempFar_String.components(separatedBy: separators)[0] + " °F"
    }
    
    func convertTofahrenheit(tempKel : Float)->String{
        let tempInCelcius = tempKel - 273.15
        let fractionalValue : Float = 9/5
        let tempInFar : Float = tempInCelcius * fractionalValue + 32
        return cleanTemp(tempFar_String: String(format: "%.01f", ceil(tempInFar)))
    }
    
    
    var body: some View{
        ZStack(alignment: .top){
            RoundedRectangle(cornerRadius: 20)
                .frame(minWidth: 0, maxWidth: 300 )
                .scaledToFit()
                .foregroundColor(.clear)
            VStack(alignment: .leading, spacing: 5){
                
                HStack{
                    Text(date_).font(.title).bold().frame(alignment: .leading).foregroundColor(.black)
                    Image(day.weather[0].icon).frame(maxWidth: .infinity, alignment: .leading)
                }.padding(.top)

                    horizontalText(text1: "Morn", text2: convertTofahrenheit(tempKel: day.temp.morn))
                exDivider()
                    horizontalText(text1: "Day", text2: convertTofahrenheit(tempKel: day.temp.day))
                exDivider()
                    horizontalText(text1: "Eve", text2: convertTofahrenheit(tempKel: day.temp.eve))
                exDivider()
                    horizontalText(text1: "Min", text2: convertTofahrenheit(tempKel: day.temp.min))
                exDivider()
                    horizontalText(text1: "Max", text2: convertTofahrenheit(tempKel: day.temp.max))
                
            }
        }
    }
}

struct exDivider: View {
    var color: Color = .clear
    var width: CGFloat = 20
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(color)
            .frame(height: width)
            .edgesIgnoringSafeArea(.horizontal)
            .padding(.trailing)
            //.padding(.leading)
    }
}


struct axDivider: View {
    var color: Color = .black
    var height: CGFloat = 2
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(color)
            .frame(width: height)
            .edgesIgnoringSafeArea(.vertical)
            .padding(.trailing)
            //.padding(.leading)
    }
}

struct horizontalText : View{
    var text1 : String
    var text2 : String
    
    var body: some View{
        HStack(spacing:0){
            
            Text(text2).font(.system(size: 20, design: .default)).bold().frame(alignment: .leading).foregroundColor(.black)
            Text(text1).frame(maxWidth: 100, alignment: .center).foregroundColor(.black)
            
            
        }
    }
}

struct weatherView : View{
    var data : weatherData
    
    func getCity(timezone : String)->String{
        let tempString = timezone.replacingOccurrences(of: "_", with: " ", options: .literal, range: nil)
        
        let separators = CharacterSet(charactersIn: "/")
        return tempString.components(separatedBy: separators)[1]
    }
    func cleanTemp(tempFar_String : String)->String{
        let separators = CharacterSet(charactersIn: ".")
        return tempFar_String.components(separatedBy: separators)[0] + "°F"
    }
    func convertTofahrenheit(tempKel : Float)->String{
        let tempInCelcius = tempKel - 273.15
        let fractionalValue : Float = 9/5
        let tempInFar : Float = tempInCelcius * fractionalValue + 32
        return cleanTemp(tempFar_String: String(format: "%.01f", ceil(tempInFar)))
    }
    
    
    var body: some View{
        VStack{
            Text(getCity(timezone: data.timezone))
                .font(.system(size: 35, design: .default)).bold().padding(.top).foregroundColor(.black)
            Text(data.current.weather[0].description.capitalized).foregroundColor(.black)
            tempAndIcon(tempInFar: convertTofahrenheit(tempKel: data.current.temp), iconName: data.current.weather[0].icon)
        }
    }
}




struct weatherViewWithRoundedRect : View{
    var data : weatherData
    var weatherModel : weatherApi
    func unix_to_utc(unixTime : Int)->String{
        let Date = NSDate(timeIntervalSince1970: Double(unixTime))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(for: Date)
        let yourDate = formatter.date(from: myString!)
        formatter.dateFormat = "MMM. d"
        let myStringDate = formatter.string(from: yourDate!)
        return myStringDate
    }
    
    var body: some View{
        
        ScrollView(.vertical) {
            VStack{
                    
                weatherView(data: data).padding()
                
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        ForEach(data.daily, id: \.self){day in
                            futureForcast(date_ : unix_to_utc(unixTime: day.dt),day: day).frame(width: 200, height:300)
                        }
                    }
                }.padding()
                
                exDivider()
                exDivider()
                
                customButton(weatherData: weatherModel).frame(alignment: .bottom).padding(.top)
                
            }
        }
        
    }
}

struct tempAndIcon : View{
    var tempInFar : String
    var iconName : String
    var body: some View{
        HStack{
            Text(tempInFar)
                .font(.largeTitle).foregroundColor(.black)
            Image(iconName)
                .renderingMode(.original)
                .resizable()
                .frame(width: 100, height: 100, alignment: .center)
                .scaledToFit()
        }
    }
}

struct customButton : View{
    var weatherData : weatherApi
    var body: some View{
        ZStack{
            
            
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 200, height: 50, alignment: .bottom)
                .foregroundColor(.white)
            
            
            
            Button(action: weatherData.reload){
                Text("Refresh").foregroundColor(.pink)
            }
        }.padding()
    }
}



struct ContentView_Previews: PreviewProvider {
    
    
    static var previews: some View {
        
        ContentView()
    }
}
