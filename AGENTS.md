# Zasady pracy agentów

1. Nie rozszerzaj zakresu zadania bez wyraźnej zgody użytkownika.
2. Przed każdą zmianą przeanalizuj istniejący kod i dokumentację w obszarze modyfikacji.
3. Po zmianie uruchom testy oraz kontrolę jakości właściwe dla zmodyfikowanego komponentu.
4. Nie omijaj ani nie ignoruj błędów testów; ustal ich przyczynę przed kontynuowaniem.
5. Nie dodawaj sekretów, haseł, prywatnych kluczy ani produkcyjnych connection stringów.
6. Nie wykonuj automatycznych commitów.
7. Utrzymuj wyraźne granice między .NET, Django i Flutterem; integruj je przez jawne kontrakty.
8. Używaj czytelnych, jednoznacznych nazw plików, typów, funkcji i zmiennych.
9. Komentuj tylko kod wymagający wyjaśnienia; preferuj kod wyrażający intencję.
10. Niestandardowe komentarze w skryptach zapisuj po polsku i angielsku.
11. Aktualizuj dokumentację przy każdej zmianie granic lub decyzji architektonicznej.
12. Gdy polecenie użytkownika wymaga raportu do przeglądu, agent zapisuje pełny raport jako `raport_z_polecenia.txt`, następnie uruchamia `./scripts/publish-review-artifacts.sh` i dopiero potem pokazuje krótkie podsumowanie w panelu Codexa. Nie uruchamiaj publikacji w zadaniach, które wyraźnie zabraniają dostępu do `/mnt/f` albo nie wymagają raportu.
13. Backend rozwijaj i waliduj Linux-first w klonie WSL pod `/home`; klony Windows i WSL synchronizuj przez Git, bez współdzielenia środowisk `.venv`.
14. Do lokalnych baz używaj Engine Docker Desktop udostępnionego przez WSL 2; nie instaluj drugiego Docker Engine w Ubuntu.
