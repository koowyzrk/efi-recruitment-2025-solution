# Weatherapp

To prosta aplikacja pogodowa, pokazująca aktualne warunki dla wybranego miasta. Składa się z **frontendu** i **backendu**.

## Jak to działa?

* **Frontend (React.js):** Strona, którą widzisz w przeglądarce. Wyświetla ikonę pogody, a dane pobiera z backendu. Budowa frontendu opiera się na **React.js** z użyciem **Webpacka**.
* **Backend (Koa.js):** Serwer API, który łączy się z **OpenWeatherMap API**, pobiera dane pogodowe i przekazuje je do frontendu. Zbudowany na **Node.js (Koa.js)**.

---

## Co w projekcie

* **Node.js 16:** Aplikacja działa na Node.js w wersji 16 (`node:16-alpine`), ponieważ nowsze wersje powodowały błędy.
* **Zmienne środowiskowe:
  * ** Klucz API do OpenWeatherMap (**`APPID`**) jest ustawiony jako zmienna środowiskowa dla bezpieczeństwa i elastyczności.
  * Zmienna przechowująca klucz ssh (**`TF_VAR_user_ssh_keys`**)

---

### Budowanie aplikacji lokalnie oraz w chmurze

## Proces wdrażania

W katalogu głównym znajduje się skrypt `deploy.sh`, który umożliwia wybór środowiska:

1. **Tryb chmurowy (Google Cloud)** gdzie maszyna ma statyczny adres (34.40.75.156):
   * Uruchamia Terraform i tworzy VM.
   * Oczekuje na możliwość połączenia przez SSH.
   * Uruchamia Ansible w celu zainstalowania i uruchomienia aplikacji.

2. **Tryb lokalny**:
   * Uruchamia Ansible bezpośrednio lokalnie.
   * Buduje i uruchamia kontenery Dockera z katalogu źródłowego.

---
(Aplikacja już jest uruchomiona na postawionej maszynie ale i tak można użyć deploy.sh aby ją przeładować)
Wystarczy więc wejść na strone <http://34.40.75.156:8000> aby sprawdzić poprawność wykonanwego zadania.

Przed zbudowaniem aplikacji należy upewnić się czy w swoim środowisku komputerowym ma się zainstalowane programy. Lista potrzebnych:

* ansible
* terraform
* git
* docker
* docker-compose
* gcloud

Aby je zainstalować wystarczy wykonać komendę w terminalu:

* dla środowiska Debian, Ubuntu

```bash
sudo apt install ansible terraform git docker docker-compose
```

* dla środowiska Arch

```bash
sudo pacman -S ansible terraform git docker docker-compose
```

Do zainstalowania gcloud potrzebujemy wykonać następujące działania:

```bash
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
tar -xf google-cloud-cli-linux-x86_64.tar.gz
./google-cloud-sdk/install.sh
./google-cloud-sdk/bin/gcloud init
```

Po zainstalowaniu potrzebnego oprogramowania możemy przystąpić do zbudowania aplikacji.

1. Najpierw musimy sciągnąć potrzebne repozytorium, używając:

```bash
git clone https://github.com/koowyzrk/efi-recruitment-2025-solution
```

2. Możemy to zrobić na dwa sposoby:

* lokalnie - nie będziemy do tego potrzebować terraform a jedynie ansible,docker i docker-compose
  * Przed trzeba dodać swojego użytkownika do grupy docker
  * wywołać skrypt deploy.sh i wybrać opcję lokalnie

* w chmurze
  * przed przystąpieniem do inicjalizacji za pomocą terraform musimy stworzyć Google Cloud project:

  ```bash
  gcloud projects create PROJECT_ID
  ```

  * po stworzeniu należy go wybrać

  ```bash
  gcloud config set project PROJECT_ID
  ```

  * włączyć Compute Engine API:

  ```bash
  gcloud services enable compute.googleapis.com
  ```

  Do poprawnego działania terraform i do umożliwienia zalogowania sie do maszyny za pomocą ssh musimy przed użyciem terraform dodać zmienną środowiskową aby dodać do maszyny odpowiedni klucz ssh:

  ```bash
  export TF_VAR_user_ssh_keys="efi_user:$(cat path/to/id_rsa_internship.pub)"
  ```

  Po tych krokach możemy skorzystać z skryptu deploy.sh

  ```bash
  ./deploy.sh --key /path/to/your/key
  ```

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
* W pliku frontend/src/index.jsx (lub innym komponencie) wprowadź drobną, widoczną zmianę tekstową. Zapisz plik.

2. Obserwuj zmiany:

* W przeglądarce: Aplikacja powinna odświeżyć się automatycznie (lub w trybie live reload) i pokazać wprowadzoną zmianę, bez potrzeby ręcznego odświeżania strony czy przebudowywania obrazu Dockera.
* W terminalu z logami: Jeśli masz otwarte docker compose logs -f weatherapp_frontend (lub docker compose logs -f), zobaczysz, jak webpack-dev-server wykrywa zmianę pliku, rekompiluje kod i sygnalizuje hot reload.

### Cloud hosting

Do hostingu wykorzystałem maszyne wirtualną compute instance dostępne w Google Cloud.Przykładowa komenda do stworzenia maszyny:

```bash
gcloud compute instances create efi-recruitment-instance 
  --zone=europe-west3-b --machine-type=e2-small 
  --image-family=debian-12 
  --image-project=debian-cloud 
  --boot-disk-size=20GB 
  --metadata=ssh-keys="weather_app:$(cat ~/.ssh/weather_rsa.pub)" 
  --tags=http-server,https-server,weatherapp 
  --scopes=https://www.googleapis.com/auth/cloud-platform
```

#### Dostęp SSH dla weryfikacji

Aby umożliwić weryfikację działania aplikacji oraz dostęp do maszyny wirtualnej można połączyć się do niej za pomocą ssh.

* **Nazwy użytkownika:** `efi_user`
* **Zewnętrznego adresu IP instancji, który można zpingować:** (34.40.75.156)
* **Klucza prywatnego:** Odpowiadającego kluczowi publicznemu `id_rsa_internship.pub`.

**Przykładowa komenda SSH dla weryfikujących (`id_rsa_internship`):**

```bash
ssh -i /sciezka/do/id_rsa_internship efi_user@34.40.75.156
```

## Terraform

Terraform odpowiada za **przygotowanie infrastruktury** potrzebnej do działania aplikacji w chmurze GCP.

### Główne działania

* Tworzy **statyczny adres IP** (zewnętrzny) dla maszyny wirtualnej. (34.40.75.156)
* Tworzy **instancję VM** w strefie `europe-west3-b`, opartą na obrazie Debian 12.
* Przypisuje **klucze SSH**, umożliwiające zdalne połączenie.
* Definiuje **zasady zapory sieciowej (firewall)** umożliwiające dostęp do portu `8000` z zewnątrz.
* Taguje instancję etykietą `weatherapp`, aby reguły sieciowe mogły ją identyfikować.
* Udostępnia **adres IP instancji** jako dane wyjściowe (output).

---

## Ansible

Ansible odpowiada za **konfigurację środowiska** oraz **wdrożenie aplikacji**.

### `deploy_app.yml` – Wdrożenie w chmurze

* Wykonywany zdalnie na maszynie wirtualnej GCP.
* Instalacja wymaganych pakietów (`python3`, `git`, `curl`, `docker`, itp.).
* Pobranie i dodanie oficjalnego klucza GPG Dockera.
* Instalacja Dockera i Docker Compose.
* Klonowanie repozytorium aplikacji z GitHub.
* Dodanie użytkownika do grupy `docker`.
* Uruchomienie aplikacji przy pomocy `docker-compose up -d --build`.

### `deploy_local.yml` – Wdrożenie lokalne

* Wykonywany lokalnie, bez potrzeby uprawnień administratora.
* Buduje i uruchamia aplikację za pomocą `community.docker.docker_compose_v2` z lokalnego katalogu źródłowego.

### `inventory.ini`

* Definiuje grupy hostów dla Ansible:
  * `local` – lokalna maszyna użytkownika.
  * `cloud` – dynamiczna grupa dla maszyn w chmurze (ustawiana przez skrypt deploy.sh).

---
