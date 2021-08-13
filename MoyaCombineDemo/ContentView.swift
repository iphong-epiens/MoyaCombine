//
//  ContentView.swift
//  MoyaCombine
//
//  Created by Inpyo Hong on 2021/08/13.
//

import SwiftUI
import CombineMoya
/*
 Combine extension provides requestPublisher(:callbackQueue:) and requestWithProgressPublisher(:callbackQueue) returning AnyPublisher<Response, MoyaError> and AnyPublisher<ProgressResponse, MoyaError> respectively.

 Here's an example of requestPublisher usage:
 
 provider = MoyaProvider<GitHub>()
 let cancellable = provider.requestPublisher(.userProfile("ashfurrow"))
     .sink(receiveCompletion: { completion in
         guard case let .failure(error) = completion else { return }

         print(error)
     }, receiveValue: { response in
         image = UIImage(data: response.data)
     })
*/

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
