import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Image("Veriable")
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(width: 180, height: 180)
                .accessibilityLabel("Veriable logo")
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
