// 1. Импортируем библиотеки:
import OpenAPIRuntime
import OpenAPIURLSession

// 2. Улучшаем читаемость кода — необязательный шаг
// Создаём псевдоним (typealias) для сгенерированного типа Stations.
// Полное имя Components.Schemas.Stations соответствует пути в openapi.yaml:
// components → schemas → Stations
typealias NearestStations = Components.Schemas.Stations

// Определяем протокол для нашего сервиса (хорошая практика для тестирования и гибкости)
protocol NearestStationsServiceProtocol {
  // Функция для получения станций, асинхронная и может выбросить ошибку
  func getNearestStations(lat: Double, lng: Double, distance: Int) async throws -> NearestStations
}

// Конкретная реализация сервиса
final class NearestStationsService: NearestStationsServiceProtocol {
  // Хранит экземпляр сгенерированного клиента
  private let client: Client
  // Хранит API-ключ (лучше передавать его извне, чем хранить прямо в сервисе)
  private let apikey: String
  
  init(client: Client, apikey: String) {
    self.client = client
    self.apikey = apikey
  }
  
  func getNearestStations(lat: Double, lng: Double, distance: Int) async throws -> NearestStations {
    // Вызываем функцию getNearestStations на ЭКЗЕМПЛЯРЕ сгенерированного клиента.
    // Имя функции и параметры 'query' напрямую соответствуют операции
    // 'getNearestStations' и её параметрам в openapi.yaml
    let response = try await client.getNearestStations(query: .init(
        apikey: apikey,     // Передаём API-ключ
        lat: lat,           // Передаём широту
        lng: lng,           // Передаём долготу
        distance: distance  // Передаём дистанцию
    ))
    // response.ok: Доступ к успешному ответу
    // .body: Получаем тело ответа
    // .json: Получаем объект из JSON в ожидаемом типе NearestStations
    return try response.ok.body.json
  }
}

// Функция для тестового вызова API
func testFetchStations() {
    // Создаём Task для выполнения асинхронного кода
    Task {
        do {
            // 1. Создаём экземпляр сгенерированного клиента
            let client = Client(
                // Используем URL сервера, также сгенерированный из openapi.yaml (если он там определён)
                serverURL: try Servers.Server1.url(),
                // Указываем, какой транспорт использовать для отправки запросов
                transport: URLSessionTransport()
            )
            
            // 2. Создаём экземпляр нашего сервиса, передавая ему клиент и API-ключ
            let service = NearestStationsService(
                client: client,
                apikey: "ceea6351-f390-4784-8f66-7f6409f22768"
            )
            
            // 3. Вызываем метод сервиса
            print("Fetching stations...")
            let stations = try await service.getNearestStations(
                lat: 59.864177, // Пример координат
                lng: 30.319163, // Пример координат
                distance: 50    // Пример дистанции
            )
            
            // 4. Если всё успешно, печатаем результат в консоль
            print("Successfully fetched stations: \(stations)")
        } catch {
            // 5. Если произошла ошибка на любом из этапов (создание клиента, вызов сервиса, обработка ответа),
            //    она будет поймана здесь, и мы выведем её в консоль
            print("Error fetching stations: \(error)")
            // В реальном приложении здесь должна быть логика обработки ошибок (показ алерта и т. д.)
        }
    }
}
