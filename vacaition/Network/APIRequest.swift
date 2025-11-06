import Foundation
import FirebaseAuth

struct APIRequest {
    static func createRequest(
        endpoint: APIEndpoint,
        body: [String: Any]? = nil,
        headers: [String: String]? = nil
    ) async throws -> URLRequest {
        guard let url = endpoint.url() else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add Firebase Auth token
        if let user = Auth.auth().currentUser {
            let token = try await user.getIDToken()
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add custom headers
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add body if provided
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                throw APIError.decodingError(error)
            }
        }
        
        return request
    }
    
    static func perform<T: Decodable>(
        endpoint: APIEndpoint,
        body: [String: Any]? = nil,
        responseType: T.Type
    ) async throws -> T {
        let request = try await createRequest(endpoint: endpoint, body: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // Handle HTTP errors
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)["error"]
            
            switch httpResponse.statusCode {
            case 401:
                throw APIError.unauthorized
            case 429:
                throw APIError.rateLimitExceeded
            case 500...599:
                throw APIError.serverError(httpResponse.statusCode)
            default:
                throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
            }
        }
        
        // Decode response
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}

