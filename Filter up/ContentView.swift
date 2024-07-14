//
//  ContentView.swift
//  Filter up
//
//  Created by Parth Antala on 2024-07-14.
//
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI
import PhotosUI

struct ContentView: View {
    
    @State private var showingConfirmation = false
    @State private var backgroundColor = Color.white
    @State private var image: Image?
    
    @State private var pickerItems = [PhotosPickerItem]()
    @State private var selectedImages = [Image]()
    
    
    var body: some View {
        
        VStack {
            let image = Image(.img)
            
            ShareLink(item: image, preview: SharePreview("MAC", image: image)) {
                Label("Click to share", systemImage: "airplane")
            }
            ShareLink(item: URL(string: "www.apple.com")!, subject: Text("Apple Website"), message: Text("Its a very beautiful site"))
            PhotosPicker(selection: $pickerItems, maxSelectionCount: 3, matching: .any(of: [.images, .not(.screenshots)])) {
                Label("Select a picture", systemImage: "photo")
            }
            
            ScrollView {
                ForEach(0..<selectedImages.count, id: \.self) { i in
                    selectedImages[i]
                        .resizable()
                        .scaledToFit()
                }
            }
            
        }
        .onChange(of: pickerItems) {
            Task {
                selectedImages.removeAll()
                for item in pickerItems {
                    if let loadedImage = try await item.loadTransferable(type: Image.self) {
                        selectedImages.append(loadedImage)
                    }
                }
                
                //selectedImage = try await pickerItem?.loadTransferable(type: Image.self)
            }
        }
        
//        ContentUnavailableView {
//            Label("No snippets", systemImage: "swift")
//        } description: {
//            Text("You don't have any saved snippets yet.")
//        } actions: {
//            Button("Create Snippet") {
//                // create a snippet
//            }
//            .buttonStyle(.borderedProminent)
//        }
        
//        VStack {
//            image?
//                .resizable()
//                .scaledToFit()
//            
//            Button("Filter-Up") {
//                loadImage()
//            }
//        }
     //   .onAppear(perform: loadImage)
        
    }
    
//    func loadImage() {
//        let inputImage = UIImage(resource: .img)
//        let beginImage = CIImage(image: inputImage)
//        let context = CIContext()
//        let currentFilter = CIFilter.crystallize()
//        
//        currentFilter.inputImage = beginImage
//        let inputKeys = currentFilter.inputKeys
//        
//        let amount = 1
//        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(amount, forKey: kCIInputIntensityKey)}
//        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(amount * 200, forKey: kCIInputRadiusKey)}
//        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(amount * 10, forKey: kCIInputScaleKey)}
//        
//        
//        
//        if let outputImage = currentFilter.outputImage {
//            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
//                let uiImage = UIImage(cgImage: cgImage)
//                image = Image(uiImage: uiImage)
//            }
//        }
//    }
}

#Preview {
    ContentView()
}
