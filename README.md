# Weatherapp
Prosta aplikacja pogodowa, która pokazuje aktualne warunki dla wybranego miasta. Składa się z dwóch głównych części: frontendu i backendu.

## Działanie
- frontend (react.js) - strona internetowa wyświetlająca ikonkę pogody. Pobiera potrzebne dane z backendu. Do działania frontendu używamy Webpacka.
- backend (koa.js) - serwer API. Jego zadanie to łączenie się z zewnętrznym serwisem OpenWeatherMap API, pobieranie stamtąd danych i przekazanie ich do frontendu.

## Elementy techiniczne
Aplikacja działa na środowisku node.js w wersji 16 (node:16-alpine). Nowsze wersje nie są kompatybilne i przy uruchamianiu jej lokalnie za pomocą npm i && npm start wyrzuca wiele błędów
- zmienne środowiskowe - APPID - klucz API pobrany ze strony pogodowej

### docker 
- obie części projektu backend i frontend zostały opakowane w konetenery Docker (co powoduje że działa w identycznym izolowanym środowisku).
