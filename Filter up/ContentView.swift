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
import StoreKit

struct ContentView: View {
    
    @State private var processedImage: Image?
    @State private var filterIntensity = 0.5
    @State private var selectedItem: PhotosPickerItem?
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    @AppStorage("filterCount") var filterCount = 0
    @Environment(\.requestReview) var requestReview
    
    @State private var isImageSelected = false
    @State private var filterName: String = "Sepia Tone"
    @State private var showFilterName = false
    
    @State private var dragOffset: CGFloat = 0.0
       @State private var isSwiping = false
    
    @State private var ciImage: CIImage?
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                PhotosPicker(selection: $selectedItem) {
                    VStack {
                        
                        if showFilterName {
                            Text(filterName)
                                .font(.title)
                                .bold()
                                .foregroundColor(.black.opacity(0.6))
                                .shadow(radius: 10)
                                .transition(.opacity)
                        }
                        
                        
                        if let processedImage {
                            processedImage
                                .resizable()
                                .scaledToFit()
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            isSwiping = true
                                            dragOffset = value.translation.width
                                        }
                                        .onEnded { value in
                                                if value.translation.width < -50 {
                                                    nextFilter()
                                                } else if value.translation.width > 50 {
                                                    previousFilter()
                                                }
                                                dragOffset = 0
                                                isSwiping = false
                                            
                                        }
                                )
                                .cornerRadius(22)
                                .shadow(radius: 12)
                        } else {
                            ContentUnavailableView("No Picture", systemImage: "photo.badge.plus", description: Text("Tap to import a photo"))
                        }
                        
                        
                    }
                }
                .buttonStyle(.plain)
                .onChange(of: selectedItem, loadImage)
                
                Spacer()
                
                HStack {
               
                    Slider(value: $filterIntensity)
                        .onChange(of: filterIntensity, applyProcessing)
                        .padding()
                        .tint(.orange)
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Filter up")
            .toolbar {
                Button("Share", systemImage: "square.and.arrow.up") {
                    if let processedImage {
                        ShareLink(item: processedImage, preview: SharePreview("\(currentFilter)ed Image", image: processedImage))
                    }
                }
                .tint(.orange)
                
              
            }
        }
    }
    

    
    func loadImage() {
        isImageSelected = true
        showFilterName = true
        Task {
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return }
            guard let inputImage = UIImage(data: imageData) else { return }
            
            let beginImage = CIImage(image: inputImage)
           
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            applyProcessing()
        }
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey) }
        
        guard let outputImage = currentFilter.outputImage else { return }
        ciImage = outputImage
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        let uiImage = UIImage(cgImage: cgImage)
        processedImage = Image(uiImage: uiImage)
    }
    
    func setFilter(_ filter: CIFilter, filterName: String) {
        currentFilter = filter
        self.filterName = filterName
        loadImage()
        
        filterCount += 1
        
        if filterCount >= 2000 {
            requestReview()
        }
        
        showFilterName = true
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            withAnimation {
//                showFilterName = false
//            }
//        }
    }
    
    func nextFilter() {
        let filters: [(CIFilter, String)] = [
            (CIFilter.crystallize(), "Crystallize"),
            (CIFilter.edges(), "Edges"),
            (CIFilter.gaussianBlur(), "Gaussian Blur"),
            (CIFilter.pixellate(), "Pixellate"),
            (CIFilter.sepiaTone(), "Sepia Tone"),
            (CIFilter.unsharpMask(), "Unsharp Mask"),
            (CIFilter.vignette(), "Vignette")
        ]
        
        if let currentIndex = filters.firstIndex(where: { $0.0.name == currentFilter.name }), currentIndex + 1 < filters.count {
            let nextFilter = filters[currentIndex + 1]
            setFilter(nextFilter.0, filterName: nextFilter.1)
        } else {
            setFilter(filters[0].0, filterName: filters[0].1)
        }
    }
    
    func previousFilter() {
        let filters: [(CIFilter, String)] = [
            (CIFilter.crystallize(), "Crystallize"),
            (CIFilter.edges(), "Edges"),
            (CIFilter.gaussianBlur(), "Gaussian Blur"),
            (CIFilter.pixellate(), "Pixellate"),
            (CIFilter.sepiaTone(), "Sepia Tone"),
            (CIFilter.unsharpMask(), "Unsharp Mask"),
            (CIFilter.vignette(), "Vignette")
        ]
        
        if let currentIndex = filters.firstIndex(where: { $0.0.name == currentFilter.name }), currentIndex > 0 {
            let previousFilter = filters[currentIndex - 1]
            setFilter(previousFilter.0, filterName: previousFilter.1)
        } else {
            setFilter(filters.last!.0, filterName: filters.last!.1)
        }
    }
}


#Preview {
    ContentView()
}
