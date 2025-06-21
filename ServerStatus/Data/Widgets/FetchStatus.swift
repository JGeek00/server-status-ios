import Foundation

@MainActor
func fetchStatus(serverInstance: ServerInstances) async -> StatusModel? {
    let response = await ApiClient.status(
        baseUrl: generateInstanceUrl(instance: serverInstance),
        token: serverInstance.useBasicAuth ? encodeCredentialsBasicAuth(username: serverInstance.basicAuthUser!, password: serverInstance.basicAuthPassword!) : nil
    )
    
    if response.successful == true && response.data != nil {
        do {
            let jsonDictionary = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [String: Any]
            let jsonData = try JSONSerialization.data(withJSONObject: transformStatusJSON(input: jsonDictionary!), options: [])
            let data = try JSONDecoder().decode(StatusModel.self, from: Data(jsonData))
            
            return data
        } catch {
            return nil
        }
    }
    else {
        return nil
    }
}
