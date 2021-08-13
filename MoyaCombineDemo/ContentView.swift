//
//  ContentView.swift
//  MoyaCombine
//
//  Created by Inpyo Hong on 2021/08/13.
//

import SwiftUI
import Combine
import CombineMoya
import Moya

struct ContentView: View {
    struct Response<T> {
        let value: T
        let response: URLResponse
    }
    var cancellable: AnyCancellable?
    
    @State private var msgTextStr: String = """
                                          Something went wrong!
                                          Try again later.
                                        """
    @State private var msgImgStr: String = "Error"
    @State private var msgHidden: Bool = false
    
    enum MsgState {
        case loading
        case ready([Comic])
        case error
    }
    
    private var msgState: MsgState = .loading {
        didSet {
            print(msgState)
            switch msgState {
            case .ready:
                self.msgHidden = true
            //          tblComics.isHidden = false
            //          tblComics.reloadData()
            case .loading:
                //          tblComics.isHidden = true
                //          viewMessage.isHidden = false
                self.msgTextStr = "Getting comics ..."
                self.msgImgStr = "Loading"
            case .error:
                //          tblComics.isHidden = true
                self.msgHidden = false
                self.msgTextStr = """
                                          Something went wrong!
                                          Try again later.
                                        """
                self.msgImgStr = "Error"
            }
        }
    }
    
    let provider = MoyaProvider<Marvel>()
    
    init() {
        cancellable = provider.requestPublisher(.comics)
            .map(MarvelResponse<Comic>.self)
            .sink(receiveCompletion: { completion in
//                print ("completion: \(completion)")
                switch completion {
                case .finished:
                    print(">>> finished. success!")
                    
                case .failure(let error as Moya.MoyaError?):
                    
                    if let statusCode = error?.response?.statusCode,
                       let localizedDescription = error?.localizedDescription {
                        print(">>> fail statusCode: \(statusCode), localizedDescription: \(localizedDescription)")
                       let resultCode =  HTTPStatusCode(rawValue: statusCode)!
                       print(resultCode)
                    }
                }
                
            },receiveValue: { message in
                print(">>> message", message.data.results)
            })
    }
    
    var body: some View {
        ZStack {
            viewMessage(image: $msgImgStr, text: $msgTextStr)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct viewMessage: View {
    @Binding var image: String
    @Binding var text: String
    
    var body: some View {
        VStack {
            Image(uiImage: UIImage(named: image)!)
            
            Text(text)
                .foregroundColor(Color(UIColor.label))
                .font(.custom("CoolStoryregular", size: 22))
                .padding()
        }
        .frame(width: 250, height: 250, alignment: .center)
    }
}
