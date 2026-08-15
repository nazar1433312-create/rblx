# roblox-game

Rojo-проект: код пишется здесь (в этом репозитории), а Rojo синхронизирует его
в открытый плейс в Roblox Studio в реальном времени.

## Структура

```
src/
  server/   -> ServerScriptService   (обычные Script, серверный код)
  client/   -> StarterPlayer.StarterPlayerScripts (LocalScript, клиентский код)
  shared/   -> ReplicatedStorage     (ModuleScript, общий код)
```

## Установка (один раз, на Windows)

1. Поставь **Rokit** (менеджер версий инструментов Roblox, преемник Aftman):
   - Скачай установщик с https://github.com/rojo-rbx/rokit/releases (файл `rokit-*-windows-x86_64.zip`)
   - Распакуй и запусти `rokit-install.exe`, либо просто положи `rokit.exe` в PATH
   - Открой PowerShell в папке проекта и выполни:
     ```powershell
     rokit install
     ```
     Это поставит Rojo нужной версии из `aftman.toml`.

   Если не хочешь Rokit — можно поставить Rojo вручную: скачать `.exe` с
   https://github.com/rojo-rbx/rojo/releases и добавить в PATH.

2. Поставь плагин Rojo в Roblox Studio:
   ```powershell
   rojo plugin install
   ```
   (или вручную из Roblox Marketplace — плагин называется "Rojo")

3. Склонируй репозиторий (ссылку дам после публикации на GitHub):
   ```powershell
   git clone <URL_РЕПОЗИТОРИЯ>
   cd roblox-game
   ```

## Каждый раз, когда работаем

1. Подтяни свежий код:
   ```powershell
   git pull
   ```
2. Запусти сервер синхронизации из папки проекта:
   ```powershell
   rojo serve
   ```
3. Открой свой плейс в Roblox Studio → вкладка **Plugins** → кнопка **Rojo** →
   **Connect**. Всё, что лежит в `src/`, появится в дереве Explorer.
4. Дальше я пишу/правлю файлы, ты делаешь `git pull` — Rojo сам подхватывает
   изменения на лету, пока `rojo serve` запущен и Studio подключена.

## Важно

- Правки, сделанные вручную в самой Studio (через Explorer), Rojo **не**
  сохраняет обратно в файлы — источник истины это файлы в `src/`. Игровые
  объекты (модели, части карты и т.п.), которые ты собираешь руками в Studio,
  трогать через Rojo не нужно — они остаются в самом плейсе.
- `default.project.json` описывает, какая папка куда мапится в дереве игры.
