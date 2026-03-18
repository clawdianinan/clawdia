const { ethers } = require('ethers');
const bitcoin = require('bitcoinjs-lib');
const bip39 = require('bip39');
const { BIP32Factory } = require('bip32');
const ecc = require('tiny-secp256k1');
const bip32 = BIP32Factory(ecc);
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// Create secure directory
const ADVANCED_WALLET_DIR = path.join(__dirname, 'advanced-wallets');
if (!fs.existsSync(ADVANCED_WALLET_DIR)) {
  fs.mkdirSync(ADVANCED_WALLET_DIR, { recursive: true });
}

// Encryption function for sensitive data
function encryptData(data, password) {
  const algorithm = 'aes-256-gcm';
  const iv = crypto.randomBytes(16);
  const key = crypto.scryptSync(password, 'salt', 32);
  const cipher = crypto.createCipheriv(algorithm, key, iv);
  
  let encrypted = cipher.update(JSON.stringify(data), 'utf8', 'hex');
  encrypted += cipher.final('hex');
  const authTag = cipher.getAuthTag();
  
  return {
    iv: iv.toString('hex'),
    encrypted: encrypted,
    authTag: authTag.toString('hex'),
    algorithm: algorithm
  };
}

// Generate HD wallet from mnemonic
function generateHDWallet(mnemonic, password = '') {
  console.log('🔗 Generating HD Wallet from mnemonic...\n');
  
  // Validate mnemonic
  if (!bip39.validateMnemonic(mnemonic)) {
    throw new Error('Invalid mnemonic phrase');
  }
  
  // Generate seed from mnemonic
  const seed = bip39.mnemonicToSeedSync(mnemonic);
  const root = bip32.fromSeed(seed);
  
  // Generate addresses for different chains using BIP44 paths
  const chains = {
    bitcoin: {
      path: "m/44'/0'/0'/0/0",
      name: 'Bitcoin Mainnet',
      symbol: 'BTC'
    },
    ethereum: {
      path: "m/44'/60'/0'/0/0",
      name: 'Ethereum Mainnet',
      symbol: 'ETH'
    },
    binance: {
      path: "m/44'/60'/0'/0/0", // Same as Ethereum for BSC
      name: 'BNB Smart Chain',
      symbol: 'BNB'
    },
    polygon: {
      path: "m/44'/60'/0'/0/0", // Same as Ethereum for Polygon
      name: 'Polygon Mainnet',
      symbol: 'MATIC'
    },
    solana: {
      path: "m/44'/501'/0'/0'", // Solana derivation path
      name: 'Solana Mainnet',
      symbol: 'SOL'
    }
  };
  
  const walletData = {
    mnemonic: mnemonic,
    seed: seed.toString('hex'),
    rootPublicKey: root.publicKey.toString('hex'),
    chains: {},
    generatedAt: new Date().toISOString()
  };
  
  // Generate addresses for each chain
  for (const [chainId, chainInfo] of Object.entries(chains)) {
    try {
      const child = root.derivePath(chainInfo.path);
      
      if (chainId === 'bitcoin') {
        // Bitcoin address generation
        const { address } = bitcoin.payments.p2wpkh({
          pubkey: child.publicKey,
          network: bitcoin.networks.bitcoin
        });
        
        walletData.chains[chainId] = {
          name: chainInfo.name,
          symbol: chainInfo.symbol,
          derivationPath: chainInfo.path,
          address: address,
          publicKey: child.publicKey.toString('hex'),
          privateKey: child.toWIF(), // Wallet Import Format
          xpub: root.neutered().toBase58() // Extended public key
        };
      } else if (chainId === 'ethereum' || chainId === 'binance' || chainId === 'polygon') {
        // Ethereum-style address generation
        const ethWallet = ethers.HDNodeWallet.fromSeed(seed);
        const derivedWallet = ethWallet.derivePath(chainInfo.path);
        
        walletData.chains[chainId] = {
          name: chainInfo.name,
          symbol: chainInfo.symbol,
          derivationPath: chainInfo.path,
          address: derivedWallet.address,
          publicKey: derivedWallet.publicKey,
          privateKey: derivedWallet.privateKey
        };
      } else if (chainId === 'solana') {
        // Solana address (simplified - would need @solana/web3.js in real implementation)
        walletData.chains[chainId] = {
          name: chainInfo.name,
          symbol: chainInfo.symbol,
          derivationPath: chainInfo.path,
          address: `SOL_${child.publicKey.toString('hex').substring(0, 32)}`,
          note: 'Solana requires @solana/web3.js for proper address generation'
        };
      }
    } catch (error) {
      console.log(`⚠️  Error generating ${chainId} address: ${error.message}`);
    }
  }
  
  return walletData;
}

// Create a complete multi-chain wallet
function createMultiChainWallet() {
  console.log('🚀 Clawdia Advanced Multi-Chain Wallet Creator');
  console.log('===============================================\n');
  
  // Generate random mnemonic
  const mnemonic = bip39.generateMnemonic(128); // 12 words
  console.log('📝 Generated 12-word mnemonic phrase:');
  console.log('─────────────────────────────────────────────');
  const words = mnemonic.split(' ');
  words.forEach((word, index) => {
    console.log(`${index + 1}. ${word}`);
  });
  console.log('─────────────────────────────────────────────\n');
  
  // Generate HD wallet from mnemonic
  const walletData = generateHDWallet(mnemonic);
  
  // Display wallet information
  console.log('✅ Multi-Chain Wallet Generated Successfully!\n');
  
  for (const [chainId, chainData] of Object.entries(walletData.chains)) {
    console.log(`🔗 ${chainData.name} (${chainData.symbol}):`);
    console.log(`   Address: ${chainData.address}`);
    console.log(`   Path: ${chainData.derivationPath}`);
    if (chainData.privateKey && chainId === 'bitcoin') {
      console.log(`   WIF: ${chainData.privateKey.substring(0, 20)}...`);
    }
    console.log('');
  }
  
  // Save wallet data (encrypted)
  const password = crypto.randomBytes(16).toString('hex');
  const encryptedData = encryptData(walletData, password);
  
  const walletFile = path.join(ADVANCED_WALLET_DIR, `multichain_wallet_${Date.now()}.encrypted.json`);
  fs.writeFileSync(walletFile, JSON.stringify(encryptedData, null, 2));
  
  // Save recovery information separately
  const recoveryFile = path.join(ADVANCED_WALLET_DIR, `recovery_${Date.now()}.txt`);
  const recoveryContent = `=== MULTI-CHAIN WALLET RECOVERY ===

IMPORTANT: This information can restore ALL your crypto wallets.
Keep it SECURE and OFFLINE.

MNEMONIC PHRASE:
${mnemonic}

ENCRYPTION PASSWORD:
${password}

DERIVATION PATHS:
- Bitcoin: m/44'/0'/0'/0/0
- Ethereum: m/44'/60'/0'/0/0
- BSC: m/44'/60'/0'/0/0
- Polygon: m/44'/60'/0'/0/0
- Solana: m/44'/501'/0'/0'

GENERATED ADDRESSES:
${Object.entries(walletData.chains).map(([chain, data]) => `${data.name}: ${data.address}`).join('\n')}

Generated: ${new Date().toISOString()}
By: Clawdia AI Advanced Wallet System

=== SECURITY INSTRUCTIONS ===
1. Write mnemonic on paper/metal
2. Store password separately
3. Never store digitally
4. Test with small amounts first
5. Consider hardware wallet for large holdings
`;
  
  fs.writeFileSync(recoveryFile, recoveryContent);
  
  console.log('💾 Encrypted wallet saved to:', walletFile);
  console.log('📄 Recovery file saved to:', recoveryFile);
  console.log('\n🔐 Encryption password:', password);
  console.log('\n⚠️  IMPORTANT: Save the password separately from the mnemonic!');
  
  // Create a comprehensive HTML report
  createAdvancedWalletHTML(walletData, password);
  
  return { walletData, password, files: { walletFile, recoveryFile } };
}

// Create HTML report
function createAdvancedWalletHTML(walletData, password) {
  const html = `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Clawdia AI Multi-Chain Wallet</title>
    <style>
        :root {
            --primary: #667eea;
            --secondary: #764ba2;
            --success: #48bb78;
            --warning: #ed8936;
            --danger: #f56565;
            --dark: #2d3748;
            --light: #f7fafc;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
            color: var(--dark);
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .header {
            text-align: center;
            margin-bottom: 40px;
            color: white;
        }
        
        .header h1 {
            font-size: 2.5rem;
            margin-bottom: 10px;
            text-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .header p {
            font-size: 1.1rem;
            opacity: 0.9;
        }
        
        .card {
            background: white;
            border-radius: 16px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
        }
        
        .card-title {
            font-size: 1.5rem;
            color: var(--primary);
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid var(--light);
        }
        
        .mnemonic-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
            margin: 20px 0;
        }
        
        .mnemonic-word {
            background: var(--light);
            padding: 15px;
            border-radius: 8px;
            text-align: center;
            font-weight: 600;
            border: 2px solid #e2e8f0;
            transition: all 0.3s ease;
        }
        
        .mnemonic-word:hover {
            border-color: var(--primary);
            transform: translateY(-2px);
        }
        
        .mnemonic-number {
            display: block;
            font-size: 0.8rem;
            color: #718096;
            margin-bottom: 5px;
        }
        
        .chain-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        
        .chain-card {
            background: var(--light);
            border-radius: 12px;
            padding: 20px;
            border-left: 4px solid var(--primary);
        }
        
        .chain-header {
            display: flex;
            align-items: center;
            margin-bottom: 15px;
        }
        
        .chain-icon {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            margin-right: 15px;
        }
        
        .chain-name {
            font-weight: 600;
            font-size: 1.1rem;
        }
        
        .chain-symbol {
            color: #718096;
            font-size: 0.9rem;
        }
        
        .address-box {
            background: white;
            padding: 15px;
            border-radius: 8px;
            margin: 10px 0;
            font-family: monospace;
            word-break: break-all;
            border: 1px solid #e2e8f0;
        }
        
        .warning-box {
            background: #fff5f5;
            border: 2px solid var(--danger);
            border-radius: 12px;
            padding: 20px;
            margin: 20px 0;
        }
        
        .warning-title {
            color: var(--danger);
            font-weight: 600;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
        }
        
        .warning-title::before {
            content: "⚠️";
            margin-right: 10px;
        }
        
        .info-box {
            background: #ebf8ff;
            border: 2px solid #4299e1;
            border-radius: 12px;
            padding: 20px;
            margin: 20px 0;
        }
        
        .button {
            display: inline-block;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
            padding: 12px 30px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
            margin: 5px;
        }
        
        .button:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        
        .button-secondary {
            background: var(--light);
            color: var(--dark);
            border: 2px solid #e2e8f0;
        }
        
        .footer {
            text-align: center;
            margin-top: 40px;
            color: white;
            opacity: 0.8;
            font-size: 0.9rem;
        }
        
        @media (max-width: 768px) {
            .mnemonic-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .chain-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔐 Clawdia AI Multi-Chain Wallet</h1>
            <p>Your decentralized wallet for multiple blockchain networks</p>
        </div>
        
        <div class="card">
            <h2 class="card-title">🎯 Wallet Overview</h2>
            <p>Generated on: ${new Date(walletData.generatedAt).toLocaleString()}</p>
            <p>Total chains supported: ${Object.keys(walletData.chains).length}</p>
        </div>
        
        <div class="card">
            <h2 class="card-title">📝 Recovery Phrase (12 Words)</h2>
            <p class="info-box">
                <strong>🔑 Encryption Password:</strong> ${password}<br>
                <small>Save this password separately from your mnemonic phrase.</small>
            </p>
            
            <div class="mnemonic-grid">
                ${walletData.mnemonic.split(' ').map((word, index) => `
                    <div class="mnemonic-word">
                        <span class="mnemonic-number">${index + 1}</span>
                        ${word}
                    </div>
                `).join('')}
            </div>
            
            <div class="warning-box">
                <div class="warning-title">CRITICAL SECURITY WARNING</div>
                <p>This 12-word phrase controls ALL your cryptocurrency across all chains.</p>
                <ul style="margin-left: 20px; margin-top: 10px;">
                    <li>Write it down on paper/metal</li>
                    <li>Store in multiple secure locations</li>
                    <li>Never share with anyone</li>
                    <li>Never store digitally (no photos/cloud)</li>
                    <li>Test with small amounts first</li>
                </ul>
            </div>
        </div>
        
        <div class="card">
            <h2 class="card-title">🔗 Multi-Chain Addresses</h2>
            <p>One mnemonic, multiple blockchain addresses:</p>
            
            <div class="chain-grid">
                ${Object.entries(walletData.chains).map(([chainId, chainData]) => `
                    <div class="chain-card">
                        <div class="chain-header">
                            <div class="chain-icon">${chainData.symbol.substring(0, 3)}</div>
                            <div>
                                <div class="chain-name">${chainData.name}</div>
                                <div class="chain-symbol">${chainData.symbol}</div>
                            </div>
                        </div>
                        <div>
                            <strong>Address:</strong>
                            <div class="address-box">${chainData.address}</div>
                            <small>Path: ${chainData.derivationPath}</small>
                        </div>
                    </div>
                `).join('')}
            </div>
        </div>
        
        <div class="card">
            <h2 class="card-title">🚀 Quick Actions</h2>
            <div style="text-align: center; margin: 20px 0;">
                ${Object.entries(walletData.chains).map(([chainId, chainData]) => {
                    let explorerUrl = '';
                    switch(chainId) {
                        case 'bitcoin':
                            explorerUrl = `https://blockstream.info/address/${chainData.address}`;
                            break;
                        case 'ethereum':
                            explorerUrl = `https://etherscan.io/address/${chainData.address}`;
                            break;
                        case 'binance':
                            explorerUrl = `https://bscscan.com/address/${chainData.address}`;
                            break;
                        case 'polygon':
                            explorerUrl = `https://polygonscan.com/address/${chainData.address}`;
                            break;
                        default:
                            explorerUrl = '#';
                    }
                    return `<a href="${explorerUrl}" target="_blank" class="button">View ${chainData.symbol} on Explorer</a>`;
                }).join('')}
                
                <br><br>
                <a href="https://metamask.io" target="_blank" class="button button-secondary">Get MetaMask</a>
                <a href="https://trustwallet.com" target="_blank" class="button button-secondary">Get Trust Wallet</a>
            </div>
        </div>
        
        <div class="card">
            <h2 class="card-title">📋 Security Checklist</h2>
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 15px;">
                <div style="background: #f0fff4; padding: 15px; border-radius: 8px; border: 1px solid #9ae6b4;">
                    <strong>✅ Done</strong>
                    <p>Wallet generated with strong entropy</p>
                </div>
                <div style="background: #fff5f5; padding: 15px; border-radius: 8px; border: 1px solid #fc8181;">
                    <strong>⏳ Pending</strong>
                    <p>Write mnemonic on paper/metal</p>
                </div>
                <div style="background: #fff5f5; padding: 15px; border-radius: 8px; border: 1px solid #fc8181;">
                    <strong>⏳ Pending</strong>
                    <p>Store password separately</p>
                </div>
                <div style="background: #fff5f5; padding: 15px; border-radius: 8px; border: 1px solid #fc8181;">
                    <strong>⏳ Pending</strong>
                    <p>Test with small amounts</p>
                </div>
            </div>
        </div>
        
        <div class="footer">
            <p>Generated by Clawdia AI Advanced Wallet System</p>
            <p>For educational and demonstration purposes only</p>
            <p>${new Date().toLocaleString()}</p>
        </div>
    </div>
</body>
</html>`;