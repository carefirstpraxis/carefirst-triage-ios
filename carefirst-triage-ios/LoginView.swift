import SwiftUI

let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)

struct LoginView: View {
  @State var username: String = ""
  @State var usernameError: String = ""
  @State var password: String = ""
  @State var passwordError: String = ""
  @State var submitError: String = ""
  
  @ObservedObject var screens: Screens
  
  var body: some View {
    @EnvironmentObject var screens: Screens
      VStack {
        WelcomeText()
        UserImage()
        
        TextField("Username", text: $username)
          .padding()
          .background(lightGreyColor)
          .cornerRadius(5.0)
          .padding(.bottom, 20)
          .textInputAutocapitalization(.never)
          .frame(width: 220)
        
        HStack {
          Text( usernameError )
            .fontWeight(.light)
            .font(.footnote)
            .foregroundColor(Color.red)
          
          if !usernameError.isEmpty  {
            Image( systemName: "exclamationmark.triangle")
             .foregroundColor(Color.red)
             .font(.footnote)
          }
        }.padding(.bottom, 20).frame(width: 220, alignment: .leading)
        
        SecureField("Password", text: $password)
          .padding()
          .background(lightGreyColor)
          .cornerRadius(5.0)
          .padding(.bottom, 20)
          .frame(width: 220)
        
        HStack {
          Text( passwordError )
            .fontWeight(.light)
            .font(.footnote)
            .foregroundColor(Color.red)
          
          if !passwordError.isEmpty  {
            Image( systemName: "exclamationmark.triangle")
             .foregroundColor(Color.red)
             .font(.footnote)
          }
        }.padding(.bottom, 20).frame(width: 220, alignment: .leading)
        
        Button(action: handleSubmit) {
          LoginButtonContent()
        }
      
       
        HStack {
          Text( submitError )
            .fontWeight(.light)
            .font(.footnote)
            .foregroundColor(Color.red)
          
          if !submitError.isEmpty  {
            Image( systemName: "exclamationmark.triangle")
             .foregroundColor(Color.red)
             .font(.footnote)
          }
        }.padding(.top, 20)
        
      }
      .padding()
  }
  
  
    func handleSubmit() {
      if (!validate()) {
        return
      }
      guard let url = URL(string: "http://192.168.86.250:8080/cfpm/app/login") else {
        return
      }

      var request = URLRequest(url: url)
      let queryItems = [URLQueryItem(name: "data", value: "{\"username\":\(username),\"password\":\(password),\"clientType\":\"user\",\"module\":\"pm\"}"),]
      var urlComponents = URLComponents(string: "")
      urlComponents?.queryItems = queryItems
      let request_body = urlComponents!.query!
      request.httpBody = Data(request_body.utf8)
      request.httpMethod = "POST"
      request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
      let task = URLSession.shared.dataTask(with: request) { data, _, error in
        guard let data = data, error == nil else {
          return
        }
        do {
          print("DATA: \(data)")
          let response: Response = try JSONDecoder().decode(Response.self, from: data)
          print("SUCCESS: \(response)")
          let authStatus = response.client.authStatus
          print("authStatus: \(authStatus)")
            
          if authStatus == AUTH_STATUS.AUTHENTICATED {
            DispatchQueue.main.async {
              screens.currentScreen = 2
            }
          }
          else {
            submitError = "Invalid login"
          }
        }
        catch {
          submitError = "Invalid Server Response"
          print("ERROR: \(error)")
        }
      }
      task.resume()
    }
  
  
  func validate() -> Bool {
    usernameError = ""
    passwordError = ""
    submitError = ""
    var isValid = true
    
    if username.isEmpty {
      usernameError = "Username required"
      isValid = false
    }
    if password.isEmpty {
      passwordError = "Password required"
      isValid = false
    }
    return isValid
  }
}

  
struct WelcomeText : View {
  var body: some View {
    return Text("CareFirst Triage")
      .font(.largeTitle)
      .fontWeight(.semibold)
      .padding(.bottom, 20)
    }
}

struct UserImage : View {
  var body: some View {
    return Image("appLogo")
      .resizable()
      .aspectRatio(contentMode: .fill)
      .frame(width: 150, height: 150)
      .padding(.bottom, 75)
  }
}

struct LoginButtonContent : View {
  var body: some View {
    return Text("LOGIN")
      .font(.headline)
      .foregroundColor(.white)
      .padding()
      .frame(width: 220, height: 60)
      .background(Color.green)
      .cornerRadius(15.0)
  }
}

struct Response: Codable {
  let authenticated: Bool
  let clientType: String
  let client: Client
}

struct Client: Codable {
  let authStatus: Int
}

class JSONNull: Codable, Hashable {

  public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
    return true
  }

  public var hashValue: Int {
    return 0
  }

  public func hash(into hasher: inout Hasher) {
    // No-op
  }

  public init() {}

  public required init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if !container.decodeNil() {
      throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encodeNil()
  }
}
