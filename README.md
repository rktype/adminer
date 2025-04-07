> 🚨 Questo repository è deprecato. Vai al nuovo repository: [rktype/adminneo](https://github.com/rktype/adminneo)

# Adminer container with Pematon Theme
Based on [Adminer (Pematon version)](https://github.com/pematon/adminer) with preinstalled [Pematon Theme](https://github.com/pematon/adminer-theme)

Docker hub: https://hub.docker.com/r/rktype/adminer

## Environment variables
- `ADMINER_APP_KEY` Sets the key to use for permanentLogin()

- `ADMINER_ENV` Sets theme color
  - `local` => green theme
  - `dev` | `test` | `stage` | `staging` => blue theme
  - `prod` | `production` => orange theme (default)

- `ADMINER_DEFAULT_SERVER` Sets the default server host

- `ADMINER_DEFAULT_DRIVER` Sets the default database driver
  - `mysql`
  - `sqlite`
  - `sqlite2`
  - `pgsql`
  - `oracle`
  - `mssql`
  - `mongo`
  - `elastic`

- `MSSQL_TRUST_SERVER_CERTIFICATE` Sets the `TrustServerCertificate` value in MSSql configuration
  - `true`
  - `false`
