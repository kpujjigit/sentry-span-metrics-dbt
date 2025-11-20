#!/bin/bash

# dbt runner script for sentry-span-metrics project
# This script provides easy access to dbt commands without needing to type the full path

DBT_PATH="/Users/kpujji/Library/Python/3.9/bin/dbt"
PROJECT_DIR="/Users/kpujji/Documents/GitHub/sentry-span-metrics-dbt/sentry-span-metrics-dbt/sentry_span_metrics"

cd "$PROJECT_DIR"

if [ $# -eq 0 ]; then
    echo "Usage: ./dbt-run.sh <command> [args...]"
    echo ""
    echo "Examples:"
    echo "  ./dbt-run.sh seed           # Load seed data"
    echo "  ./dbt-run.sh run            # Build all models"
    echo "  ./dbt-run.sh test           # Run all tests"
    echo "  ./dbt-run.sh docs generate  # Generate documentation"
    echo "  ./dbt-run.sh docs serve     # Serve documentation"
    exit 1
fi

"$DBT_PATH" "$@"
