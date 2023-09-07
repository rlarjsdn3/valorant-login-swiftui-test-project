//
//  LoginManager.swift
//  ValorantLoginTest
//
//  Created by 김건우 on 2023/09/06.
//

import Foundation

struct AuthCookieBody: Codable {
    var client_id: String = "play-valorant-web-prod"
    var nonce: String = "1"
    var redirect_uri: String = "https://playvalorant.com/opt_in"
    var response_type: String = "token id_token"
}

struct AuthTokenBody: Codable {
    var type: String = "auth"
    var username: String
    var password: String
    var language: String = "ko_KR"
}

struct AuthTokenResponse: Codable {
    let type: String?
    let response: Response?
}

struct Response: Codable {
    let parameters: URI?
}

struct URI: Codable {
    let uri: String?
}

struct EntitlementResponse: Codable{
    let entitlementToken: String?
    
    enum CodingKeys: String, CodingKey {
        case entitlementToken = "entitlements_token"
    }
}

struct PlayerInfoResponse: Codable {
    let sub: String?
}

struct NameServiceResponse: Codable {
    var displayName: String?
    var subject: String?
    var gameName: String?
    var tagLine: String?
    
    enum CodingKeys: String, CodingKey {
        case displayName = "DisplayName"
        case subject = "Subject"
        case gameName = "GameName"
        case tagLine = "TagLine"
    }
}

struct StorefrontResponse: Codable {
    let skinsPanelLayout: SkinPanelLayout?
    
    enum CodingKeys: String, CodingKey {
        case skinsPanelLayout = "SkinsPanelLayout"
    }
}

struct SkinPanelLayout: Codable {
    let singleItemOffers : [String]?
    let singleItemOffersRemainingDurationInSeconds : Int?
    
    enum CodingKeys: String, CodingKey {
        case singleItemOffers = "SingleItemOffers"
        case singleItemOffersRemainingDurationInSeconds = "SingleItemOffersRemainingDurationInSeconds"
    }
}

final class LoginManager {
    
    // 로그인하여 계정 기본 정보를 콘솔에 출력하고, 무기 스킨의 고유 UUID를 반환하는 함수
    func run(username: String, password: String) async -> [String]? {
        // AccessToken 호출을 위한 URL 생성하기
        guard let accessTokenUrl = URL(string: "https://auth.riotgames.com/api/v1/authorization") else {
            return nil
        }
        // HTTP 통신을 위한 세션 생성하기
        let session = URLSession(configuration: .ephemeral)
        
        // 쿠키 요청을 위한 HTTP 바디 생성하기
        let authCookieBody = AuthCookieBody()
        // 리퀘스트 생성하기
        var authCookieRequest = URLRequest(url: accessTokenUrl)
        authCookieRequest.httpMethod = "POST"
        authCookieRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        authCookieRequest.httpBody = try! JSONEncoder().encode(authCookieBody)
        // 서버에 Cookie 요청하기
        let (_, cookieResponse) = try! await session.data(for: authCookieRequest)
        // 상태 코드 검사하기
        guard let statusCode = (cookieResponse as? HTTPURLResponse)?.statusCode, statusCode == 200 else {
            print("authCookieRequest Error")
            return nil
        }
        
        // Access Token 요청을 위한 HTTP 바디 생성하기
        let authTokenBody = AuthTokenBody(username: username, password: password)
        // 리퀘스트 생성하기
        var authTokenRequest = URLRequest(url: accessTokenUrl)
        authTokenRequest.httpMethod = "PUT"
        authTokenRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        authTokenRequest.httpBody = try! JSONEncoder().encode(authTokenBody)
        // 서버에 Access Token 요청하기
        let (tokenData, tokenResponse) = try! await session.data(for: authTokenRequest)
        // 상태 코드 검사하기
        guard let statusCode = (tokenResponse as? HTTPURLResponse)?.statusCode, statusCode == 200 else {
            print("authTokenRequest Error")
            return nil
        }
        // 받아온 데이터를 구조체로 파싱하기
        guard let tokenParsedData = try? JSONDecoder().decode(AuthTokenResponse.self, from: tokenData),
              let uri = tokenParsedData.response?.parameters?.uri  else {
            print("JSON Decode Error")
            return nil
        }
        // 리다이렉트된 URI에서 Access Token 추출하기
        let pattern: String = #"access_token=((?:[a-zA-Z]|\d|\.|-|_)*).*id_token=((?:[a-zA-Z]|\d|\.|-|_)*).*expires_in=(\d*)"#
        guard let range = uri.range(of: pattern, options: .regularExpression) else {
            print("Regex Error")
            return nil
        }
        let accessToken = uri[range].split(separator: "&")[0].split(separator: "=")[1]
        print("⭐️Access Token: \(accessToken)") // ⭐️ Access Token 출력하기
        
        // Entitlement 호출을 위한 URL 생성하기
        guard let entitlementUrl = URL(string: "https://entitlements.auth.riotgames.com/api/token/v1") else {
            return nil
        }
        
        // Entitlement 요청을 위한 리퀘스트 생성하기
        var entitlementRequest = URLRequest(url: entitlementUrl)
        entitlementRequest.httpMethod = "POST"
        entitlementRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        entitlementRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        // 서버에 Entitlement 요청하기
        let (entitlementData, entitlementResponse) = try! await session.data(for: entitlementRequest)
        // 상태 코드 검사하기
        guard let statusCode = (entitlementResponse as? HTTPURLResponse)?.statusCode, statusCode == 200 else {
            print("entitlementReqeust Error")
            return nil
        }
        // 받아온 데이터를 구조체로 파싱하기
        guard let entitlementParsedData = try? JSONDecoder().decode(EntitlementResponse.self, from: entitlementData) else {
            print("JSON Decode Error")
            return nil
        }
        // Entitlement 추출하기
        guard let entitlementToken = entitlementParsedData.entitlementToken else {
            print("Entitlement Opional Binding Error")
            return nil
        }
    
        print("⭐️Entitlement Token: \(entitlementToken)") // ⭐️ Entitlement Token 출력하기
        
        // UserInfo 호출을 위한 URL 생성하기
        guard let userInfoUrl = URL(string: "https://auth.riotgames.com/userinfo") else {
            return nil
        }
        // UserInfo 요청을 위한 리퀘스트 생성하기
        var userInfoRequest = URLRequest(url: userInfoUrl)
        userInfoRequest.httpMethod = "POST"
        userInfoRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        userInfoRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        // 서버에 UserInfo 요청하기
        let (userInfoData, userInfoResponse) = try! await session.data(for: userInfoRequest)
        // 상태 코드 검사하기
        guard let statusCode = (userInfoResponse as? HTTPURLResponse)?.statusCode, statusCode == 200 else {
            print("userInfoRequest Error")
            return nil
        }
        // 받아온 데이터를 구조체로 파싱하기
        guard let userInfoParsedData = try? JSONDecoder().decode(PlayerInfoResponse.self, from: userInfoData) else {
            print("JSON Decode Error")
            return nil
        }
        // UserInfo 추출하기
        guard let puuid = userInfoParsedData.sub else {
            print("NickName Optional Binding Error")
            return nil
        }
        
        print("⭐️User PUUID: \(puuid)") // ⭐️ NickName 출력하기
        
        // PlayerName 호출을 위한 URL 생성하기
        guard let playerInfoUrl = URL(string: "https://pd.kr.a.pvp.net/name-service/v2/players") else {
            return nil
        }
        
        // PlayerName 요청을 위한 HTTP 바디 생성하기
        let playerInfoBody = [puuid]
        // PlayerName 요청을 위한 리퀘스트 생성하기
        var playerInfoRequest = URLRequest(url: playerInfoUrl)
        playerInfoRequest.httpMethod = "PUT"
        playerInfoRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        playerInfoRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        playerInfoRequest.setValue("\(entitlementToken)", forHTTPHeaderField: "X-Riot-Entitlements-JWT")
        playerInfoRequest.httpBody = try! JSONEncoder().encode(playerInfoBody)
        // 서버에 PlayerName 정보 요청하기
        let (playerNameData, playerNameResponse) = try! await session.data(for: playerInfoRequest)
        // 상태 코드 검사하기
        guard let statusCode = (playerNameResponse as? HTTPURLResponse)?.statusCode, statusCode == 200 else {
            print("playerInfoRequest Error")
            return nil
        }
        // 받아온 데이터를 구조체로 파싱하기
        guard let playerNameParsedData = try? JSONDecoder().decode([NameServiceResponse].self, from: playerNameData) else {
            print("JSON Decode Error")
            return nil
        }
        
        // 게임 닉네임 가져오기
        guard let displayName = playerNameParsedData[0].displayName else {
            return nil
        }
        print("⭐️DisplayName: \(displayName)")
        // 게임 닉네임 가져오기
        guard let gameName = playerNameParsedData[0].gameName else {
            return nil
        }
        print("⭐️GameName: \(gameName)")
        // PUUID 가져오기
        guard let subject = playerNameParsedData[0].subject else {
            return nil
        }
        print("⭐️PUUID: \(subject)")
        // 태그 가져오기
        guard let tag = playerNameParsedData[0].tagLine else {
            return nil
        }
        print("⭐️Tag: \(tag)")
        
        // StoreFront 호출을 위한 URL 생성하기
        guard let storeFrontUrl = URL(string: "https://pd.kr.a.pvp.net/store/v2/storefront/\(puuid)") else {
            return nil
        }
        // StoreFront 호출을 위한 리쿼스트 생성하기
        var storeFrontRequest = URLRequest(url: storeFrontUrl)
        storeFrontRequest.httpMethod = "GET"
        storeFrontRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        storeFrontRequest.setValue("\(entitlementToken)", forHTTPHeaderField: "X-Riot-Entitlements-JWT")
        // 서버에 StoreFront 정보 요청하기
        let (storeFrontData, storeFrontResponse) = try! await session.data(for: storeFrontRequest)
        // 상태 코드 검사하기
        guard let statusCode = (storeFrontResponse as? HTTPURLResponse)?.statusCode, statusCode == 200 else {
            print("playerInfoRequest Error")
            return nil
        }
        // 받아온 데이터를 구조체로 파싱하기
        guard let storeFrontParsedData = try? JSONDecoder().decode(StorefrontResponse.self, from: storeFrontData) else {
            print("JSON Decode Error")
            return nil
        }
        
        // 스킨 UUID 가져오기
        guard let skinsUuid = storeFrontParsedData.skinsPanelLayout?.singleItemOffers else {
            return nil
        }
        print("⭐️Weapon Skin UUID: \(skinsUuid)")
        
        // 스킨 UUID 반환하기
        return skinsUuid
    }
    
}
