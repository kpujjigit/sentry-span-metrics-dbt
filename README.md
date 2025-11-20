# Sentry Span Metrics dbt Project

A portfolio-worthy dbt Core project demonstrating proficiency in dbt Labs and Sentry integration. This project showcases modern data modeling practices, comprehensive testing, and production-ready documentation.

## 🎯 Project Overview

This dbt project combines user event data with Sentry performance monitoring spans to create comprehensive analytics for user engagement and system performance monitoring. Perfect for demonstrating dbt skills on a resume or in interviews.

## 🏗️ Architecture

The project follows dbt's recommended layered architecture:

- **Seeds**: Raw CSV data (`users.csv`, `events.csv`, `spans.csv`)
- **Staging**: Clean, standardized data models
- **Intermediate**: Business logic aggregations
- **Marts**: Final business-ready datasets with incremental materialization

## ✅ Features Demonstrated

- **SQL Modeling**: CTEs, proper naming conventions, incremental models
- **Data Quality**: Comprehensive testing (unique, not null, accepted values, relationships)
- **Documentation**: Detailed model and column descriptions with lineage
- **Sources & Exposures**: External dependency management
- **Materializations**: Incremental tables with delete+insert strategy
- **Sentry Integration**: Performance monitoring data modeling

## 🚀 Quick Start

1. **Navigate to project:**
   ```bash
   cd sentry-span-metrics-dbt/sentry_span_metrics
   ```

2. **Run the project (using the provided script):**
   ```bash
   ./dbt-run.sh seed           # Load sample data
   ./dbt-run.sh run            # Build all models
   ./dbt-run.sh test           # Run data quality tests
   ./dbt-run.sh docs generate  # Generate documentation
   ./dbt-run.sh docs serve     # View documentation (optional)
   ```

   **Or use full dbt path directly:**
   ```bash
   /Users/kpujji/Library/Python/3.9/bin/dbt seed
   /Users/kpujji/Library/Python/3.9/bin/dbt run
   /Users/kpujji/Library/Python/3.9/bin/dbt test
   ```

## 📊 Sample Output

The project generates two key business metrics tables:

- **`user_engagement`**: Daily user activity combining events and performance data
- **`span_volume_daily`**: Service-level performance metrics with error rates and latency percentiles

## 🔧 Configuration

- **Database**: DuckDB (for easy local development)
- **Sentry Config**: See `sentry_config.env` for integration settings
- **Profiles**: Configured in `~/.dbt/profiles.yml`

## 📈 Business Value

This project demonstrates the ability to:
- Track user engagement across multiple touchpoints
- Monitor system performance with detailed span analytics
- Combine behavioral and performance data for holistic insights
- Support data-driven product and infrastructure decisions

## 🏆 Portfolio Highlights

- **50 lines per model**: Focused, readable SQL
- **Production-ready**: Tests, documentation, incremental loading
- **Real-world scenario**: User events + performance monitoring
- **Modern practices**: CTEs, proper materializations, comprehensive testing

Perfect for showcasing dbt proficiency in job applications and interviews!
