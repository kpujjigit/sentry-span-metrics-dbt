# Sentry Span Metrics dbt Project

This dbt project demonstrates proficiency in data modeling, testing, and documentation using dbt Labs tools. The project combines user event data with Sentry performance monitoring spans to create comprehensive analytics for user engagement and system performance.

## Project Structure

The project follows dbt's recommended layered architecture:

### 🗂️ Layers

1. **Seeds** - Raw CSV data sources
   - `users.csv` - User profile and subscription data
   - `events.csv` - User interaction events (page views, clicks, form submissions)
   - `spans.csv` - Sentry performance monitoring spans

2. **Staging** (`models/staging/`) - Clean, standardized data
   - `stg_users` - Standardized user data with derived fields
   - `stg_events` - Cleaned event data with categorization flags
   - `stg_spans` - Processed span data with performance indicators

3. **Intermediate** (`models/intermediate/`) - Business logic aggregations
   - `int_event_rollups` - Event metrics aggregated by date, user, and type
   - `int_user_activity` - Combined user profile and activity metrics

4. **Marts** (`models/marts/metrics/`) - Final business-ready datasets
   - `user_engagement` - Daily user engagement combining events and spans
   - `span_volume_daily` - Daily span performance by service and operation

## Key Features Demonstrated

### ✅ SQL Modeling Best Practices
- CTE (Common Table Expression) usage for readability
- Proper column naming conventions
- Incremental materialization for performance
- Appropriate use of views vs. tables

### ✅ Data Quality & Testing
- Unique constraints on primary keys
- Not null constraints on required fields
- Accepted values tests for categorical data
- Relationship tests between models
- Generic test templates for reusability

### ✅ Documentation & Lineage
- Comprehensive model and column descriptions
- Clear data lineage from seeds to marts
- Business context for all metrics

### ✅ Advanced dbt Features
- Incremental models with delete+insert strategy
- Sources and exposures for external dependencies
- Proper schema configurations
- Materialization strategies

## Business Value

This project showcases the ability to:

1. **Track User Engagement** - Monitor daily active users, session metrics, and engagement patterns
2. **Monitor System Performance** - Analyze span durations, error rates, and service reliability
3. **Combine Multiple Data Sources** - Join user behavior with system performance data
4. **Support Data-Driven Decisions** - Provide metrics for product improvements and infrastructure optimization

## Technologies Used

- **dbt Core** - Data transformation and modeling
- **DuckDB** - Local database for development and testing
- **Sentry** - Performance monitoring data source
- **YAML** - Configuration and documentation
- **SQL** - Data transformation logic

## Getting Started

1. Install dependencies: `pip install dbt-core dbt-duckdb`
2. Configure profiles.yml for your environment
3. Run `dbt seed` to load sample data
4. Run `dbt run` to build all models
5. Run `dbt test` to execute data quality tests
6. Run `dbt docs generate && dbt docs serve` to view documentation
