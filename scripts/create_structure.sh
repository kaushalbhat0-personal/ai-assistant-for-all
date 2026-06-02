#!/bin/bash
# ScreenFix AI — Repository Structure Creator (Mac/Linux)
# Run from project root: bash scripts/create_structure.sh

echo "Creating ScreenFix AI directory structure..."

# Core
mkdir -p lib/core/constants
mkdir -p lib/core/config
mkdir -p lib/core/errors
mkdir -p lib/core/network/interceptors
mkdir -p lib/core/ai
mkdir -p lib/core/identity
mkdir -p lib/core/telemetry
mkdir -p lib/core/feature_flags
mkdir -p lib/core/di

# Common
mkdir -p lib/common/widgets

# Features — Overlay
mkdir -p lib/features/overlay/domain/entities
mkdir -p lib/features/overlay/domain/repositories
mkdir -p lib/features/overlay/domain/usecases
mkdir -p lib/features/overlay/data/repositories
mkdir -p lib/features/overlay/data/datasources
mkdir -p lib/features/overlay/data/di
mkdir -p lib/features/overlay/presentation/widgets
mkdir -p lib/features/overlay/presentation/notifier

# Features — Screen Capture
mkdir -p lib/features/screen_capture/domain/entities
mkdir -p lib/features/screen_capture/domain/repositories
mkdir -p lib/features/screen_capture/domain/usecases
mkdir -p lib/features/screen_capture/data/repositories
mkdir -p lib/features/screen_capture/data/datasources
mkdir -p lib/features/screen_capture/data/di
mkdir -p lib/features/screen_capture/presentation/notifier

# Features — OCR
mkdir -p lib/features/ocr/domain/entities
mkdir -p lib/features/ocr/domain/repositories
mkdir -p lib/features/ocr/domain/usecases
mkdir -p lib/features/ocr/data/repositories
mkdir -p lib/features/ocr/data/datasources
mkdir -p lib/features/ocr/data/di
mkdir -p lib/features/ocr/presentation/notifier

# Features — Local Analysis
mkdir -p lib/features/local_analysis/domain/entities
mkdir -p lib/features/local_analysis/domain/repositories
mkdir -p lib/features/local_analysis/domain/usecases
mkdir -p lib/features/local_analysis/data/repositories
mkdir -p lib/features/local_analysis/data/datasources/patterns
mkdir -p lib/features/local_analysis/data/di
mkdir -p lib/features/local_analysis/presentation/notifier

# Features — Prompt Engine
mkdir -p lib/features/prompt_engine/domain/entities
mkdir -p lib/features/prompt_engine/domain/repositories
mkdir -p lib/features/prompt_engine/domain/usecases
mkdir -p lib/features/prompt_engine/data/repositories
mkdir -p lib/features/prompt_engine/data/datasources
mkdir -p lib/features/prompt_engine/data/mappers
mkdir -p lib/features/prompt_engine/data/di
mkdir -p lib/features/prompt_engine/presentation

# Features — AI Gateway
mkdir -p lib/features/ai_gateway/domain/entities
mkdir -p lib/features/ai_gateway/domain/repositories
mkdir -p lib/features/ai_gateway/domain/usecases
mkdir -p lib/features/ai_gateway/data/repositories
mkdir -p lib/features/ai_gateway/data/datasources
mkdir -p lib/features/ai_gateway/data/mappers
mkdir -p lib/features/ai_gateway/data/di
mkdir -p lib/features/ai_gateway/presentation/notifier

# Features — Settings
mkdir -p lib/features/settings/domain/entities
mkdir -p lib/features/settings/domain/repositories
mkdir -p lib/features/settings/domain/usecases
mkdir -p lib/features/settings/data/repositories
mkdir -p lib/features/settings/data/datasources
mkdir -p lib/features/settings/data/di
mkdir -p lib/features/settings/presentation/pages
mkdir -p lib/features/settings/presentation/widgets
mkdir -p lib/features/settings/presentation/notifier

# Integration
mkdir -p lib/integration

# Infrastructure
mkdir -p lib/infrastructure/logging
mkdir -p lib/infrastructure/cache
mkdir -p lib/infrastructure/permissions
mkdir -p lib/infrastructure/platform

# Routing
mkdir -p lib/routing

# Tests
mkdir -p test/helpers
mkdir -p test/unit/core/config
mkdir -p test/unit/core/errors
mkdir -p test/unit/core/ai
mkdir -p test/unit/core/identity
mkdir -p test/unit/core/telemetry
mkdir -p test/unit/core/feature_flags
mkdir -p test/widget/common
mkdir -p test/integration/flows

# Docs & Assets
mkdir -p docs
mkdir -p assets
mkdir -p .github/workflows

# .gitkeep files for empty directories (ensures git tracks them)
touch assets/.gitkeep
touch docs/.gitkeep

echo "Done — $(find lib -type d | wc -l | tr -d ' ') directories created under lib/"
echo "Done — $(find test -type d | wc -l | tr -d ' ') directories created under test/"
