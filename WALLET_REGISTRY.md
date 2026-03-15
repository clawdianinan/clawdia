# Wallet Registry

Last Updated: 2026-03-15T05:35:00Z
Owner: Clawdia (workspace-level registry)

## Rules
- This registry stores only non-sensitive wallet metadata.
- Never store private keys, seed phrases, mnemonics, raw secrets, or passwords here.
- Sensitive credentials are stored only in encrypted secret files with restricted permissions.

---

## A) Sheba Wallets

### 1) sheba-main-wallet
- Owner: Sheba
- Label: `sheba-main-wallet`
- Type: EVM (single address, multi-network)
- Address: `0xeD95ab503C84426A4C8876206F33584a104FDF9a`
- Chains/Purpose:
  - Ethereum, Base, Arbitrum, Polygon, BNB Smart Chain
  - Autonomous decentralized transactions
- Created: `2026-03-15T03:47:13.097Z`
- Public profile: `agents/sheba/config/wallet-profile.json`

### 2) sheba-solana-wallet
- Owner: Sheba
- Label: `sheba-solana-wallet`
- Type: Solana
- Address: `5aLQzMw7Nuh6dyqLG97izUfRZbK5Vp4rKrkq5jwEbbUT`
- Chains/Purpose:
  - Solana
  - Autonomous decentralized transactions
- Created: `2026-03-15T03:49:50.404Z`
- Public profile: `agents/sheba/config/solana-wallet-profile.json`

### 3) sheba-lightning-wallet
- Owner: Sheba
- Label: `sheba-lightning-wallet`
- Type: Bitcoin + Lightning
- On-chain BTC receive: `bc1q2ttq03uqfvqqwqufrntx4wmr5qpdcu67g6rnlc`
- Lightning receive endpoint: `shebaagent78641@coinos.io`
- Chains/Purpose:
  - Bitcoin (mainnet), Lightning Network
  - Autonomous decentralized transactions
- Created: `2026-03-15T05:00:25.506Z`
- Public profile: `agents/sheba/config/lightning-wallet-profile.json`

---

## B) Wallets Created by/for Clawdia

### 4) Operational Wallet
- Owner: Clawdia
- Type: Ethereum
- Address: `0xE535B9D812609b354db0f4cF46fdA00Ebb9A84E0`
- Chain/Purpose:
  - Ethereum
  - Operational transactions
- Source: `clawdia-wallets/clawdia_wallet_system_1773546288504.json`

### 5) Treasury Wallet
- Owner: Clawdia
- Type: Ethereum
- Address: `0xEEF0bc32C299C5Cd24c5609Ffca0635a2808f311`
- Chain/Purpose:
  - Ethereum
  - Treasury storage/management
- Source: `clawdia-wallets/clawdia_wallet_system_1773546288504.json`

### 6) Development Wallet
- Owner: Clawdia
- Type: Ethereum
- Address: `0xEAeD681304cBE037A1bC389bB336A7ECD80ca256`
- Chain/Purpose:
  - Ethereum
  - Development/testing operations
- Source: `clawdia-wallets/clawdia_wallet_system_1773546288504.json`

### 7) Bitcoin Operational Wallet
- Owner: Clawdia
- Type: Bitcoin
- Address: `bc1qm9zhpdt3m90rcqtx8vlu3njhsc8e0vu7pzehnx`
- Chain/Purpose:
  - Bitcoin mainnet
  - Operational BTC transactions
- Source: `clawdia-wallets/clawdia_wallet_system_1773546288504.json`

### 8) Bitcoin Treasury Wallet
- Owner: Clawdia
- Type: Bitcoin
- Address: `bc1qy5r6eh2xs09vt6nz6k94al4umw9epaez4agsfe`
- Chain/Purpose:
  - Bitcoin mainnet
  - Treasury BTC storage/management
- Source: `clawdia-wallets/clawdia_wallet_system_1773546288504.json`

### 9) Clawdia Quick Access Wallet
- Owner: Clawdia
- Type: EVM (Ethereum)
- Address: `0x1402307f62C1eF113A4c16fFe13ED819c1D4E15d`
- Chain/Purpose:
  - Ethereum-compatible networks
  - Quick access wallet
- Created: `2026-03-15T03:45:44.144Z`
- Source: `clawdia-wallets/quick-wallet/quick_wallet_1773546344145.json`

### 10) Ethereum Mainnet Wallet (legacy file)
- Owner: Clawdia (unlabeled)
- Type: Ethereum Mainnet
- Address: `0x9f8927dC86d7C48F604DC45A02b42ba294DAFcF0`
- Chain/Purpose:
  - Ethereum mainnet
  - Legacy/single-wallet record
- Created: `2026-03-15T03:34:29.389Z`
- Source: `wallets/wallet_0x9f8927dC_1773545669390.json`

---

## Sensitive Storage Locations (Encrypted / restricted)
- `agents/sheba/secrets/.wallet_master.key`
- `agents/sheba/secrets/sheba-main-wallet.enc.json`
- `agents/sheba/secrets/sheba-solana-wallet.enc.json`
- `agents/sheba/secrets/sheba-lightning-wallet.enc.json`
- `agents/sheba/secrets/sheba-coinos-account.enc.json`

Note: Some older Clawdia wallet files under `clawdia-wallets/` and `wallets/` may include sensitive material and should be migrated to encrypted storage in a follow-up hardening pass.
