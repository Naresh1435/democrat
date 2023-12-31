import { useAddress, useContract } from '@thirdweb-dev/react';
import { ThirdwebSDK } from '@thirdweb-dev/sdk';

export const getContract = ()=>{
    try {
        const {contract} = useContract(import.meta.env.CONTRACT_ADDRESS);
        return contract ? contract : null;
    } catch (err) {
        console.log("Error in fetching contract : ", err);
        return null
    }
}
