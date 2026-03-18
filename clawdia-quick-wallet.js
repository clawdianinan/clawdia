const { ethers } = require('ethers');
const fs = require('fs');
const path = require('path');

console.log('🐾 Clawdia Quick Wallet Generator');
console.log('==================================\n');

// Create a simple Ethereum wallet for immediate use
const wallet = ethers.Wallet.createRandom();

console.log('✅ Quick Ethereum Wallet Created!');
console.log('─────────────────────────────────');
console.log(`🏷️  Address: ${wallet.address}`);
console.log(`🔑 Private Key: ${wallet.privateKey}`);
console.log(`📝 Mnemonic (12 words): ${wallet.mnemonic.phrase}`);
console.log('─────────────────────────────────\n');

// Create import instructions
console.log('📱 How to Import:');
console.log('─────────────────────────────────');
console.log('1. MetaMask:');
console.log('   - Click account icon → "Import account"');
console.log('   - Paste private key: ' + wallet.privateKey);
console.log('');
console.log('2. Trust Wallet:');
console.log('   - Add wallet → "Import wallet"');
console.log('   - Choose "Private Key"');
console.log('   - Paste: ' + wallet.privateKey);
console.log('');
console.log('3. Using Mnemonic:');
console.log('   - Any wallet: "Restore from seed phrase"');
console.log('   - Enter: ' + wallet.mnemonic.phrase);
console.log('─────────────────────────────────\n');

// Save to file
const quickWalletDir = path.join(__dirname, 'clawdia-wallets', 'quick-wallet');
if (!fs.existsSync(quickWalletDir)) {
  fs.mkdirSync(quickWalletDir, { recursive: true });
}

const walletData = {
  address: wallet.address,
  privateKey: wallet.privateKey,
  mnemonic: wallet.mnemonic.phrase,
  createdAt: new Date().toISOString(),
  purpose: 'Clawdia Quick Access Wallet',
  note: 'For immediate testing and small transactions'
};

const walletFile = path.join(quickWalletDir, `quick_wallet_${Date.now()}.json`);
fs.writeFileSync(walletFile, JSON.stringify(walletData, null, 2));

// Create import card
const importCard = path.join(quickWalletDir, 'import_instructions.txt');
const cardContent = `=== CLAWDIA QUICK WALLET ===
For immediate testing and access

Address: ${wallet.address}
Private Key: ${wallet.privateKey}
Mnemonic: ${wallet.mnemonic.phrase}

=== QUICK IMPORT ===
MetaMask: Import account → Private Key → Paste above
Trust Wallet: Add wallet → Import → Private Key → Paste
Any wallet: Restore from seed phrase → Enter mnemonic

=== SECURITY ===
• This is for testing/small amounts only
• Never share private key or mnemonic
• Store mnemonic securely if keeping funds
• Test with faucet ETH first

Generated: ${new Date().toISOString()}
By: Clawdia AI Wallet System
`;
fs.writeFileSync(importCard, cardContent);

console.log('💾 Files saved:');
console.log(`   Wallet data: ${walletFile}`);
console.log(`   Import instructions: ${importCard}`);
console.log('\n⚠️  Remember: Never share private keys or mnemonics!');
console.log('   Use testnet faucets first before sending real funds.');