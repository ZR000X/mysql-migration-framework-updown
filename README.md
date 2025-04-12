# Database Migration Automation Script

A robust PowerShell script for managing database migrations with strict version control and sequential enforcement. This tool ensures database changes are applied safely and consistently across environments.

## 🚀 Features

- **Sequential Migration Enforcement**: Guarantees migrations are applied in the correct order
- **Version Tracking**: Maintains local version state to prevent out-of-order migrations
- **Bidirectional Support**: Handles both upgrade and downgrade migrations
- **Environment-Aware**: Configurable through environment variables
- **Error Handling**: Stops execution on failed migrations to maintain database integrity

## 📋 Prerequisites

- PowerShell 5.1 or later
- MySQL client installed and accessible in PATH
- MySQL server running and accessible
- `.env` file with database credentials (optional)

## 🔧 Installation

1. Clone this repository
2. Ensure MySQL client is installed and accessible
3. (Optional) Create a `.env` file with your database credentials:
   ```env
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_USER=root
   DB_PASSWORD=your_password
   ```

## 📚 Usage

### Basic Commands

| Command      | Description                                  | Example            |
| ------------ | -------------------------------------------- | ------------------ |
| `up x [y]`   | Apply migrations from version x to y         | `up 1` or `up 1 3` |
| `down x y`   | Rollback migrations from x to y              | `down 3 1`         |
| `updown x y` | Test migrations by applying and rolling back | `updown 1 3`       |

### Detailed Command Examples

1. **Up Migration**

   ```powershell
   # Apply single migration
   .\automation.ps1 up 1

   # Apply range of migrations
   .\automation.ps1 up 1 3
   ```

2. **Down Migration**

   ```powershell
   # Rollback single migration
   .\automation.ps1 down 1 1

   # Rollback range of migrations
   .\automation.ps1 down 3 1
   ```

3. **Updown Migration (Testing)**
   ```powershell
   # Test migration sequence
   .\automation.ps1 updown 1 3
   ```

## ⚠️ Rules and Constraints

- **Sequential Enforcement**: Migrations must be applied in sequence
  - Current version must match the starting version of the migration
  - Cannot skip versions
- **Version Tracking**:
  - Version state is stored in `migration_config.txt`
  - Version numbers must be positive integers
- **File Naming Convention**:
  - Up migrations: `*_up_*.sql`
  - Down migrations: `*_down_*.sql`

## 🔍 How It Works

1. **Version Check**: Script verifies current version matches migration requirements
2. **File Processing**:
   - Up migrations: Processes files in ascending order
   - Down migrations: Processes files in descending order
3. **Execution**:
   - Applies each migration file sequentially
   - Updates version tracking on success
   - Stops on first failure
4. **State Management**:
   - Maintains version state in `migration_config.txt`
   - Prevents out-of-order migrations

## 🛠️ Configuration

### Environment Variables

The script supports configuration through environment variables:

- Loaded from `.env` file if present
- Can be set in the system environment
- Required variables:
  - `DB_HOST`
  - `DB_PORT`
  - `DB_USER`
  - `DB_PASSWORD`

### Local Configuration

- Version tracking file: `migration_config.txt`
- Migration files directory: `migrations/`

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Credits

- Migration logic inspired by [golang-migrate](https://github.com/golang-migrate/migrate)
- Installation framework `.sql` is from [mysql_logic_base](https://github.com/ZR000X/mysql_logic_base)
