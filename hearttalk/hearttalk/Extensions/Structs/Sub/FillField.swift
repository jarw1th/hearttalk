
import SwiftUI

struct FillField: View {
    
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        makeContent()
    }
    
    private func makeContent() -> some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                    .foregroundColor(.lightBlack)
                    .opacity(0.66)
            }
            TextField("", text: $text)
                .autocapitalization(.sentences)
                .disableAutocorrection(true)
                .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                .foregroundStyle(.lightBlack)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32)
        .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 8 : 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.darkWhite)
        )
    }
    
}

struct TagsFillField: View {
    
    let placeholder: String
    @Binding var texts: [String]
    @State private var text: String = ""
    @FocusState private var focused: Bool
    
    var body: some View {
        makeContent()
            .onChange(of: focused) { newValue in
                if !newValue && !text.isEmpty {
                    texts.append(text)
                }
            }
    }
    
    private func makeContent() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(texts, id: \.self) { usedText in
                    Button {
                        if texts.contains(usedText) {
                            texts.removeAll(where: { $0 == usedText })
                        }
                    } label: {
                        Text(placeholder)
                            .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                            .foregroundColor(.darkWhite)
                            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24)
                            .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 4 : 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.darkGreen)
                            )
                    }
                }
                ZStack(alignment: .leading) {
                    if texts.isEmpty && text.isEmpty {
                        Text(placeholder)
                            .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                            .foregroundColor(.lightBlack)
                            .opacity(0.66)
                    }
                    TextField("", text: $text)
                        .autocapitalization(.sentences)
                        .disableAutocorrection(true)
                        .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                        .foregroundStyle(.lightBlack)
                        .frame(maxWidth: .infinity)
                        .focused($focused)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24)
            .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 4 : 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.darkWhite)
            )
        }
    }
    
}
