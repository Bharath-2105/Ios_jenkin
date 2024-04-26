import SwiftUI
import PDFKit


struct PDFViewController: View {
    @State private var downloadProgress : Int = 0
    @State private var pdfFileLocalPath: String? = nil
    var pdfUrl: String
    
    var body: some View {
        ZStack(alignment: .top) {
            
            if let localPath = pdfFileLocalPath, let url = URL(string: localPath){
                PDFViewer(url: url)
            } else {
                VStack{
                    StyledButton(label: "", width: 40){
                    }
                    .showLoading(.constant(true))
                    CustomText.InterBoldText(Messages.downloadingPDFFile, fontSize: .subHeadingMedium, color: .black.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(){
            if let fileUrl = FileCache.shared.getCachedFile(for: pdfUrl){
                pdfFileLocalPath = fileUrl.absoluteString
            }
        }
        .onDownloadNotification(completion: { urlString , localFilePath in
            self.pdfFileLocalPath = localFilePath
        }, progress: { urlString, progressValue in
            downloadProgress = progressValue
        })
    }
}

struct PDFViewer: UIViewRepresentable {
    
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: self.url)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        // Update pdf if needed
    }
}
