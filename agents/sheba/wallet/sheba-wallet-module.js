const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { Wallet } = require('ethers');

const BASE = path.resolve(__dirname, '..');
const SECRETS_PATH = path.join(BASE, 'secrets', 'sheba-main-wallet.enc.json');
const KEY_PATH = path.join(BASE, 'secrets', '.wallet_master.key');
const PROFILE_PATH = path.join(BASE, 'config', 'wallet-profile.json');
const CAPABILITY_PATH = path.join(BASE, 'config', 'capability-profile.json');

function loadWallet() {
  const bundle = JSON.parse(fs.readFileSync(SECRETS_PATH, 'utf8'));
  const key = fs.readFileSync(KEY_PATH);
  const iv = Buffer.from(bundle.iv, 'base64');
  const tag = Buffer.from(bundle.tag, 'base64');
  const ciphertext = Buffer.from(bundle.ciphertext, 'base64');
  const decipher = crypto.createDecipheriv('aes-256-gcm', key, iv);
  decipher.setAuthTag(tag);
  const plaintext = Buffer.concat([decipher.update(ciphertext), decipher.final()]).toString('utf8');
  const secret = JSON.parse(plaintext);
  return new Wallet(secret.privateKey);
}

function getPublicProfile() {
  return JSON.parse(fs.readFileSync(PROFILE_PATH, 'utf8'));
}

function getCapabilities() {
  return JSON.parse(fs.readFileSync(CAPABILITY_PATH, 'utf8'));
}

module.exports = {
  loadWallet,
  getPublicProfile,
  getCapabilities,
};
