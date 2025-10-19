import Foundation

@MainActor
class ApiClient {
    public static func status(baseUrl: String, token: String?) async -> StatusResponse {
        let defaultErrorResponse = StatusResponse(successful: false, statusCode: nil, data: nil)
        if baseUrl == "" {
            return defaultErrorResponse
        }
        guard let url = URL(string: "\(baseUrl)/api/status") else { return defaultErrorResponse }
        do {
            var request = URLRequest(url: url)
            if token != nil {
                request.setValue("Basic \(token!)", forHTTPHeaderField: "Authorization")
            }
            let (data, r) = try await URLSession.shared.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                return StatusResponse(successful: true, statusCode: response.statusCode, data: data)
            }
            else {
                return StatusResponse(successful: false, statusCode: response.statusCode, data: nil)
            }
        } catch {
            return defaultErrorResponse
        }
    }
}
