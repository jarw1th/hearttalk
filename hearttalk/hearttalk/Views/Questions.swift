
import SwiftUI

struct Questions: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    let cardType: CardType
    
    @State private var questionMode: QuestionMode = .cards
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .edgesIgnoringSafeArea(.bottom)
            .onAppear {
                viewModel.fetchCards(forCardTypeId: cardType.id)
            }
    }
    
    private func makeContent() -> some View {
        VStack(spacing: 24) {
            NavigationBar {
                Image(questionMode.imageName())
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(.darkWhite)
                    .frame(width: 16, height: 16)
            } buttonAction: {
                questionMode.toggle()
            }
            .padding(.horizontal, 20)
            
            if questionMode == .list {
                makeList()
            } else {
                makeCards()
            }
            
            makeBackButton()
        }
        .padding(.top, 8)
        .padding(.bottom, 70)
    }
    
    private func makeCards() -> some View {
        ScrollView {
            
        }
    }
    
    private func makeList() -> some View {
        ScrollView {
            LazyVStack {
                ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                    ListItem(number: index + 1, question: card.question)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func makeBackButton() -> some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text("Go back")
                .font(.custom("PlayfairDisplay-Regular", size: 16))
                .underline()
                .multilineTextAlignment(.center)
                .foregroundStyle(.darkWhite)
                .opacity(66)
        }
    }
    
}

#Preview {
    Questions(cardType: CardType(id: "", name: ""))
}
