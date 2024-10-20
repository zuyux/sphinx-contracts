import { generateWallet } from '@stacks/wallet-sdk';

async function getPrivateKeyFromMnemonic() {
    const mnemonic = 'your mnemonic phrase';
    const wallet = await generateWallet({
        secretKey: mnemonic,
        password: 'optional-password',  
    });
    const account = wallet.accounts[0];
    const senderKey = account.stxPrivateKey;
    return senderKey;
}

getPrivateKeyFromMnemonic().then(privateKey => {
    console.log("Your private key:", privateKey);
}).catch(error => {
    console.error("Error generating wallet:", error);
});
