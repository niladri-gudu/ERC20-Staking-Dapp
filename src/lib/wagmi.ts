import { getDefaultConfig } from "@rainbow-me/rainbowkit";
import { http } from "viem";
import { sepolia } from "viem/chains";

export const config = getDefaultConfig({
    appName: "ERC20 Staking Dapp",
    projectId: process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID!,
    chains: [ sepolia ],
    transports: {
        [sepolia.id]: http(),
    }
})
