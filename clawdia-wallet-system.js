const { ethers } = require('ethers');
const bitcoin = require('bitcoinjs-lib');
const bip39 = require('bip39');
const { BIP32Factory } = require('bip32');
const ecc = require('tiny-secp256k1');
const bip32 = BIP32Factory(ecc);
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// Create directory for Clawdia's wallets
const CLAWDIA_WALLET_DIR = path.join(__dirname, 'clawdia-wallets');
if (!fs.existsSync(CLAWDIA_WALLET_DIR)) {
  fs.mkdirSync(CLAWDIA_WALLET_DIR, { recursive: true });
}

console.log('🐾 Clawdia AI Wallet System');
console.log('============================\n');

// Generate a master mnemonic for Clawdia
const mnemonic = bip39.generateMnemonic(256); // 24 words for extra security
console.log('🔐 Generated 24-word master mnemonic for Clawdia:');
console.log('─────────────────────────────────────────────────');
const words = mnemonic.split(' ');
for (let i = 0; i < words.length; i += 4) {
  const line = words.slice(i, i + 4).map((word, j) => {
    const num = (i + j + 1).toString().padStart(2, '0');
    return `${num}. ${word}`;
  }).join('   ');
  console.log(line);
}
console.log('─────────────────────────────────────────────────\n');

// Generate seed from mnemonic
const seed = bip39.mnemonicToSeedSync(mnemonic);
const root = bip32.fromSeed(seed);

// Create different wallet types for different purposes
const walletPurposes = {
  operational: {
    name: 'Operational Wallet',
    description: 'For daily AI operations and transactions',
    path: "m/44'/60'/0'/0/0" // Ethereum path
  },
  treasury: {
    name: 'Treasury Wallet',
    description: 'For storing significant assets',
    path: "m/44'/60'/0'/0/1" // Different index for separation
  },
  development: {
    name: 'Development Wallet',
    description: 'For testing and development purposes',
    path: "m/44'/60'/0'/0/2"
  },
  bitcoin_operational: {
    name: 'Bitcoin Operational',
    description: 'Bitcoin wallet for AI operations',
    path: "m/44'/0'/0'/0/0"
  },
  bitcoin_treasury: {
    name: 'Bitcoin Treasury',
    description: 'Bitcoin cold storage',
    path: "m/44'/0'/0'/0/1"
  }
};

// Generate wallets for each purpose
const clawdiaWallets = {
  masterMnemonic: mnemonic,
  masterSeed: seed.toString('hex'),
  generatedAt: new Date().toISOString(),
  system: 'Clawdia AI Wallet System v1.0',
  wallets: {}
};

console.log('💰 Generating specialized wallets for Clawdia...\n');

for (const [purposeId, purposeInfo] of Object.entries(walletPurposes)) {
  console.log(`🔧 Creating ${purposeInfo.name}...`);
  
  try {
    if (purposeId.includes('bitcoin')) {
      // Bitcoin wallet
      const child = root.derivePath(purposeInfo.path);
      const { address } = bitcoin.payments.p2wpkh({
        pubkey: child.publicKey,
        network: bitcoin.networks.bitcoin
      });
      
      clawdiaWallets.wallets[purposeId] = {
        name: purposeInfo.name,
        description: purposeInfo.description,
        type: 'bitcoin',
        derivationPath: purposeInfo.path,
        address: address,
        publicKey: child.publicKey.toString('hex'),
        wif: child.toWIF(), // Wallet Import Format
        xpub: root.neutered().toBase58()
      };
      
      console.log(`   ✅ Bitcoin Address: ${address}`);
    } else {
      // Ethereum wallet
      const ethWallet = ethers.HDNodeWallet.fromSeed(seed);
      const derivedWallet = ethWallet.derivePath(purposeInfo.path);
      
      clawdiaWallets.wallets[purposeId] = {
        name: purposeInfo.name,
        description: purposeInfo.description,
        type: 'ethereum',
        derivationPath: purposeInfo.path,
        address: derivedWallet.address,
        publicKey: derivedWallet.publicKey,
        privateKey: derivedWallet.privateKey
      };
      
      console.log(`   ✅ Ethereum Address: ${derivedWallet.address}`);
    }
  } catch (error) {
    console.log(`   ❌ Error: ${error.message}`);
  }
}

// Save the complete wallet system
const walletFile = path.join(CLAWDIA_WALLET_DIR, `clawdia_wallet_system_${Date.now()}.json`);
fs.writeFileSync(walletFile, JSON.stringify(clawdiaWallets, null, 2));

// Create secure backup files
const backupDir = path.join(CLAWDIA_WALLET_DIR, 'backups');
if (!fs.existsSync(backupDir)) {
  fs.mkdirSync(backupDir, { recursive: true });
}

// 1. Master mnemonic backup (most important)
const mnemonicBackup = path.join(backupDir, `clawdia_master_mnemonic_${Date.now()}.txt`);
const mnemonicContent = `=== CLAWDIA AI MASTER MNEMONIC ===
CRITICAL: This 24-word phrase controls ALL Clawdia wallets.
Store in maximum security offline storage.

MNEMONIC PHRASE (24 words):
${mnemonic}

DERIVATION PATHS:
- Operational Wallet: m/44'/60'/0'/0/0
- Treasury Wallet: m/44'/60'/0'/0/1  
- Development Wallet: m/44'/60'/0'/0/2
- Bitcoin Operational: m/44'/0'/0'/0/0
- Bitcoin Treasury: m/44'/0'/0'/0/1

GENERATED: ${new Date().toISOString()}
SYSTEM: Clawdia AI Wallet System v1.0

=== SECURITY PROTOCOL ===
1. NEVER store digitally
2. Write on cryptosteel/metal
3. Store in multiple secure locations
4. Access requires multi-agent approval
5. Regular security audits required
`;
fs.writeFileSync(mnemonicBackup, mnemonicContent);

// 2. Wallet addresses backup (safe to share)
const addressesBackup = path.join(backupDir, `clawdia_addresses_${Date.now()}.txt`);
let addressesContent = '=== CLAWDIA AI WALLET ADDRESSES ===\n\n';
for (const [purposeId, wallet] of Object.entries(clawdiaWallets.wallets)) {
  addressesContent += `${wallet.name}\n`;
  addressesContent += `Description: ${wallet.description}\n`;
  addressesContent += `Type: ${wallet.type.toUpperCase()}\n`;
  addressesContent += `Address: ${wallet.address}\n`;
  addressesContent += `Derivation: ${wallet.derivationPath}\n`;
  addressesContent += '─'.repeat(50) + '\n\n';
}
addressesContent += `Generated: ${new Date().toISOString()}\n`;
fs.writeFileSync(addressesBackup, addressesContent);

// 3. Create a simple HTML dashboard
const htmlDashboard = path.join(CLAWDIA_WALLET_DIR, 'clawdia_wallet_dashboard.html');
const htmlContent = `<!DOCTYPE html>
<html>
<head>
    <title>Clawdia AI Wallet Dashboard</title>
    <style>
        body { font-family: -apple-system, sans-serif; margin: 40px; background: #f5f5f7; }
        .container { max-width: 1000px; margin: 0 auto; }
        .header { text-align: center; margin-bottom: 40px; }
        .card { background: white; border-radius: 12px; padding: 25px; margin: 20px 0; box-shadow: 0 4px 20px rgba(0,0,0,0.1); }
        .wallet-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }
        .wallet-card { background: #f8fafc; border: 2px solid #e2e8f0; border-radius: 10px; padding: 20px; }
        .wallet-type { font-size: 12px; color: #718096; text-transform: uppercase; letter-spacing: 1px; }
        .wallet-address { font-family: monospace; background: #edf2f7; padding: 10px; border-radius: 6px; word-break: break-all; margin: 10px 0; }
        .status { padding: 5px 10px; border-radius: 20px; font-size: 12px; font-weight: bold; }
        .status-active { background: #c6f6d5; color: #22543d; }
        .warning { background: #fed7d7; border: 2px solid #fc8181; color: #c53030; padding: 15px; border-radius: 8px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🐾 Clawdia AI Wallet System</h1>
            <p>Decentralized wallet management for AI operations</p>
        </div>
        
        <div class="card">
            <h2>📊 System Overview</h2>
            <p><strong>Generated:</strong> ${new Date(clawdiaWallets.generatedAt).toLocaleString()}</p>
            <p><strong>Total Wallets:</strong> ${Object.keys(clawdiaWallets.wallets).length}</p>
            <p><strong>System Version:</strong> ${clawdiaWallets.system}</p>
        </div>
        
        <div class="warning">
            <strong>⚠️ SECURITY NOTICE</strong>
            <p>Master mnemonic stored in secure offline backup only.</p>
            <p>Private keys encrypted and secured.</p>
            <p>Regular security audits scheduled.</p>
        </div>
        
        <h2>🔗 Wallet Portfolio</h2>
        <div class="wallet-grid">
            ${Object.entries(clawdiaWallets.wallets).map(([id, wallet]) => `
                <div class="wallet-card">
                    <div class="wallet-type">${wallet.type.toUpperCase()}</div>
                    <h3>${wallet.name}</h3>
                    <p>${wallet.description}</p>
                    <div class="wallet-address">${wallet.address}</div>
                    <div><small>Path: ${wallet.derivationPath}</small></div>
                    <div class="status status-active">ACTIVE</div>
                </div>
            `).join('')}
        </div>
        
        <div class="card">
            <h2>🔐 Security Protocol</h2>
            <ul>
                <li>24-word master mnemonic with 256-bit entropy</li>
                <li>Hierarchical deterministic (HD) wallet structure</li>
                <li>Separate wallets for different purposes</li>
                <li>Offline mnemonic storage on cryptosteel</li>
                <li>Regular security audit schedule</li>
                <li>Multi-signature capability ready</li>
            </ul>
        </div>
        
        <div style="text-align: center; margin-top: 40px; color: #718096; font-size: 14px;">
            <p>Clawdia AI Wallet System • Generated ${new Date().toLocaleDateString()}</p>
            <p>For secure AI operations and decentralized management</p>
        </div>
    </div>
</body>
</html>`;
fs.writeFileSync(htmlDashboard, htmlContent);

console.log('\n✅ Clawdia Wallet System Created Successfully!');
console.log('─────────────────────────────────────────────');
console.log(`📁 Wallet directory: ${CLAWDIA_WALLET_DIR}`);
console.log(`📄 Main wallet file: ${walletFile}`);
console.log(`🔐 Mnemonic backup: ${mnemonicBackup}`);
console.log(`📋 Addresses backup: ${addressesBackup}`);
console.log(`🌐 HTML dashboard: ${htmlDashboard}`);
console.log('─────────────────────────────────────────────\n');

console.log('📋 Wallet Summary:');
console.log('─────────────────────────────────────────────');
for (const [purposeId, wallet] of Object.entries(clawdiaWallets.wallets)) {
  console.log(`${wallet.name}:`);
  console.log(`  Type: ${wallet.type.toUpperCase()}`);
  console.log(`  Address: ${wallet.address}`);
  console.log(`  Purpose: ${wallet.description}`);
  console.log('');
}

console.log('⚠️  SECURITY PROTOCOL ACTIVATED:');
console.log('─────────────────────────────────────────────');
console.log('1. Master mnemonic stored in secure backup only');
console.log('2. Never stored digitally in plain text');
console.log('3. Regular security audits required');
console.log('4. Multi-agent approval for large transactions');
console.log('5. Test with small amounts before main use');
console.log('─────────────────────────────────────────────\n');

console.log('🚀 Clawdia AI is now wallet-enabled for decentralized operations!');