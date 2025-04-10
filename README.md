# Migration Automation Script

This script automates the application of SQL migration files in a sequential manner. It maintains a local record of the current database version and ensures that migrations are applied in the correct order.

## Features

- **Sequential Application**: Enforces sequential application of migrations.
- **Local Version Tracking**: Maintains a local config file to track the current database version.
- **Up and Down Migrations**: Supports both up and down migrations.

## Usage

### Commands

1. **Up Migration**: `up x [y]`

   - Applies up migrations from version `x` to `y`.
   - If `y` is not specified, it defaults to `x`.
   - Example: `up 1` should run upfile 1, while `up 1 3` will run those of 1, 2, 3.

2. **Down Migration**: `down x y`

   - Applies down migrations from version `x` to `y`.
   - Example: `down 3 1` should run those of 3, 2. `down 1` is equivalent to `down 1 1`

3. **Updown Migration**: `updown x y`
   - Applies up migrations from version `x` to `y`, then down migrations from `y` to `x`.
   - Example: `updown 1 3`

### Rules

- **Sequential Enforcement**: Migrations must be applied in sequence. The current version must match the starting version of the migration.
- **Version Tracking**: The script updates the local version after applying migrations.

## Configuration

- **Environment Variables**: Load MySQL credentials from a `.env` file.
- **Local Config File**: `migration_config.txt` stores the current database version.

## Example

```powershell
.\automation.ps1 up 1
```

This command applies the up migration for version 1 if the current version is 0.
