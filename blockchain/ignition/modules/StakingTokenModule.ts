import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("StakingToken", (m) => {
  const token = m.contract("StakingToken");
  return { token };
});
