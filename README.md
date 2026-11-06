# Смены — журнал массажиста

Простое приложение для iPhone, которое заменяет бумажный рабочий журнал на смену.
Забиваешь клиентов между сеансами в два касания, а внизу всегда видно выручку и свою зарплату.

## Что умеет

- **Сетка смены 08:00–21:30** — ячейки по 30 минут (27 штук), каждая со своим временем начала и конца.
- **Три поля на ячейку:** фамилия клиента, зона массажа (выпадающий список), стоимость в рублях.
- **Зоны:** ШВЗ, СПИНА, ПОЯСНИЦА, ПОЗВОНОЧНИК, ШЕЙНО-ГРУДНОЙ, СПИНА+ПОЯСНИЦА.
- **Панель итогов внизу экрана** (всегда на виду): выручка за день и **зарплата ровно 21%** от неё, плюс счётчик занятых ячеек.
- **«Очистить день»** — кнопка-корзина в правом верхнем углу, с подтверждением.
- **Сохранение по дням:** каждая дата хранится отдельно, можно листать стрелками ‹ › и возвращаться к прошлым сменам. Данные пишутся автоматически при каждом изменении.
- Тёмных экранов нет — светлая тема, крупные поля (46 pt), цифровая клавиатура с кнопкой «Готово».

## Как это выглядит

Сверху — дата смены и стрелки переключения дней. Дальше идут строки: слева время, справа фамилия, зона и сумма.
Внизу закреплена тёмно-зелёная панель с итогами — она не уезжает при прокрутке.

## Структура

```
MassageJournal/
├── project.yml                  # описание проекта для XcodeGen
├── Info.plist
├── Sources/
│   ├── App/MassageJournalApp.swift
│   ├── Model/Shift.swift        # зоны, параметры смены, модель ячейки
│   ├── Model/JournalStore.swift # хранение по дням, итоги, зарплата
│   ├── Support/Support.swift    # деньги, haptics, клавиатура
│   └── Views/                   # ContentView, DayHeader, SlotRow, ZoneMenu, PriceField, TotalsBar
├── Resources/Assets.xcassets    # иконка
├── scripts/make_icon.py         # перегенерация иконки
└── .github/workflows/build-ipa.yml
```

## Сколько ячеек и как поменять

В задаче было «24 ячейки», но 24 × 30 минут — это 08:00–20:00, а смена заканчивается в 21:30.
Поэтому сетка покрывает смену целиком: **08:00–21:30 = 27 ячеек**.

Если нужно ровно 24 (до 20:00) — одна строка в `Sources/Model/Shift.swift`:

```swift
static let endHour = 21   // ← поставить 20
static let endMinute = 30 // ← и 0
```

Количество ячеек считается автоматически: `(конец − начало) / 30`.

## Сборка

**Есть Mac:**

```bash
brew install xcodegen
xcodegen generate
open MassageJournal.xcodeproj
```

**Только Windows** — через GitHub Actions (этот репозиторий уже настроен):

```bash
git init && git add . && git commit -m "init"
gh repo create massage-journal --public --source=. --push
gh run watch
gh run download -n MassageJournal-unsigned-ipa -D artifacts
```

Получишь **неподписанный** `MassageJournal-unsigned.ipa` — подписываешь своим сертификатом:

```powershell
zsign.exe -k cert.p12 -p <пароль> -m profile.mobileprovision -o MassageJournal-signed.ipa MassageJournal-unsigned.ipa
python -m pymobiledevice3 apps install MassageJournal-signed.ipa
```

Важно: `runs-on` в workflow зафиксирован на `macos-14`, а в `project.yml` стоит `projectFormat: xcode15_3` —
оба пункта появились из-за реальных ошибок (очередь `macos-latest` и «future Xcode project file format (77)»).

## Что стоит знать

- Bundle ID по умолчанию `com.example.massagejournal`; при подписи он должен совпадать с профилем (или быть wildcard).
- Файлы подписи (`.p12`, `.mobileprovision`) в репозиторий не попадают — они в `.gitignore`.
- Иконку можно перерисовать: `python scripts/make_icon.py` (нужен Pillow).
