# Weatherapp

To prosta aplikacja pogodowa, pokazująca aktualne warunki dla wybranego miasta. Składa się z **frontendu** i **backendu**.

## Jak to działa?

* **Frontend (React.js):** Strona, którą widzisz w przeglądarce. Wyświetla ikonę pogody, a dane pobiera z backendu. Budowa frontendu opiera się na **React.js** z użyciem **Webpacka**.
* **Backend (Koa.js):** Serwer API, który łączy się z **OpenWeatherMap API**, pobiera dane pogodowe i przekazuje je do frontendu. Zbudowany na **Node.js (Koa.js)**.

---

## Co pod maską?

* **Node.js 16:** Aplikacja działa na Node.js w wersji 16 (`node:16-alpine`), ponieważ nowsze wersje powodowały błędy.
* **Zmienne środowiskowe:** Klucz API do OpenWeatherMap (**`APPID`**) jest ustawiony jako zmienna środowiskowa dla bezpieczeństwa i elastyczności.

---

### Docker

Cała aplikacja, czyli frontend i backend, została **skonteneryzowana w Dockerze**. To ułatwia zarówno uruchamianie, jak i pracę nad kodem:

* **`volumes`:** Wykorzystałem **woluminy (bind mounts)**, aby mieć pewność, że kod źródłowy w kontenerze jest zawsze identyczny z tym, który znajduje się w lokalnym projekcie na Twoim komputerze. Dzięki temu zmiany w plikach są natychmiast widoczne.
* **Hot Reload:** Aby uzyskać natychmiastowe odświeżanie aplikacji podczas dewelopmentu, wykorzystałem skrypt **`dev`** z pliku `package.json` w backendzie. Za funkcję hot reload odpowiadają odpowiednio `nodemon` (dla backendu) i `webpack-dev-server` (dla frontendu), które wykrywają zmiany w plikach dzięki wspomnianym woluminom.

---

#### Uruchamianie

Aby uruchomić całą aplikację w trybie deweloperskim, korzystamy z **Docker Compose**. Upewnij się, że znajdujesz się w głównym katalogu projektu, gdzie znajduje się plik `docker-compose.yml`.

1. **Zbuduj obrazy Docker i uruchom wszystkie kontenery:**

    ```bash
    docker compose up --build -d
    ```

    * `up`: Uruchamia wszystkie serwisy zdefiniowane w pliku `docker-compose.yml`.
    * `--build`: Sprawia, że Docker Compose najpierw przebudowuje obrazy (jeśli zaszły zmiany w `Dockerfile`'ach) lub buduje je od zera. Gwarantuje to użycie aktualnej wersji kodu.
    * `-d`: Uruchamia kontenery w tle (`detached mode`), zwalniając terminal.

2. **Dostęp do aplikacji:**
    Po uruchomieniu kontenerów, aplikacja będzie dostępna w przeglądarce pod adresem:
    * **Frontend:** `http://localhost:8000`
    * **Backend API:** `http://localhost:9000/api`

---

#### Przydatne komendy

Oto kilka dodatkowych komend, które przydadzą się podczas pracy z Docker Compose:

* **Sprawdź status uruchomionych kontenerów:**

    ```bash
    docker compose ps
    ```

    Ta komenda pokaże, które serwisy są aktywne, ich status (np. `running`), oraz mapowanie portów.

* **Śledź logi kontenerów w czasie rzeczywistym:**

    ```bash
    docker compose logs -f
    ```

    Wyświetla połączone logi ze wszystkich serwisów. Jest to przydatne do monitorowania działania aplikacji i debugowania błędów. Aby śledzić logi konkretnego serwisu (np. frontendu):

    ```bash
    docker compose logs -f weatherapp_frontend
    ```

* **Zatrzymaj i usuń wszystkie kontenery, sieci i woluminy:**

    ```bash
    docker compose down -v
    ```

    Ta komenda zatrzymuje i usuwa wszystkie zasoby Docker (kontenery, sieci), które zostały utworzone przez `docker compose up`.

#### Sprawdzanie hot-reload i docker volumes

Po uruchomieniu aplikacji z Docker Compose, możesz łatwo sprawdzić, czy hot reload oraz woluminy działają poprawnie:

1. Przejdź do <http://localhost:8000>. Powinieneś zobaczyć ikonke podobną do pogody.

* Zmodyfikuj plik źródłowy na swoim komputerze:
* W pliku frontend/src/index.jsx (lub innym komponencie) wprowadź drobną, widoczną zmianę tekstową. Na przykład, dodaj \<h1>Hello Docker!\</h1> gdzieś w sekcji render().
Zapisz plik.

2. Obserwuj zmiany:

* W przeglądarce: Aplikacja powinna odświeżyć się automatycznie (lub w trybie live reload) i pokazać wprowadzoną zmianę, bez potrzeby ręcznego odświeżania strony czy przebudowywania obrazu Dockera.
* W terminalu z logami: Jeśli masz otwarte docker compose logs -f weatherapp_frontend (lub docker compose logs -f), zobaczysz, jak webpack-dev-server wykrywa zmianę pliku, rekompiluje kod i sygnalizuje hot reload.

3. Test hot reload dla backendu (opcjonalnie):

* W pliku backend/src/index.js dodaj console.log('Zmiana w kodzie backendu!'); na początku pliku lub w jakiejś funkcji.
* Zapisz plik.
* W terminalu z logami: Zobaczysz, jak nodemon wykrywa zmianę pliku i automatycznie restartuje serwer Node.js, wyświetlając Twój nowy komunikat w logach.

### Cloud hosting

#### Dostęp SSH dla weryfikacji

Aby umożliwić weryfikację działania aplikacji oraz dostęp do maszyny wirtualnej, na instancji `efi-recruitment-instance` został dodany klucz publiczny `id_rsa_internship.pub`.

Osoba weryfikująca może połączyć się z maszyną za pomocą:

* **Nazwy użytkownika:** `efi_user`
* **Zewnętrznego adresu IP instancji:** (Tutaj podaj aktualny adres IP swojej maszyny, np. `34.107.5.93`)
* **Klucza prywatnego:** Odpowiadającego kluczowi publicznemu `id_rsa_internship.pub`.

**Przykładowa komenda SSH dla weryfikujących (zakładając, że mają klucz prywatny `id_rsa_internship`):**

```bash
ssh -i /sciezka/do/id_rsa_internship efi_user@34.107.5.93
