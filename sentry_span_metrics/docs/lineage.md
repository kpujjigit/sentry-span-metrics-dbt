# Data Lineage & Flow

This document outlines how data flows through the Sentry Span Metrics dbt project, from raw sources to final business metrics.

## Data Sources

### Seeds (Raw Data)
```
users.csv ───┐
              ├──► Staging Layer
events.csv ──┘
spans.csv ───┘
```

### Source Data Dictionary

#### users.csv
- **user_id**: Unique user identifier (integer)
- **name**: Full user name (string)
- **email**: User email address (string)
- **signup_date**: Account creation date (YYYY-MM-DD)
- **country**: ISO country code (string)
- **subscription_tier**: 'basic' or 'premium' (string)

#### events.csv
- **event_id**: Unique event identifier (integer)
- **user_id**: User who triggered the event (integer)
- **event_type**: 'page_view', 'button_click', or 'form_submit' (string)
- **event_name**: Specific event name (string)
- **timestamp**: Event timestamp (YYYY-MM-DD HH:MM:SS)
- **page_url**: Page URL where event occurred (string)
- **session_id**: User session identifier (string)
- **duration_ms**: Event duration in milliseconds (integer)

#### spans.csv
- **span_id**: Unique span identifier (string)
- **trace_id**: Trace this span belongs to (string)
- **parent_span_id**: Parent span ID, null for root spans (string)
- **operation_name**: Name of the operation (string)
- **start_timestamp**: Span start time (YYYY-MM-DD HH:MM:SS)
- **end_timestamp**: Span end time (YYYY-MM-DD HH:MM:SS)
- **duration_ms**: Span duration in milliseconds (integer)
- **status**: 'ok' or 'error' (string)
- **service_name**: Service that executed the span (string)
- **user_id**: Associated user ID (integer, nullable)
- **tags**: Additional metadata (string)

## Transformation Flow

### Stage 1: Staging Layer
Raw seed data is cleaned and standardized:

```
users.csv ──► stg_users
                 ↓
            - Standardize email to lowercase
            - Add is_premium_user flag
            - Extract signup_month

events.csv ─► stg_events
                 ↓
            - Parse timestamps
            - Add event categorization flags
            - Extract date and hour

spans.csv ──► stg_spans
                 ↓
            - Parse timestamps
            - Add success/failure flags
            - Add service type flags
```

### Stage 2: Intermediate Layer
Staging data is aggregated with business logic:

```
stg_users + stg_events ──► int_event_rollups
                              ↓
                         - Aggregate events by date/user/type
                         - Calculate session metrics
                         - Compute duration statistics

stg_users + stg_events + stg_spans ──► int_user_activity
                                          ↓
                                     - Combine user profile with activity
                                     - Calculate engagement metrics
                                     - Join span performance data
```

### Stage 3: Marts Layer
Intermediate data becomes final business-ready datasets:

```
int_event_rollups + stg_spans ──► user_engagement (incremental)
                                      ↓
                                 - Daily user engagement metrics
                                 - Combined event and span KPIs
                                 - Incremental updates

stg_spans ─────────────────────► span_volume_daily (incremental)
                                      ↓
                                 - Daily span performance by service
                                 - P95/P99 latency metrics
                                 - Error rate analysis
```

## Key Data Relationships

### User Journey
```
User signs up ──► generates events ──► creates spans
     ↓                ↓                      ↓
  stg_users     stg_events            stg_spans
     ↓                ↓                      ↓
int_user_activity ←───── int_event_rollups ────► user_engagement
                                                        ↓
                                                 span_volume_daily
```

### Business Metrics Flow
```
Raw Events ──► Session Metrics ──► User Engagement ──► Business KPIs
Raw Spans  ──► Performance Data ──► Service Health ──► System Reliability
```

## Incremental Strategy

Both mart models use `delete+insert` incremental strategy:

- **user_engagement**: Updates daily user and span metrics
- **span_volume_daily**: Updates daily service performance metrics

This ensures:
- Efficient updates for new data
- Reprocessing capability for historical corrections
- Optimized performance for large datasets

## Data Quality Gates

Each layer includes automated tests:

### Staging Tests
- Primary key uniqueness and not-null constraints
- Foreign key relationships
- Accepted value validations
- Data type consistency

### Intermediate Tests
- Aggregation accuracy
- Join completeness
- Business logic validation

### Mart Tests
- Metric calculation accuracy
- Incremental update integrity
- Historical data consistency

## External Dependencies

The project includes source and exposure definitions for:
- **Sentry API** (source): Performance monitoring data
- **Analytics Dashboard** (exposure): Consumer of user_engagement metrics
- **Monitoring Dashboard** (exposure): Consumer of span_volume_daily metrics
