# Скрипт синхронизации репозиториев (PowerShell)

function Copy-Repo {
    param ($source, $destination)
    Write-Host "Копирование содержимого из $source в $destination..."
    robocopy $source $destination /E /XD ".git" /MT /NFL /NDL /NJH /NJS
    Write-Host "Копирование завершено."
}

# Ввод ссылок на репозитории
$MY_REPO = Read-Host "Введите ссылку на ваш репозиторий (куда синхронизировать)"
$CLONE_REPO = Read-Host "Введите ссылку на репозиторий для клонирования"

# Клонирование во временную папку
$TEMP_DIR = New-Item -ItemType Directory -Path ([System.IO.Path]::GetTempPath() + [System.Guid]::NewGuid())
Write-Host "Клонирование $CLONE_REPO в $TEMP_DIR..."
git clone $CLONE_REPO $TEMP_DIR.FullName

# Pull изменений
Set-Location $TEMP_DIR.FullName
git pull origin main -ErrorAction SilentlyContinue
git pull origin master -ErrorAction SilentlyContinue
Set-Location ..

# Клонирование локального репозитория, если не существует
$LOCAL_DIR = Join-Path (Get-Location) "my_repo"
if (-Not (Test-Path $LOCAL_DIR)) {
    Write-Host "Клонирование вашего репозитория $MY_REPO в $LOCAL_DIR..."
    git clone $MY_REPO $LOCAL_DIR
}

# Копирование содержимого
Copy-Repo $TEMP_DIR.FullName $LOCAL_DIR

# Опциональный push
$PUSH_CHOICE = Read-Host "Выполнить git push в вашем репозитории? (y/n)"
if ($PUSH_CHOICE -eq "y" -or $PUSH_CHOICE -eq "Y") {
    Set-Location $LOCAL_DIR
    git add .
    git commit -m "Sync from remote repo"
    git push origin main -ErrorAction SilentlyContinue
    git push origin master -ErrorAction SilentlyContinue
    Set-Location ..
}

# Очистка временной папки
Remove-Item -Recurse -Force $TEMP_DIR
Write-Host "Синхронизация завершена."