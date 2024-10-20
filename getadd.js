import { showConnect } from '@stacks/connect';

showConnect({
  appDetails,
  userSession,
  onFinish: () => {
    const user = userSession.loadUserData();
    const address = user.profile.stxAddress.testnet;
    
    console.log(address); 
  },
});