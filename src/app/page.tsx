import { ConnectButton } from "@rainbow-me/rainbowkit"

export default function Home() {
  return (
    <main className="flex flex-col gap-6 justify-center items-center h-screen">
      <h1 className="text-3xl font-bold">ERC20 Staking dApp</h1>
      <ConnectButton />
    </main>
  )
}
