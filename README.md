# Berealty Real Estate Property Management Database

MySQL 8.4 project containing only the executable database code and supporting developer files.

## Included

- `sql/01_schema.sql` — database schema, keys, constraints and indexes
- `sql/02_triggers.sql` — completion triggers
- `sql/03_sample_data.sql` — synthetic test data
- `sql/04_queries.sql` — Q1-Q14 analytical queries
- `sql/05_safe_dml_demo.sql` — transactional update/rollback demo
- `sql/06_trigger_demo.sql` — trigger before/after/rollback demo
- `sql/07_verification.sql` — schema, row-count and integrity checks
- `scripts/run.sh` — builds the database
- `scripts/verify.sh` — runs verification checks
- `scripts/evidence.sh` — runs queries and writes text outputs locally
- `.vscode/tasks.json` — VS Code tasks
- `.github/workflows/mysql-validation.yml` — GitHub Actions MySQL 8.4 validation

No assignment report, screenshots, rendered evidence images, logos, or document files are included.

## Requirements

- MySQL 8.x / MySQL 8.4
- `mysql` command available in the terminal

## Build

If your local Homebrew MySQL root account has no password:

```bash
bash scripts/run.sh
```

If your MySQL user has a password:

```bash
export MYSQL_USER=root
export MYSQL_PASSWORD='your-password'
bash scripts/run.sh
```

## Verify

```bash
bash scripts/verify.sh
```

## Run Q1-Q14

```bash
mysql -u root --table < sql/04_queries.sql
```

If your account uses a password, add `-p`.

## Run Q15

```bash
mysql -u root --table < sql/05_safe_dml_demo.sql
```

## Run the trigger demo

```bash
mysql -u root --table < sql/06_trigger_demo.sql
```

## VS Code

Open **Terminal > Run Task** and choose one of the Berealty tasks.

## GitHub Actions

On push, `.github/workflows/mysql-validation.yml` starts MySQL 8.4, rebuilds the database, runs the checks and query scripts, and uploads text evidence as a workflow artifact.
