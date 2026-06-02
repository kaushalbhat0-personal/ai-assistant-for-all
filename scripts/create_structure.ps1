# ScreenFix AI — Repository Structure Creator (Windows PowerShell)
# Run from project root: .\scripts\create_structure.ps1

Write-Host "Creating ScreenFix AI directory structure..." -ForegroundColor Green

# Core
$null = New-Item -ItemType Directory -Path lib/core/constants -Force
$null = New-Item -ItemType Directory -Path lib/core/config -Force
$null = New-Item -ItemType Directory -Path lib/core/errors -Force
$null = New-Item -ItemType Directory -Path lib/core/network/interceptors -Force
$null = New-Item -ItemType Directory -Path lib/core/ai -Force
$null = New-Item -ItemType Directory -Path lib/core/identity -Force
$null = New-Item -ItemType Directory -Path lib/core/telemetry -Force
$null = New-Item -ItemType Directory -Path lib/core/feature_flags -Force
$null = New-Item -ItemType Directory -Path lib/core/di -Force

# Common
$null = New-Item -ItemType Directory -Path lib/common/widgets -Force

# Features — Overlay
$null = New-Item -ItemType Directory -Path lib/features/overlay/domain/entities -Force
$null = New-Item -ItemType Directory -Path lib/features/overlay/domain/repositories -Force
$null = New-Item -ItemType Directory -Path lib/features/overlay/domain/usecases -Force
$null = New-Item -ItemType Directory -Path lib/features/overlay/data/repositories -Force
$null = New-Item -ItemType Directory -Path lib/features/overlay/data/datasources -Force
$null = New-Item -ItemType Directory -Path lib/features/overlay/data/di -Force
$null = New-Item -ItemType Directory -Path lib/features/overlay/presentation/widgets -Force
$null = New-Item -ItemType Directory -Path lib/features/overlay/presentation/notifier -Force

# Features — Screen Capture
$null = New-Item -ItemType Directory -Path lib/features/screen_capture/domain/entities -Force
$null = New-Item -ItemType Directory -Path lib/features/screen_capture/domain/repositories -Force
$null = New-Item -ItemType Directory -Path lib/features/screen_capture/domain/usecases -Force
$null = New-Item -ItemType Directory -Path lib/features/screen_capture/data/repositories -Force
$null = New-Item -ItemType Directory -Path lib/features/screen_capture/data/datasources -Force
$null = New-Item -ItemType Directory -Path lib/features/screen_capture/data/di -Force
$null = New-Item -ItemType Directory -Path lib/features/screen_capture/presentation/notifier -Force

# Features — OCR
$null = New-Item -ItemType Directory -Path lib/features/ocr/domain/entities -Force
$null = New-Item -ItemType Directory -Path lib/features/ocr/domain/repositories -Force
$null = New-Item -ItemType Directory -Path lib/features/ocr/domain/usecases -Force
$null = New-Item -ItemType Directory -Path lib/features/ocr/data/repositories -Force
$null = New-Item -ItemType Directory -Path lib/features/ocr/data/datasources -Force
$null = New-Item -ItemType Directory -Path lib/features/ocr/data/di -Force
$null = New-Item -ItemType Directory -Path lib/features/ocr/presentation/notifier -Force

# Features — Local Analysis
$null = New-Item -ItemType Directory -Path lib/features/local_analysis/domain/entities -Force
$null = New-Item -ItemType Directory -Path lib/features/local_analysis/domain/repositories -Force
$null = New-Item -ItemType Directory -Path lib/features/local_analysis/domain/usecases -Force
$null = New-Item -ItemType Directory -Path lib/features/local_analysis/data/repositories -Force
$null = New-Item -ItemType Directory -Path lib/features/local_analysis/data/datasources/patterns -Force
$null = New-Item -ItemType Directory -Path lib/features/local_analysis/data/di -Force
$null = New-Item -ItemType Directory -Path lib/features/local_analysis/presentation/notifier -Force

# Features — Prompt Engine
$null = New-Item -ItemType Directory -Path lib/features/prompt_engine/domain/entities -Force
$null = New-Item -ItemType Directory -Path lib/features/prompt_engine/domain/repositories -Force
$null = New-Item -ItemType Directory -Path lib/features/prompt_engine/domain/usecases -Force
$null = New-Item -ItemType Directory -Path lib/features/prompt_engine/data/repositories -Force
$null = New-Item -ItemType Directory -Path lib/features/prompt_engine/data/datasources -Force
$null = New-Item -ItemType Directory -Path lib/features/prompt_engine/data/mappers -Force
$null = New-Item -ItemType Directory -Path lib/features/prompt_engine/data/di -Force
$null = New-Item -ItemType Directory -Path lib/features/prompt_engine/presentation -Force

# Features — AI Gateway
$null = New-Item -ItemType Directory -Path lib/features/ai_gateway/domain/entities -Force
$null = New-Item -ItemType Directory -Path lib/features/ai_gateway/domain/repositories -Force
$null = New-Item -ItemType Directory -Path lib/features/ai_gateway/domain/usecases -Force
$null = New-Item -ItemType Directory -Path lib/features/ai_gateway/data/repositories -Force
$null = New-Item -ItemType Directory -Path lib/features/ai_gateway/data/datasources -Force
$null = New-Item -ItemType Directory -Path lib/features/ai_gateway/data/mappers -Force
$null = New-Item -ItemType Directory -Path lib/features/ai_gateway/data/di -Force
$null = New-Item -ItemType Directory -Path lib/features/ai_gateway/presentation/notifier -Force

# Features — Settings
$null = New-Item -ItemType Directory -Path lib/features/settings/domain/entities -Force
$null = New-Item -ItemType Directory -Path lib/features/settings/domain/repositories -Force
$null = New-Item -ItemType Directory -Path lib/features/settings/domain/usecases -Force
$null = New-Item -ItemType Directory -Path lib/features/settings/data/repositories -Force
$null = New-Item -ItemType Directory -Path lib/features/settings/data/datasources -Force
$null = New-Item -ItemType Directory -Path lib/features/settings/data/di -Force
$null = New-Item -ItemType Directory -Path lib/features/settings/presentation/pages -Force
$null = New-Item -ItemType Directory -Path lib/features/settings/presentation/widgets -Force
$null = New-Item -ItemType Directory -Path lib/features/settings/presentation/notifier -Force

# Integration
$null = New-Item -ItemType Directory -Path lib/integration -Force

# Infrastructure
$null = New-Item -ItemType Directory -Path lib/infrastructure/logging -Force
$null = New-Item -ItemType Directory -Path lib/infrastructure/cache -Force
$null = New-Item -ItemType Directory -Path lib/infrastructure/permissions -Force
$null = New-Item -ItemType Directory -Path lib/infrastructure/platform -Force

# Routing
$null = New-Item -ItemType Directory -Path lib/routing -Force

# Tests
$null = New-Item -ItemType Directory -Path test/helpers -Force
$null = New-Item -ItemType Directory -Path test/unit/core/config -Force
$null = New-Item -ItemType Directory -Path test/unit/core/errors -Force
$null = New-Item -ItemType Directory -Path test/unit/core/ai -Force
$null = New-Item -ItemType Directory -Path test/unit/core/identity -Force
$null = New-Item -ItemType Directory -Path test/unit/core/telemetry -Force
$null = New-Item -ItemType Directory -Path test/unit/core/feature_flags -Force
$null = New-Item -ItemType Directory -Path test/widget/common -Force
$null = New-Item -ItemType Directory -Path test/integration/flows -Force

# Docs & Assets
$null = New-Item -ItemType Directory -Path docs -Force
$null = New-Item -ItemType Directory -Path assets -Force
$null = New-Item -ItemType Directory -Path .github/workflows -Force

# .gitkeep files for empty directories (ensures git tracks them)
$null = New-Item -ItemType File -Path assets/.gitkeep -Force
$null = New-Item -ItemType File -Path docs/.gitkeep -Force

# Summary
$libDirs = (Get-ChildItem -Directory -Recurse -Path lib).Count
$testDirs = (Get-ChildItem -Directory -Recurse -Path test).Count
Write-Host "Done — $libDirs directories created under lib/" -ForegroundColor Green
Write-Host "Done — $testDirs directories created under test/" -ForegroundColor Green
